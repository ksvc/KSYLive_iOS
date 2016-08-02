//
//  KSYPlayerVC.m
//
//  Created by zengfanping on 11/3/15.
//  Copyright (c) 2015 zengfanping. All rights reserved.
//

#import "KSYPlayerVC.h"
#import <CommonCrypto/CommonDigest.h>

@interface KSYPlayerVC ()
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSURL *reloadUrl;
@property (strong, nonatomic) KSYMoviePlayerController *player;
@end

#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}
@implementation KSYPlayerVC{
    UILabel *stat;
    NSTimer* timer;
    NSTimer* repeateTimer;
    double lastSize;
    NSTimeInterval lastCheckTime;
    NSString* serverIp;
    UIView *videoView;
    UIButton *btnPlay;
    UIButton *btnPause;
    UIButton *btnReload;
    UIButton *btnStop;
    UIButton *btnQuit;
    UIButton *btnRepeat;
    UIButton *btnRotate;
    UIButton *btnContentMode;
    UILabel  *lableHWCodec;
    UISwitch  *switchHwCodec;
    UILabel  *labelMute;
    UISwitch *switchMute;
    
    UISlider *sliderLeftVolume;
    UISlider *sliderRightVolume;
    
    long long int prepared_time;
    int fvr_costtime;
    int far_costtime;
	int rotate_degress;
	int content_mode;
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
    repeateTimer = nil;
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
    
    //add rotate button
    btnRotate = [self addButtonWithTitle:@"rotate" action:@selector(onRotate:)];
   
	//add content mode buttpn
	btnContentMode = [self addButtonWithTitle:@"mode" action:@selector(onContentMode:)];
    
    //add repeate play button
    btnRepeat = [self addButtonWithTitle:@"repeat" action:@selector(onRepeatPlay:)];

	stat = [[UILabel alloc] init];
    stat.backgroundColor = [UIColor clearColor];
    stat.textColor = [UIColor redColor];
    stat.numberOfLines = -1;
    stat.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:stat];
    
    lableHWCodec = [[UILabel alloc] init];
    lableHWCodec.text = @"开启硬件解码";
    lableHWCodec.textColor = [UIColor lightGrayColor];
    [self.view addSubview:lableHWCodec];
    
    labelMute = [[UILabel alloc] init];
    labelMute.text = @"静音";
    labelMute.textColor = [UIColor lightGrayColor];
    [self.view addSubview:labelMute];
    

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
    
    switchMute = [[UISwitch alloc] init];
    [switchMute addTarget:self action:@selector(switchMuteEvent:) forControlEvents:UIControlEventValueChanged];
    [self.view  addSubview:switchMute];
    switchMute.on = NO;
    
    sliderLeftVolume = [[UISlider alloc] init];
    sliderLeftVolume.minimumValue = 0;
    sliderLeftVolume.maximumValue = 100;
    sliderLeftVolume.value = 100;
    [sliderLeftVolume addTarget:self action:@selector(onLeftVolumeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:sliderLeftVolume];

    sliderRightVolume = [[UISlider alloc] init];
    sliderRightVolume.minimumValue = 0;
    sliderRightVolume.maximumValue = 100;
    sliderRightVolume.value = 100;
    [sliderRightVolume addTarget:self action:@selector(onRightVolumeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:sliderRightVolume];
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
    lableHWCodec.frame =CGRectMake(xPos, yPos, btnWdt * 2, btnHgt);
    xPos = wdt/2 - btnWdt/2;
    switchHwCodec.frame = CGRectMake(xPos, gap, btnWdt, btnHgt);
    
    labelMute.frame  = CGRectMake(gap, btnHgt + 30, btnWdt*2, btnHgt);
    switchMute.frame = CGRectMake(xPos, btnHgt + 30, btnWdt, btnHgt);

    sliderLeftVolume.frame  = CGRectMake(gap, btnHgt + 35*2, 300, 20);
    sliderRightVolume.frame = CGRectMake(gap, btnHgt + 35*3, 300, 20);
    
    
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
    xPos = gap;
	yPos -= (btnHgt + gap);
    btnRotate.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnContentMode.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnRepeat.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
	stat.frame = CGRectMake(gap, 0, wdt, hgt);
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

-(void)onLeftVolumeChanged:(UISlider *)slider
{
    if (_player){
        [_player setVolume:slider.value/100 rigthVolume:sliderRightVolume.value/100];
    }
}

-(void)onRightVolumeChanged:(UISlider *)slider
{
    if (_player){
        [_player setVolume:sliderLeftVolume.value/100 rigthVolume:slider.value/100];
    }
}

- (void)switchMuteEvent:(UISwitch *)switchControl
{
    if (_player) {
        _player.shouldMute = switchControl.isOn;
        
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
        NSLog(@"KSYPlayerVC: %@ -- ip:%@", _url, serverIp);
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
        if (reason ==  MPMovieFinishReasonPlaybackEnded) {
            stat.text = [NSString stringWithFormat:@"player finish"];
        }else if (reason == MPMovieFinishReasonPlaybackError){
            stat.text = [NSString stringWithFormat:@"player Error : %@", [[notify userInfo] valueForKey:@"error"]];
        }else if (reason == MPMovieFinishReasonUserExited){
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
    
    if (MPMoviePlayerSuggestReloadNotification == notify.name)
    {
        NSLog(@"suggest using reload function!\n");
	}
    
    if(MPMoviePlayerPlaybackStatusNotification == notify.name)
    {
        int status = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackStatusUserInfoKey] intValue];
        if(MPMovieStatusVideoDecodeWrong == status)
        {
            NSLog(@"Video Decode Wrong!\n");
        }
        else if(MPMovieStatusAudioDecodeWrong == status)
        {
            NSLog(@"Audio Decode Wrong!\n");
        }
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
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerSuggestReloadNotification)
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerPlaybackStatusNotification)
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
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerSuggestReloadNotification
                                                 object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackStatusNotification
                                                 object:nil];
}
- (IBAction)onPlayVideo:(id)sender {
    
    if (_player) {
        [_player play];
        [self StartTimer];
        return;
    }
    lastSize = 0.0;
    _player = [[KSYMoviePlayerController alloc] initWithContentURL: _url];
    
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
//    _player.bufferTimeMax = 5;
    _player.shouldEnableVideoPostProcessing = TRUE;
    _player.scalingMode = MPMovieScalingModeAspectFit;
	content_mode = _player.scalingMode + 1;
	if(content_mode > MPMovieScalingModeFill)
		content_mode = MPMovieScalingModeNone;
    
    _player.videoDecoderMode = switchHwCodec.isOn? MPMovieVideoDecoderMode_Hardware : MPMovieVideoDecoderMode_Software;
//    _player.videoDecoderMode = MPMovieVideoDecoderMode_AUTO;
    _player.shouldMute  = switchMute.isOn;
    _player.shouldEnableKSYStatModule = TRUE;
    _player.shouldLoop = NO;
    [_player setTimeout:5 readTimeout:10];
    
    NSKeyValueObservingOptions opts = NSKeyValueObservingOptionNew;
    [_player addObserver:self forKeyPath:@"currentPlaybackTime" options:opts context:nil];
    [_player addObserver:self forKeyPath:@"clientIP" options:opts context:nil];
    [_player addObserver:self forKeyPath:@"localDNSIP" options:opts context:nil];
    
    NSLog(@"sdk version:%@", [_player getVersion]);
    prepared_time = (long long int)([self getCurrentTime] * 1000);
    [_player prepareToPlay];
    
}
- (IBAction)onReloadVideo:(id)sender {
    if (_player) {
        [_player reload:_reloadUrl is_flush:FALSE];
    }
}

- (IBAction)onPauseVideo:(id)sender {
    if (_player) {
        [_player pause];
    }
}
- (void)repeatPlay:(NSTimer *)t {
    if(nil == _player||arc4random() % 20 == 0 || _player.currentPlaybackTime > 60)
    {
        dispatch_main_sync_safe(^{
            [self onStopVideo:nil];
            [self onPlayVideo:nil];
            _player.bufferTimeMax = (arc4random() % 8) - 1;
            NSLog(@"bufferTimeMax %f", _player.bufferTimeMax);
        });
    }else if(arc4random() % 15 == 0){
        [self onReloadVideo:nil];
    }else if(arc4random() % 25 == 0){
        switchHwCodec.on = !switchHwCodec.isOn;
    }
}
- (IBAction)onRepeatPlay:(id)sender{
    if ([repeateTimer isValid]) {
        [repeateTimer invalidate];
    }else{
        repeateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(repeatPlay:) userInfo:nil repeats:YES];
    }
}
- (IBAction)onStopVideo:(id)sender {
    if (_player) {
        NSLog(@"player download flow size: %f MB", _player.readSize);
        NSLog(@"buffer monitor  result: \n   empty count: %d, lasting: %f seconds",
              (int)_player.bufferEmptyCount,
              _player.bufferEmptyDuration);
        
        [_player stop];
        
        [_player removeObserver:self forKeyPath:@"currentPlaybackTime" context:nil];
        [_player removeObserver:self forKeyPath:@"clientIP" context:nil];
        [_player removeObserver:self forKeyPath:@"localDNSIP" context:nil];
        
        [_player.view removeFromSuperview];
        _player = nil;
        stat.text = [NSString stringWithFormat:@"url: %@\nstopped", _url];
        [self StopTimer];
    }
}

- (void)StartTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateStat:) userInfo:nil repeats:YES];
}
- (void)StopTimer
{
    if (nil == timer) {
        return;
    }
    [timer invalidate];
    timer = nil;
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
//    NSLog(@"flowSize:%f", flowSize);
    NSDictionary *meta = [_player getMetadata];
    KSYQosInfo *info = _player.qosInfo;
    stat.text = [NSString stringWithFormat:@
                 "SDK Version:v%@\n"
                 "streamerUrl:%@\n"
                 "serverIp:%@\n"
                 "clientIp:%@\n"
                 "localDnsIp:%@\n"
                 "Resolution:(w-h: %.0f-%.0f)\n"
                 "play time:%.1fs\n"
                 "playable Time:%.1fs\n"
                 "video duration%.1fs\n"
                 "cached times:%.1fs/%ld\n"
                 "cached max time:%.1fs\n"
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
                 _player.clientIP,
                 _player.localDNSIP,
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

- (IBAction)onRotate:(id)sender {
	
	rotate_degress += 90;
	if(rotate_degress >= 360)
		rotate_degress = 0;

    if (_player) {
        _player.rotateDegress = rotate_degress;
    }
}

- (IBAction)onContentMode:(id)sender {

	if (_player) {
        _player.scalingMode = content_mode;
    }
	content_mode++;
	if(content_mode > MPMovieScalingModeFill)
		content_mode = MPMovieScalingModeNone;
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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if([keyPath isEqual:@"currentPlaybackTime"])
    {
        NSTimeInterval position = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        //NSLog(@"current playback position is:%.1fs\n", position);
    }
    else if([keyPath isEqual:@"clientIP"])
    {
        NSLog(@"client IP is %@\n", [change objectForKey:NSKeyValueChangeNewKey]);
    }
    else if([keyPath isEqual:@"localDNSIP"])
    {
        NSLog(@"local DNS IP is %@\n", [change objectForKey:NSKeyValueChangeNewKey]);
    }
}
@end
