//
//  KSYGPUStreamerKit.m
//  KSYStreamer
//
//  Created by pengbin on 09/01/16.
//  Copyright © 2016 ksyun. All rights reserved.
//
#import "KSYGPUStreamerKit.h"

#define FLOAT_EQ( f0, f1 ) ( (f0 - f1 < 0.0001)&& (f0 - f1 > -0.0001) )

#define weakObj(o) __weak typeof(o) o##Weak = o;

@interface KSYGPUStreamerKit (){
    dispatch_queue_t _capDev_q;
    NSLock   *       _quitLock;  // ensure capDev closed before dealloc
    CGFloat _previewRotateAng;
    int            _autoRetryCnt;
    BOOL           _bRetry;
    BOOL           _bInterrupt;
    KSYDummyAudioSource *_dAudioSrc;
    // 音频采集模式（KSYAudioCapType）为AVCaptureDevice时发送静音包
    BOOL _bMute;
    KSYNetworkStatus _lastNetStatus;
}
// vMixerTargets
@property (nonatomic, copy) NSArray *vPreviewTargets;
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
    _bInterrupt       = bInter;
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
    _audioDataType = KSYAudioData_CMSampleBuffer;
    
    _autoRetryCnt    = 0;
    _maxAutoRetry    = 0;
    _autoRetryDelay  = 2.0;
    _bRetry          = NO;
    
    // 图层和音轨的初始化
    _cameraLayer  = 2;
    _logoPicLayer = 3;
    _logoTxtLayer = 4;
    _aeLayer = 6;

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
    // 设置 AudioSession的属性为直播需要的默认值, 具体如下:
    // bInterruptOtherAudio : NO  不打断其他播放器
    // bDefaultToSpeaker : YES    背景音乐从外放播放
    // bAllowBluetooth : YES      启用蓝牙
    // AVAudioSessionCategory : AVAudioSessionCategoryPlayAndRecord  允许录音
    // 设置不打断其他播放器时，需要放在_aCapDev初始化前设置，否则没效果
    [[AVAudioSession sharedInstance] setDefaultCfg];
    [AVAudioSession sharedInstance].bInterruptOtherAudio = bInter;
    // 创建背景音乐播放模块
    _bgmPlayer = [[KSYBgmPlayer   alloc] init];
    // 音频采集模块
    _aCapDev = [[KSYAUAudioCapture alloc] init];
    // 各种图片
    _logoPic = nil;
    _textPic = nil;
    _aePic = nil;
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
    // 初始化图层的位置
    self.logoRect = CGRectMake(0.1 , 0.05, 0, 0.1);
    self.textRect = CGRectMake(0.05, 0.15, 0, 20.0/640);
    
    ///// 3.2 音频通路 ///////////
    // 核心部件:音频叠加混合
    _aMixer = [[KSYAudioMixer alloc]init];
    _bStereoAudioStream = NO;
    
    // 组装音频通道
    [self setupAudioPath];
    
    //消息通道
    _msgStreamer = [[KSYMessage alloc] init];
    [self setupMessagePath];
    
    weakObj(self);
    _streamerBase.streamStateChange = ^(KSYStreamState state) {
        [selfWeak onStreamState:state];
    };
    _streamerBase.videoFPSChange = ^(int newVideoFPS){
        [selfWeak changeFPS:newVideoFPS];
    };
    //设置profile初始值
    self.streamerProfile = KSYStreamerProfile_540p_3;

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
    _bgmPlayer = nil;
    _streamerBase = nil;
    _vCapDev = nil;
    _dAudioSrc = nil;
    [_quitLock unlock];
    _quitLock = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/* reset all submodules */
- (void) closeKit{
    [_bgmPlayer    stopPlayBgm];
    [_streamerBase stopStream];
    [_aCapDev      stopCapture];
    [_vCapDev      stopCameraCapture];
    [_vCapDev      removeAudioInputsAndOutputs];
    
    [_capToGpu    removeAllTargets];
    [_filter      removeAllTargets];
    [_logoPic     removeAllTargets];
    [_textPic     removeAllTargets];
    [_aePic       removeAllTargets];
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
    self.aePic = _aePic;
    [self setPreviewMirrored: _previewMirrored];
    [self setStreamerMirrored: _streamerMirrored];
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
    // 设置镜像
    [self setPreviewOrientation:_previewOrientation];
    [self setStreamOrientation:_streamOrientation];
}

// 添加图层到 vMixer 中
- (void) addPic:(KSYGPUPicture*)pic ToMixerAt: (NSInteger)idx{
    KSYGPUPicMixer * vMixer[2] = {_vPreviewMixer, _vStreamMixer};
    if (pic == nil){
        for (int i = 0; i<2; ++i) {
            [vMixer[i]  clearPicOfLayer:idx];
        }
        return;
    }
    [pic removeAllTargets];
    for (int i = 0; i<2; ++i) {
        [pic addTarget:vMixer[i] atTextureLocation:idx];
    }
}
// 组装视频通道
- (void) setupVideoPath {
    weakObj(self);
    // 前处理 和 图像 mixer
    [self setupFilter:_filter];
    [self setupVMixer];

    // 采集到的画面上传GPU
    _vCapDev.videoProcessingCallback = ^(CMSampleBufferRef buf) {
        if ( selfWeak.videoProcessingCallback ){
            selfWeak.videoProcessingCallback(buf);
        }
        [selfWeak.capToGpu processSampleBuffer:buf];
    };
    // GPU 上的数据导出到streamer
    _gpuToStr.videoProcessingCallback = ^(CVPixelBufferRef pixelBuffer, CMTime timeInfo){
        if (![selfWeak.streamerBase isStreaming]){
            return;
        }
        [selfWeak.streamerBase processVideoPixelBuffer:pixelBuffer
                                         timeInfo:timeInfo];
    };
    // 采集被打断的事件回调
    _vCapDev.interruptCallback = ^(BOOL bInterrupt) {
        if (bInterrupt) {
            [selfWeak appEnterBackground];
        }
        else {
            [selfWeak appBecomeActive];
        }
        if(selfWeak.interruptCallback) {
            selfWeak.interruptCallback(bInterrupt);
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
    weakObj(self);
    //1. 音频采集, 语音数据送入混音器
    if (_audioDataType == KSYAudioData_CMSampleBuffer) {
        _aCapDev.audioProcessingCallback = ^(CMSampleBufferRef buf){
            if ( selfWeak.audioProcessingCallback ){
                selfWeak.audioProcessingCallback(buf);
            }
            [selfWeak mixAudio:buf to:selfWeak.micTrack];
        };
    }
    else {
        _aCapDev.pcmProcessingCallback = ^(uint8_t **pData, int len, const AudioStreamBasicDescription *fmt, CMTime timeInfo) {
            if ( selfWeak.pcmProcessingCallback ){
                selfWeak.pcmProcessingCallback(pData, len, fmt, timeInfo);
            }
            if (![selfWeak.streamerBase isStreaming]){
                return;
            }
            [selfWeak.aMixer processAudioData:pData nbSample:len withFormat:fmt timeinfo:timeInfo of:selfWeak.micTrack];
        };
    }
    //2. 背景音乐播放,音乐数据送入混音器
    _bgmPlayer.audioDataBlock = ^ BOOL(uint8_t** pData, int len, const AudioStreamBasicDescription* fmt, CMTime pts){
        if ([selfWeak.streamerBase isStreaming]) {
        [selfWeak.aMixer processAudioData:pData
                            nbSample:len
                          withFormat:fmt
                            timeinfo:pts
                                  of:selfWeak.bgmTrack];
        }
        return YES;
    };
    // 混音结果送入streamer
    if (_audioDataType == KSYAudioData_CMSampleBuffer) {
        _aMixer.audioProcessingCallback = ^(CMSampleBufferRef buf){
            if (![selfWeak.streamerBase isStreaming]){
                return;
            }
            [selfWeak.streamerBase processAudioSampleBuffer:buf];
        };
    }
    else {
        _aMixer.pcmProcessingCallback = ^(uint8_t **pData, int nbSample, CMTime pts) {
            if (![selfWeak.streamerBase isStreaming]){
                return;
            }
            [selfWeak.streamerBase processAudioData:pData
                                           nbSample:nbSample
                                         withFormat:selfWeak.aMixer.outFmtDes
                                           timeinfo:&pts];
        };
    }
    // mixer 的主通道为麦克风,时间戳以main通道为准
    _aMixer.mainTrack = _micTrack;
    [_aMixer setTrack:_micTrack enable:YES];
    [_aMixer setTrack:_bgmTrack enable:YES];
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
    if (_capDev_q == nil || view == nil || [_vCapDev isRunning]) {
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
    AVAuthorizationStatus status_video = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ( status_video == AVAuthorizationStatusDenied == AVAuthorizationStatusDenied) {
        [self newCaptureState:KSYCaptureStateDevAuthDenied];
        return NO;
    }
    if (_capPreset == nil) {
        [self newCaptureState:KSYCaptureStateParameterError];
        return NO;
    }
    dispatch_async(_capDev_q, ^{
        [_quitLock lock];
        if ( _cameraPosition != [_vCapDev cameraPosition] ){
            [_vCapDev rotateCamera];
        }
        _vCapDev.captureSessionPreset = _capPreset;
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
    if (_vPreviewMixer.targets.count > 0){
        _vPreviewTargets = [_vPreviewMixer.targets copy];
    }
    
    // 进入后台时, 将预览从图像混合器中脱离, 避免后台OpenGL渲染崩溃
    [_vPreviewMixer removeAllTargets];
    if (_audioCaptureType == KSYAudioCap_AVCaptureDevice) {
        [self startDummySource];
    }
    // 重复最后一帧视频图像
    _gpuToStr.bAutoRepeat = YES;
    if (_streamerBase.bypassRecordState == KSYRecordStateRecording ) {
        [_streamerBase stopBypassRecord];
    }
}

/** 回到前台 */
- (void) appBecomeActive{
    // 回到前台, 重新连接预览
    [self setupVMixer];
    [_aCapDev  resumeCapture];
    
    if (_audioCaptureType == KSYAudioCap_AVCaptureDevice) {
        _bMute = NO;
        // 停止 dummy audio source
        if ([_dAudioSrc bRunning]) {
            [_dAudioSrc stop];
            _dAudioSrc.audioProcessingCallback  = nil;
        }
    }
    if (!_streamerFreezed) {
        _gpuToStr.bAutoRepeat = NO;
    }
}

- (void)startDummySource{
    weakObj(self);
    _bMute = YES;
    // 开启后台任务，避免被suspend
    __block UIBackgroundTaskIdentifier background_task;
    
    dispatch_queue_t back_task_queue = dispatch_queue_create("com.ksyun.backgroundTask.queue", DISPATCH_QUEUE_SERIAL);
    background_task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^ {
        [[UIApplication sharedApplication] endBackgroundTask:background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(back_task_queue, ^{
        while (_bMute) {
            sleep(1);
        }
        [[UIApplication sharedApplication] endBackgroundTask:background_task];
        background_task = UIBackgroundTaskInvalid;
    });
    
    // 开启 dummy audio source
    _dAudioSrc.audioProcessingCallback = ^(CMSampleBufferRef buf) {
        if (selfWeak.audioProcessingCallback && _bMute) {
            selfWeak.audioProcessingCallback( buf);
        }
    };
    [_dAudioSrc start];
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
@synthesize audioDataType = _audioDataType;
- (void) setAudioDataType:(KSYAudioDataType)audioDataType {
    _audioDataType = audioDataType;
    [self setupAudioPath];
}
- (KSYAudioDataType) audioDataType {
    return _audioDataType;
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
                               byOriention:_videoOrientation];
    CGSize  inSz     =  [self captureDimension];
    inSz = [self getDimension:inSz byOriention:_vCapDev.outputImageOrientation];
    CGSize cropSz = [self calcCropSize:inSz to:_previewDimension];
    _capToGpu.cropRegion = [self calcCropRect:inSz to:cropSz];
    _capToGpu.outputRotation = kGPUImageNoRotation;
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
- (void)changeFPS:(int)fps {
    _videoFPS = MAX(1, MIN(fps, 30));
    _vCapDev.frameRate = _videoFPS;
    _streamerBase.videoFPS = _videoFPS;
}

- (void) setVideoFPS: (int) fps {
    if(_captureState  ==  KSYCaptureStateIdle)
    {
        [self changeFPS:fps];
    }
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

@synthesize bStereoAudioStream = _bStereoAudioStream;
- (void) setBStereoAudioStream:(BOOL)bStereoAudioStream {
    if (_streamerBase.isStreaming){
        return; // 推流过程中修改本属性会导致观众端的声音异常
    }
    _bStereoAudioStream =
    _aMixer.bStereo = bStereoAudioStream;
}
-(BOOL) bStereoAudioStream {
    return _aMixer.bStereo;
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
@synthesize textPic = _textPic;
-(void) setTextPic:(KSYGPUPicture *)textPic{
    _textPic = textPic;
    [self addPic:_textPic ToMixerAt:_logoTxtLayer];
}
@synthesize logoPic = _logoPic;
-(void) setLogoPic:(KSYGPUPicture *)pic{
    _logoPic = pic;
    [self addPic:_logoPic ToMixerAt:_logoPicLayer];
}
static GPUImageRotationMode KSYImage2GPURotate[] = {
    kGPUImageNoRotation,// UIImageOrientationUp,            // default orientation
    kGPUImageRotate180,//UIImageOrientationDown,          // 180 deg rotation
    kGPUImageRotateLeft, //UIImageOrientationLeft,          // 90 deg CCW
    kGPUImageRotateRight,//UIImageOrientationRight,         // 90 deg CW
    kGPUImageFlipHorizonal,//UIImageOrientationUpMirrored,    // as above but image mirrored along other axis. horizontal flip
    kGPUImageFlipHorizonal,//UIImageOrientationDownMirrored,  // horizontal flip
    kGPUImageFlipVertical,//UIImageOrientationLeftMirrored,  // vertical flip
    kGPUImageRotateRightFlipVertical//UIImageOrientationRightMirrored, // vertical flip
};

- (void) setOrientaion:(UIImageOrientation) orien ofLayer:(NSInteger)idx {
    [_vPreviewMixer setPicRotation:KSYImage2GPURotate[orien]
                           ofLayer:idx];
    [_vStreamMixer setPicRotation:KSYImage2GPURotate[orien]
                          ofLayer:idx];
}
- (void) setLogoOrientaion:(UIImageOrientation) orien{
    [self setOrientaion:orien ofLayer:_logoPicLayer];
}
@synthesize aePic = _aePic;
-(void) setAePic:(GPUImageUIElement *)aePic{
    _aePic = aePic;
    [self.vStreamMixer  clearPicOfLayer:_aeLayer];
    if (_aePic == nil){
        return;
    }
    [_aePic removeAllTargets];
    [_aePic addTarget:self.vStreamMixer atTextureLocation:_aeLayer];
}

- (void) setRect:(CGRect) rect ofLayer:(NSInteger)idx {
    [_vPreviewMixer setPicRect:rect
                       ofLayer:idx];
    [_vStreamMixer setPicRect:rect
                      ofLayer:idx];
}

// 水印logo的图片的位置和大小
@synthesize logoRect = _logoRect;
- (CGRect) logoRect {
    return [_vPreviewMixer getPicRectOfLayer:_logoPicLayer];
}
- (void) setLogoRect:(CGRect)logoRect{
    _logoRect = logoRect;
    [self setRect:logoRect ofLayer:_logoPicLayer];
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
    _textRect = rect;
    [self setRect:rect ofLayer:_logoTxtLayer];
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

    if(fmt != kCVPixelFormatType_32BGRA  &&
        fmt != kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange &&
        fmt != kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
    {
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
    if( fmt !=  kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange &&
        fmt !=  kCVPixelFormatType_420YpCbCr8BiPlanarFullRange &&
        fmt !=  kCVPixelFormatType_420YpCbCr8PlanarFullRange &&
        fmt !=  kCVPixelFormatType_420YpCbCr8Planar ){
        fmt = kCVPixelFormatType_32BGRA;
    }
    _gpuOutputPixelFormat = fmt;
    _gpuToStr =[[KSYGPUPicOutput alloc] initWithOutFmt:fmt];
    [self setupVideoPath];
    [self updateStrDimension:self.videoOrientation];
}

#pragma mark - rotate & mirror

- (void) setPreviewMirrored:(BOOL)bMirrored {
    if(_vPreviewMixer){
        GPUImageRotationMode ro = bMirrored ? kGPUImageFlipHorizonal: kGPUImageNoRotation;
        int ang = _previewRotateAng / M_PI_2;
        BOOL capAng = GPUImageRotationSwapsWidthAndHeight(_capToGpu.outputRotation);
        if ( !capAng && (ang == 1 || ang == 3)) {
            ro = bMirrored ? kGPUImageFlipVertical : kGPUImageNoRotation;
        }
        [_vPreviewMixer setPicRotation:ro ofLayer:_cameraLayer];
    }
    _previewMirrored = bMirrored;
    return ;
}

- (void) setStreamerMirrored:(BOOL)bMirrored {
    if (_vStreamMixer){
        GPUImageRotationMode ro = bMirrored ? kGPUImageFlipHorizonal: kGPUImageNoRotation;
        [_vStreamMixer setPicRotation:ro ofLayer:_cameraLayer];
    }
    _streamerMirrored = bMirrored;
}

- (void) setStreamerFreezed:(BOOL)streamerFreezed {
    _streamerFreezed = streamerFreezed;
    _gpuToStr.bAutoRepeat = streamerFreezed;
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
    weakObj(self);
    dispatch_async(dispatch_get_main_queue(), ^(){
        [selfWeak internalRotatePreviewTo:orie];
    });
}

-(void)internalRotatePreviewTo: (UIInterfaceOrientation) orie {
    _previewOrientation = orie;
    UIView* view = [_preview superview];
    if (_videoOrientation == orie || view == nil) {
        _previewRotateAng = 0;
    }
    else {
        int capOri = UIOrienToIdx(_vCapDev.outputImageOrientation);
        int appOri = UIOrienToIdx(orie);
        _previewRotateAng = KSYRotateAngles[ capOri ][ appOri ];
    }
    for (UIView<GPUImageInput> *v in _vPreviewMixer.targets) {
        v.transform = CGAffineTransformMakeRotation(_previewRotateAng);
    }
    _preview.frame = view.bounds;
    [self setPreviewMirrored: _previewMirrored];
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
    if (_gpuToStr.bAutoRepeat) {
        return;
    }
    int capOri = UIOrienToIdx(_videoOrientation);
    int appOri = UIOrienToIdx(orie);
    GPUImageRotationMode oppositeMode = KSYRotateMode[appOri][capOri];
    [_preview setInputRotation:oppositeMode atIndex:0];
    [self updatePreDimension];
    [self updateStrDimension:orie];
    GPUImageRotationMode mode = KSYRotateMode[capOri][appOri];
    _capToGpu.outputRotation = mode;
    [self setStreamerMirrored: _streamerMirrored];
    [self setPreviewMirrored: _previewMirrored];
}

/**
 @abstract 摄像头自动曝光
 */
- (BOOL)exposureAtPoint:(CGPoint )point{
    AVCaptureDevice *dev = _vCapDev.inputCamera;
    NSError *error;
    
    if ([dev isExposurePointOfInterestSupported] && [dev isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        if ([dev lockForConfiguration:&error]) {
            [dev setExposurePointOfInterest:point];  // 曝光点
            [dev setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
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
- (void)setStreamerProfile:(KSYStreamerProfile)profile{
    
    _streamerBase.videoCodec = KSYVideoCodec_AUTO;
    _streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
    _streamerBase.bwEstimateMode = KSYBWEstMode_Default;
    _streamerBase.videoMinFPS = 10;
    _streamerBase.videoMaxFPS = 25;
    _streamerBase.videoEncodePerf = KSYVideoEncodePer_HighPerformance;
    switch (profile) {
        case KSYStreamerProfile_360p_auto:
            _capPreset = AVCaptureSessionPreset640x480;
            _previewDimension = CGSizeMake(640, 360);
            _streamDimension = CGSizeMake(640, 360);
            self.videoFPS = 15;
            _streamerBase.videoMaxBitrate = 512;
            _streamerBase.audiokBPS = 64;
            break;
        case KSYStreamerProfile_360p_1:
            _capPreset = AVCaptureSessionPreset640x480;
            _previewDimension = CGSizeMake(640, 360);
            _streamDimension = CGSizeMake(640, 360);
            self.videoFPS = 15;
            _streamerBase.videoMaxBitrate = 512;
            _streamerBase.audiokBPS = 64;
            break;
        case KSYStreamerProfile_360p_2:
            _capPreset = AVCaptureSessionPresetiFrame960x540;
            _previewDimension = CGSizeMake(960, 540);
            _streamDimension = CGSizeMake(640, 360);
            self.videoFPS = 15;
            _streamerBase.videoMaxBitrate = 512;
            _streamerBase.audiokBPS = 64;
            break;
        case KSYStreamerProfile_360p_3:
            _capPreset = AVCaptureSessionPreset1280x720;
            _previewDimension = CGSizeMake(1280, 720);
            _streamDimension = CGSizeMake(640, 360);
            self.videoFPS = 20;
            _streamerBase.videoMaxBitrate = 768;
            _streamerBase.audiokBPS = 64;
            break;
        case KSYStreamerProfile_540p_auto:
            _capPreset = AVCaptureSessionPresetiFrame960x540;
            _previewDimension = CGSizeMake(960, 540);
            _streamDimension = CGSizeMake(960, 540);
            self.videoFPS = 15;
            _streamerBase.videoMaxBitrate = 768;
            _streamerBase.audiokBPS = 64;
            break;
        case KSYStreamerProfile_540p_1:
            _capPreset = AVCaptureSessionPresetiFrame960x540;
            _previewDimension = CGSizeMake(960, 540);
            _streamDimension = CGSizeMake(960, 540);
            self.videoFPS = 15;
            _streamerBase.videoMaxBitrate = 768;
            _streamerBase.audiokBPS = 64;
            break;
        case KSYStreamerProfile_540p_2:
            _capPreset = AVCaptureSessionPreset1280x720;
            _previewDimension = CGSizeMake(1280, 720);
            _streamDimension = CGSizeMake(960, 540);
            self.videoFPS = 15;
            _streamerBase.videoMaxBitrate = 768;
            _streamerBase.audiokBPS = 64;
            break;
        case KSYStreamerProfile_540p_3:
            _capPreset = AVCaptureSessionPreset1280x720;
            _previewDimension = CGSizeMake(1280, 720);
            _streamDimension = CGSizeMake(960, 540);
            self.videoFPS = 20;
            _streamerBase.videoMaxBitrate = 1024;
            _streamerBase.audiokBPS = 64;
            break;
        case KSYStreamerProfile_720p_auto:
            _capPreset = AVCaptureSessionPreset1280x720;
            _previewDimension = CGSizeMake(1280, 720);
            _streamDimension = CGSizeMake(1280, 720);
            self.videoFPS = 15;
            _streamerBase.videoMaxBitrate = 1024;
            _streamerBase.audiokBPS = 128;
            break;
        case KSYStreamerProfile_720p_1:
            _capPreset = AVCaptureSessionPreset1280x720;
            _previewDimension = CGSizeMake(1280, 720);
            _streamDimension = CGSizeMake(1280, 720);
            self.videoFPS = 15;
            _streamerBase.videoMaxBitrate = 1024;
            _streamerBase.audiokBPS = 128;
            break;
        case KSYStreamerProfile_720p_2:
            _capPreset = AVCaptureSessionPreset1280x720;
            _previewDimension = CGSizeMake(1280, 720);
            _streamDimension = CGSizeMake(1280, 720);
            self.videoFPS = 20;
            _streamerBase.videoMaxBitrate = 1280;
            _streamerBase.audiokBPS = 128;
            break;
        case KSYStreamerProfile_720p_3:
            _capPreset = AVCaptureSessionPreset1280x720;
            _previewDimension = CGSizeMake(1280, 720);
            _streamDimension = CGSizeMake(1280, 720);
            self.videoFPS = 24;
            _streamerBase.videoMaxBitrate = 1536;
            _streamerBase.audiokBPS = 128;
            break;
        default:
            NSLog(@"Set Invalid Profile");
            return;
    }
    _streamerBase.videoInitBitrate = _streamerBase.videoMaxBitrate*6/10;
    _streamerBase.videoMinBitrate  = 0;
    _streamerProfile = profile;
}

//
- (void)setAudioCaptureType:(KSYAudioCapType)audioCaptureType{
    _audioCaptureType = audioCaptureType;
    weakObj(self);
    if (audioCaptureType == KSYAudioCap_AudioUnit) {
        [_vCapDev removeAudioInputsAndOutputs];
        
        if (!_aCapDev) {
            _aCapDev = [[KSYAUAudioCapture alloc] init];
        }
        [_aCapDev startCapture];
        
        _aCapDev.audioProcessingCallback = ^(CMSampleBufferRef buf){
            if ( selfWeak.audioProcessingCallback ){
                selfWeak.audioProcessingCallback(buf);
            }
            [selfWeak mixAudio:buf to:selfWeak.micTrack];
        };
    }else if (audioCaptureType == KSYAudioCap_AVCaptureDevice) {
        _aCapDev = nil;
        [_vCapDev addAudioInputsAndOutputs];

        // 创建 dummy audio source
        _dAudioSrc = [[KSYDummyAudioSource alloc] init];
        
        _vCapDev.audioProcessingCallback = ^(CMSampleBufferRef buf){
            if ( selfWeak.audioProcessingCallback ){
                selfWeak.audioProcessingCallback(buf);
            }
            [selfWeak mixAudio:buf to:selfWeak.micTrack];
        };
    }
}

- (BOOL)setStabilizationMode:(AVCaptureVideoStabilizationMode)stabilizationMode{
    _stabilizationMode = stabilizationMode;
    __block BOOL supported = NO;
    
    __weak typeof(self) weakSelf = self;
    NSArray<AVCaptureOutput *> *outputs = _vCapDev.captureSession.outputs;
    [outputs enumerateObjectsUsingBlock:^(AVCaptureOutput *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[AVCaptureVideoDataOutput class]]) {
            if ([weakSelf.vCapDev.inputCamera.activeFormat isVideoStabilizationModeSupported:stabilizationMode]){
                AVCaptureConnection *connection = [obj connectionWithMediaType:AVMediaTypeVideo];
                
                if ([connection isVideoStabilizationSupported]) {
                    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
                        [connection setPreferredVideoStabilizationMode:stabilizationMode];
                    }else{
                        [connection setEnablesVideoStabilizationWhenAvailable:YES];
                    }
                    supported = YES;
                }
            }
        }
    }];
    
    return supported;
}



@end
