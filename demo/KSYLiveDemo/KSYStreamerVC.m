//
//  ViewController.m
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 ksyun. All rights reserved.
//

#import "KSYStreamerVC.h"
#ifdef KSYSTREAMER_DEMO
#import <KSYStreamer/KSYStreamer.h>
#import <KSYStreamer/KSYAuthInfo.h>
#endif


@interface KSYStreamerVC ()

@property KSYStreamer * pubSession;

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

@property UIView* preview;

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

@implementation KSYStreamerVC


-(KSYStreamer *)getStreamer {
    return _pubSession;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI ];
    [self initKSYAuth];
    _pubSession = [[KSYStreamer alloc] initWithDefaultCfg];
    [self setStreamerCfg];
    
    // statistics update every seconds
    _timer =  [NSTimer scheduledTimerWithTimeInterval:1.2
                                               target:self
                                             selector:@selector(updateStat:)
                                             userInfo:nil
                                              repeats:YES];
    //KSYStreamer state changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCaptureStateChange:)
                                                 name:KSYCaptureStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onStreamStateChange:)
                                                 name:KSYStreamStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNetStateEvent:)
                                                 name:KSYNetStateEventNotification
                                               object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KSYCaptureStateDidChangeNotification
                                                  object:nil];
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

- (void) initUI {
    _btnPreview = [self addButton:@"开始预览" action:@selector(onPreview:)];
    _btnTStream = [self addButton:@"开始推流" action:@selector(onStream:)];
    _btnFlash = [self addButton:@"闪光灯" action:@selector(onFlash:)];
    _btnCamera = [self addButton:@"前后摄像头" action:@selector(onCamera:)];
    _btnQuit = [self addButton:@"退出" action:@selector(onQuit:)];
   
    _lblAutoBW = [[UILabel alloc] init];
    _lblAutoBW.text = @"自动调码率";
    [self.view addSubview:_lblAutoBW];
    
    _btnAutoBw = [[UISwitch alloc] init];
    [self.view addSubview:_btnAutoBw];
    _btnAutoBw.on = YES;
    
    _lblAutoReconnect = [[UILabel alloc] init];
    _lblAutoReconnect.text = @"自动重连";
    [self.view addSubview:_lblAutoReconnect];
    
    _btnAutoReconnect = [[UISwitch alloc] init];
    [self.view addSubview:_btnAutoReconnect];
    _btnAutoReconnect.on = FALSE;
    
    
    _lblHighRes = [[UILabel alloc] init];
    _lblHighRes.text = @"高分辨率";
    [self.view addSubview:_lblHighRes];
    
    _btnHighRes = [[UISwitch alloc] init];
    [self.view addSubview:_btnHighRes];
    _btnHighRes.on = YES;

    _stat = [[UILabel alloc] init];
    _stat.backgroundColor = [UIColor clearColor];
    _stat.textColor = [UIColor redColor];

    [self.view addSubview:_stat];
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
}

- (BOOL)shouldAutorotate {
    BOOL  bShould = _pubSession.captureState != KSYCaptureStateCapturing;
    [self layoutUI];
    return bShould;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

const char * getDocPath () ;

- (void) setStreamerCfg {
    // capture settings
    if (_btnHighRes.on ) {
        _pubSession.videoDimension = KSYVideoDimension_16_9__960x540;
    }
    else {
        _pubSession.videoDimension = KSYVideoDimension_16_9__640x360;

    }
    _pubSession.videoCodec = KSYVideoCodec_X264;
    _pubSession.videoFPS = 15;
    [self.view autoresizesSubviews];
    
    // stream settings

    _pubSession.videoInitBitrate = 1000; // k bit ps
    _pubSession.videoMaxBitrate = 1000; // k bit ps
    _pubSession.videoMinBitrate = 100; // k bit ps
    _pubSession.audiokBPS = 48; // k bit ps
    _pubSession.enAutoApplyEstimateBW = _btnAutoBw.on;
    
    // rtmp server info
    NSString *rtmpSrv  = @"rtmp://test.uplive.ksyun.com/live";
    // stream name = 随机数 + codec名称
    NSString *devCode  = [ [KSYAuthInfo sharedInstance].mCode substringToIndex:6];
    NSString *codecSuf = _pubSession.videoCodec == KSYVideoCodec_X264 ? @"264" : @"265";
    NSString *url      = [  NSString stringWithFormat:@"%@/%@.%@", rtmpSrv, devCode, codecSuf ];
    //url      = [  NSString stringWithFormat:@"%s/out.flv",getDocPath() ];
    _hostURL = [[NSURL alloc] initWithString:url];
    [self setVideoOrientation];
}

- (IBAction)onQuit:(id)sender {
    [_pubSession stopStream];
    [_pubSession stopPreview];
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

- (IBAction)onPreview:(id)sender {
    if ( NO == _btnPreview.isEnabled) {
        return;
    }
    if ( _pubSession.captureState != KSYCaptureStateCapturing ) {
        [self setStreamerCfg];
        [_pubSession startPreview: self.view];
        [UIApplication sharedApplication].idleTimerDisabled=YES;
    }
    else {
        [_pubSession stopPreview];
        [UIApplication sharedApplication].idleTimerDisabled=NO;
    }
}

- (IBAction)onStream:(id)sender {
    if (_pubSession.captureState != KSYCaptureStateCapturing ||
        NO == _btnTStream.isEnabled ) {
        return;
    }
    if (_pubSession.streamState != KSYStreamStateConnected) {
        [_pubSession startStream: _hostURL];
        [self initStatData];
    }
    else {
        [_pubSession stopStream];
    }
}

- (IBAction)onFlash:(id)sender {
    [_pubSession toggleTorch ];
    //[_pubSession setPreviewMirrored:_bMirrored];
    //_bMirrored= !_bMirrored;
}

- (IBAction)onCamera:(id)sender {
    [_pubSession switchCamera ];
    BOOL backCam = (_pubSession.cameraPosition == AVCaptureDevicePositionBack);
    if ( backCam ) {
        [_btnCamera setTitle:@"切到前摄像" forState: UIControlStateNormal];
    }
    else {
        [_btnCamera setTitle:@"切到后摄像" forState: UIControlStateNormal];
    }
    backCam = backCam && (_pubSession.captureState == KSYCaptureStateCapturing);
    [_btnFlash  setEnabled:backCam ];
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
    if (_pubSession.streamState == KSYStreamStateConnected ) {
        int    KB          = [_pubSession uploadedKByte];
        int    curFrames   = [_pubSession encodedFrames];
        int    droppedF    = [_pubSession droppedVideoFrames];

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
    AVCaptureDevice *dev = [_pubSession getCurrentCameraDevices];
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

- (void) onCaptureStateChange:(NSNotification *)notification {
    // init stat
    [_btnTStream setEnabled:NO];
    [_btnAutoBw  setEnabled:YES];
    [_btnHighRes setEnabled:YES];
    [_btnFlash   setEnabled:NO];
    if ( _pubSession.captureState == KSYCaptureStateIdle){
        _stat.text = @"idle";
        [_btnPreview setEnabled:YES];
        [_btnPreview setTitle:@"StartPreview" forState:UIControlStateNormal];
    }
    else if (_pubSession.captureState == KSYCaptureStateCapturing ) {
        _stat.text = @"capturing";
        [_btnPreview setEnabled:YES];
        [_btnTStream setEnabled:YES];
        [_btnPreview setTitle:@"StopPreview" forState:UIControlStateNormal];
        BOOL backCam = (_pubSession.cameraPosition == AVCaptureDevicePositionBack);
        [_btnFlash   setEnabled:backCam];
        [_btnAutoBw  setEnabled:NO];
        [_btnHighRes setEnabled:NO];
    }
    else if (_pubSession.captureState == KSYCaptureStateClosingCapture ) {
        _stat.text = @"closing capture";
        [_btnPreview setEnabled:NO];
    }
    else if (_pubSession.captureState == KSYCaptureStateDevAuthDenied ) {
        _stat.text = @"camera/mic Authorization Denied";
        [_btnPreview setEnabled:YES];
    }
    else if (_pubSession.captureState == KSYCaptureStateParameterError ) {
        _stat.text = @"capture devices ParameterError";
        [_btnPreview setEnabled:YES];
    }
    else if (_pubSession.captureState == KSYCaptureStateDevBusy ) {
        _stat.text = @"device busy, try later";
        [self toast:_stat.text];
    }
    NSLog(@"newCapState: %lu [%@]", (unsigned long)_pubSession.captureState, _stat.text);
}

- (void) onStreamError {
    KSYStreamErrorCode err = _pubSession.streamErrorCode;
    [_btnPreview setEnabled:TRUE];
    [_btnTStream setEnabled:TRUE];
    [_btnTStream setTitle:@"StartStream" forState:UIControlStateNormal];
    [self toast:@"stream err"];
    if ( KSYStreamErrorCode_KSYAUTHFAILED == err ) {
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
    else {
        _stat.text = [[NSString alloc] initWithFormat:@"error: %lu",  (unsigned long)err];
    }
    NSLog(@"onErr: %lu [%@]", (unsigned long) err, _stat.text);
    // 断网重连
    if ( KSYStreamErrorCode_CONNECT_BREAK == err && _btnAutoReconnect.isOn ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_pubSession stopStream];
            [_pubSession startStream:_hostURL];
            [self initStatData];
        });
    }
}

- (void) onNetStateEvent:(NSNotification *)notification {
    KSYNetStateCode netEvent = _pubSession.netStateCode;
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
}

- (void) onStreamStateChange:(NSNotification *)notification {
    [_btnPreview setEnabled:NO];
    [_btnTStream setEnabled:NO];
    if ( _pubSession.streamState == KSYStreamStateIdle) {
        _stat.text = @"idle";
        [_btnPreview setEnabled:TRUE];
        [_btnTStream setEnabled:TRUE];
        [_btnTStream setTitle:@"StartStream" forState:UIControlStateNormal];
    }
    else if ( _pubSession.streamState == KSYStreamStateConnected){
        _stat.text = @"connected";
        [_btnTStream setEnabled:TRUE];
        [_btnTStream setTitle:@"StopStream" forState:UIControlStateNormal];
    }
    else if (_pubSession.streamState == KSYStreamStateConnecting ) {
        _stat.text = @"connecting";
    }
    else if (_pubSession.streamState == KSYStreamStateDisconnecting ) {
        _stat.text = @"disconnecting";
    }
    else if (_pubSession.streamState == KSYStreamStateError ) {
        [self onStreamError];
    }
    NSLog(@"newState: %lu [%@]", (unsigned long)_pubSession.streamState, _stat.text);
}

- (void) setVideoOrientation {
    UIDeviceOrientation orien = [ [UIDevice  currentDevice]  orientation];
    switch (orien) {
        case UIDeviceOrientationPortraitUpsideDown:
            _pubSession.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            _pubSession.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            _pubSession.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            _pubSession.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
    }
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
    NSString* time = [NSString stringWithFormat:@"%d",(int)[[NSDate date]timeIntervalSince1970]];
    NSString* sk = [NSString stringWithFormat:@"s77d5c0eef4aaeff62e43d89f1b12a25%@", time];
    NSString* sksign = [KSYAuthInfo KSYMD5:sk];
    [[KSYAuthInfo sharedInstance]setAuthInfo:@"QYA0E0639AC997A8D128" accessKey:@"a5644305efa79b56b8dac55378b83e35" secretKeySign:sksign timeSeconds:time];
}

@end
