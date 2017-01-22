//
//  KSYGPUStreamerKit.m
//  KSYStreamer
//
//  Created by pengbin on 09/01/16.
//  Copyright © 2016 ksyun. All rights reserved.
//
#import "KSYGPUStreamerKit.h"

#define FLOAT_EQ( f0, f1 ) ( (f0 - f1 < 0.0001)&& (f0 - f1 > -0.0001) )

#define WeakObj(o) try{}@finally{} __weak typeof(o) o##Weak = o;

@interface KSYGPUStreamerKit (){
    dispatch_queue_t _capDev_q;
    NSLock   *       _quitLock;  // ensure capDev closed before dealloc
    CGFloat _previewRotateAng;
    int            _autoRetryCnt;
    BOOL           _bRetry;
}
@end

@implementation KSYGPUStreamerKit

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
    _captureState     = KSYCaptureStateIdle;
    _capPreset        = AVCaptureSessionPreset640x480;
    _videoFPS         = 15;
    _previewDimension = CGSizeMake(640, 360);
    _streamDimension  = CGSizeMake(640, 360);
    _cameraPosition   = AVCaptureDevicePositionFront;
    _streamerMirrored = NO;
    _previewMirrored  = NO;
    _previewRotateAng = 0;
    _videoProcessingCallback = nil;
    _audioProcessingCallback = nil;
    _interruptCallback       = nil;
    _gpuOutputPixelFormat = kCVPixelFormatType_32BGRA;
    _capturePixelFormat   = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
    
    _autoRetryCnt    = 0;
    _maxAutoRetry    = 0;
    _autoRetryDelay  = 2.0;
    _bRetry          = NO;
    
    // 图层和音轨的初始化
    _cameraLayer  = 2;
    _logoPicLayer = 3;
    _logoTxtLayer = 4;
    _micTrack = 0;
    _bgmTrack = 1;

    /////1. 数据来源 ///////////
    _capToGpu = [[KSYGPUPicInput alloc] init];
    // 采集模块
    _vCapDev = [[KSYAVFCapture alloc] initWithSessionPreset:_capPreset
                                             cameraPosition:_cameraPosition];
    if(_vCapDev == nil) {
        return nil;
    }
    
    _vCapDev.outputImageOrientation =
    _previewOrientation =
    _videoOrientation   =
    _streamOrientation  = UIInterfaceOrientationPortrait;
    //Session模块
    _avAudioSession = [[KSYAVAudioSession alloc] init];
    _avAudioSession.bInterruptOtherAudio = bInter;
    [_avAudioSession setAVAudioSessionOption];

    // 创建背景音乐播放模块
    _bgmPlayer = [[KSYBgmPlayer   alloc] init];
    // 音频采集模块
    _aCapDev = [[KSYAUAudioCapture alloc] init];
    // 各种图片
    _logoPic = nil;
    _textPic = nil;
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 360, 640)];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.font = [UIFont fontWithName:@"Courier" size:20.0];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.alpha = 1.0;
    
    /////2. 数据出口 ///////////
    // get pic data from gpu filter
    _gpuToStr =[[KSYGPUPicOutput alloc] init];
    // 创建 推流模块
    _streamerBase = [[KSYStreamerBase alloc] initWithDefaultCfg];
    // 创建 预览模块, 并放到视图底部
    _preview = [[GPUImageView alloc] init];
    
    ///// 3. 数据处理和通路 ///////////
    ///// 3.1 视频通路 ///////////
    // 核心部件:图像处理滤镜
    _filter     = [[KSYGPUDnoiseFilter alloc] init];
    // 核心部件:视频叠加混合
    _vPreviewMixer = [[KSYGPUPicMixer alloc] init];
    _vStreamMixer = [[KSYGPUPicMixer alloc] init];
    // 组装视频通道
    [self setupVideoPath];
    // 初始化图层的位置
    self.logoRect = CGRectMake(0.1 , 0.05, 0, 0.1);
    self.textRect = CGRectMake(0.05, 0.15, 0, 20.0/640);
    
    ///// 3.2 音频通路 ///////////
    // 核心部件:音频叠加混合
    _aMixer = [[KSYAudioMixer alloc]init];

    // 组装音频通道
    [self setupAudioPath];
    @WeakObj(self);
    _streamerBase.streamStateChange = ^(KSYStreamState state) {
        [selfWeak onStreamState:state];
    };
    return self;
}
- (instancetype)init {
    return [self initWithDefaultCfg];
}
- (void)dealloc {
    [_quitLock lock];
    [self closeKit];
    _bgmPlayer = nil;
    _streamerBase = nil;
    _vCapDev = nil;
    [_quitLock unlock];
    _quitLock = nil;
}

/* reset all submodules */
- (void) closeKit{
    [_bgmPlayer    stopPlayBgm];
    [_streamerBase stopStream];
    [_aCapDev      stopCapture];
    [_vCapDev      stopCameraCapture];
    
    [_capToGpu    removeAllTargets];
    [_filter      removeAllTargets];
    [_logoPic     removeAllTargets];
    [_textPic     removeAllTargets];
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
    if (_vCapDev  == nil) {
        return;
    }
    // 采集的图像先经过前处理
    [_capToGpu removeAllTargets];
    GPUImageOutput* src = _capToGpu;
    if (_filter) {
        [_filter removeAllTargets];
        [src addTarget:_filter];
        src = _filter;
    }
    // 组装图层
    _vPreviewMixer.masterLayer = _cameraLayer;
    _vStreamMixer.masterLayer = _cameraLayer;
    [self addPic:src       ToMixerAt:_cameraLayer];
    [self addPic:_logoPic  ToMixerAt:_logoPicLayer];
    [self addPic:_textPic  ToMixerAt:_logoTxtLayer];
}

- (void) setupVMixer {
    // 混合后的图像输出到预览和推流
    [_vPreviewMixer removeAllTargets];
    [_vPreviewMixer addTarget:_preview];
    
    [_vStreamMixer  removeAllTargets];
    [_vStreamMixer  addTarget:_gpuToStr];
    // 设置镜像
    [self setPreviewOrientation:_previewOrientation];
    [self setStreamOrientation:_streamOrientation];
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
    __weak KSYGPUStreamerKit * kit = self;
    // 前处理 和 图像 mixer
    [self setupFilter:_filter];
    [self setupVMixer];
    // 采集到的画面上传GPU
    _vCapDev.videoProcessingCallback = ^(CMSampleBufferRef buf) {
        if ( kit.videoProcessingCallback ){
            kit.videoProcessingCallback(buf);
        }
        [kit.capToGpu processSampleBuffer:buf];
    };
    // GPU 上的数据导出到streamer
    _gpuToStr.videoProcessingCallback = ^(CVPixelBufferRef pixelBuffer, CMTime timeInfo){
        if (![kit.streamerBase isStreaming]){
            return;
        }
        [kit.streamerBase processVideoPixelBuffer:pixelBuffer
                                         timeInfo:timeInfo];
    };
    // 采集被打断的事件回调
    _vCapDev.interruptCallback = ^(BOOL bInterrupt) {
        if (bInterrupt) {
            [kit appEnterBackground];
        }
        else {
            [kit appBecomeActive];
        }
        if(kit.interruptCallback) {
            kit.interruptCallback(bInterrupt);
        }
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
    __weak KSYGPUStreamerKit * kit = self;
    //1. 音频采集, 语音数据送入混音器
    _aCapDev.audioProcessingCallback = ^(CMSampleBufferRef buf){
        if ( kit.audioProcessingCallback ){
            kit.audioProcessingCallback(buf);
        }
        [kit mixAudio:buf to:kit.micTrack];
    };
    //2. 背景音乐播放,音乐数据送入混音器
    _bgmPlayer.audioDataBlock = ^(CMSampleBufferRef buf){
        [kit mixAudio:buf to:kit.bgmTrack];
    };
    // 混音结果送入streamer
    _aMixer.audioProcessingCallback = ^(CMSampleBufferRef buf){
        if (![kit.streamerBase isStreaming]){
            return;
        }
        [kit.streamerBase processAudioSampleBuffer:buf];
    };
    // mixer 的主通道为麦克风,时间戳以main通道为准
    _aMixer.mainTrack = _micTrack;
    [_aMixer setTrack:_micTrack enable:YES];
    [_aMixer setTrack:_bgmTrack enable:YES];
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
    if (_capDev_q == nil || view == nil || [_vCapDev isRunning]) {
        return;
    }
    AVAuthorizationStatus status_audio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    AVAuthorizationStatus status_video = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ( status_audio == AVAuthorizationStatusDenied ||
         status_video == AVAuthorizationStatusDenied ) {
        [self newCaptureState:KSYCaptureStateDevAuthDenied];
        return;
    }
    dispatch_async(_capDev_q, ^{
        dispatch_async(dispatch_get_main_queue(), ^(){
            [view addSubview:_preview];
            [view sendSubviewToBack:_preview];
            _preview.frame = view.bounds;
        });
        if (_capPreset == nil) {
            [self newCaptureState:KSYCaptureStateParameterError];
            return;
        }
        [_quitLock lock];
        if ( _cameraPosition != [_vCapDev cameraPosition] ){
            [_vCapDev rotateCamera];
        }
        _vCapDev.captureSessionPreset = _capPreset;
        _vCapDev.frameRate = _videoFPS;
        // check if preset ok
        _capPreset = _vCapDev.captureSessionPreset;
        [self  updatePreDimension];
        [self  updateStrDimension:self.videoOrientation];
        // 旋转
        [self rotatePreviewTo:_videoOrientation ];
        [self rotateStreamTo: _videoOrientation ];
        // 连接
        [self setupFilter:_filter];
        [self setupVMixer];
        // 开始预览
        [_vCapDev startCameraCapture];
        [_aCapDev startCapture];
        [_quitLock unlock];
        [self newCaptureState:KSYCaptureStateCapturing];
    });
}

/**
 @abstract   停止预览，停止采集设备，并清理会话（step5）
 @discussion 若推流未结束，则先停止推流
 
 @see stopStream
 */
- (void) stopPreview {
    if (_vCapDev== nil ) {
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
    // 进入后台时, 将预览从图像混合器中脱离, 避免后台OpenGL渲染崩溃
    [_vPreviewMixer removeAllTargets];
    // 重复最后一帧视频图像
    _gpuToStr.bAutoRepeat = YES;
}

/** 回到前台 */
- (void) appBecomeActive{
    // 回到前台, 重新连接预览
    [self setupVMixer];
    [_aCapDev  resumeCapture];
    _gpuToStr.bAutoRepeat = NO;
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
- (void) tryReconnect {
    _bRetry = YES;
    int64_t delaySec = (int64_t)(_autoRetryDelay * NSEC_PER_SEC);
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delaySec);
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        if (_autoRetryCnt <= 0) {
            _bRetry = NO; // reach max retry, stop
            return;
        }
        NSLog(@"retry connect %d/%d", _autoRetryCnt, _maxAutoRetry);
        _autoRetryCnt--;
        [_streamerBase startStream:_streamerBase.hostURL];
        [self tryReconnect];// schedule next retry
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
/**
 @abstract   查询实际的采集分辨率
 @discussion 参见iOS的 AVCaptureSessionPresetXXX的定义
 */
- (CGSize) captureDimension {
    if (_vCapDev){
        return _vCapDev.captureDimension;
    }
    return CGSizeZero;
}

// 根据朝向, 判断是否需要交换宽和高
-(CGSize) getDimension: (CGSize) sz
           byOriention: (UIInterfaceOrientation) ori {
    CGSize outSz = sz;
    if ( ( ori == UIInterfaceOrientationPortraitUpsideDown ||
           ori == UIInterfaceOrientationPortrait )) {
        outSz.height = MAX(sz.width, sz.height);
        outSz.width  = MIN(sz.width, sz.height);
    }
    else  {
        outSz.height = MIN(sz.width, sz.height);
        outSz.width  = MAX(sz.width, sz.height);
    }
    return outSz;
}
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

// 更新分辨率相关设置
// 根据宽高比计算需要裁剪掉的区域
- (void) updatePreDimension {
    _previewDimension = [self getDimension:_previewDimension
                               byOriention:self.videoOrientation];
    CGSize  inSz     =  [self captureDimension];
    inSz = [self getDimension:inSz byOriention:self.videoOrientation];
    CGSize cropSz = [self calcCropSize:inSz to:_previewDimension];
    _capToGpu.cropRegion = [self calcCropRect:inSz to:cropSz];
    [_capToGpu forceProcessingAtSize:_previewDimension];
}
- (void) updateStrDimension:(UIInterfaceOrientation) orie {
    _streamDimension  = [self getDimension:_streamDimension
                               byOriention:orie];
    _gpuToStr.bCustomOutputSize = YES;
    _gpuToStr.outputSize = _streamDimension;
    CGSize preSz = [self getDimension:_previewDimension
                          byOriention:orie];
    CGSize cropSz = [self calcCropSize:preSz
                                    to:_streamDimension];
    _gpuToStr.cropRegion = [self calcCropRect:preSz
                                           to:cropSz];
}

// 分辨率有效范围检查
@synthesize previewDimension = _previewDimension;
- (void) setPreviewDimension:(CGSize) sz{
    _previewDimension.width  = MAX(sz.width, sz.height);
    _previewDimension.height = MIN(sz.width, sz.height);
    _previewDimension.width  = MAX(160, MIN(_previewDimension.width, 1920));
    _previewDimension.height = MAX( 90, MIN(_previewDimension.height,1080));
}
@synthesize streamDimension = _streamDimension;
- (void) setStreamDimension:(CGSize) sz{
    _streamDimension.width  = MAX(sz.width, sz.height);
    _streamDimension.height = MIN(sz.width, sz.height);
    _streamDimension.width  = MAX(160, MIN(_streamDimension.width, 1280));
    _streamDimension.height = MAX( 90, MIN(_streamDimension.height, 720));
}
@synthesize videoFPS = _videoFPS;
- (void) setVideoFPS: (int) fps {
    _videoFPS = MAX(1, MIN(fps, 30));
}

@synthesize videoOrientation = _videoOrientation;
- (void) setVideoOrientation: (UIInterfaceOrientation) orie {
    if (_vCapDev.isRunning){
        return;
    }
    _vCapDev.outputImageOrientation =
    _previewOrientation =
    _streamOrientation  =
    _videoOrientation   = orie;
}
- (UIInterfaceOrientation) videoOrientation{
    return _vCapDev.outputImageOrientation;
}

/**
 @abstract   切换摄像头
 @return     TRUE: 成功切换摄像头， FALSE：当前参数，下一个摄像头不支持，切换失败
 @discussion 在前后摄像头间切换，从当前的摄像头切换到另一个，切换成功则修改cameraPosition的值
 @discussion 开始预览后开始有效，推流过程中也响应切换请求
 
 @see cameraPosition
 */
- (BOOL) switchCamera{
    if (_vCapDev == nil) {
        return NO;
    }
    _cameraPosition = _vCapDev.cameraPosition;
    [_vCapDev rotateCamera];
    if (_cameraPosition == _vCapDev.cameraPosition) {
        return  NO;
    }
    _cameraPosition = _vCapDev.cameraPosition;
    return YES;
}

/**
 @abstract   当前采集设备是否支持闪光灯
 @return     YES / NO
 @discussion 通常只有后置摄像头支持闪光灯
 
 @see setTorchMode
 */
- (BOOL) isTorchSupported{
    if (_vCapDev){
        return _vCapDev.isTorchSupported;
    }
    return NO;
}

/**
 @abstract   开关闪光灯
 @discussion 切换闪光灯的开关状态 开 <--> 关
 
 @see setTorchMode
 */
- (void) toggleTorch {
    if (_vCapDev){
        [_vCapDev toggleTorch];
    }
}

/**
 @abstract   设置闪光灯
 @param      mode  AVCaptureTorchModeOn/Off
 @discussion 设置闪光灯的开关状态
 @discussion 开始预览后开始有效
 
 @see AVCaptureTorchMode
 */
- (void) setTorchMode: (AVCaptureTorchMode)mode{
    if (_vCapDev){
        [_vCapDev setTorchMode:mode];
    }
}

/**
 @abstract   获取当前采集设备的指针
 
 @discussion 开放本指针的目的是开放类似下列添加到AVCaptureDevice的 categories：
 - AVCaptureDeviceFlash
 - AVCaptureDeviceTorch
 - AVCaptureDeviceFocus
 - AVCaptureDeviceExposure
 - AVCaptureDeviceWhiteBalance
 - etc.
 
 @return AVCaptureDevice* 预览开始前调用返回为nil，开始预览后，返回当前正在使用的摄像头
 
 @warning  请勿修改摄像头的像素格式，帧率，分辨率等参数，修改后会导致推流工作异常或崩溃
 @see AVCaptureDevice  AVCaptureDeviceTorch AVCaptureDeviceFocus
 */
- (AVCaptureDevice*) getCurrentCameraDevices {
    if (_vCapDev){
        return _vCapDev.inputCamera;
    }
    return nil;
}
#pragma mark - utils
-(UIImage *)imageFromUIView:(UIView *)v {
    CGSize s = v.frame.size;
    UIGraphicsBeginImageContextWithOptions(s, NO, 0.0);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
#pragma mark - pictures & logo
@synthesize logoPic = _logoPic;
-(void) setLogoPic:(GPUImagePicture *)pic{
    _logoPic = pic;
    [self addPic:_logoPic ToMixerAt:_logoPicLayer];
}
// 水印logo的图片的位置和大小
@synthesize logoRect = _logoRect;
- (CGRect) logoRect {
    return [_vPreviewMixer getPicRectOfLayer:_logoPicLayer];
}
- (void) setLogoRect:(CGRect)logoRect{
    [_vPreviewMixer setPicRect:logoRect
                       ofLayer:_logoPicLayer];
    [_vStreamMixer setPicRect:logoRect
                      ofLayer:_logoPicLayer];
}
// 水印logo的图片的透明度
@synthesize logoAlpha = _logoAlpha;
- (CGFloat)logoAlpha{
    return [_vPreviewMixer getPicAlphaOfLayer:_logoPicLayer];
}
- (void)setLogoAlpha:(CGFloat)alpha{
    [_vPreviewMixer setPicAlpha:alpha ofLayer:_logoPicLayer];
    [_vStreamMixer setPicAlpha:alpha ofLayer:_logoPicLayer];
}
// 水印文字的位置
@synthesize textRect = _textRect;
- (CGRect) textRect {
    return [_vPreviewMixer getPicRectOfLayer:_logoTxtLayer];
}
- (void) setTextRect:(CGRect)rect{
    [_vPreviewMixer setPicRect:rect
                       ofLayer:_logoTxtLayer];
    [_vStreamMixer setPicRect:rect
                      ofLayer:_logoTxtLayer];
}
/**
 @abstract   刷新水印文字的内容
 @discussion 先修改文字的内容或格式,调用该方法后生效
 @see textLable
 */
- (void) updateTextLabel{
    if ( [_textLabel.text length] <= 0 ){
        _textPic = nil;
        [_vPreviewMixer  clearPicOfLayer:_logoPicLayer];
        [_vStreamMixer  clearPicOfLayer:_logoPicLayer];
        return;
    }
    [_textLabel sizeToFit];
    UIImage * img = [self imageFromUIView:_textLabel];
    _textPic = [[GPUImagePicture alloc] initWithImage:img];
    [self addPic:_textPic ToMixerAt:_logoTxtLayer];
    [_textPic processImage];
}
@synthesize capturePixelFormat = _capturePixelFormat;
- (void)setCapturePixelFormat: (OSType) fmt {
    if (_vCapDev.isRunning){
        return;
    }
    if(fmt != kCVPixelFormatType_32BGRA ){
        fmt = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
    }
    _capturePixelFormat = fmt;
    _vCapDev.outputPixelFmt = fmt;
    _capToGpu =[[KSYGPUPicInput alloc] initWithFmt:fmt];
    [self setupVideoPath];
    [self updatePreDimension];
}
/// 设置gpu输出的图像像素格式
@synthesize gpuOutputPixelFormat = _gpuOutputPixelFormat;
- (void)setGpuOutputPixelFormat: (OSType) fmt {
    if ([_streamerBase isStreaming]){
        return;
    }
    if( fmt !=  kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange ||
        fmt !=  kCVPixelFormatType_420YpCbCr8Planar ){
        fmt = kCVPixelFormatType_32BGRA;
    }
    _gpuOutputPixelFormat = fmt;
    _gpuToStr =[[KSYGPUPicOutput alloc] initWithOutFmt:_gpuOutputPixelFormat];
    [self setupVideoPath];
    [self updateStrDimension:self.videoOrientation];
}

#pragma mark - rotate & mirror

- (void) setPreviewMirrored:(BOOL)bMirrored {
    if(_vPreviewMixer){
        GPUImageRotationMode ro = kGPUImageNoRotation;
        if (bMirrored) {
            if (FLOAT_EQ(_previewRotateAng, M_PI_2*1) ||
                FLOAT_EQ(_previewRotateAng, M_PI_2*3)) {
                ro = kGPUImageFlipVertical;
            }
            else {
                ro = kGPUImageFlipHorizonal;
            }
        }
        [_vPreviewMixer setPicRotation:ro ofLayer:_cameraLayer];
    }
    _previewMirrored = bMirrored;
    return ;
}

- (void) setStreamerMirrored:(BOOL)bMirrored {
    if (_vStreamMixer){
        GPUImageRotationMode ro = kGPUImageNoRotation;
        if( bMirrored ) {
            GPUImageRotationMode inRo = [_gpuToStr getInputRotation];
            if (inRo == kGPUImageRotateLeft ||
                inRo == kGPUImageRotateRight ) {
                ro = kGPUImageFlipVertical;
            }
            else {
                ro = kGPUImageFlipHorizonal;
            }
        }
        [_vStreamMixer setPicRotation:ro ofLayer:_cameraLayer];
    }
    _streamerMirrored = bMirrored;
}

int UIOrienToIdx (UIInterfaceOrientation orien) {
    switch (orien) {
        case UIInterfaceOrientationPortrait:
            return 0;
        case UIInterfaceOrientationPortraitUpsideDown:
            return 1;
        case UIInterfaceOrientationLandscapeLeft:
            return 2;
        case UIInterfaceOrientationLandscapeRight:
            return 3;
        case UIInterfaceOrientationUnknown:
        default:
            return 0;
    }
    
}
const static CGFloat KSYRotateAngles [4] [4] = {
M_PI_2*0,M_PI_2*2, M_PI_2*1, M_PI_2*3,
M_PI_2*2,M_PI_2*0, M_PI_2*3, M_PI_2*1,
M_PI_2*3,M_PI_2*1, M_PI_2*0, M_PI_2*2,
M_PI_2*1,M_PI_2*3, M_PI_2*2, M_PI_2*0,
};

- (void) setPreviewOrientation:(UIInterfaceOrientation)previewOrientation {
    [self rotatePreviewTo:previewOrientation];
}
/**
 @abstract 根据UI的朝向旋转预览视图, 保证预览视图全屏铺满窗口
 @discussion 采集到的图像的朝向还是和启动时的朝向一致
 */
- (void) rotatePreviewTo: (UIInterfaceOrientation) orie {
    dispatch_async(dispatch_get_main_queue(), ^(){
        _previewOrientation = orie;
        UIView* view = [_preview superview];
        if (_videoOrientation == orie || view == nil || _vCapDev.isRunning == NO ) {
            _preview.transform = CGAffineTransformIdentity;
            _previewRotateAng = 0;
            _preview.frame = view.bounds;
        }
        else {
            int capOri = UIOrienToIdx(_videoOrientation);
            int appOri = UIOrienToIdx(orie);
            _previewRotateAng = KSYRotateAngles[ capOri ][ appOri ];
            _preview.transform = CGAffineTransformMakeRotation(_previewRotateAng);
        }
        _preview.center = view.center;
        [self setPreviewMirrored: _previewMirrored];
    });
}

const static GPUImageRotationMode KSYRotateMode [4] [4] = {
 kGPUImageNoRotation,  kGPUImageRotate180,kGPUImageRotateRight,  kGPUImageRotateLeft,
  kGPUImageRotate180, kGPUImageNoRotation, kGPUImageRotateLeft, kGPUImageRotateRight,
 kGPUImageRotateLeft,kGPUImageRotateRight, kGPUImageNoRotation,   kGPUImageRotate180,
kGPUImageRotateRight, kGPUImageRotateLeft,  kGPUImageRotate180,  kGPUImageNoRotation,
};
-(void) setStreamOrientation:(UIInterfaceOrientation)streamOrientation {
    [self rotateStreamTo:streamOrientation];
}
/**
 @abstract 根据UI的朝向旋转推流画面
 */
- (void) rotateStreamTo: (UIInterfaceOrientation) orie {
    _streamOrientation = orie;
    if (_videoOrientation == orie || _vCapDev.isRunning == NO) {
        [_gpuToStr setInputRotation:kGPUImageNoRotation atIndex:0];
    }
    else {
        int capOri = UIOrienToIdx(_videoOrientation);
        int appOri = UIOrienToIdx(orie);
        GPUImageRotationMode mode = KSYRotateMode[capOri][appOri];
        [_gpuToStr setInputRotation: mode  atIndex:0];
    }
    [self updateStrDimension:orie];
    [self setStreamerMirrored: _streamerMirrored];
}

/**
 @abstract 摄像头自动曝光
 */
- (BOOL)exposureAtPoint:(CGPoint )point{
    AVCaptureDevice *dev = _vCapDev.inputCamera;
    NSError *error;
    
    if ([dev isExposurePointOfInterestSupported] && [dev isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        if ([dev lockForConfiguration:&error]) {
            [dev setExposurePointOfInterest:point];  // 曝光点
            [dev setExposureMode:AVCaptureExposureModeAutoExpose];
            [dev unlockForConfiguration];
            return YES;
        }
    }
    return NO;
}

/**
 @abstract 摄像头自动变焦
 */
- (BOOL)focusAtPoint:(CGPoint )point{
    AVCaptureDevice *dev = _vCapDev.inputCamera;
    NSError *error;

    if ([dev isFocusPointOfInterestSupported] && [dev isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        if ([dev lockForConfiguration:&error]) {
            [dev setFocusPointOfInterest:point];
            [dev setFocusMode:AVCaptureFocusModeAutoFocus];
            [dev unlockForConfiguration];
            return YES;
        }
    }
    return NO;
}

@synthesize pinchZoomFactor =_pinchZoomFactor;
- (CGFloat) pinchZoomFactor {
    _pinchZoomFactor = _vCapDev.inputCamera.videoZoomFactor;
    return _pinchZoomFactor;
}

//设置新的触摸缩放因子
- (void)setPinchZoomFactor:(CGFloat)zoomFactor{
    AVCaptureDevice *captureDevice=_vCapDev.inputCamera;
    NSError *error = nil;
    [captureDevice lockForConfiguration:&error];
    if (!error) {
        CGFloat videoMaxZoomFactor = captureDevice.activeFormat.videoMaxZoomFactor;
        if (zoomFactor < 1.0f)
            zoomFactor = 1.0f;
        if (zoomFactor > videoMaxZoomFactor)
            zoomFactor = videoMaxZoomFactor;
        
        [captureDevice rampToVideoZoomFactor:zoomFactor withRate:1.0];
        captureDevice.videoZoomFactor = zoomFactor;
        [captureDevice unlockForConfiguration];
    }
}

//设置采集和推流配置参数
@synthesize streamerProfile =_streamerProfile;
- (void)setStreamerProfile:(KSYStreamerProfile)profile{
    switch (profile) {
        case KSYStreamerProfile_360p_1:
            _capPreset = AVCaptureSessionPreset640x480;
            _previewDimension = CGSizeMake(640, 360);
            _streamDimension = CGSizeMake(640, 360);
            _videoFPS = 15;
            _streamerBase.videoCodec = KSYVideoCodec_AUTO;
            _streamerBase.videoMaxBitrate = 512;
            _streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
            _streamerBase.audiokBPS = 48;
            _streamerBase.bwEstimateMode = KSYBWEstMode_Default;
            break;
        case KSYStreamerProfile_360p_2:
            _capPreset = AVCaptureSessionPresetiFrame960x540;
            _previewDimension = CGSizeMake(960, 540);
            _streamDimension = CGSizeMake(640, 360);
            _videoFPS = 15;
            _streamerBase.videoCodec = KSYVideoCodec_AUTO;
            _streamerBase.videoMaxBitrate = 512;
            _streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
            _streamerBase.audiokBPS = 48;
            _streamerBase.bwEstimateMode = KSYBWEstMode_Default;
            break;
        case KSYStreamerProfile_360p_3:
            _capPreset = AVCaptureSessionPreset1280x720;
            _previewDimension = CGSizeMake(1280, 720);
            _streamDimension = CGSizeMake(640, 360);
            _videoFPS = 20;
            _streamerBase.videoCodec = KSYVideoCodec_AUTO;
            _streamerBase.videoMaxBitrate = 768;
            _streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
            _streamerBase.audiokBPS = 48;
            _streamerBase.bwEstimateMode = KSYBWEstMode_Default;
            break;
        case KSYStreamerProfile_360p_auto:
            _capPreset = AVCaptureSessionPreset640x480;
            _previewDimension = CGSizeMake(640, 360);
            _streamDimension = CGSizeMake(640, 360);
            _videoFPS = 15;
            _streamerBase.videoCodec = KSYVideoCodec_AUTO;
            _streamerBase.videoMaxBitrate = 512;
            _streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
            _streamerBase.audiokBPS = 48;
            _streamerBase.bwEstimateMode = KSYBWEstMode_Default;
            break;
        case KSYStreamerProfile_540p_1:
            _capPreset = AVCaptureSessionPresetiFrame960x540;
            _previewDimension = CGSizeMake(960, 540);
            _streamDimension = CGSizeMake(960, 540);
            _videoFPS = 15;
            _streamerBase.videoCodec = KSYVideoCodec_AUTO;
            _streamerBase.videoMaxBitrate = 768;
            _streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
            _streamerBase.audiokBPS = 64;
            _streamerBase.bwEstimateMode = KSYBWEstMode_Default;
            break;
        case KSYStreamerProfile_540p_2:
            _capPreset = AVCaptureSessionPreset1280x720;
            _previewDimension = CGSizeMake(1280, 720);
            _streamDimension = CGSizeMake(960, 540);
            _videoFPS = 15;
            _streamerBase.videoCodec = KSYVideoCodec_AUTO;
            _streamerBase.videoMaxBitrate = 768;
            _streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
            _streamerBase.audiokBPS = 64;
            _streamerBase.bwEstimateMode = KSYBWEstMode_Default;
            break;
        case KSYStreamerProfile_540p_3:
            _capPreset = AVCaptureSessionPreset1280x720;
            _previewDimension = CGSizeMake(1280, 720);
            _streamDimension = CGSizeMake(960, 540);
            _videoFPS = 20;
            _streamerBase.videoCodec = KSYVideoCodec_AUTO;
            _streamerBase.videoMaxBitrate = 1024;
            _streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
            _streamerBase.audiokBPS = 64;
            _streamerBase.bwEstimateMode = KSYBWEstMode_Default;
            break;
        case KSYStreamerProfile_540p_auto:
            _capPreset = AVCaptureSessionPresetiFrame960x540;
            _previewDimension = CGSizeMake(960, 540);
            _streamDimension = CGSizeMake(960, 540);
            _videoFPS = 15;
            _streamerBase.videoCodec = KSYVideoCodec_AUTO;
            _streamerBase.videoMaxBitrate = 768;
            _streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
            _streamerBase.audiokBPS = 64;
            _streamerBase.bwEstimateMode = KSYBWEstMode_Default;
            break;
        case KSYStreamerProfile_720p_1:
            _capPreset = AVCaptureSessionPreset1280x720;
            _previewDimension = CGSizeMake(1280, 720);
            _streamDimension = CGSizeMake(1280, 720);
            _videoFPS = 15;
            _streamerBase.videoCodec = KSYVideoCodec_AUTO;
            _streamerBase.videoMaxBitrate = 1024;
            _streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
            _streamerBase.audiokBPS = 128;
            _streamerBase.bwEstimateMode = KSYBWEstMode_Default;
            break;
        case KSYStreamerProfile_720p_2:
            _capPreset = AVCaptureSessionPreset1280x720;
            _previewDimension = CGSizeMake(1280, 720);
            _streamDimension = CGSizeMake(1280, 720);
            _videoFPS = 20;
            _streamerBase.videoCodec = KSYVideoCodec_AUTO;
            _streamerBase.videoMaxBitrate = 1280;
            _streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
            _streamerBase.audiokBPS = 128;
            _streamerBase.bwEstimateMode = KSYBWEstMode_Default;
            break;
        case KSYStreamerProfile_720p_3:
            _capPreset = AVCaptureSessionPreset1280x720;
            _previewDimension = CGSizeMake(1280, 720);
            _streamDimension = CGSizeMake(1280, 720);
            _videoFPS = 24;
            _streamerBase.videoCodec = KSYVideoCodec_AUTO;
            _streamerBase.videoMaxBitrate = 1536;
            _streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
            _streamerBase.audiokBPS = 128;
            _streamerBase.bwEstimateMode = KSYBWEstMode_Default;
            break;
        case KSYStreamerProfile_720p_auto:
            _capPreset = AVCaptureSessionPreset1280x720;
            _previewDimension = CGSizeMake(1280, 720);
            _streamDimension = CGSizeMake(1280, 720);
            _videoFPS = 15;
            _streamerBase.videoCodec = KSYVideoCodec_AUTO;
            _streamerBase.videoMaxBitrate = 1024;
            _streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
            _streamerBase.audiokBPS = 128;
            _streamerBase.bwEstimateMode = KSYBWEstMode_Default;
            break;
        default:
            NSLog(@"Set Invalid Profile");
    }
}

@end
