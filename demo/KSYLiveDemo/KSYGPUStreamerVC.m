//
//  ViewController.m
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 ksyun. All rights reserved.
//

#import "KSYGPUStreamerVC.h"
#import <GPUImage/GPUImage.h>
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/libksygpuimage.h>


@interface KSYGPUStreamerVC () {
    UIButton *_btnMusicPlay;
    UIButton *_btnMusicPause;
    UIButton *_btnMusicMix;
    UIButton *_btnMute;

    UISlider *_bgmVolS;
    UISlider *_micVolS;
    // chose filters
    UIButton *_btnFilters[4];
    
    int       _iReverb; // Reverb level

    UIButton *_btnPreview;
    UIButton *_btnTStream;
    UIButton *_btnCamera;
    UIButton *_btnFlash;
    UISwitch *_btnAutoBw;
    UILabel  *_lblAutoBW;
    UIButton *_btnQuit;
    UISwitch *_btnAutoReconnect;
    UILabel  *_lblAutoReconnect;

    UIButton *_startReverb;
    UIButton *_stopReverb;

    UISwitch *_btnHighRes;
    UILabel  *_lblHighRes;
    // status monitor
    double    _lastSecond;
    int       _lastByte;
    int       _lastFrames;
    int       _lastDroppedF;
    int       _netEventCnt;
    NSString *_netEventRaiseDrop;
    int       _netTimeOut;
    int       _raiseCnt;
    int       _dropCnt;
    double    _startTime;
}
@property KSYGPUStreamer * gpuStreamer;
@property KSYGPUCamera * capDev;
@property GPUImageFilter     * filter;
@property GPUImageCropFilter * cropfilter;
@property GPUImageFilter * scalefilter;
@property GPUImageView   * preview;

@property NSTimer *timer;

@end

@implementation KSYGPUStreamerVC

-(KSYStreamerBase *)getStreamer {
    return _gpuStreamer.streamerBase;
}

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI ];
    [self setStreamerCfg];
    [self addObservers ];
    NSLog(@"version: %@", [_gpuStreamer.streamerBase getKSYVersion]);
}
- (void) addObservers {
    // statistics update every seconds
    _timer =  [NSTimer scheduledTimerWithTimeInterval:1.2
                                               target:self
                                             selector:@selector(updateStat:)
                                             userInfo:nil
                                              repeats:YES];
    //KSYStreamer state changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onStreamStateChange:)
                                                 name:KSYStreamStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNetStateEvent:)
                                                 name:KSYNetStateEventNotification
                                               object:nil];
}

- (void) rmObservers {
    [_timer invalidate];
    _timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KSYStreamStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KSYNetStateEventNotification
                                                  object:nil];
}
- (void)viewDidAppear:(BOOL)animated {
    if ( _btnAutoBw != nil ) {
        [self layoutUI];
    }
    if (_bAutoStart) {
        [self onPreview:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self onStream:nil];
        });
    }
}

- (BOOL)shouldAutorotate {
    [self layoutUI];
    return !(_capDev && _capDev.isRunning);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - add UIs to view
- (UIButton *)addButton:(NSString*)title
                 action:(SEL)action {
    UIButton * button;
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle: title forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}

- (UILabel *)addLable:(NSString*)title{
    UILabel *  lbl = [[UILabel alloc] init];
    lbl.text = title;
    [self.view addSubview:lbl];
    return lbl;
}
- (UISwitch *)addSwitch:(BOOL) on{
    UISwitch *sw = [[UISwitch alloc] init];
    [self.view addSubview:sw];
    sw.on = on;
    return sw;
}

- (UISlider *)addSliderFrom: (float) minV
                         To: (float) maxV{
    UISlider *sl = [[UISlider alloc] init];
    [self.view addSubview:sl];
    sl.minimumValue = minV;
    sl.maximumValue = maxV;
    sl.value = 0.5;
    [ sl addTarget:self action:@selector(onVolChanged:) forControlEvents:UIControlEventValueChanged ];
    return sl;
}

- (void) initUI {
    // add prevew at bottom
    _preview    = [[GPUImageView alloc] init];
    [_preview setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
    [self.view addSubview:_preview];
    
    _btnPreview = [self addButton:@"开始预览"  action:@selector(onPreview:)];
    _btnTStream = [self addButton:@"开始推流"  action:@selector(onStream:)];
    _btnFlash   = [self addButton:@"闪光灯"    action:@selector(onFlash:)];
    _btnCamera  = [self addButton:@"前后摄像头" action:@selector(onCamera:)];
    _btnQuit    = [self addButton:@"退出"      action:@selector(onQuit:)];
    _btnFilters[0] = [self addButton:@"原始美白" action:@selector(OnChoseFilter:)];
    _btnFilters[1] = [self addButton:@"美颜" action:@selector(OnChoseFilter:)];
    _btnFilters[2] = [self addButton:@"白皙" action:@selector(OnChoseFilter:)];
    _btnFilters[3] = [self addButton:@"美白x+" action:@selector(OnChoseFilter:)];
    
    _startReverb =[self addButton:@"开始混响" action:@selector(onReverbStart:)];
    NSString * SReverb = [NSString stringWithFormat:@"开始混响%d",_iReverb];
    [_startReverb setTitle:SReverb  forState: UIControlStateNormal];
    _stopReverb = [self addButton:@"停止混响" action:@selector(onReverbStop:)];
    _iReverb    = 1;

    _btnMusicPlay  = [self addButton:@"播放"  action:@selector(onMusicPlay:)];
    _btnMusicPause = [self addButton:@"暂停"  action:@selector(onMusicPause:)];
    _btnMusicMix   = [self addButton:@"混音"  action:@selector(onMusicMix:)];
    
    _bgmVolS     = [self addSliderFrom:0.0 To:1.0];
    _micVolS     = [self addSliderFrom:0.0 To:1.0];
    _micVolS.value = 1.0;
    _btnMute    = [self addButton:@"静音"   action:@selector(onStreamMute:)];
    

    _lblAutoBW = [self addLable:@"自动调码率"];
    _btnAutoBw = [self addSwitch:YES];

    _lblAutoReconnect = [self addLable:@"自动重连"];
    _btnAutoReconnect = [self addSwitch:NO];

    _lblHighRes =[self addLable:@"360p/540p"];
    _btnHighRes =[self addSwitch:YES];

    _stat = [self addLable:@""];
    _stat.backgroundColor = [UIColor clearColor];
    _stat.textColor = [UIColor redColor];
    _stat.numberOfLines = 6;
    _stat.textAlignment = NSTextAlignmentLeft;

    self.view.backgroundColor = [UIColor whiteColor];
    _netEventRaiseDrop = @"";
    [self layoutUI];
}

- (void) layoutUI {
    CGFloat wdt = self.view.bounds.size.width;
    CGFloat hgt = self.view.bounds.size.height;
    CGFloat gap = 4;
    CGFloat btnWdt = 100;
    CGFloat btnHgt = 40;
    CGFloat yPos = hgt - btnHgt - gap;
    CGFloat xLeft   = gap;
    CGFloat xMiddle = (wdt - btnWdt*3 - gap*2) /2 + gap + btnWdt;
    CGFloat xRight  = wdt - btnWdt - gap;
    // full screen
    _preview.frame = self.view.bounds;
    
    // bottom left
    _btnPreview.frame = CGRectMake(xLeft,   yPos, btnWdt, btnHgt);
    _btnTStream.frame = CGRectMake(xRight, yPos, btnWdt, btnHgt);
    
    // top left
    yPos = 20+gap*3;
    _btnFlash.frame  = CGRectMake(xLeft,   yPos, btnWdt, btnHgt);
    _btnCamera.frame = CGRectMake(xMiddle, yPos, btnWdt, btnHgt);
    _btnQuit.frame   = CGRectMake(xRight,  yPos, btnWdt, btnHgt);

    // top row 2 left
    yPos += (gap + btnHgt);
    _lblAutoBW.frame        = CGRectMake(xLeft,   yPos, btnWdt, btnHgt);
    _lblHighRes.frame       = CGRectMake(xMiddle, yPos, btnWdt, btnHgt);
    _lblAutoReconnect.frame = CGRectMake(xRight,  yPos, btnWdt, btnHgt);
    
    // top row 3 left
    yPos += (btnHgt);
    _btnAutoBw.frame        = CGRectMake(xLeft,   yPos, btnWdt, btnHgt);
    _btnHighRes.frame       = CGRectMake(xMiddle, yPos, btnWdt, btnHgt);
    _btnAutoReconnect.frame = CGRectMake(xRight,  yPos, btnWdt, btnHgt);
    
    // top row 4 left
    yPos += (btnHgt);
    _btnMusicPlay.frame   = CGRectMake(xLeft,   yPos, btnWdt, btnHgt);
    _btnMusicPause.frame  = CGRectMake(xMiddle, yPos, btnWdt, btnHgt);
    _btnMusicMix.frame    = CGRectMake(xRight,  yPos, btnWdt, btnHgt);
    
    // top row 5 left
    yPos += (btnHgt+2);
    _bgmVolS.frame    = CGRectMake(xLeft,   yPos, btnWdt, btnHgt);
    _micVolS.frame    = CGRectMake(xMiddle, yPos, btnWdt, btnHgt);
    _btnMute.frame    = CGRectMake(xRight,  yPos, btnWdt, btnHgt);

     yPos += (btnHgt+20);
    _btnFilters[0].frame = CGRectMake(xLeft,   yPos, btnWdt, btnHgt);
    _startReverb.frame = CGRectMake(xRight,   yPos, btnWdt, btnHgt);

    yPos += (btnHgt+5);
    _btnFilters[1].frame = CGRectMake(xLeft,   yPos, btnWdt, btnHgt);
    _stopReverb.frame = CGRectMake(xRight,   yPos, btnWdt, btnHgt);
    yPos += (btnHgt+5);
    _btnFilters[2].frame = CGRectMake(xLeft,   yPos, btnWdt, btnHgt);
    yPos += (btnHgt+5);
    _btnFilters[3].frame = CGRectMake(xLeft,   yPos, btnWdt, btnHgt);
    // top row 5
    yPos += ( btnHgt);
    btnWdt = self.view.bounds.size.width - gap*2;
    btnHgt = hgt - yPos - btnHgt;
    _stat.frame = CGRectMake(gap, yPos , btnWdt, btnHgt);
}

#pragma mark - stream setup (采集推流参数设置)
- (void) setStreamerCfg {
    UIInterfaceOrientation orien = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect rect ;
    double srcWdt = 480.0;
    double srcHgt = 640.0;
    double dstWdt = 320.0;
    double dstHgt = 640.0;
    double x = (srcWdt-dstWdt)/2/srcWdt;
    double y = (srcHgt-dstHgt)/2/srcHgt;
    double wdt = dstWdt/srcWdt;
    double hgt = dstHgt/srcHgt;
    if (orien == UIInterfaceOrientationPortrait ||
        orien == UIInterfaceOrientationPortraitUpsideDown) {
        rect = CGRectMake(x, y, wdt, hgt);
    }
    else {
        rect = CGRectMake(y, x, hgt, wdt);
    }
    
    // capture settings
    NSString *preset = @"";
    if (_btnHighRes.on ) {
        preset = AVCaptureSessionPresetiFrame960x540;
    }
    else {
        preset = AVCaptureSessionPreset640x480;
        _cropfilter = [[GPUImageCropFilter alloc] initWithCropRegion:rect];
    }
    _gpuStreamer = [[KSYGPUStreamer alloc] initWithDefaultCfg];
    _gpuStreamer.streamerBase.logBlock = ^(NSString *string){
//        NSLog(@"logBlock: %@", string);
    };
    _capDev = [[KSYGPUCamera alloc] initWithSessionPreset:preset
                                           cameraPosition:AVCaptureDevicePositionBack];
    if (_capDev == nil) {
        [self toast:@"open camera failed"];
        return;
    }
    _capDev.outputImageOrientation = orien;
    _filter = [[KSYGPUBeautifyFilter alloc] init];
    
    _capDev.bStreamVideo = NO;
    _capDev.bStreamAudio = YES;
    [_capDev setAudioEncTarget:_gpuStreamer];

    _capDev.horizontallyMirrorFrontFacingCamera = NO;
    _capDev.horizontallyMirrorRearFacingCamera  = NO;
    _capDev.frameRate = 15;
    [_capDev addAudioInputsAndOutputs];

    // stream settings
    _gpuStreamer.streamerBase.videoCodec = KSYVideoCodec_X264;
    //_gpuStreamer.streamerBase.videoCodec = KSYVideoCodec_VT264;
    _gpuStreamer.streamerBase.videoFPS   = _capDev.frameRate;
    _gpuStreamer.streamerBase.audiokBPS  = 48;   // k bit ps
    _gpuStreamer.streamerBase.enAutoApplyEstimateBW = _btnAutoBw.on;
    if (_gpuStreamer.streamerBase.enAutoApplyEstimateBW) {
        _gpuStreamer.streamerBase.videoInitBitrate  = 500;  // k bit ps
    }
    else {
        _gpuStreamer.streamerBase.videoInitBitrate  = 1000; // k bit ps
    }
    _gpuStreamer.streamerBase.videoMaxBitrate   = 1000; // k bit ps
    _gpuStreamer.streamerBase.videoMinBitrate   = 300;  // k bit ps
    // connect blocks
    if (_btnHighRes.on) {
        [_capDev addTarget:_filter];
        [_filter addTarget:_preview];
        [_filter addTarget:_gpuStreamer];
    }
    else {
        [_capDev addTarget:_filter];
        [_filter addTarget:_cropfilter];
        [_cropfilter addTarget:_preview];
        [_cropfilter addTarget:_gpuStreamer];
    }

    // rtmp server info
    if (_hostURL == nil){
        
        // stream name = 随机数 + codec名称 （构造流名，避免多个demo推向同一个流）
        NSString *devCode  = [ [KSYGPUStreamerVC getUuid] substringToIndex:3];
        NSString *codecSuf = _gpuStreamer.streamerBase.videoCodec == KSYVideoCodec_QY265 ? @"265" : @"264";
        NSString *streamName = [NSString stringWithFormat:@"%@.%@", devCode, codecSuf ];
        
        // hostURL = rtmpSrv + streamName
        NSString *rtmpSrv  = @"rtmp://test.uplive.ksyun.com/live";
        NSString *url      = [  NSString stringWithFormat:@"%@/%@", rtmpSrv, streamName];
        _hostURL = [[NSURL alloc] initWithString:url];
    }
  
}

#pragma mark - UI responde

- (IBAction)onQuit:(id)sender {
    [_gpuStreamer.streamerBase stopMixMusic];
    [_gpuStreamer.streamerBase stopStream];
    [_capDev stopCameraCapture];
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

-(IBAction)OnChoseFilter:(id)sender {
    for (int b = 0; b < 4; ++b) {
        if (sender == _btnFilters[b]) {
            _btnFilters[b].enabled = NO;
        }
        else {
            _btnFilters[b].enabled = YES;
        }
    }
    if( sender == _btnFilters[0]) {
        _filter = [[KSYGPUBeautifyExtFilter alloc] init];
    }
    else if( sender == _btnFilters[1]) {
        _filter = [[KSYGPUBeautifyFilter alloc] init];
    }
    else if( sender == _btnFilters[2]) {
        _filter = [[KSYGPUDnoiseFilter alloc] init];
    }
    else if( sender == _btnFilters[3])    {
        _filter = [[KSYGPUBeautifyPlusFilter alloc] init];
    }

    [_capDev removeAllTargets];
    [_filter removeAllTargets];
    
    [_capDev addTarget:_filter];
    [_filter addTarget:_preview];
    [_filter addTarget:_gpuStreamer];
}

- (IBAction)onPreview:(id)sender {
    if ( NO == _btnPreview.isEnabled) {
        return;
    }
    if ( ! _capDev.isRunning ) {
        [self setStreamerCfg];
        [_capDev startCameraCapture];
        [_btnPreview setTitle:@"停止预览" forState:UIControlStateNormal];
    }
    else {
        [_capDev stopCameraCapture];
        [_btnPreview setTitle:@"开始预览" forState:UIControlStateNormal];
    }
    [UIApplication sharedApplication].idleTimerDisabled=_capDev.isRunning;
}

- (IBAction)onStream:(id)sender {
    if (NO == _capDev.isRunning  ||
        NO == _btnTStream.isEnabled ) {
        return;
    }
    if (_gpuStreamer.streamerBase.streamState != KSYStreamStateConnected) {
        [_gpuStreamer.streamerBase startStream: _hostURL];
        [_gpuStreamer.streamerBase setMicVolume:_micVolS.value];
        [_gpuStreamer.streamerBase setBgmVolume:_bgmVolS.value];
        [self initStatData];
    }
    else {
        [_gpuStreamer.streamerBase stopStream];
    }
    return;
}

- (IBAction)onFlash:(id)sender {
    if ([_capDev isTorchSupported]) {
        [_capDev toggleTorch ];
    }
}

- (IBAction)onCamera:(id)sender {
    [_capDev rotateCamera];
    BOOL backCam = (_capDev.cameraPosition == AVCaptureDevicePositionBack);
    if ( backCam ) {
        [_btnCamera setTitle:@"切到前摄像" forState: UIControlStateNormal];
    }
    else {
        [_btnCamera setTitle:@"切到后摄像" forState: UIControlStateNormal];
    }
    [_btnFlash  setEnabled:(_capDev.isRunning && [_capDev isTorchSupported]) ];
}
- (IBAction)onMusicPlay:(id)sender {
    NSString *testMp3 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.mp3"];
    static int i = 0;
    i = !i;
    if (i) {
        NSLog(@"bgm start %@", testMp3);
        _gpuStreamer.streamerBase.bgmFinishBlock = ^{
            NSLog(@"bgm over %@", testMp3);
        };
        [_gpuStreamer.streamerBase startMixMusic:testMp3 isLoop:NO];
    }
    else {
        [_gpuStreamer.streamerBase stopMixMusic];
    }
}

- (IBAction)onMusicPause:(id)sender {
    static int i = 0;
    i = !i;
    if (i) {
        [_gpuStreamer.streamerBase pauseMixMusic];
    }
    else {
        [_gpuStreamer.streamerBase resumeMixMusic];
    }
}

- (IBAction)onMusicMix:(id)sender {
    static BOOL i = NO;
    i = !i;
    [_gpuStreamer.streamerBase enableMicMixMusic:i];
}

-(IBAction)onReverbStart:(id)sender {
    [_gpuStreamer.streamerBase enableReverb:_iReverb];
    
    _startReverb.enabled = NO;
    _stopReverb.enabled = YES;
    
    _iReverb++;
    _iReverb = _iReverb % 4;
    NSString * SReverb = [NSString stringWithFormat:@"开始混响%d",_iReverb];
    [sender setTitle:SReverb  forState: UIControlStateNormal];
} // Reverb

-(IBAction)onReverbStop:(id)sender{
    [_gpuStreamer.streamerBase enableReverb:0];
    _startReverb.enabled = YES;
    _stopReverb.enabled = NO;
} //Reverb

- (IBAction)onVolChanged:(id)sender {
    if (sender == _bgmVolS) {
        [_gpuStreamer.streamerBase setBgmVolume:_bgmVolS.value];
    }
    else if (sender == _micVolS) {
        [_gpuStreamer.streamerBase setMicVolume:_micVolS.value];
    }
}

- (IBAction)onStreamMute:(id)sender {
    static BOOL i = NO;
    i = !i;
    if (_gpuStreamer.streamerBase){
        [_gpuStreamer.streamerBase muteStreame:i];
    }
}

- (IBAction)onTap:(id)sender {
    CGPoint point = [sender locationInView:self.view];
    CGPoint tap;
    tap.x = (point.x/self.view.frame.size.width);
    tap.y = (point.y/self.view.frame.size.height);
    NSError __autoreleasing *error;
    [self focusAtPoint:tap error:&error];
}

- (BOOL)focusAtPoint:(CGPoint )point error:(NSError *__autoreleasing* )error
{
    AVCaptureDevice *dev = _capDev.inputCamera;
    if ([dev isFocusPointOfInterestSupported] && [dev isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        if ([dev lockForConfiguration:error]) {
            [dev setFocusPointOfInterest:point];
            [dev setFocusMode:AVCaptureFocusModeAutoFocus];
            NSLog(@"Focusing..");
            [dev unlockForConfiguration];
            return YES;
        }
    }
    return NO;
}

#pragma mark - status monitor
- (void) initStatData {
    _lastByte    = 0;
    _lastSecond  = [[NSDate date]timeIntervalSince1970];
    _lastFrames  = 0;
    _netEventCnt = 0;
    _raiseCnt    = 0;
    _dropCnt     = 0;
    _startTime   =  [[NSDate date]timeIntervalSince1970];
}

- (NSString*) sizeFormatted : (int )KB {
    if ( KB > 1000 ) {
        double MB   =  KB / 1000.0;
        return [NSString stringWithFormat:@" %4.2f MB", MB];
    }
    else {
        return [NSString stringWithFormat:@" %d KB", KB];
    }
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

- (void)updateStat:(NSTimer *)theTimer{
    if (_gpuStreamer.streamerBase.streamState == KSYStreamStateConnected ) {
        int    KB          = _gpuStreamer.streamerBase.uploadedKByte;
        int    curFrames   = _gpuStreamer.streamerBase.encodedFrames;
        int    droppedF    = _gpuStreamer.streamerBase.droppedVideoFrames;

        int deltaKbyte = KB - _lastByte;
        double curTime = [[NSDate date]timeIntervalSince1970];
        double deltaTime = curTime - _lastSecond;
        double realKbps = deltaKbyte*8 / deltaTime;   // deltaByte / deltaSecond
        
        double deltaFrames =(curFrames - _lastFrames);
        double fps = deltaFrames / deltaTime;
        
        double dropRate = (droppedF - _lastDroppedF ) / deltaTime;
        _lastByte     = KB;
        _lastSecond   = curTime;
        _lastFrames   = curFrames;
        _lastDroppedF = droppedF;
        NSString *uploadDateSize = [ self sizeFormatted:KB ];
        NSString* stateurl  = [NSString stringWithFormat:@"%@\n", [_hostURL absoluteString]] ;
        NSString* statekbps = [NSString stringWithFormat:@"realtime:%4.1fkbps %.2f%@\n", realKbps, _bgmVolS.value, _netEventRaiseDrop];
        NSString* statefps  = [NSString stringWithFormat:@"%2.1f fps | %@  | %@ \n", fps, uploadDateSize, [self timeFormatted: (int)(curTime-_startTime) ] ];
        NSString* statedrop = [NSString stringWithFormat:@"dropFrame %4d | %3.1f | %2.1f%% \n", droppedF, dropRate, droppedF * 100.0 / curFrames ];

        NSString* netEvent = [NSString stringWithFormat:@"netEvent %d notGood | %d raise | %d drop", _netEventCnt, _raiseCnt, _dropCnt];
        
        _stat.text = [ stateurl    stringByAppendingString:statekbps ];
        _stat.text = [ _stat.text  stringByAppendingString:statefps  ];
        _stat.text = [ _stat.text  stringByAppendingString:statedrop ];
        _stat.text = [ _stat.text  stringByAppendingString:netEvent  ];

        if (_netTimeOut == 0) {
            _netEventRaiseDrop = @" ";
        }
        else {
            _netTimeOut--;
        }
    }
}

#pragma mark - state handle
- (void) onStreamError {
    KSYStreamErrorCode err = _gpuStreamer.streamerBase.streamErrorCode;
    [_btnPreview setEnabled:TRUE];
    [_btnTStream setEnabled:TRUE];
    [_btnTStream setTitle:@"开始推流" forState:UIControlStateNormal];
    [self toast:@"stream err"];
    if ( KSYStreamErrorCode_FRAMES_THRESHOLD == err ) {
        _stat.text = @"SDK auth failed, \npls check ak/sk";
    }
    else if ( KSYStreamErrorCode_CODEC_OPEN_FAILED == err) {
        _stat.text = @"Selected Codec not supported \n in this version";
    }
    else if ( KSYStreamErrorCode_CONNECT_FAILED == err) {
        _stat.text = @"Connecting error, pls check host url \nor network";
    }
    else if ( KSYStreamErrorCode_CONNECT_BREAK == err) {
        _stat.text = @"Connection break";
    }
    else if (  KSYStreamErrorCode_RTMP_NonExistDomain   == err) {
        _stat.text = @"error: NonExistDomain";
    }
    else if (  KSYStreamErrorCode_RTMP_NonExistApplication   == err) {
        _stat.text = @"error: NonExistApplication";
    }
    else if (  KSYStreamErrorCode_RTMP_AlreadyExistStreamName   == err) {
        _stat.text = @"error: AlreadyExistStreamName";
    }
    else if (  KSYStreamErrorCode_RTMP_ForbiddenByBlacklist   == err) {
        _stat.text = @"error: ForbiddenByBlacklist";
    }
    else if (  KSYStreamErrorCode_RTMP_InternalError   == err) {
        _stat.text = @"error: InternalError";
    }
    else if (  KSYStreamErrorCode_RTMP_URLExpired   == err) {
        _stat.text = @"error: URLExpired";
    }
    else if (  KSYStreamErrorCode_RTMP_SignatureDoesNotMatch   == err) {
        _stat.text = @"error: SignatureDoesNotMatch";
    }
    else if (  KSYStreamErrorCode_RTMP_InvalidAccessKeyId   == err) {
        _stat.text = @"error: InvalidAccessKeyId";
    }
    else if (  KSYStreamErrorCode_RTMP_BadParams   == err) {
        _stat.text = @"error: BadParams";
    }
    else if (  KSYStreamErrorCode_RTMP_ForbiddenByRegion   == err) {
        _stat.text = @"error: ForbiddenByRegion";
    }
    else if ( KSYStreamErrorCode_NO_INPUT_SAMPLE   == err) {
        _stat.text = @"error: No input sample";
    }
    else {
        _stat.text = [[NSString alloc] initWithFormat:@"error: %lu",  (unsigned long)err];
    }
    NSLog(@"onErr: %lu [%@]", (unsigned long) err, _stat.text);
    // 断网重连
    if ( KSYStreamErrorCode_CONNECT_BREAK == err && _btnAutoReconnect.isOn ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_gpuStreamer.streamerBase stopStream];
            [_gpuStreamer.streamerBase startStream:_hostURL];
            [self initStatData];
        });
    }
}

- (void) onNetStateEvent:(NSNotification *)notification {
    KSYNetStateCode netEvent = _gpuStreamer.streamerBase.netStateCode;
    //NSLog(@"net event : %ld", (unsigned long)netEvent );
    if ( netEvent == KSYNetStateCode_SEND_PACKET_SLOW ) {
        _netEventCnt++;
        if (_netEventCnt % 10 == 9) {
            [self toast:@"bad network"];
        }
        NSLog(@"bad network" );
    }
    else if ( netEvent == KSYNetStateCode_EST_BW_RAISE ) {
        _netEventRaiseDrop = @"raising";
        _raiseCnt++;
        _netTimeOut = 5;
        NSLog(@"bitrate raising" );
    }
    else if ( netEvent == KSYNetStateCode_EST_BW_DROP ) {
        _netEventRaiseDrop = @"dropping";
        _dropCnt++;
        _netTimeOut = 5;
        NSLog(@"bitrate dropping" );
    }
    else if ( netEvent == KSYNetStateCode_KSYAUTHFAILED ) {
        _netEventRaiseDrop = @"auth failed";
        NSLog(@"SDK auth failed, SDK will stop stream in a few minius" );
    }
}

- (void) onStreamStateChange:(NSNotification *)notification {
    [_btnPreview setEnabled:NO];
    [_btnTStream setEnabled:NO];
    if ( _gpuStreamer.streamerBase.streamState == KSYStreamStateIdle) {
        _stat.text = @"idle";
        [_btnPreview setEnabled:TRUE];
        [_btnTStream setEnabled:TRUE];
        [_btnTStream setTitle:@"开始推流" forState:UIControlStateNormal];
    }
    else if ( _gpuStreamer.streamerBase.streamState == KSYStreamStateConnected){
        _stat.text = @"connected";
        [_btnTStream setEnabled:TRUE];
        [_btnTStream setTitle:@"停止推流" forState:UIControlStateNormal];
        if (_gpuStreamer.streamerBase.streamErrorCode == KSYStreamErrorCode_KSYAUTHFAILED ) {
            NSLog(@"Auth failed, stream would stop in 5~8 minute");
            _stat.text = @"connected(auth failed";
        }
    }
    else if (_gpuStreamer.streamerBase.streamState == KSYStreamStateConnecting ) {
        _stat.text = @"connecting";
    }
    else if (_gpuStreamer.streamerBase.streamState == KSYStreamStateDisconnecting ) {
        _stat.text = @"disconnecting";
    }
    else if (_gpuStreamer.streamerBase.streamState == KSYStreamStateError ) {
        [self onStreamError];
        return;
    }
    NSLog(@"newState: %lu [%@]", (unsigned long)_gpuStreamer.streamerBase.streamState, _stat.text);
}

- (void) toast:(NSString*)message{
    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil, nil];
    [toast show];
    double duration = 0.3; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
}

+ (NSString *) getUuid{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}
@end
