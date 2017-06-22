//
//  KSYGPUBgpStreamerKit.m
//  KSYStreamer
//
//  Created by 江东 on 17/4/21.
//  Copyright © 2017年 qyvideo. All rights reserved.
//
#import "KSYGPUBgpStreamerKit.h"

#define FLOAT_EQ( f0, f1 ) ( (f0 - f1 < 0.0001)&& (f0 - f1 > -0.0001) )

#define weakObj(o) __weak typeof(o) o##Weak = o;

@interface KSYGPUBgpStreamerKit (){
    dispatch_queue_t _capDev_q;
    NSLock   *       _quitLock;  // ensure capDev closed before dealloc
    CGFloat _previewRotateAng;
    int            _autoRetryCnt;
    BOOL           _bRetry;
    BOOL           _bInterrupt;
    KSYNetworkStatus _lastNetStatus;
    GPUImageFilter * _rotateFilter;
}
// vMixerTargets
@property (nonatomic, copy) NSArray *vPreviewTargets;
@end

@implementation KSYGPUBgpStreamerKit

/**
 @abstract   获取SDK版本号
 */
- (NSString*) getKSYVersion {
    if (_streamerBase){
        return [_streamerBase getKSYVersion];
    }
    return @"KSY-i-v0.0.0";
}

/**
 @abstract 初始化方法
 @discussion 创建带有默认参数的 kit，不会打断其他后台的音乐播放
 
 @warning kit只支持单实例推流，构造多个实例会出现异常
 */
- (instancetype) initWithDefaultCfg {
    return [self initInterrupt:NO];
}

/**
 @abstract 初始化方法
 @discussion 创建带有默认参数的 kit，会打断其他后台的音乐播放
 
 @warning kit只支持单实例推流，构造多个实例会出现异常
 */
- (instancetype) initWithInterruptCfg {
    return [self initInterrupt:YES];
}

- (instancetype) initInterrupt:(BOOL) bInter {
    self = [super init];
    
    _quitLock = [[NSLock alloc] init];
    _capDev_q = dispatch_queue_create( "com.ksyun.capDev_q", DISPATCH_QUEUE_SERIAL);
    // init default property
    _bInterrupt       = bInter;
    _captureState     = KSYCaptureStateIdle;
    _videoFPS         = 15;
    _previewDimension = CGSizeMake(640, 360);
    _streamDimension  = CGSizeMake(640, 360);
    _previewRotateAng = 0;
    _videoProcessingCallback = nil;
    _audioProcessingCallback = nil;
    _gpuOutputPixelFormat = kCVPixelFormatType_32BGRA;
    
    _autoRetryCnt    = 0;
    _maxAutoRetry    = 0;
    _autoRetryDelay  = 2.0;
    _bRetry          = NO;
    _bgPic           = nil;
    
    // 图层和音轨的初始化
    _cameraLayer  = 0;
    _micTrack = 0;
    
    /////1. 数据来源 ///////////
    // 音频采集模块
    _aCapDev = [[KSYAUAudioCapture alloc] init];
    
    /////2. 数据出口 ///////////
    // get pic data from gpu filter
    _gpuToStr =[[KSYGPUPicOutput alloc] init];
    _rotateFilter = [[GPUImageFilter alloc] init];
    // 创建 推流模块
    _streamerBase = [[KSYStreamerBase alloc] initWithDefaultCfg];
    // 创建 预览模块, 并放到视图底部
    _preview = [[KSYGPUView alloc] init];
    _preview.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    ///// 3. 数据处理和通路 ///////////
    ///// 3.1 视频通路 ///////////
    // 核心部件:图像处理滤镜
    _filter     = [[KSYGPUDnoiseFilter alloc] init];
    // 核心部件:视频叠加混合
    _vPreviewMixer = [[KSYGPUPicMixer alloc] init];
    _vStreamMixer = [[KSYGPUPicMixer alloc] init];
    // 组装视频通道
    [self setupVideoPath];
    
    ///// 3.2 音频通路 ///////////
    // 核心部件:音频叠加混合
    _aMixer = [[KSYAudioMixer alloc]init];
    
    // 组装音频通道
    [self setupAudioPath];
    // 设置 AudioSession的属性为直播需要的默认值, 具体如下:
    // bInterruptOtherAudio : NO  不打断其他播放器
    // bDefaultToSpeaker : YES    背景音乐从外放播放
    // bAllowBluetooth : YES      启用蓝牙
    // AVAudioSessionCategory : AVAudioSessionCategoryPlayAndRecord  允许录音
    [[AVAudioSession sharedInstance] setDefaultCfg];
    [AVAudioSession sharedInstance].bInterruptOtherAudio = bInter;
    
    //消息通道
    _msgStreamer = [[KSYMessage alloc] init];
    [self setupMessagePath];
    
    weakObj(self);
    _streamerBase.streamStateChange = ^(KSYStreamState state) {
        [selfWeak onStreamState:state];
    };
    _streamerBase.videoFPSChange = ^(int newVideoFPS){
        selfWeak.videoFPS = MAX(1, MIN(newVideoFPS, 30));
        selfWeak.streamerBase.videoFPS = selfWeak.videoFPS;
    };
    
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(appBecomeActive)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
    [dc addObserver:self
           selector:@selector(appEnterBackground)
               name:UIApplicationDidEnterBackgroundNotification
             object:nil];
    [dc addObserver:self
           selector:@selector(onNetEvent)
               name:KSYNetStateEventNotification
             object:nil];
    return self;
}
- (instancetype)init {
    return [self initWithDefaultCfg];
}
- (void)dealloc {
    [_quitLock lock];
    [self closeKit];
    _msgStreamer = nil;
    _streamerBase = nil;
    [_quitLock unlock];
    _quitLock = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/* reset all submodules */
- (void) closeKit{
    [_streamerBase stopStream];
    [_aCapDev      stopCapture];
    [_bgPic       removeAllTargets];
    [_filter      removeAllTargets];
    [_vPreviewMixer  removeAllTargets];
    [_vStreamMixer   removeAllTargets];
}

/**
 @abstract   设置当前使用的滤镜
 @discussion 若filter 为nil， 则关闭滤镜
 @discussion 若filter 为GPUImageFilter的实例，则使用该滤镜做处理
 @discussion filter 也可以是GPUImageFilterGroup的实例，可以将多个滤镜组合
 
 @see GPUImageFilter
 */
- (void) setupFilter:(GPUImageOutput<GPUImageInput> *) filter {
    _filter = filter;
    
    //采集的图像先经过前处理
    if (_bgPic  == nil) {
        return;
    }
    [_bgPic removeAllTargets];
    GPUImageOutput* src = _bgPic;
    if (_filter) {
        [_filter removeAllTargets];
        [src addTarget:_filter];
        src = _filter;
    }
    
    [_rotateFilter removeAllTargets];
    [src addTarget:_rotateFilter];
    [_rotateFilter setInputRotation:_bgPicRotate atIndex:0];
    [_rotateFilter forceProcessingAtSize:_previewDimension];
    src = _rotateFilter;
    // 组装图层
    _vPreviewMixer.masterLayer = _cameraLayer;
    _vStreamMixer.masterLayer = _cameraLayer;
    [self addPic:src       ToMixerAt:_cameraLayer];
}

- (void) setupVMixer {
    if (_vPreviewMixer.targets.count > 0 && _vPreviewTargets.count == 0) {
        _vPreviewTargets = [_vPreviewMixer.targets copy];
    }
    // 混合后的图像输出到预览和推流
    [_vPreviewMixer removeAllTargets];
    
    if (![_vPreviewTargets containsObject:_preview]) {
        [_vPreviewMixer addTarget:_preview];
    }else{
        for (id<GPUImageInput> target in _vPreviewTargets) {
            [_vPreviewMixer addTarget:target];
        }
    }
    _vPreviewTargets = nil;
    
    [_vStreamMixer  removeAllTargets];
    [_vStreamMixer  addTarget:_gpuToStr];
}

// 添加图层到 vMixer 中
- (void) addPic:(GPUImageOutput*)pic ToMixerAt: (NSInteger)idx{
    if (pic == nil){
        return;
    }
    [pic removeAllTargets];
    KSYGPUPicMixer * vMixer[2] = {_vPreviewMixer, _vStreamMixer};
    for (int i = 0; i<2; ++i) {
        [vMixer[i]  clearPicOfLayer:idx];
        [pic addTarget:vMixer[i] atTextureLocation:idx];
    }
}

// 组装视频通道
- (void) setupVideoPath {
    weakObj(self);
    // 前处理 和 图像 mixer
    [self setupFilter:_filter];
    [self setupVMixer];
    
    // GPU 上的数据导出到streamer
    _gpuToStr.videoProcessingCallback = ^(CVPixelBufferRef pixelBuffer, CMTime timeInfo){
        if(selfWeak.gpuToStr.bAutoRepeat == NO){
            selfWeak.gpuToStr.bAutoRepeat = YES;
        }
        if (![selfWeak.streamerBase isStreaming]){
            return;
        }
        [selfWeak.streamerBase processVideoPixelBuffer:pixelBuffer
                                              timeInfo:timeInfo];
    };
}

// 将声音送入混音器
- (void) mixAudio:(CMSampleBufferRef)buf to:(int)idx{
    if (![_streamerBase isStreaming]){
        return;
    }
    [_aMixer processAudioSampleBuffer:buf of:idx];
}
// 组装声音通道
- (void) setupAudioPath {
    weakObj(self);
    //音频采集, 语音数据送入混音器
    _aCapDev.audioProcessingCallback = ^(CMSampleBufferRef buf){
        if ( selfWeak.audioProcessingCallback ){
            selfWeak.audioProcessingCallback(buf);
        }
        [selfWeak mixAudio:buf to:selfWeak.micTrack];
    };
    // 混音结果送入streamer
    _aMixer.audioProcessingCallback = ^(CMSampleBufferRef buf){
        if (![selfWeak.streamerBase isStreaming]){
            return;
        }
        CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(buf);
        [selfWeak.streamerBase processAudioSampleBuffer:buf];
    };
    // mixer 的主通道为麦克风,时间戳以main通道为准
    _aMixer.mainTrack = _micTrack;
    [_aMixer setTrack:_micTrack enable:YES];
}

#pragma mark - message
- (void) setupMessagePath {
    weakObj(self);
    _msgStreamer.messageProcessingCallback = ^(NSDictionary *messageData){
        [selfWeak.streamerBase processMessageData:messageData];
    };
}

- (BOOL)  processMessageData:(NSDictionary *)messageData{
    if(_msgStreamer)
        return [_msgStreamer processMessageData:messageData];
    return NO;
}

#pragma mark - 状态通知
- (void) newCaptureState:(KSYCaptureState) state {
    dispatch_async(dispatch_get_main_queue(), ^{
        _captureState = state;
        NSNotificationCenter* dc =[NSNotificationCenter defaultCenter];
        [dc postNotificationName:KSYCaptureStateDidChangeNotification
                          object:self];
    });
}

#define CASE_RETURN( ENU ) case ENU : {return @#ENU;}
/**
 @abstract   获取采集状态对应的字符串
 */
- (NSString*) getCaptureStateName: (KSYCaptureState) stat{
    switch (stat){
            CASE_RETURN(KSYCaptureStateIdle)
            CASE_RETURN(KSYCaptureStateCapturing)
            CASE_RETURN(KSYCaptureStateDevAuthDenied)
            CASE_RETURN(KSYCaptureStateClosingCapture)
            CASE_RETURN(KSYCaptureStateParameterError)
            CASE_RETURN(KSYCaptureStateDevBusy)
        default: {    return @"unknow"; }
    }
}

- (NSString*) getCurCaptureStateName {
    return [self getCaptureStateName:_captureState];
}

#pragma mark - capture actions
/**
 @abstract 启动预览
 @param view 预览画面作为subview，插入到 view 的最底层
 @discussion 设置完成采集参数之后，按照设置值启动预览，启动后对采集参数修改不会生效
 @discussion 需要访问摄像头和麦克风的权限，若授权失败，其他API都会拒绝服务
 
 @warning: 开始推流前必须先启动预览
 @see videoDimension, cameraPosition, videoOrientation, videoFPS
 */
- (void) startPreview: (UIView*) view {
    if (_capDev_q == nil || view == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(){
        [view addSubview:_preview];
        [view sendSubviewToBack:_preview];
        _preview.frame = view.bounds;
        if ([self startVideoCap] == NO){
            return;
        }
        if ([self startAudioCap] == NO){
            return;
        }
    });
}

/**
 @abstract 开启视频配置和采集
 @discussion 设置完成视频采集参数之后，按照设置值启动视频预览，启动后对视频采集参数修改不会生效
 @discussion 需要访问摄像头的权限，若授权失败，其他API都会拒绝服务
 @discussion 视频采集成功返回YES，不成功返回NO
 */
- (BOOL) startVideoCap{
    dispatch_async(_capDev_q, ^{
        [_quitLock lock];
        [self  updateStrDimension];
        // 连接
        [self setupFilter:_filter];
        [self setupVMixer];
        // 开始预览
        [_bgPic processImage];
        [_quitLock unlock];
        [self newCaptureState:KSYCaptureStateCapturing];
    });
    return YES;
}

/**
 @abstract 开始音频配置和采集
 @discussion 设置完成音频采集参数之后，按照设置值启动音频预览，启动后对音频采集参数修改不会生效
 @discussion 需要访问麦克风的权限，若授权失败，其他API都会拒绝服务
 @discussion 音频采集成功返回YES，不成功返回NO
 */
- (BOOL) startAudioCap{
    AVAuthorizationStatus status_audio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if ( status_audio == AVAuthorizationStatusDenied) {
        [self newCaptureState:KSYCaptureStateDevAuthDenied];
        return NO;
    }
    dispatch_async(_capDev_q, ^{
        [_quitLock lock];
        //配置audioSession的方法由init移入startPreview，防止在init之后，startPreview之前被外部修改
        [AVAudioSession sharedInstance].bInterruptOtherAudio = _bInterrupt;
        [_aCapDev startCapture];
        [_quitLock unlock];
        [self newCaptureState:KSYCaptureStateCapturing];
    });
    return YES;
}
/**
 @abstract   停止预览，停止采集设备，并清理会话（step5）
 @discussion 若推流未结束，则先停止推流
 
 @see stopStream
 */
- (void) stopPreview {
    if (_bgPic== nil ) {
        return;
    }
    [self newCaptureState:KSYCaptureStateClosingCapture];
    dispatch_async(_capDev_q, ^{
        [_quitLock lock];
        [self closeKit];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_preview){
                [_preview removeFromSuperview];
            }
        });
        [_quitLock unlock];
        [self newCaptureState:KSYCaptureStateIdle];
    });
}

/**  进入后台 */
- (void) appEnterBackground {
    if (_vPreviewMixer.targets.count > 0){
        _vPreviewTargets = [_vPreviewMixer.targets copy];
    }
    // 进入后台时, 将预览从图像混合器中脱离, 避免后台OpenGL渲染崩溃
    [_vPreviewMixer removeAllTargets];
    if (_streamerBase.bypassRecordState == KSYRecordStateRecording ) {
        [_streamerBase stopBypassRecord];
    }
}

/** 回到前台 */
- (void) appBecomeActive{
    // 回到前台, 重新连接预览
    [self setupVMixer];
    [_aCapDev  resumeCapture];
}
#pragma mark - try reconnect
- (void) onStreamState : (KSYStreamState) stat {
    if (stat == KSYStreamStateError){
        [self onStreamError:_streamerBase.streamErrorCode];
    }
    else if (stat == KSYStreamStateConnected){
        _autoRetryCnt = _maxAutoRetry;
        _bRetry = NO;
    }
}
- (void) onStreamError: (KSYStreamErrorCode) errCode {
    NSString * name = [_streamerBase getCurKSYStreamErrorCodeName];
    NSLog(@"stream Error: %@", [name substringFromIndex:19]);
    if (errCode == KSYStreamErrorCode_CONNECT_BREAK ||
        errCode == KSYStreamErrorCode_AV_SYNC_ERROR ||
        errCode == KSYStreamErrorCode_Connect_Server_failed ||
        errCode == KSYStreamErrorCode_DNS_Parse_failed ||
        errCode == KSYStreamErrorCode_CODEC_OPEN_FAILED) {
        if (_bRetry == NO){
            [self tryReconnect];
        }
    }
}
- (void) onNetEvent {
    KSYNetStateCode code = [_streamerBase netStateCode];
    if (code == KSYNetStateCode_REACHABLE) {
        if ( _streamerBase.streamState == KSYStreamStateError) {
            [self tryReconnect];
        }
        KSYNetworkStatus curStat = _streamerBase.netReachability.currentReachabilityStatus;
        if (_lastNetStatus == KSYReachableViaWWAN &&
            curStat == KSYReachableViaWiFi) { // 4G to wifi
            NSLog(@"warning: 4Gtowifi: still using 4G!");
        }
        _lastNetStatus = curStat;
    }
    else if (code == KSYNetStateCode_UNREACHABLE) {
        _lastNetStatus = _streamerBase.netReachability.currentReachabilityStatus;
    }
}
- (void) tryReconnect {
    _bRetry = YES;
    int64_t delaySec = (int64_t)(_autoRetryDelay * NSEC_PER_SEC);
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delaySec);
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        _bRetry = NO;
        if (_autoRetryCnt <= 0 || _streamerBase.netReachState == KSYNetReachState_Bad) {
            return;
        }
        if (!_streamerBase.isStreaming) {
            NSLog(@"retry connect %d/%d", _autoRetryCnt, _maxAutoRetry);
            _autoRetryCnt--;
            [_streamerBase startStream:_streamerBase.hostURL];
        }
    });
}
@synthesize autoRetryDelay = _autoRetryDelay;
-(void) setAutoRetryDelay:(double)autoRetryDelay {
    _autoRetryDelay = MAX(0.1, autoRetryDelay);
}
@synthesize maxAutoRetry = _maxAutoRetry;
-(void) setMaxAutoRetry:(int)maxAutoRetry {
    _maxAutoRetry = MAX(0, maxAutoRetry);
    _autoRetryCnt = _maxAutoRetry;
}

#pragma mark - Dimension
// 居中裁剪
-(CGRect) calcCropRect: (CGSize) camSz to: (CGSize) outSz {
    double x = (camSz.width  -outSz.width )/2/camSz.width;
    double y = (camSz.height -outSz.height)/2/camSz.height;
    double wdt = outSz.width/camSz.width;
    double hgt = outSz.height/camSz.height;
    return CGRectMake(x, y, wdt, hgt);
}
// 对 inSize 按照 targetSz的宽高比 进行裁剪, 得到最大的输出size
-(CGSize) calcCropSize: (CGSize) inSz to: (CGSize) targetSz {
    CGFloat preRatio = targetSz.width / targetSz.height;
    CGSize cropSz = inSz; // set width
    cropSz.height = cropSz.width / preRatio;
    if (cropSz.height > inSz.height){
        cropSz.height = inSz.height; // set height
        cropSz.width  = cropSz.height * preRatio;
    }
    return cropSz;
}

- (void) updateStrDimension {
    _gpuToStr.bCustomOutputSize = YES;
    _gpuToStr.outputSize = _streamDimension;
    CGSize preSz = _previewDimension;
    CGSize cropSz = [self calcCropSize:preSz
                                    to:_streamDimension];
    _gpuToStr.cropRegion = [self calcCropRect:preSz
                                           to:cropSz];
}

// 分辨率有效范围检查
@synthesize previewDimension = _previewDimension;
- (void) setPreviewDimension:(CGSize) sz{
    _previewDimension = sz;
}
@synthesize streamDimension = _streamDimension;
- (void) setStreamDimension:(CGSize) sz{
    _streamDimension = sz;
}
@synthesize videoFPS = _videoFPS;
- (void) setVideoFPS: (int) fps {
    if(_captureState  ==  KSYCaptureStateIdle)
    {
        _videoFPS = MAX(1, MIN(fps, 30));
        _streamerBase.videoFPS = _videoFPS;
    }
}

/// 设置gpu输出的图像像素格式
@synthesize gpuOutputPixelFormat = _gpuOutputPixelFormat;
- (void)setGpuOutputPixelFormat: (OSType) fmt {
    if( fmt !=  kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange ||
       fmt !=  kCVPixelFormatType_420YpCbCr8Planar ){
        fmt = kCVPixelFormatType_32BGRA;
    }
    _gpuOutputPixelFormat = fmt;
    _gpuToStr =[[KSYGPUPicOutput alloc] initWithOutFmt:_gpuOutputPixelFormat];
    [self setupVideoPath];
}
+ (GPUImageRotationMode) getRotationMode:(UIImage*) img {
    switch (img.imageOrientation) {
        case UIImageOrientationUp:
            return kGPUImageNoRotation;
        case UIImageOrientationDown:
            return kGPUImageRotate180;
        case UIImageOrientationLeft:
            return kGPUImageRotateLeft;
        case UIImageOrientationRight:
            return kGPUImageRotateRight;
        default:
            return kGPUImageNoRotation;
    }
}
@end

