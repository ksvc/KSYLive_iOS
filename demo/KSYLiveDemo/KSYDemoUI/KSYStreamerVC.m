//
//  ViewController.m
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 ksyun. All rights reserved.
//
#import "KSYUIView.h"
#import "KSYUIVC.h"

#import "KSYPresetCfgView.h"
#import "KSYStreamerVC.h"
#import "KSYFilterView.h"
#import "KSYBgmView.h"
#import "KSYPipView.h"
#import "KSYNameSlider.h"
#import "KSYQRCode.h"
#import <YYImage/YYImage.h>
#if  __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <CallKit/CXCallObserver.h>
#import <CallKit/CallKit.h>
#endif

// 为防止将手机存储写满,限制录像时长为30s
#define REC_MAX_TIME 30 //录制视频的最大时间，单位s

@interface KSYStreamerVC () <UIImagePickerControllerDelegate
,UINavigationControllerDelegate
#if  __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
,CXCallObserverDelegate
#endif
>{
    UISwipeGestureRecognizer *_swipeGest;
    NSDateFormatter * _dateFormatter;
    int _strSeconds; // 推流持续的时间 , 单位s
    
    BOOL _bRecord;//是推流还是录制到本地
    NSString *_bypassRecFile;// 旁路录制
    // 旁路录制:一边推流到rtmp server, 一边录像到本地文件
    // 本地录制:直接存储到本地
    UIImageView *_foucsCursor;//对焦框
    CGFloat _currentPinchZoomFactor;//当前触摸缩放因子
    BOOL _bOutputInfo;//是否输出推流过程中的统计信息
#if  __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    CXCallObserver *_callObserver;
#endif
    YYImageDecoder  * _animateDecoder;
    int _animateIdx;
    
    NSTimeInterval   _dlTime;
    NSLock          *_dlLock;
    KSYGPUPicture *_logoPicure;
    UIImageOrientation _logoOrientation;
    CADisplayLink   *_displayLink;
}

@end

@implementation KSYStreamerVC

- (id) initWithCfg:(KSYPresetCfgView*)presetCfgView{
    self = [super init];
    _presetCfgView = presetCfgView;
    [self initObservers];
    _menuNames = @[@"背景音乐", @"图像/美颜",@"声音", @"消息", @"其他"];
    self.view.backgroundColor = [UIColor blackColor];
    _dlLock = [[NSLock alloc] init];
    return self;
}

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.kit == nil){
        _kit = [[KSYGPUStreamerKit alloc] initWithDefaultCfg];
    }
    [self addSubViews];
    [self addSwipeGesture];
    [self addfoucsCursor];
    [self addPinchGestureRecognizer];
    if (_presetCfgView.profileUI.selectedSegmentIndex){
        [self setCustomizeCfg];//自定义
    }else{//预设等级
        _kit.streamerProfile = _presetCfgView.curProfileIdx;//配置profile
    }
    // load default value
    _miscView.vEncPerf = _kit.streamerBase.videoEncodePerf;
    // 采集相关设置初始化
    [self setCaptureCfg];
    //推流相关设置初始化
    [self setStreamerCfg];
    // 打印版本号信息
    NSLog(@"version: %@", [_kit getKSYVersion]);

    [self setupLogo];
    _bypassRecFile =[NSHomeDirectory() stringByAppendingString:@"/Library/Caches/rec.mp4"];
    weakObj(self);
    _kit.streamerBase.bypassRecordStateChange = ^(KSYRecordState state) {
        //旁路录制状态改变会调用该block
        [selfWeak onBypassRecordStateChange:state];
    };
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_kit) { // init with default filter
        // 确保videoOrientation为正确的方向正确，否则画面方向会有异常
        _kit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [_kit setupFilter:self.ksyFilterView.curFilter];
        [_kit startPreview:_bgView];
    }
}

- (void) addSwipeGesture{
    SEL onSwip =@selector(swipeController:);
    _swipeGest = [[UISwipeGestureRecognizer alloc]initWithTarget:self
                                                          action:onSwip];
    _swipeGest.direction |= UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:_swipeGest];
}

- (void)addfoucsCursor{
    _foucsCursor = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"camera_focus_red"]];
    _foucsCursor.frame = CGRectMake(80, 80, 80, 80);
    [self.view addSubview:_foucsCursor];
    _foucsCursor.alpha = 0;
}

- (void)addSubViews{
    _bgView = [[UIView alloc] init];
    [self.view addSubview: _bgView];
    _ctrlView  = [[KSYCtrlView alloc] initWithMenu:_menuNames];
    _colView = [[KSYCollectionView alloc] init];
    _decalBGView = [[KSYDecalBGView alloc] init];
    [self.view addSubview:_ctrlView];
    [self.view addSubview:_colView];
    [self.colView addSubview:_decalBGView];
    [self.colView sendSubviewToBack:_decalBGView];
    _colView.hidden = YES;
    _ksyFilterView  = [[KSYFilterView alloc]initWithParent:_ctrlView];
    _ksyBgmView     = [[KSYBgmView alloc]initWithParent:_ctrlView];
    _audioView      = [[KSYAudioCtrlView alloc]initWithParent:_ctrlView];
    _miscView       = [[KSYMiscView alloc]initWithParent:_ctrlView];
    
    // connect UI
    weakObj(self);
    _colView.DEBlock = ^(NSString *imgName){
        [selfWeak genDecalViewWithImgName:imgName];
    };
    _ctrlView.onBtnBlock = ^(id btn){
        [selfWeak onBasicCtrl:btn];
    };
    // 背景音乐控制页面
    _ksyBgmView.onBtnBlock = ^(id sender) {
        [selfWeak onBgmBtnPress:sender];
    };
    _ksyBgmView.onSliderBlock = ^(id sender) {
        [selfWeak onBgmSlider:sender];
    };
    _ksyBgmView.onSegCtrlBlock = ^(id sender) {
        [selfWeak onBgmCtrSle:sender];
    };
    [selfWeak onBgmCtrSle:_ksyBgmView.loopType];
    _ksyBgmView.progressBar.dragingSliderCallback = ^(float progress) {
        [selfWeak.kit.bgmPlayer seekToProgress:progress];
    };
    // 滤镜相关参数改变
    _ksyFilterView.onSegCtrlBlock=^(id sender) {
        [selfWeak onFilterChange:sender];
    };
    _ksyFilterView.onBtnBlock=^(id sender) {
        [selfWeak onFilterBtn:sender];
    };
    _ksyFilterView.onSwitchBlock=^(id sender) {
        [selfWeak onFilterSwitch:sender];
    };
    // 混音相关参数改变
    _audioView.onSwitchBlock=^(id sender){
        [selfWeak onAMixerSwitch:sender];
    };
    _audioView.onSliderBlock=^(id sender){
        [selfWeak onAMixerSlider:sender];
    };
    _audioView.onSegCtrlBlock=^(id sender){
        [selfWeak onAMixerSegCtrl:sender];
    };
    // 其他杂项
    _miscView.onBtnBlock = ^(id sender) {
        [selfWeak onMiscBtns: sender];
    };
    _miscView.onSwitchBlock = ^(id sender) {
        [selfWeak onMiscSwitch: sender];
    };
    _miscView.onSliderBlock = ^(id sender) {
        [selfWeak onMiscSlider: sender];
    };
    _miscView.onSegCtrlBlock=^(id sender){
        [selfWeak onMisxSegCtrl:sender];
    };
    _colView.onBtnBlock=^(id sender){
        [selfWeak onColBtns:sender];
    };
    self.onNetworkChange = ^(NSString * msg){
        selfWeak.ctrlView.lblNetwork.text = msg;
    };
    [self layoutUI];
}

- (void) initObservers{
    _obsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                SEL_VALUE(onCaptureStateChange:) ,  KSYCaptureStateDidChangeNotification,
                SEL_VALUE(onStreamStateChange:) ,   KSYStreamStateDidChangeNotification,
                SEL_VALUE(onNetStateEvent:) ,       KSYNetStateEventNotification,
                SEL_VALUE(onBgmPlayerStateChange:) ,KSYAudioStateDidChangeNotification,
                nil];
#if  __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    _callObserver = [[CXCallObserver alloc] init];
    [_callObserver setDelegate:self queue:nil];
#endif
}

- (void) addObservers {
    [super addObservers];
    //KSYStreamer state changes
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    for (NSString* key in _obsDict) {
        SEL aSel = [[_obsDict objectForKey:key] pointerValue];
        [dc addObserver:self
               selector:aSel
                   name:key
                 object:nil];
    }
}

- (void) rmObservers {
    [super rmObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if  __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    _callObserver = nil;
#endif
}

- (void) layoutUI {
    // 适配预览区域为 16:9, 当设备为iPhoneX时,屏幕比例不是16:9, previewRect为上下填黑边后的区域.
    CGRect previewRect = [self calcPreviewRect:16.0/9.0];
    _bgView.frame = previewRect;
    if(_ctrlView){
        _ctrlView.frame = previewRect;
        [_ctrlView layoutUI];
    }
    if(_colView){
        _colView.frame = previewRect;
        [_colView layoutUI];
    }
    if (_decalBGView){
        _decalBGView.frame = previewRect;
        [self updateAePicView];
    }
}
- (NSString *) timeStr {
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"HH:mm:ss";
    }
    NSDate *now = [[NSDate alloc] init];
    return [_dateFormatter stringFromDate:now];
}
#pragma mark - logo setup
- (void) setupLogo{
    
    UIImage * logoImg = [UIImage imageNamed:@"ksvc"];
    _logoPicure   =  [[KSYGPUPicture alloc] initWithImage:logoImg];
    _kit.logoPic  = _logoPicure;
    _logoOrientation = logoImg.imageOrientation;
    [_kit setLogoOrientaion: _logoOrientation];
    _kit.logoAlpha= 0.5;
    _miscView.alphaSl.normalValue = _kit.logoAlpha;
    _kit.textLabel.numberOfLines = 2;
    _kit.textLabel.textAlignment = NSTextAlignmentCenter;
    NSString * timeStr = [self timeStr];
    _kit.textLabel.text = [NSString stringWithFormat:@"ksyun\n%@", timeStr];
    [_kit.textLabel sizeToFit];
    [_kit updateTextLabel];
    [self setupLogoRect];
}
- (void) setupLogoRect{
    CGFloat yPos = 0.05;
    // 预览视图的scale
    CGSize frameSz = _ctrlView.frame.size;
    CGFloat scale = MAX(frameSz.width, frameSz.height) / frameSz.height;
    CGFloat hgt  = 0.1 * scale; // logo图片的高度是预览画面的十分之一
    _kit.logoRect = CGRectMake(0.05, yPos, 0, hgt);
    yPos += hgt;
    _kit.textRect = CGRectMake(0.05, yPos, 0, 0.04 * scale); // 水印文字的高度为预览画面的 0.04倍
}

- (void) updateLogoText {
    UIApplicationState appState = [UIApplication sharedApplication].applicationState;
    if (appState != UIApplicationStateActive){
        return;
    } // 将当前时间显示在左上角
    NSString * timeStr = [self timeStr];
    _kit.textLabel.text = [NSString stringWithFormat:@"ksyun\n%@", timeStr];
    [_kit updateTextLabel];
}

- (void) setupAnimateLogo:(NSString*)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    [_dlLock lock];
    _animateDecoder = [YYImageDecoder decoderWithData:data scale: [[UIScreen mainScreen] scale]];
    [_kit setLogoOrientaion:UIImageOrientationUp];
    [_dlLock unlock];
    _animateIdx = 0;
    _dlTime = 0;
    if(!_displayLink){
        KSYWeakProxy *proxy = [KSYWeakProxy proxyWithTarget:self];
        SEL dpCB = @selector(displayLinkCallBack:);
        _displayLink = [CADisplayLink displayLinkWithTarget:proxy
                                                   selector:dpCB];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSRunLoopCommonModes];
    }
}

- (void) updateAnimateLogo {
    if (_animateDecoder==nil) {
        return;
    }
    [_dlLock lock];
    YYImageFrame* frame = [_animateDecoder frameAtIndex:_animateIdx
                                       decodeForDisplay:NO];
    if (frame.image) {
        _kit.logoPic = [[GPUImagePicture alloc] initWithImage:frame.image];
    }
    _animateIdx = (_animateIdx+1)%_animateDecoder.frameCount;
    [_dlLock unlock];
}

- (void)displayLinkCallBack:(CADisplayLink *)link {
    dispatch_async( dispatch_get_global_queue(0, 0), ^(){
        if (_animateDecoder) {
            _dlTime += link.duration;
            // 读取 图像的 duration 来决定下一帧的刷新时间
            // 也可以固定设置为一个值来调整动画的快慢程度
            NSTimeInterval delay = [_animateDecoder frameDurationAtIndex:_animateIdx];
            if (delay < 0.04) {
                delay = 0.04;
            }
            if (_dlTime < delay) return;
            _dlTime -= delay;
            [self updateAnimateLogo];
        }
    });
}
#pragma mark - Capture & stream setup
- (void) setCustomizeCfg {
    _kit.capPreset        = [self.presetCfgView capResolution];
    _kit.previewDimension = [self.presetCfgView capResolutionSize];
    _kit.streamDimension  = [self.presetCfgView strResolutionSize ];
    _kit.videoFPS         = [self.presetCfgView frameRate];
    _kit.streamerBase.videoCodec       = [_presetCfgView videoCodec];
    _kit.streamerBase.videoMaxBitrate  = [_presetCfgView videoKbps];
    _kit.streamerBase.audioCodec       = [_presetCfgView audioCodec];
    _kit.streamerBase.audiokBPS        = [_presetCfgView audioKbps];
    _kit.streamerBase.bwEstimateMode   = [_presetCfgView bwEstMode];
    _kit.streamerBase.bWithMessage     = [_presetCfgView withMessage];
    _kit.streamerBase.videoInitBitrate = _kit.streamerBase.videoMaxBitrate*6/10;//60%
    _kit.streamerBase.videoMinBitrate  = 0;
}

- (void) setCaptureCfg {
    _kit.cameraPosition = [self.presetCfgView cameraPos];
    _kit.gpuOutputPixelFormat = [self.presetCfgView gpuOutputPixelFmt];
    _kit.capturePixelFormat   = [self.presetCfgView gpuOutputPixelFmt];
    _kit.aCapDev.noiseSuppressionLevel = self.audioView.noiseSuppress;
    weakObj(self);
    _kit.videoProcessingCallback = ^(CMSampleBufferRef buf){
        selfWeak.ctrlView.lblStat.capFrames += 1; // 统计预览帧率(实际使用时不需要)
        // 在此处添加自定义图像处理, 直接修改buf中的图像数据会传递到观众端
        // 或复制图像数据之后再做其他处理, 则观众端仍然看到处理前的图像
    };
    _kit.audioProcessingCallback = ^(CMSampleBufferRef buf){
        // 在此处添加自定义音频处理, 直接修改buf中的pcm数据会传递到观众端
        // 或复制音频数据之后再做其他处理, 则观众端仍然听到原始声音
    };
    _kit.pcmProcessingCallback = ^(uint8_t** pData, int len, const AudioStreamBasicDescription* fmt, CMTime timeInfo){
        // 在此处添加自定义音频处理, 直接修改pcm数据会传递到观众端
        // 或复制音频数据之后再做其他处理, 则观众端仍然听到原始声音
    };
    _kit.interruptCallback = ^(BOOL bInterrupt){
        // 在此处添加自定义图像采集被打断的处理 (比如接听电话等)
    };
}

- (void) defaultStramCfg{
    // stream default settings
    _kit.streamerBase.videoCodec = KSYVideoCodec_AUTO;
    _kit.streamerBase.videoInitBitrate =  800;
    _kit.streamerBase.videoMaxBitrate  = 1000;
    _kit.streamerBase.videoMinBitrate  =    0;
    _kit.streamerBase.audiokBPS        =   48;
    // 设置编码的场景
    _kit.streamerBase.liveScene       = KSYLiveScene_Default;
    // 设置编码码率控制
    _kit.streamerBase.recScene        = KSYRecScene_ConstantQuality;
    // 视频编码性能档次 (硬编码建议用HighPerformance)
    if(_kit.streamerBase.videoCodec == KSYVideoCodec_AUTO ||
       _kit.streamerBase.videoCodec == KSYVideoCodec_VT264) {
        _kit.streamerBase.videoEncodePerf = KSYVideoEncodePer_HighPerformance;
    }
    else { // 软编码建议用 lowpower
        _kit.streamerBase.videoEncodePerf = KSYVideoEncodePer_LowPower;
    }
    _kit.streamerBase.logBlock = ^(NSString* str){
        NSLog(@"%@", str);
    };
    _hostURL = [NSURL URLWithString:@"rtmp://120.92.224.235/live/123"];
}
- (void) setStreamerCfg { // must set after capture
    if (_kit.streamerBase == nil) {
        return;
    }
    _bOutputInfo = YES;
    if (_presetCfgView){ // cfg from presetcfgview
        _kit.streamerBase.logBlock = ^(NSString* str){
            //NSLog(@"%@", str);
        };
        _hostURL = [NSURL URLWithString:[_presetCfgView hostUrl]];
    }
    else {
        [self defaultStramCfg];
    }
}

- (void) updateStreamCfg: (BOOL) bStart {
    _kit.streamerBase.liveScene       = self.miscView.liveScene;
    _kit.streamerBase.recScene        = self.miscView.recScene;
    _kit.streamerBase.videoEncodePerf = self.miscView.vEncPerf;
    
    _strSeconds = 0;
    self.miscView.liveSceneSeg.enabled = !bStart;
    self.miscView.recSceneSeg.enabled = !bStart;
    self.miscView.vEncPerfSeg.enabled = !bStart;
    self.audioView.stereoStream.enabled = !bStart;
    _miscView.swBypassRec.on = NO;
    _miscView.autoReconnect.slider.enabled = !bStart;
    _kit.maxAutoRetry = (int)_miscView.autoReconnect.slider.value;
    [self updateSwAudioOnly:bStart];
    
    //判断是直播还是录制
    NSString* title = _ctrlView.btnStream.currentTitle;
    _bRecord = [ title isEqualToString:@"开始录制"];
    _miscView.swBypassRec.enabled = !_bRecord; // 直接录制时, 不能旁路录制
    if (_bRecord && bStart){
        [self deleteFile:[_presetCfgView hostUrl]];
    }
}

// 启动推流 / 停止推流
- (void) updateSwAudioOnly : (BOOL) bStart {
    if (bStart) {
        if (self.audioView.swAudioOnly.on) {  // 开启了纯音频推流
            self.audioView.swAudioOnly.enabled = NO;
            self.audioView.lblAudioOnly.text =@"纯音频流";
            _kit.streamerBase.bWithVideo = NO;  // 关闭视频
        }
        else {
            self.audioView.swAudioOnly.enabled = YES;
            self.audioView.lblAudioOnly.text =@"冻结画面";
            _kit.streamerBase.bWithVideo = YES; //未启用纯音频推流 开启视频
        }
    }
    else {
        if ([self.audioView.lblAudioOnly.text isEqualToString:@"冻结画面"]) {
            self.audioView.swAudioOnly.on = NO;
        }
        self.audioView.lblAudioOnly.text = @"纯音频流";
        self.audioView.swAudioOnly.enabled = YES;
    }
}

#pragma mark -  state change
- (void) onCaptureStateChange:(NSNotification *)notification{
    NSLog(@"new capStat: %@", _kit.getCurCaptureStateName );
    if (_bOutputInfo){
        self.ctrlView.lblStat.text = [_kit getCurCaptureStateName];
    }
    if (_kit.captureState == KSYCaptureStateIdle) {
        self.ctrlView.btnCapture.backgroundColor = [UIColor darkGrayColor];
        self.audioView.audioDataTypeSeg.enabled = YES;
    }
    else if(_kit.captureState == KSYCaptureStateCapturing) {
        self.ctrlView.btnCapture.backgroundColor = [UIColor lightGrayColor];
        self.audioView.audioDataTypeSeg.enabled = NO;
    }
}

- (void) onNetStateEvent     :(NSNotification *)notification{
    //记录网络拥塞等事件所发生的次数
    switch (_kit.streamerBase.netStateCode) {
        case KSYNetStateCode_SEND_PACKET_SLOW: {
            _ctrlView.lblStat.notGoodCnt++;
            break;
        }
        case KSYNetStateCode_EST_BW_RAISE: {
            _ctrlView.lblStat.bwRaiseCnt++;
            break;
        }
        case KSYNetStateCode_EST_BW_DROP: {
            _ctrlView.lblStat.bwDropCnt++;
            break;
        }
        case KSYNetStateCode_VIDEO_FPS_RAISE: {
            _ctrlView.lblStat.fpsRaiseCnt++;
            break;
        }
        case KSYNetStateCode_VIDEO_FPS_DROP: {
            _ctrlView.lblStat.fpsDropCnt++;
            break;
        }
        default:break;
    }
}
- (void) onBgmPlayerStateChange  :(NSNotification *)notification{
    NSString * st = [_kit.bgmPlayer getCurBgmStateName];
    _ksyBgmView.bgmStatus = [st substringFromIndex:17];
    _ksyBgmView.pauseBtn.selected = NO;
    if (_kit.bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePlaying) {
        _ksyBgmView.progressBar.totalTimeInSeconds = _kit.bgmPlayer.bgmDuration;
    }
    else if (_kit.bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePaused) {
        _ksyBgmView.pauseBtn.selected = YES;
    }
}
- (void) onStreamStateChange :(NSNotification *)notification{
    if (_kit.streamerBase){
        NSLog(@"stream State %@", [_kit.streamerBase getCurStreamStateName]);
    }
    if (_bOutputInfo){
        _ctrlView.lblStat.text = [_kit.streamerBase getCurStreamStateName];
    }
    if(_kit.streamerBase.streamState == KSYStreamStateError) {
        [self onStreamError:_kit.streamerBase.streamErrorCode];
    }
    else if (_kit.streamerBase.streamState == KSYStreamStateConnecting) {
        [_ctrlView.lblStat initStreamStat]; // 尝试开始连接时,重置统计数据
        [self updateSwAudioOnly:YES];
    }
    else if (_kit.streamerBase.streamState == KSYStreamStateConnected) {
        [self updateSwAudioOnly:YES];
        self.ctrlView.btnStream.backgroundColor = [UIColor lightGrayColor];
    }
    else if (_kit.streamerBase.streamState == KSYStreamStateIdle) {
        [self updateSwAudioOnly:NO];
        self.ctrlView.btnStream.backgroundColor = [UIColor darkGrayColor];
    }
    //状态为KSYStreamStateIdle且_bRecord为ture时，录制视频
    if (_kit.streamerBase.streamState == KSYStreamStateIdle && _bRecord){
        [self saveVideoToAlbum:[_presetCfgView hostUrl]];
    }
}

- (void) onStreamError:(KSYStreamErrorCode) errCode{
    if (_bOutputInfo){
        _ctrlView.lblStat.text  = [_kit.streamerBase getCurKSYStreamErrorCodeName];
    }
    if (errCode == KSYStreamErrorCode_CONNECT_BREAK) {
        // Reconnect
        [self tryReconnect];
    }
    else if (errCode == KSYStreamErrorCode_AV_SYNC_ERROR) {
        NSLog(@"audio video is not synced, please check timestamp");
        [self tryReconnect];
    }
    else if (errCode == KSYStreamErrorCode_CODEC_OPEN_FAILED) {
        NSLog(@"video codec open failed, try software codec");
        _kit.streamerBase.videoCodec = KSYVideoCodec_X264;
        [self tryReconnect];
    }
}
- (void) tryReconnect {
    if (_kit.maxAutoRetry > 0){ // retry by kit
        return;
    }
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        NSLog(@"try again");
        [self updateStreamCfg:YES];
        [_kit.streamerBase startStream:self.hostURL];
    });
}

- (void) onBypassRecordStateChange: (KSYRecordState) newState {
    if (newState == KSYRecordStateRecording){
        NSLog(@"start bypass record");
    }
    else if (newState == KSYRecordStateStopped) {
        NSLog(@"stop bypass record");
        [self saveVideoToAlbum:_bypassRecFile];
        _miscView.swBypassRec.on = NO;
    }
    else if (newState == KSYRecordStateError) {
        NSLog(@"bypass record error %@", _kit.streamerBase.bypassRecordErrorName);
    }
}
#pragma mark - timer respond per second
- (void)onTimer:(NSTimer *)theTimer{
    if (_kit.streamerBase.streamState == KSYStreamStateConnected && _bOutputInfo) {
        [_ctrlView.lblStat updateState: _kit.streamerBase];
    }
    if (_kit.bgmPlayer && _kit.bgmPlayer.bgmPlayerState ==KSYBgmPlayerStatePlaying ) {
        _ksyBgmView.progressBar.playProgress = _kit.bgmPlayer.bgmProcess;
    }
    _strSeconds++;
    [self updateLogoText];
    [self updateRecLabel];  // 本地录制:直接存储到本地, 不推流
    [self updateBypassRecLable];//// 旁路录制:一边推流一边录像
}

#pragma mark - UI respond
//ctrView control (for basic ctrl)
- (void) onBasicCtrl: (id) btn {
    if (btn == _ctrlView.btnFlash){
        [self onFlash];
    }
    else if (btn == _ctrlView.btnCameraToggle){
        [self onCameraToggle];
    }
    else if (btn == _ctrlView.btnQuit){
        [self onQuit];
    }
    else if(btn == _ctrlView.btnCapture){
        [self onCapture];
    }
    else if(btn == _ctrlView.btnStream){
        [self onStream];
    }
    else { // other btns
        [self onMenuBtnPress:btn];
    }
}

//menuView control
- (void)onMenuBtnPress:(UIButton *)btn{
    KSYUIView * view = nil;
    if (btn == _ctrlView.menuBtns[0] ){
        view = _ksyBgmView; // 背景音乐播放相关
    }
    else if (btn == _ctrlView.menuBtns[1] ){
        view = _ksyFilterView; // 美颜滤镜相关
    }
    else if (btn == _ctrlView.menuBtns[2] ){
        view = _audioView;    // 混音控制台
        _audioView.micType = [[AVAudioSession sharedInstance] currentMicType];
        [_audioView initMicInput];
    }
    else if(btn == _ctrlView.menuBtns[3]){
        [self onMessage];
    }
    else if (btn == _ctrlView.menuBtns[4] ){
        view = _miscView;
    }
    // 将菜单的按钮隐藏, 将触发二级菜单的view显示
    if (view){
        [_ctrlView showSubMenuView:view];
    }
}

- (void)swipeController:(UISwipeGestureRecognizer *)swipGestRec{
    if (_ctrlView.hidden == YES){
        return;
    }
    if (swipGestRec == _swipeGest){
        CGRect rect = _bgView.frame;
        _ctrlView.lblStat.hideText = NO;
        if ( CGRectEqualToRect(rect, _ctrlView.frame)){
            rect.origin.x = self.view.frame.size.width; // hide
            _ctrlView.lblStat.hideText = YES;
        }
        weakObj(self);
        [UIView animateWithDuration:0.1 animations:^{
            selfWeak.ctrlView.frame = rect;
        }];
    }
}
#pragma mark - subviews: bgmview
- (void)onBgmCtrSle:(UISegmentedControl*)sender {
    if ( sender == _ksyBgmView.loopType){
        weakObj(self);
        if ( sender.selectedSegmentIndex == 0) { //单曲播放
            _kit.bgmPlayer.bgmFinishBlock = ^{};
        }
        else { // loop to next
            _kit.bgmPlayer.bgmFinishBlock = ^{
                [selfWeak.ksyBgmView loopNextBgmPath];
                [selfWeak onBgmPlay];
            };
        }
    }
}
//bgmView Control
- (void)onBgmBtnPress:(UIButton *)btn{
    @WeakObj(self);
    if (btn == _ksyBgmView.playBtn){
        [self onBgmPlay];
    }
    else if (btn ==  _ksyBgmView.pauseBtn){
        if (_kit.bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePlaying) {
            [_kit.bgmPlayer pauseBgm];
        }
        else if (_kit.bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePaused){
            [_kit.bgmPlayer resumeBgm];
        }
    }
    else if (btn == _ksyBgmView.stopBtn){
        [_kit.bgmPlayer stopPlayBgm];
    }
    else if (btn == _ksyBgmView.nextBtn){
        [self.ksyBgmView nextBgmPath];
        [_kit.bgmPlayer stopPlayBgm:^() {
            [selfWeak onBgmPlay];
        }];
    }
    else if (btn == _ksyBgmView.previousBtn) {
        [self.ksyBgmView previousBgmPath];
        [_kit.bgmPlayer stopPlayBgm:^() {
            [selfWeak onBgmPlay];
        }];
    }
    else if (btn == _ksyBgmView.muteBtn){
        // 仅仅是静音了本地播放, 推流中仍然有音乐
        _kit.bgmPlayer.bMuteBgmPlay = !_kit.bgmPlayer.bMuteBgmPlay;
    }
}

- (void) onBgmPlay{
    NSString* path = _ksyBgmView.bgmPath;
    if (!path) {
        [_kit.bgmPlayer stopPlayBgm];
        return;
    }
    [_kit.bgmPlayer startPlayBgm:path isLoop:NO];
}
// 背景音乐音量调节
- (void)onBgmSlider:(id )sl{
    if (sl == _ksyBgmView.volumSl){
        // 仅仅修改播放音量, 观众音量请调节mixer的音量
        _kit.bgmPlayer.bgmVolume = _ksyBgmView.volumSl.normalValue;
    }
    else if (sl == _ksyBgmView.pitchSl){
        // 同时修改本地和观众端的 音调 (推荐变调的取值范围为 -3 到 3的整数)
        _kit.bgmPlayer.bgmPitch = _ksyBgmView.pitchSl.value;
    }
}

#pragma mark - subviews: basic ctrl
- (void) onFlash {
    [_kit toggleTorch];
}
- (void) onCameraToggle{ // see kit or block
    [_kit switchCamera];
    if (_kit.vCapDev && _kit.vCapDev.cameraPosition == AVCaptureDevicePositionBack) {
        [_ctrlView.btnFlash setEnabled:YES];
    }
    else{
        [_ctrlView.btnFlash setEnabled:NO];
    }
}
- (void) onCapture{
    if (!_kit.vCapDev.isRunning){
        _kit.audioDataType = self.audioView.audioDataType;
        _kit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        // 重新开启预览是需要重新根据方向setupLogo
        [self setupLogo];
        [_kit startPreview:_bgView];
    }
    else {
        [_kit stopPreview];
    }
}
- (void) onStream{
    if (_kit.streamerBase.streamState == KSYStreamStateIdle ||
        _kit.streamerBase.streamState == KSYStreamStateError) {
        [self updateStreamCfg:YES];
        [_kit.streamerBase startStream:self.hostURL];
    }
    else {
        [self updateStreamCfg:NO];
        [_kit.streamerBase stopStream];
    }
}

- (void) onQuit{
    [_kit stopPreview];
    _kit = nil;
    [self rmObservers];
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

-(void) onMessage{
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    NSString * timeStr = [self timeStr];
    [message setObject:@"user" forKey:@"type"];
    [message setObject:@"test" forKey:@"event"];
    [message setObject:timeStr forKey:@"time"];
    [_kit processMessageData:message];
}

#pragma mark - UI respond : gpu filters
- (void) onFilterChange:(id)sender{
    // use a new filter
    [_kit setupFilter:self.ksyFilterView.curFilter];
}
- (void) onFilterBtn:(id)sender{
}
- (void) onFilterSwitch:(id)sender{
    UISwitch* sw = sender;
    if (sw == self.ksyFilterView.swPrevewFlip){
        [_kit setPreviewMirrored:sw.on];
    }
    else if (sw == self.ksyFilterView.swStreamFlip){
        [_kit setStreamerMirrored:sw.on];
    }
}
#pragma mark - UI respond : audio ctrl
- (void)onAMixerSwitch:(UISwitch *)sw{
    if (sw == _audioView.muteStream){
        // 静音推流(发送音量为0的数据)
        BOOL mute = _audioView.muteStream.isOn;
        [_kit.streamerBase muteStream:mute];
    }
    else if (sw == _audioView.bgmMix){
        // 背景音乐 是否 参与混音
        [_kit.aMixer setTrack:_kit.bgmTrack enable: sw.isOn];
    }
    else if (sw == _audioView.swAudioOnly && _kit.streamerBase) {
        if (_kit.streamerBase.isStreaming) {
            _kit.streamerFreezed = sw.on;
        }
    }
    else if (sw == _audioView.stereoStream ){
        _kit.bStereoAudioStream = sw.on;
    }
    else if (sw == _audioView.swPlayCapture){
        if ( ![KSYAUAudioCapture isHeadsetPluggedIn] ) {
            [KSYUIVC toast:@"没有耳机, 开启耳返会有刺耳的声音" time:0.3];
            sw.on = NO;
            _kit.aCapDev.bPlayCapturedAudio = NO;
            return;
        }
        _kit.aCapDev.bPlayCapturedAudio = sw.isOn;
    }
    else if (sw == _audioView.swReverbEffect){
        if (_audioView.audioEffect != KSYAudioEffectType_COUSTOM){
            [KSYUIVC toast:@"切换至自定义模式，才可开启" time:0.3];
            sw.on = NO;
            return;
        }
        if (sw.on){
            _kit.aCapDev.effectTypeFlag |= KSYAUReverb_FLAG;
        }
        else{
            _kit.aCapDev.effectTypeFlag &= (~KSYAUReverb_FLAG);
        }
    }
    else if (sw == _audioView.swDelayEffect){
        if (_audioView.audioEffect != KSYAudioEffectType_COUSTOM){
            [KSYUIVC toast:@"切换至自定义模式，才可开启" time:0.3];
            sw.on = NO;
            return;
        }
        if (sw.on){
            _kit.aCapDev.effectTypeFlag |= KSYAUDelay_FLAG;
        }
        else{
            _kit.aCapDev.effectTypeFlag &= (~KSYAUDelay_FLAG);
        }
    }
    else if (sw == _audioView.swPitchEffect){
        if (_audioView.audioEffect != KSYAudioEffectType_COUSTOM){
            [KSYUIVC toast:@"切换至自定义模式，才可开启" time:0.3];
            sw.on = NO;
            return;
        }
        if (sw.on){
            _kit.aCapDev.effectTypeFlag |= KSYAUPitchshift_FLAG;
        }
        else{
            _kit.aCapDev.effectTypeFlag &= (~KSYAUPitchshift_FLAG);
        }
    }
}
- (void)onAMixerSegCtrl:(UISegmentedControl *)seg{
    if (_kit && seg == _audioView.micInput) {
        [AVAudioSession sharedInstance].currentMicType = _audioView.micType;
    }
    else if (seg == _audioView.reverbType){
        int t = (int)seg.selectedSegmentIndex;
        _kit.aCapDev.reverbType = t;
        return;
    }
    else if (seg == _audioView.effectType) {
        _audioView.swReverbEffect.on = NO;
        _audioView.swDelayEffect.on = NO;
        _audioView.swPitchEffect.on = NO;
        _kit.aCapDev.effectType = _audioView.audioEffect;
        return;
    }
    else if (seg == _audioView.noiseSuppressSeg) {
        _kit.aCapDev.noiseSuppressionLevel = _audioView.noiseSuppress;
        return;
    }
}

- (void)onAMixerSlider:(KSYNameSlider *)slider{
    float val = 0.0;
    if ([slider isKindOfClass:[KSYNameSlider class]]) {
        val = slider.normalValue;
    }
    else {
        return;
    }
    if ( slider == self.audioView.bgmVol){
        [_kit.aMixer setMixVolume:val of: _kit.bgmTrack];
    }
    else if ( slider == self.audioView.micVol){
        [_kit.aMixer setMixVolume:val of: _kit.micTrack];
    }
    else if (slider == self.audioView.playCapVol){
        if (_kit.aCapDev){
            _kit.aCapDev.micVolume = slider.normalValue;
        }
    }
    else if (slider == self.audioView.reverbEffectParamsVaule){
        if (_kit.aCapDev && self.audioView.swReverbEffect.isOn){
            [_kit.aCapDev setReverbParamID:kReverb2Param_DryWetMix withInValue:slider.value];
        }
    }
    else if (slider == self.audioView.delayEffectParamsVaule){
        if (_kit.aCapDev && self.audioView.swDelayEffect.isOn){
            [_kit.aCapDev setDelayParamID:kDelayParam_WetDryMix withInValue:slider.value];
        }
    }
    else if (slider == self.audioView.pitchEffectParamsVaule){
        if (_kit.aCapDev && self.audioView.swPitchEffect.isOn){
            [_kit.aCapDev setPitchParamID:kNewTimePitchParam_Pitch withInValue:slider.value];
        }
    }
}

#pragma mark - misc features
- (void)onMiscBtns:(id)sender {
    // 截图的三种方法:
    if (sender == _miscView.btn0){
        // 方法1: 开始预览后, 从streamer 直接将待编码的图片存为本地的文件
        NSString* path =@"snapshot/c.jpg";
        [_kit.streamerBase takePhotoWithQuality:1 fileName:path];
        NSLog(@"Snapshot save to %@", path);
    }
    else if (sender == _miscView.btn1){
        // 方法2: 开始预览后, 从streamer获取UIImage对象
        [_kit.streamerBase getSnapshotWithCompletion:^(UIImage * img){
            [KSYUIVC saveImage: img
                            to: @"snap1.png" ];
            UIImageWriteToSavedPhotosAlbum(img,nil,nil,nil);
        }];
    }
    else if (sender == _miscView.btn2) {
        // 方法3: 如果有美颜滤镜, 可以从滤镜上获取截图(UIImage) 不带水印
        //GPUImageOutput * filter = self.ksyFilterView.curFilter;
        // 方法4: 直接从预览mixer上获取截图(UIImage) 带水印
        GPUImageOutput * filter = _kit.vPreviewMixer;
        if (filter){
            [filter useNextFrameForImageCapture];
            UIImage * img =  filter.imageFromCurrentFramebuffer;
            [KSYUIVC saveImage: img
                            to: @"snap2.png" ];
            UIImageWriteToSavedPhotosAlbum(img,nil,nil,nil);
        }
    }
    else if (sender == _miscView.btn3) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else if (sender == _miscView.btn4) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else if (sender == _miscView.btn5) {
        _kit.logoPic = nil;
    }
    else if (sender == _miscView.btnAnimate) {
        if (_miscView.btnAnimate.selected) {
            [self setupAnimateLogo:_miscView.animatePath];
        }
        else {
            [_dlLock lock];
            _animateDecoder = nil;
            _kit.logoPic = _logoPicure;
            [_kit setLogoOrientaion:_logoOrientation];
            [_dlLock unlock];
        }
    }
    else if (sender == _miscView.btnNext) {
        if (_miscView.btnAnimate.selected) {
            [self setupAnimateLogo:_miscView.animatePath];
        }
        else {
            _animateDecoder = nil;
        }
    }
    //弹出拉流地址及二维码
    else if(sender == _miscView.buttonPlayUrlAndQR){
        KSYQRCode *playUrlQRCodeVc = [[KSYQRCode alloc] init];
        if (_bRecord) {
            //状态为录制视频
            playUrlQRCodeVc.url = [_presetCfgView.hostUrlUI.text lastPathComponent];
        }else{
            //状态为直播视频
            //推流地址对应的拉流地址
            NSString * uuidStr =[[[UIDevice currentDevice] identifierForVendor] UUIDString];
            NSString *devCode  = [[uuidStr substringToIndex:3] lowercaseString];
            NSString *streamPlaySrv = @"http://mobile.kscvbu.cn:8080/live";
            NSString *streamPlayPostfix = @".flv";
            playUrlQRCodeVc.url = [ NSString stringWithFormat:@"%@/%@%@", streamPlaySrv, devCode,streamPlayPostfix];
        }
        [self presentViewController:playUrlQRCodeVc animated:YES completion:nil];
    }
    else if(sender == _miscView.buttonAe){
        _ctrlView.hidden = YES;
        _colView.hidden = NO;
        if(_decalBGView){
            [_decalBGView removeFromSuperview];
            [self.colView addSubview:_decalBGView];
            [self.colView sendSubviewToBack:_decalBGView];
            _decalBGView.interactionEnabled = YES;
        }
    }
}

- (void)onMiscSwitch:(UISwitch *)sw{
    if (sw == _miscView.swBypassRec) {
        [self onBypassRecord];
    }
}

- (void)onMiscSlider:(KSYNameSlider *)slider {
    if (slider == _miscView.alphaSl){
        NSInteger layerIdx = _miscView.layerSeg.selectedSegmentIndex;
        NSString * title = [_miscView.layerSeg titleForSegmentAtIndex:layerIdx];
        float flt = slider.normalValue;
        if ([ title isEqualToString:@"logo"]){
            _kit.logoAlpha = flt;
        }
        else {
            _kit.textLabel.alpha = flt;
            [_kit updateTextLabel];
        }
    }
}
- (void)onMisxSegCtrl:(UISegmentedControl *)seg {
    if (seg == _miscView.layerSeg) {
        NSInteger layerIdx = _miscView.layerSeg.selectedSegmentIndex;
        NSString * title = [_miscView.layerSeg titleForSegmentAtIndex:layerIdx];
        if ([ title isEqualToString:@"logo"]){
            _miscView.alphaSl.normalValue = [_kit logoAlpha];
        }
        else {
            _miscView.alphaSl.normalValue =_kit.textLabel.alpha;
        }
    }
}
- (void)onColBtns:(id)sender {
    if (sender == _colView.btn0){
        _colView.hidden = YES;
        _ctrlView.hidden = NO;
        if(_decalBGView){
            [_decalBGView removeFromSuperview];
            [self.view insertSubview:_decalBGView belowSubview:_ctrlView];
            _decalBGView.interactionEnabled = NO;
        }
        [self updateAePicView];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods
-(void)imagePickerController:(UIImagePickerController *)picker
       didFinishPickingImage:(UIImage *)image
                 editingInfo:(NSDictionary *)editingInfo {
    _logoPicure = [[KSYGPUPicture alloc] initWithImage:image andOutputSize:image.size];
    _kit.logoPic = _logoPicure;
    _logoOrientation = image.imageOrientation;
    [_kit setLogoOrientaion: _logoOrientation];
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self restartVideoCapSession];
    }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self restartVideoCapSession];
    }
}
- (void) restartVideoCapSession {
#if TARGET_OS_IPHONE
    if(NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_8_4 &&
       _kit.vCapDev.captureSession ) {
        [_kit.vCapDev.captureSession stopRunning];
        [_kit.vCapDev.captureSession startRunning];
    }
#endif
}

#pragma mark - bypass record & record
-(void) onBypassRecord {
    BOOL bRec = _kit.streamerBase.bypassRecordState == KSYRecordStateRecording;
    if (_miscView.swBypassRec.on){
        if ( _kit.streamerBase.isStreaming && !bRec){
            // 如果启动录像时使用和上次相同的路径,则会覆盖掉上一次录像的文件内容
            [self deleteFile:_bypassRecFile];
            NSURL *url =[[NSURL alloc] initFileURLWithPath:_bypassRecFile];
            [_kit.streamerBase startBypassRecord:url];
        }
        else {
            NSString * msg = @"推流过程中才能旁路录像";
            [KSYUIVC toast:msg time:1];
            _miscView.swBypassRec.on = NO;
        }
    }
    else if (bRec){
        [_kit.streamerBase stopBypassRecord];
    }
}
-(void) updateBypassRecLable {
    if (!_miscView.swBypassRec.on){
        return;
    }
    double dur = _kit.streamerBase.bypassRecordDuration;
    NSString* durStr=[NSString stringWithFormat:@"%3.0fs/%ds", dur,REC_MAX_TIME];
    _miscView.lblRecDur.text = durStr;
    if (dur > REC_MAX_TIME) { // 为防止将手机存储写满,限制旁路录像时长为30s
        _miscView.swBypassRec.on = NO;
        [_kit.streamerBase stopBypassRecord];
    }
}

- (void) updateRecLabel {
    if (!_bRecord){ // 直接录制短视频
        return;
    }
    int diff = REC_MAX_TIME - _strSeconds;
    //保持连接和限制短视频长度
    if (_kit.streamerBase.isStreaming && diff < 0){
        [self onStream];//结束录制
    }
    if (_kit.streamerBase.isStreaming){//录制时的倒计时时间
        NSString *durMsg = [NSString stringWithFormat:@"%ds\n",diff];
        _ctrlView.lblNetwork.text = durMsg;
    }
    else{
        _ctrlView.lblNetwork.text = @"";
    }
}


//保存视频到相簿
- (void) saveVideoToAlbum: (NSString*) path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
            SEL onDone = @selector(video:didFinishSavingWithError:contextInfo:);
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, onDone, nil);
        }
    });
}
//保存mp4文件完成时的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    NSString *message;
    if (!error) {
        message = @"Save album success!";
    }
    else {
        message = @"Failed to save the album!";
    }
    [KSYUIVC toast:message time:3];
}
//删除文件,保证保存到相册里面的视频时间是最新的
-(void)deleteFile:(NSString *)file{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:file]) {
        [fileManager removeItemAtPath:file error:nil];
    }
}
#pragma mark - foucs
/**
 @abstract 将UI的坐标转换成相机坐标
 */
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGSize frameSize = self.view.frame.size;
    CGSize apertureSize = [_kit captureDimension];
    CGPoint point = viewCoordinates;
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    CGFloat xc = .5f;
    CGFloat yc = .5f;
    
    if (viewRatio > apertureRatio) {
        CGFloat y2 = frameSize.height;
        CGFloat x2 = frameSize.height * apertureRatio;
        CGFloat x1 = frameSize.width;
        CGFloat blackBar = (x1 - x2) / 2;
        if (point.x >= blackBar && point.x <= blackBar + x2) {
            xc = point.y / y2;
            yc = 1.f - ((point.x - blackBar) / x2);
        }
    }else {
        CGFloat y2 = frameSize.width / apertureRatio;
        CGFloat y1 = frameSize.height;
        CGFloat x2 = frameSize.width;
        CGFloat blackBar = (y1 - y2) / 2;
        if (point.y >= blackBar && point.y <= blackBar + y2) {
            xc = ((point.y - blackBar) / y2);
            yc = 1.f - (point.x / x2);
        }
    }
    return CGPointMake(xc, yc);
}

//设置摄像头对焦位置
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint current = [touch locationInView:self.view];
    CGPoint point = [self convertToPointOfInterestFromViewCoordinates:current];
    if (_ctrlView.hidden == YES){
        return;
    }
    [_kit exposureAtPoint:point];
    [_kit focusAtPoint:point];
    _foucsCursor.center = current;
    _foucsCursor.transform = CGAffineTransformMakeScale(1.5, 1.5);
    _foucsCursor.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        _foucsCursor.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        _foucsCursor.alpha=0;
    }];
}

//添加缩放手势，缩放时镜头放大或缩小
- (void)addPinchGestureRecognizer{
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchDetected:)];
    [self.view addGestureRecognizer:pinch];
}

- (void)pinchDetected:(UIPinchGestureRecognizer *)recognizer{
    if (_ctrlView.hidden == YES){
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _currentPinchZoomFactor = _kit.pinchZoomFactor;
    }
    CGFloat zoomFactor = _currentPinchZoomFactor * recognizer.scale;//当前触摸缩放因子*坐标比例
    [_kit setPinchZoomFactor:zoomFactor];
}

#if  __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#pragma mark - CXCallObserverDelegate method
- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    //处理来电事件
    NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
    BOOL needSendMsg = YES;
    
    [message setObject:@"system" forKey:@"type"];
    [message setObject:@"call" forKey:@"event"];
    
    if (call.hasEnded){
        [message setObject:@"disconnected" forKey:@"status"];
    } else if (call.hasConnected){
        [message setObject:@"connected" forKey:@"status"];
    } else if (call.outgoing) {
        [message setObject:@"dialing" forKey:@"status"];
    } else if (call.isOnHold) {
        //TODO
        needSendMsg = NO;
    } else {
        [message setObject:@"incoming" forKey:@"status"];
    }
    
    if(needSendMsg == YES)
        [_kit processMessageData:message];
}
#endif

#pragma mark - Decal 相关
- (void)genDecalViewWithImgName:(NSString *)imgName{
    [_decalBGView genDecalViewWithImgName:imgName];
}

//刷新贴纸view
- (void) updateAePicView{
    if (_decalBGView){
        _kit.aePic = [[GPUImageUIElement alloc] initWithView:_decalBGView];
    }
}
@end
