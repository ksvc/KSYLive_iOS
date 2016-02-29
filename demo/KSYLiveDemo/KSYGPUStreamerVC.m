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
#import <libksygpulive/KSYGPUCamera.h>
#import <libksygpulive/KSYGPUBeautifyFilter.h>

@interface KSYGPUStreamerVC ()
@property KSYGPUStreamer * gpuStreamer;
@property KSYStreamerBase * streamer;
@property KSYGPUCamera * capDev;
@property GPUImageFilter     * filter;
@property GPUImageCropFilter * cropfilter;
@property GPUImageFilter * scalefilter;
@property GPUImageView   * preview;

@property UIButton *btnPreview;
@property UIButton *btnTStream;
@property UIButton *btnCamera;
@property UIButton *btnFlash;
@property UISwitch *btnAutoBw;
@property UILabel  *lblAutoBW;
@property UIButton *btnQuit;
@property UISwitch *btnAutoReconnect;
@property UILabel  *lblAutoReconnect;

@property UISwitch *btnHighRes;
@property UILabel  *lblHighRes;

@property NSTimer *timer;

@property BOOL bMirrored;

@property double  lastSecond;
@property int  lastByte;
@property int  lastFrames;
@property int  lastDroppedF;
@property int  netEventCnt;

@property NSString  *netEventRaiseDrop;
@property int  netTimeOut;

@property int raiseCnt;
@property int dropCnt;

@property double  startTime;
@end

@implementation KSYGPUStreamerVC

-(KSYStreamerBase *)getStreamer {
    return _streamer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI ];
    [self initKSYAuth];
    [self setStreamerCfg];
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

- (void) initUI {
    // add prevew at bottom
    _preview    = [[GPUImageView alloc] init];
    [self.view addSubview:_preview];
    
    _btnPreview = [self addButton:@"开始预览"  action:@selector(onPreview:)];
    _btnTStream = [self addButton:@"开始推流"  action:@selector(onStream:)];
    _btnFlash   = [self addButton:@"闪光灯"    action:@selector(onFlash:)];
    _btnCamera  = [self addButton:@"前后摄像头" action:@selector(onCamera:)];
    _btnQuit    = [self addButton:@"退出"      action:@selector(onQuit:)];

    _lblAutoBW = [self addLable:@"自动调码率"];
    _btnAutoBw = [self addSwitch:YES];

    _lblAutoReconnect = [self addLable:@"自动重连"];
    _btnAutoReconnect = [self addSwitch:NO];

    _lblHighRes =[self addLable:@"高分辨率"];
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
    CGFloat xPos = gap;
    CGFloat yPos = hgt - btnHgt - gap;
    
    // full screen
    _preview.frame = self.view.bounds;
    
    // bottom left
    _btnPreview.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);

    // bottom right
    xPos = wdt - btnWdt - gap;
    _btnTStream.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    // top left
    xPos = gap;
    yPos = 20+gap*3;
    _btnFlash.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    // top middle
    xPos = (wdt - btnWdt*3 - gap*2) /2 + gap + btnWdt;
    _btnCamera.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    // top right
    xPos = wdt - btnWdt - gap;
    _btnQuit.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);

    // top row 2 left
    yPos += (gap + btnHgt);
    xPos = gap;
    _lblAutoBW.frame =CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    // top row 2 middle
    xPos = (wdt - btnWdt*3 - gap*2) /2 + gap + btnWdt;
    _lblHighRes.frame =CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    // top row 2 right
    xPos = wdt - btnWdt - gap ;
    _lblAutoReconnect.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    // top row 3 left
    yPos += (btnHgt);
    xPos = gap;
    _btnAutoBw.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    // top row 3 middle
    xPos = (wdt - btnWdt*3 - gap*2) /2 + gap + btnWdt;
    _btnHighRes.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    // top row 3 right
    xPos = wdt - btnWdt - gap ;
    _btnAutoReconnect.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    // top row 4
    yPos += ( btnHgt);
    btnWdt = self.view.bounds.size.width - gap*2;
    btnHgt = hgt - yPos - btnHgt;
    _stat.frame = CGRectMake(gap, yPos , btnWdt, btnHgt);
}

- (void)viewDidAppear:(BOOL)animated {
    if ( _btnAutoBw != nil ) {
        [self layoutUI];
    }
    [self addObservers ];
    if (_bAutoStart) {
        [self onPreview:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self onStream:nil];
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self rmObservers ];
}

- (BOOL)shouldAutorotate {
    [self layoutUI];
    return !(_capDev && _capDev.isRunning);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setStreamerCfg {
    UIInterfaceOrientation orien = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGRect rect ;
    double srcWdt = 540.0;
    double srcHgt = 960.0;
    
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
        preset = AVCaptureSessionPresetiFrame960x540;
        _cropfilter = [[GPUImageCropFilter alloc] initWithCropRegion:rect];

    }
    BOOL useGPUFilter = YES;
    if (useGPUFilter) {
        _gpuStreamer = [[KSYGPUStreamer alloc] initWithDefaultCfg];
        _streamer = [_gpuStreamer getStreamer];
    }
    else {
        _gpuStreamer = nil;
        _streamer = [[KSYStreamerBase alloc] initWithDefaultCfg];
    }
    _capDev = [[KSYGPUCamera alloc] initWithSessionPreset:preset
                                           cameraPosition:AVCaptureDevicePositionBack];
    if (_capDev == nil) {
        NSLog(@"camera open failed!");
        return;
    }
    _capDev.outputImageOrientation = orien;
    _filter = [[GPUImageColorInvertFilter alloc] init];
    //[_capDev addTarget:(GPUImageView *)filterView];
    _capDev.bStreamVideo = useGPUFilter ? NO:YES;
    _capDev.bStreamAudio = true;
    if (useGPUFilter) {
        [_capDev setAudioEncTarget:_gpuStreamer];
    }
    else {
        [_capDev setBaseAudioEncTarget:_streamer];
    }

    _capDev.horizontallyMirrorFrontFacingCamera = NO;
    _capDev.horizontallyMirrorRearFacingCamera  = NO;
    _capDev.frameRate = 15;
    [_capDev addAudioInputsAndOutputs];

    // stream settings
    _streamer.videoCodec = KSYVideoCodec_X264;
    //_streamer.videoCodec = KSYVideoCodec_VT264;
    _streamer.videoFPS   = _capDev.frameRate;
    _streamer.audiokBPS  = 48;   // k bit ps
    _streamer.enAutoApplyEstimateBW = _btnAutoBw.on;
    if (_streamer.enAutoApplyEstimateBW) {
        _streamer.videoInitBitrate  = 500;  // k bit ps
        _streamer.videoMaxBitrate   = 1000; // k bit ps
        _streamer.videoMinBitrate   = 200;  // k bit ps
    }
    else {
        _streamer.videoInitBitrate  = 1000; // k bit ps
        _streamer.videoMaxBitrate   = 1000; // k bit ps
        _streamer.videoMinBitrate   = 200;  // k bit ps
    }
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
    // stream name = 随机数 + codec名称 （构造流名，避免多个demo推向同一个流）
    NSString *devCode  = [ [KSYAuthInfo sharedInstance].mCode substringToIndex:3];
    NSString *codecSuf = _streamer.videoCodec == KSYVideoCodec_QY265 ? @"265" : @"264";
    NSString *streamName = [NSString stringWithFormat:@"%@.%@", devCode, codecSuf ];
    
    // hostURL = rtmpSrv + streamName
    NSString *rtmpSrv  = @"rtmp://test.uplive.ksyun.com/live";
    NSString *url      = [  NSString stringWithFormat:@"%@/%@", rtmpSrv, streamName];
    _hostURL = [[NSURL alloc] initWithString:url];
}

- (IBAction)onQuit:(id)sender {
    [_streamer stopStream];
    [_capDev stopCameraCapture];
    [self dismissViewControllerAnimated:FALSE completion:nil];
    
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
    if (_streamer.streamState != KSYStreamStateConnected) {
        [_streamer startStream: _hostURL];
        [self initStatData];
    }
    else {
        [_streamer stopStream];
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

- (void)updateStat:(NSTimer *)theTimer{
    if (_streamer.streamState == KSYStreamStateConnected ) {
        int    KB          = _streamer.uploadedKByte;
        int    curFrames   = _streamer.encodedFrames;
        int    droppedF    = _streamer.droppedVideoFrames;

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
        NSString* statekbps = [NSString stringWithFormat:@"realtime:%4.1fkbps %@\n", realKbps, _netEventRaiseDrop];
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

- (void) onStreamError {
    KSYStreamErrorCode err = _streamer.streamErrorCode;
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
            [_streamer stopStream];
            [_streamer startStream:_hostURL];
            [self initStatData];
        });
    }
}

- (void) onNetStateEvent:(NSNotification *)notification {
    KSYNetStateCode netEvent = _streamer.netStateCode;
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
    if ( _streamer.streamState == KSYStreamStateIdle) {
        _stat.text = @"idle";
        [_btnPreview setEnabled:TRUE];
        [_btnTStream setEnabled:TRUE];
        [_btnTStream setTitle:@"开始推流" forState:UIControlStateNormal];
    }
    else if ( _streamer.streamState == KSYStreamStateConnected){
        _stat.text = @"connected";
        [_btnTStream setEnabled:TRUE];
        [_btnTStream setTitle:@"停止推流" forState:UIControlStateNormal];
        if (_streamer.streamErrorCode == KSYStreamErrorCode_KSYAUTHFAILED ) {
            NSLog(@"Auth failed, stream would stop in 5~8 minute");
            _stat.text = @"connected(auth failed";
        }
    }
    else if (_streamer.streamState == KSYStreamStateConnecting ) {
        _stat.text = @"connecting";
    }
    else if (_streamer.streamState == KSYStreamStateDisconnecting ) {
        _stat.text = @"disconnecting";
    }
    else if (_streamer.streamState == KSYStreamStateError ) {
        [self onStreamError];
        return;
    }
    NSLog(@"newState: %lu [%@]", (unsigned long)_streamer.streamState, _stat.text);
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

- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

/**
 @abstrace 初始化金山云认证信息
 @discussion 开发者帐号fpzeng，其他信息如下：
 
 * appid: QYA0EEF0FDDD38C79913
 * ak: abc73bb5ab2328517415f8f52cd5ad37
 * sk: sff25dc4a428479ff1e20ebf225d113
 * sksign: md5(sk+tmsec)
 
 以上信息为错误ak/sk，请联系haomingfei@kingsoft.com获取正确认证信息。
 
 @warning 请将appid/ak/sk信息更新至开发者自己信息，再进行编译测试
 */
- (void)initKSYAuth {
#warning "please replace ak/sk with your own"
    NSString* time   = [NSString stringWithFormat:@"%d",(int)[[NSDate date]timeIntervalSince1970]];
    NSString* skTime = [NSString stringWithFormat:@"s77d5c0eef4aaeff62e43d89f1b12a25%@", time];
    NSString* sksign = [KSYAuthInfo KSYMD5:skTime];
    [[KSYAuthInfo sharedInstance]setAuthInfo:@"QYA0E0639AC997A8D128"
                                   accessKey:@"a5644305efa79b56b8dac55378b83e35"
                               secretKeySign:sksign
                                 timeSeconds:time];
}

@end
