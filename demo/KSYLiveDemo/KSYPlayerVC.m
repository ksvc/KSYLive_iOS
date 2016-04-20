//
//  KSYPlayerVC.m
//
//  Created by zengfanping on 11/3/15.
//  Copyright (c) 2015 zengfanping. All rights reserved.
//

#import "KSYPlayerVC.h"
#import <CommonCrypto/CommonDigest.h>
#import <ifaddrs.h>
#import <arpa/inet.h>


@interface KSYPlayerVC ()
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSURL *reloadUrl;
@property (strong, nonatomic) KSYMoviePlayerController *player;
@end


@implementation KSYPlayerVC{
    UILabel *stat;
    NSTimer* timer;
    double lastSize;
    NSTimeInterval lastCheckTime;
    NSString* serverIp;
    UIView *videoView;
    UIButton *btnPlay;
    UIButton *btnPause;
    UIButton *btnReload;
    UIButton *btnStop;
    UIButton *btnQuit;
    UILabel  *lableVPP;
    UISwitch *switchVPP;
    UISwitch *switchLog;
    UIButton *getQosBtn;
    UISwitch  *switchHwCodec;
    long long int prepared_time;
    int fvr_costtime;
    int far_costtime;
}

- (instancetype)initWithURL:(NSURL *)url {
    if((self = [super init])) {
        self.url = url;
        self.reloadUrl = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self setupObservers];
    [self initKSYAuth];
}

- (void) initUI {
    //add UIView for player
    videoView = [[UIView alloc] init];
    videoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:videoView];
    
    //add play button
    btnPlay = [self addButtonWithTitle:@"play" action:@selector(onPlayVideo:)];

    //add pause button
    btnPause = [self addButtonWithTitle:@"pause" action:@selector(onPauseVideo:)];

    //add pause button
    btnReload = [self addButtonWithTitle:@"reload" action:@selector(onReloadVideo:)];
    
    //add stop button
    btnStop = [self addButtonWithTitle:@"stop" action:@selector(onStopVideo:)];

    //add quit button
    btnQuit = [self addButtonWithTitle:@"quit" action:@selector(onQuit:)];
    
    //add getQosBtn
    getQosBtn = [self addButtonWithTitle:@"QosInfo" action:@selector(getQosBtnEvent)];

    stat = [[UILabel alloc] init];
    stat.backgroundColor = [UIColor clearColor];
    stat.textColor = [UIColor redColor];
    stat.numberOfLines = -1;
    stat.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:stat];
    
    lableVPP = [[UILabel alloc] init];
    lableVPP.text = @"开启硬件解码";
    lableVPP.textColor = [UIColor lightGrayColor];
    [self.view addSubview:lableVPP];

//    switchVPP = [[UISwitch alloc] init];
//    [self.view addSubview:switchVPP];
//    switchVPP.on = YES;
    
//    switchLog = [[UISwitch alloc] init];
//    [switchLog addTarget:self action:@selector(switchControlEvent:) forControlEvents:UIControlEventValueChanged];
//    [self.view addSubview:switchLog];
//    switchLog.on = YES;
    
    switchHwCodec = [[UISwitch alloc] init];
    [self.view  addSubview:switchHwCodec];
    switchHwCodec.on = YES;
    
    [self layoutUI];
}
- (UIButton *)addButtonWithTitle:(NSString *)title action:(SEL)action{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:title forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds  = YES;
    button.layer.cornerRadius   = 5;
    button.layer.borderColor    = [UIColor blackColor].CGColor;
    button.layer.borderWidth    = 1;
    [self.view addSubview:button];
    return button;
}
- (void) layoutUI {
    CGFloat wdt = self.view.bounds.size.width;
    CGFloat hgt = self.view.bounds.size.height;
    CGFloat gap = 20;
    CGFloat btnWdt = ( (wdt-gap) / 5) - gap;
    CGFloat btnHgt = 30;
    CGFloat xPos = 0;
    CGFloat yPos = 0;

    yPos = gap;
    xPos = gap;
    lableVPP.frame =CGRectMake(xPos, yPos, btnWdt * 2, btnHgt);
    xPos = wdt/2 - btnWdt/2;
    switchVPP.frame = CGRectMake(xPos, gap, btnWdt, btnHgt);
    switchLog.frame = CGRectMake(xPos + btnWdt + 50, gap, btnWdt, btnHgt);
    switchHwCodec.frame = CGRectMake(xPos, gap, btnWdt, btnHgt);

    videoView.frame = CGRectMake(0, 0, wdt, hgt);
    xPos = gap;
    yPos = hgt - btnHgt - gap;
    btnPlay.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnPause.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnReload.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnStop.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnQuit.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    stat.frame = CGRectMake(gap, 0, wdt, hgt);
    // top row 3 left
    yPos += (gap + btnHgt);
    xPos = gap;
    getQosBtn.frame = CGRectMake(xPos, btnStop.frame.origin.y - 40, btnWdt, btnHgt);

    
}

- (BOOL)shouldAutorotate {
    [self layoutUI];
    return YES;
}

- (void)switchControlEvent:(UISwitch *)switchControl
{
    if (_player) {
        _player.shouldEnableKSYStatModule = switchControl.isOn;

    }
}
- (NSString *)MD5:(NSString*)raw {
    
    const char * pointer = [raw UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(pointer, (CC_LONG)strlen(pointer), md5Buffer);
    
    NSMutableString *string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [string appendFormat:@"%02x",md5Buffer[i]];
    
    return string;
}

- (NSTimeInterval) getCurrentTime{
    return [[NSDate date] timeIntervalSince1970];
}

/**
 @abstrace 初始化金山云认证信息
 @discussion 开发者帐号fpzeng，其他信息如下：
 
 * appid: QYA0EEF0FDDD38C79913
 * ak: abc73bb5ab2328517415f8f52cd5ad37
 * sk: sff25dc4a428479ff1e20ebf225d113
 * sksign: md5(sk+tmsec)
 
 以上信息随时可能失效，请找金山云提供。
 
 @warning 请将appid/ak/sk信息更新至开发者自己信息，再进行编译测试
 */

- (void)initKSYAuth
{
    NSString* time = [NSString stringWithFormat:@"%d",(int)[[NSDate date]timeIntervalSince1970]];
    NSString* sk = [NSString stringWithFormat:@"sff25dc4a428479ff1e20ebf225d113%@", time];
    NSString* sksign = [self MD5:sk];
    [[KSYPlayerAuth sharedInstance]setAuthInfo:@"QYA0EEF0FDDD38C79913" accessKey:@"abc73bb5ab2328517415f8f52cd5ad37" secretKeySign:sksign timeSeconds:time];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handlePlayerNotify:(NSNotification*)notify
{
    if (!_player) {
        return;
    }
    if (MPMediaPlaybackIsPreparedToPlayDidChangeNotification ==  notify.name) {
        stat.text = [NSString stringWithFormat:@"player prepared"];
        // using autoPlay to start live stream
        //        [_player play];
        serverIp = [_player serverAddress];
        NSLog(@"%@ -- ip:%@", _url, serverIp);
        [self StartTimer];
    }
    if (MPMoviePlayerPlaybackStateDidChangeNotification ==  notify.name) {
        NSLog(@"------------------------");
        NSLog(@"player playback state: %ld", (long)_player.playbackState);
        NSLog(@"------------------------");
    }
    if (MPMoviePlayerLoadStateDidChangeNotification ==  notify.name) {
        NSLog(@"player load state: %ld", (long)_player.loadState);
        if (MPMovieLoadStateStalled & _player.loadState) {
            stat.text = [NSString stringWithFormat:@"player start caching"];
            NSLog(@"player start caching");
        }
        
        if (_player.bufferEmptyCount &&
            (MPMovieLoadStatePlayable & _player.loadState ||
             MPMovieLoadStatePlaythroughOK & _player.loadState)){
                NSLog(@"player finish caching");
                NSString *message = [[NSString alloc]initWithFormat:@"loading occurs, %d - %0.3fs",
                                     (int)_player.bufferEmptyCount,
                                     _player.bufferEmptyDuration];
                [self toast:message];
            }
    }
    if (MPMoviePlayerPlaybackDidFinishNotification ==  notify.name) {
        NSLog(@"player finish state: %ld", (long)_player.playbackState);
        NSLog(@"player download flow size: %f MB", _player.readSize);
        NSLog(@"buffer monitor  result: \n   empty count: %d, lasting: %f seconds",
              (int)_player.bufferEmptyCount,
              _player.bufferEmptyDuration);
        int reason = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
        if (reason == 0) {
            stat.text = [NSString stringWithFormat:@"player finish"];

        }else if (reason == 1){
            stat.text = [NSString stringWithFormat:@"player Error"];

        }else if (reason == 2){
            stat.text = [NSString stringWithFormat:@"player userExited"];

        }
        [self StopTimer];
    }
    if (MPMovieNaturalSizeAvailableNotification ==  notify.name) {
        NSLog(@"video size %.0f-%.0f", _player.naturalSize.width, _player.naturalSize.height);
    }
	if (MPMoviePlayerFirstVideoFrameRenderedNotification == notify.name)
	{
        fvr_costtime = (int)((long long int)([self getCurrentTime] * 1000) - prepared_time);
		NSLog(@"first video frame show, cost time : %dms!\n", fvr_costtime);
	}
	
	if (MPMoviePlayerFirstAudioFrameRenderedNotification == notify.name)
	{
        far_costtime = (int)((long long int)([self getCurrentTime] * 1000) - prepared_time);
		NSLog(@"first audio frame render, cost time : %dms!\n", far_costtime);
	}
}
- (void) toast:(NSString*)message{
    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil, nil];
    [toast show];
    
    double duration = 0.5; // duration in seconds
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
}

- (void)setupObservers
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMediaPlaybackIsPreparedToPlayDidChangeNotification)
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerPlaybackStateDidChangeNotification)
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerPlaybackDidFinishNotification)
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerLoadStateDidChangeNotification)
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMovieNaturalSizeAvailableNotification)
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerFirstVideoFrameRenderedNotification)
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerFirstAudioFrameRenderedNotification)
                                              object:nil];
}

- (void)releaseObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackDidFinishNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerLoadStateDidChangeNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMovieNaturalSizeAvailableNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerFirstVideoFrameRenderedNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerFirstAudioFrameRenderedNotification
                                                 object:nil];
}
- (IBAction)onPlayVideo:(id)sender {
    
    if (_player) {
        if (switchLog.isOn == NO) {
            _player.shouldEnableKSYStatModule = NO;
        }
        [_player play];
        [self StartTimer];
        return;
    }
    _player = [[KSYMoviePlayerController alloc] initWithContentURL: _url];
    if (switchLog.isOn == NO) {
        _player.shouldEnableKSYStatModule = NO;
    }
    
    _player.logBlock = ^(NSString *logJson){
        
        NSLog(@"logJson is %@",logJson);
    };
    
    stat.text = [NSString stringWithFormat:@"url %@", _url];
    _player.controlStyle = MPMovieControlStyleNone;
    [_player.view setFrame: videoView.bounds];  // player's frame must match parent's
    [videoView addSubview: _player.view];
    [videoView bringSubviewToFront:stat];
    videoView.autoresizesSubviews = TRUE;
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _player.shouldAutoplay = TRUE;
    _player.bufferTimeMax = 5;
    _player.shouldEnableVideoPostProcessing = switchVPP.on;
    _player.scalingMode = MPMovieScalingModeAspectFit;
    _player.shouldUseHWCodec = switchHwCodec.isOn;
    _player.shouldEnableKSYStatModule = TRUE;
    //[_player setTimeout:10];
    
    NSLog(@"sdk version:%@", [_player getVersion]);
    prepared_time = (long long int)([self getCurrentTime] * 1000);
    [_player prepareToPlay];
    
}

- (IBAction)onReloadVideo:(id)sender {
    if (_player) {
        [_player reload:_reloadUrl];
    }
}

- (IBAction)onPauseVideo:(id)sender {
    if (_player) {
        [_player pause];
    }
}
- (IBAction)onStopVideo:(id)sender {
    if (_player) {
        NSLog(@"player download flow size: %f MB", _player.readSize);
        NSLog(@"buffer monitor  result: \n   empty count: %d, lasting: %f seconds",
              (int)_player.bufferEmptyCount,
              _player.bufferEmptyDuration);
        
        [_player stop];
        [_player.view removeFromSuperview];
        _player = nil;
        stat.text = [NSString stringWithFormat:@"url: %@\nstopped", _url];
        [self StopTimer];
    }
}

- (void)StartTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateStat:) userInfo:nil repeats:YES];
    switchVPP.enabled = NO;
}
- (void)StopTimer
{
    if (nil == timer) {
        return;
    }
    [timer invalidate];
    timer = nil;
    switchVPP.enabled = YES;
}
- (void)updateStat:(NSTimer *)t
{
    if ( 0 == lastCheckTime) {
        lastCheckTime = [self getCurrentTime];
        return;
    }
    if (nil == _player) {
        return;
    }
    double flowSize = [_player readSize];
    NSLog(@"flowSize:%f", flowSize);
    NSDictionary *meta = [_player getMetadata];
    KSYQosInfo *info = _player.qosInfo;
    stat.text = [NSString stringWithFormat:@
                 "SDK Version:v%@\n"
                 "streamerUrl:%@\n"
                 "serverIp:%@\n"
                 "clentIp:%@\n"
                 "Resolution:(width-height: %.0f-%.0f)\n"
                 "play time:%.1fs\n"
                 "playable Time:%.1fs\n"
                 "on demond Time%.1fs\n"
                 "cached times:%.1fs/%ld\n"
                 "cached mix time:%.1fs\n"
                 "speed: %0.1f kbps\nvideo/audio render cost time:%dms/%dms\n"
                 "HttpConnectTime:%@\n"
                 "HttpAnalyzeDns:%@\n"
                 "HttpFirstDataTime:%@\n"
                 "audioBufferByteLength:%d\n"
                 "audioBufferTimeLength:%d\n"
                 "audioTotalDataSize:%lld\n"
                 "videoBufferByteLength:%d\n"
                 "videoBufferTimeLength:%d\n"
                 "videoTotalDataSize:%lld\n"
                 "totalDataSize:%lld\n",
                 [_player getVersion],
                 _url,
                 serverIp,
                 [self getIPAddress],
                 _player.naturalSize.width,_player.naturalSize.height,
                 _player.currentPlaybackTime,
                 _player.playableDuration,
                 _player.duration,
                 _player.bufferEmptyDuration,
                 _player.bufferEmptyCount,
                 _player.bufferTimeMax,
                 8*1024.0*(flowSize - lastSize)/([self getCurrentTime] - lastCheckTime),
                 fvr_costtime, far_costtime,
                 [meta objectForKey:kKSYPLYHttpConnectTime],
                 [meta objectForKey:kKSYPLYHttpAnalyzeDns],
                 [meta objectForKey:kKSYPLYHttpFirstDataTime],
                 info.audioBufferByteLength,
                 info.audioBufferTimeLength,
                 info.audioTotalDataSize,
                 info.videoBufferByteLength,
                 info.videoBufferTimeLength,
                 info.videoTotalDataSize,
                 info.totalDataSize];
    lastCheckTime = [self getCurrentTime];
    lastSize = flowSize;
}

- (IBAction)onQuit:(id)sender {
    [self onStopVideo:nil];
    //[self.navigationController popToRootViewControllerAnimated:FALSE];
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPlay:
                [_player play];
                NSLog(@"play");
                break;
                
            case UIEventSubtypeRemoteControlPause:
                [_player pause];
                NSLog(@"pause");
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                
                break;
                
            default:
                break;
        }
    }
}

- (void)getQosBtnEvent
{
    [self StartTimer];
}

// Get IP Address
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

@end
