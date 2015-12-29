//
//  ViewController.m
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 ksyun. All rights reserved.
//

#import "KSYStreamerVC.h"
#import <libksylive/libksylive.h>


@interface KSYStreamerVC ()

@property KSYStreamer * pubSession;
@property NSURL * hostURL;

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

@property UILabel *stat;
@property NSTimer* timer;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI ];
    [self initKSYAuth];
    // Do any additional setup after loading the view, typically from a nib.
    _pubSession = [[KSYStreamer alloc] initWithDefaultCfg];
    [self setStreamerCfg];
    
    // statistics update every seconds
    _timer =  [NSTimer scheduledTimerWithTimeInterval:1.2
                                               target:self
                                             selector:@selector(updateStat:)
                                             userInfo:nil
                                              repeats:YES];
    //QYPublisher state changes
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
- (void) initUI {
    UIButton * button;
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"StartPreview" forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:@selector(onPreview:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    _btnPreview = button;
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"startStream" forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:@selector(onStream:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    _btnTStream = button;
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"flashlight" forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:@selector(onFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    _btnFlash = button;
    [ _btnFlash setEnabled:NO];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"switchCamera" forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:@selector(onCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    _btnCamera = button;
    [ _btnCamera setEnabled:NO];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"quit" forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:@selector(onQuit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    _btnQuit = button;
    
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
    CGFloat gap = 10;
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
    yPos = gap*3;
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
    
    // top row 2 right
    xPos = wdt - btnWdt - gap ;
    _lblAutoReconnect.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    // top row 3 left
    yPos += (gap + btnHgt);
    xPos = gap;
    _btnAutoBw.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    // top row 3 right
    xPos = wdt - btnWdt - gap ;
    _btnAutoReconnect.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);

    // top row 4 left
    yPos += (gap + btnHgt);
    xPos = gap;
    _lblHighRes.frame =CGRectMake(xPos, yPos, btnWdt, btnHgt);
    // top row 5 left
    yPos += (gap + btnHgt);
    xPos = gap;
    _btnHighRes.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    // top row 6
    yPos += (gap + btnHgt);
    btnWdt = self.view.bounds.size.width - gap*2;
    btnHgt = hgt - yPos;
    _stat.frame = CGRectMake(gap, yPos , btnWdt, btnHgt);
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

- (BOOL)shouldAutorotate {
    BOOL  bShould = _pubSession.captureState != KSYCaptureStateCapturing;
    [self layoutUI];
    return bShould;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setStreamerCfg {
    // capture settings
    if (_btnHighRes.on ) {
        _pubSession.videoDimension = KSYVideoDimension_16_9__960x540;
    }
    else {
        _pubSession.videoDimension = KSYVideoDimension_16_9__640x360;
    }

    //_pubSession.videoDimension = KSYVideoDimension_4_3__640x480;
    _pubSession.videoFPS = 18;
    _pubSession.cameraPosition = AVCaptureDevicePositionFront;
    [self.view autoresizesSubviews];
    [_btnTStream setEnabled:NO];
    
    // stream settings
    //_pubSession.videoCodec = KSYVideoCodec_QY265;
    _pubSession.videoCodec = KSYVideoCodec_X264;
    _pubSession.videokBPS = 1000; // k bit ps
    _pubSession.audiokBPS = 48; // k bit ps
    _pubSession.enAutoApplyEstimateBW = _btnAutoBw.on;
    
    // rtmp server info
    NSString *devCode  = [ [KSYAuthInfo sharedInstance].mCode substringToIndex:6];
    NSString *codecSuf = _pubSession.videoCodec == KSYVideoCodec_X264 ? @"264" : @"265";
    NSString *url      = [  NSString stringWithFormat:@"rtmp://test.uplive.ksyun.com/live/%@.%@", devCode, codecSuf ];
    _hostURL = [ [NSURL alloc] initWithString:url];
    [self setVideoOrientation];
}

- (IBAction)onQuit:(id)sender {
    [_pubSession stopStream];
    [_pubSession stopPreview];
    //[self.navigationController popToRootViewControllerAnimated:FALSE];
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
    [_btnFlash  setEnabled:backCam];
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

        NSString* netEvent = [NSString stringWithFormat:@"netEvent %d slowSend | %d raise | %d drop", _netEventCnt, _raiseCnt, _dropCnt];
        
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
    NSLog(@"newCapState: %lu", (unsigned long)_pubSession.captureState);
    if ( _pubSession.captureState == KSYCaptureStateIdle){
        _stat.text = @"idle";
        [_btnPreview setEnabled:YES];
        [_btnTStream setEnabled:NO];
        [_btnPreview setTitle:@"StartPreview" forState:UIControlStateNormal];
        [_btnCamera setEnabled:NO];
        [_btnFlash  setEnabled:NO];
        [_btnAutoBw setEnabled:YES];
        [_btnHighRes setEnabled:YES];
    }
    else if (_pubSession.captureState == KSYCaptureStateCapturing ) {
        _stat.text = @"capturing";
        [_btnPreview setEnabled:YES];
        [_btnTStream setEnabled:YES];
        [_btnPreview setTitle:@"StopPreview" forState:UIControlStateNormal];
        [_btnCamera  setEnabled:YES];
        BOOL backCam = (_pubSession.cameraPosition == AVCaptureDevicePositionBack);
        [_btnFlash   setEnabled:backCam];
        [_btnAutoBw  setEnabled:NO];
        [_btnHighRes setEnabled:NO];
    }
    else if (_pubSession.captureState == KSYCaptureStateClosingCapture ) {
        _stat.text = @"closing capture";
        [_btnPreview setEnabled:NO];
        [_btnTStream setEnabled:NO];
        [_btnAutoBw  setEnabled:NO];
    }
    else if (_pubSession.captureState == KSYCaptureStateDevAuthDenied ) {
        _stat.text = @"camera/mic Authorization Denied";
        [_btnPreview setEnabled:TRUE];
        [_btnTStream setEnabled:NO];
        [_btnAutoBw setEnabled:YES];
    }
    else if (_pubSession.captureState == KSYCaptureStateParameterError ) {
        _stat.text = @"capture devices ParameterError";
        [_btnPreview setEnabled:TRUE];
        [_btnTStream setEnabled:NO];
        [_btnAutoBw setEnabled:YES];
        [_btnHighRes setEnabled:YES];
    }
}

- (void) onStreamError {
    KSYStreamErrorCode err = _pubSession.streamErrorCode;
    NSLog(@"onErr: %lu", (unsigned long) err);
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
    else {
        _stat.text = [[NSString alloc] initWithFormat:@"error: %lu",  (unsigned long)err];
    }
    if ( _btnAutoReconnect.isOn ) {
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
    NSLog(@"newState: %lu", (unsigned long)_pubSession.streamState);
    if ( _pubSession.streamState == KSYStreamStateIdle) {
        _stat.text = @"idle";
        [_btnPreview setEnabled:TRUE];
        [_btnTStream setEnabled:TRUE];
        [_btnTStream setTitle:@"StartStream" forState:UIControlStateNormal];
    }
    else if ( _pubSession.streamState == KSYStreamStateConnected){
        [_btnPreview setEnabled:NO];
        [_btnTStream setEnabled:TRUE];
        [_btnTStream setTitle:@"StopStream" forState:UIControlStateNormal];
    }
    else if (_pubSession.streamState == KSYStreamStateConnecting ) {
        _stat.text = @"connecting";
        [_btnPreview setEnabled:NO];
        [_btnTStream setEnabled:NO];
    }
    else if (_pubSession.streamState == KSYStreamStateDisconnecting ) {
        _stat.text = @"disconnecting";
        [_btnPreview setEnabled:NO];
        [_btnTStream setEnabled:NO];
    }
    else if (_pubSession.streamState == KSYStreamStateError ) {
        [self onStreamError];
    }
    [_btnPreview setNeedsDisplay];
    [_btnTStream setNeedsDisplay];
    [_stat setNeedsDisplay];
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
 
 以上信息为示例ak/sk，请联系haomingfei@kingsoft.com获取正确认证信息。
 
 @warning 请将appid/ak/sk信息更新至开发者自己信息，再进行编译测试
 */
- (void)initKSYAuth {
    NSString* time = [NSString stringWithFormat:@"%d",(int)[[NSDate date]timeIntervalSince1970]];
    NSString* sk = [NSString stringWithFormat:@"sff25dc4a428479ff1e20ebf225d113%@", time];
    NSString* sksign = [KSYAuthInfo KSYMD5:sk];
    [[KSYAuthInfo sharedInstance]setAuthInfo:@"QYA0EEF0FDDD38C79913" accessKey:@"abc73bb5ab2328517415f8f52cd5ad37" secretKeySign:sksign timeSeconds:time];
}

@end
