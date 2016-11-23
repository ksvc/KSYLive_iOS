//
//  KSYPlayerVC.m
//
//  Created by zengfanping on 11/3/15.
//  Copyright (c) 2015 zengfanping. All rights reserved.
//

#import "KSYPlayerVC.h"
#import <CommonCrypto/CommonDigest.h>
#import "QRViewController.h"
#import "URLTableViewController.h"
#import "KSYProgressView.h"

@interface KSYPlayerVC () <UITextFieldDelegate>
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
    UIButton *btnResume;
    UIButton *btnStop;
    UIButton *btnQuit;
    UIButton *btnRotate;
    UIButton *btnContentMode;
    UIButton *btnReload;
    UIButton *btnMute;
    UIButton *btnShotScreen;
    UIButton *btnMirror;
    
    UILabel  *lableHWCodec;
    UISwitch  *switchHwCodec;
    
    UILabel *labelVolume;
    UISlider *sliderVolume;
    
    KSYProgressView *progressView;
    
    BOOL usingReset;
    BOOL shouldMute;
    
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
    
    [self addObserver:self forKeyPath:@"player" options:NSKeyValueObservingOptionNew context:nil];
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:leftSwipeRecognizer];
    [self.view addGestureRecognizer:rightSwipeRecognizer];
    
    // 该变量决定停止播放时使用的接口，YES时调用reset接口，NO时调用stop接口
    usingReset = YES;
    
    shouldMute = NO;
    
    progressView.hidden = YES;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"player"];
}

- (void) initUI {
    //add UIView for player
    videoView = [[UIView alloc] init];
    videoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:videoView];
    
    //add play button
    btnPlay = [self addButtonWithTitle:@"播放" action:@selector(onPlayVideo:)];

    //add pause button
    btnPause = [self addButtonWithTitle:@"暂停" action:@selector(onPauseVideo:)];

    //add resume button
    btnResume = [self addButtonWithTitle:@"继续" action:@selector(onResumeVideo:)];
    
    //add stop button
    btnStop = [self addButtonWithTitle:@"停止" action:@selector(onStopVideo:)];

    //add quit button
    btnQuit = [self addButtonWithTitle:@"退出" action:@selector(onQuit:)];
    
    //add rotate button
    btnRotate = [self addButtonWithTitle:@"旋转" action:@selector(onRotate:)];
   
	//add content mode buttpn
	btnContentMode = [self addButtonWithTitle:@"缩放" action:@selector(onContentMode:)];
    
    //add reload button
    btnReload = [self addButtonWithTitle:@"reload" action:@selector(onReloadVideo:)];
    
    btnShotScreen = [self addButtonWithTitle:@"截图" action:@selector(onShotScreen:)];
    
    btnMute = [self addButtonWithTitle:@"mute" action:@selector(onMute:)];
    
    btnMirror = [self addButtonWithTitle:@"镜像" action:@selector(onMirror:)];

	stat = [[UILabel alloc] init];
    stat.backgroundColor = [UIColor clearColor];
    stat.textColor = [UIColor redColor];
    stat.numberOfLines = -1;
    stat.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:stat];
    
    lableHWCodec = [[UILabel alloc] init];
    lableHWCodec.text = @"硬解码";
    lableHWCodec.textColor = [UIColor lightGrayColor];
    [self.view addSubview:lableHWCodec];
    
    labelVolume = [[UILabel alloc] init];
    labelVolume.text = @"音量";
    labelVolume.textColor = [UIColor lightGrayColor];
    [self.view addSubview:labelVolume];
    
    switchHwCodec = [[UISwitch alloc] init];
    [self.view  addSubview:switchHwCodec];
    switchHwCodec.on = YES;
    
    sliderVolume = [[UISlider alloc] init];
    sliderVolume.minimumValue = 0;
    sliderVolume.maximumValue = 100;
    sliderVolume.value = 100;
    [sliderVolume addTarget:self action:@selector(onVolumeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:sliderVolume];
    
    progressView = [[KSYProgressView alloc] init];
    [self.view addSubview:progressView];

    [self layoutUI];
    
    [self.view bringSubviewToFront:stat];
    stat.frame = [UIScreen mainScreen].bounds;
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
    CGFloat gap =15;
    CGFloat btnWdt = ( (wdt-gap) / 5) - gap;
    CGFloat btnHgt = 30;
    CGFloat xPos = 0;
    CGFloat yPos = 0;

    yPos = 2 * gap;
    xPos = gap;
    labelVolume.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += btnWdt + gap;
    sliderVolume.frame  = CGRectMake(xPos, yPos, wdt - 3 * gap - btnWdt, btnHgt);
    yPos += btnHgt + gap;
    xPos = gap;
    lableHWCodec.frame =CGRectMake(xPos, yPos, btnWdt * 2, btnHgt);
    xPos += btnWdt + gap;
    switchHwCodec.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    videoView.frame = CGRectMake(0, 0, wdt, hgt);
    
    xPos = gap;
    yPos = hgt - btnHgt - gap;
    btnPlay.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnPause.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnResume.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
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
    btnShotScreen.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnReload.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnMute.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    xPos = gap;
    yPos -= (btnHgt + gap);
    btnMirror.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    xPos = gap;
    yPos = btnMirror.frame.origin.y - btnHgt - gap;
    progressView.frame = CGRectMake(xPos, yPos, wdt - 2 * gap, btnHgt);
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

-(void)onVolumeChanged:(UISlider *)slider
{
    if (_player){
        [_player setVolume:slider.value/100 rigthVolume:slider.value/100];
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
        NSLog(@"KSYPlayerVC: %@ -- ip:%@", [[_player contentURL] absoluteString], serverIp);
        [self StartTimer];
        prepared_time = (long long int)([self getCurrentTime] * 1000);
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
        else if (MPMovieStatusHWCodecUsed == status )
        {
            NSLog(@"Hardware Codec used\n");
        }
        else if (MPMovieStatusSWCodecUsed == status )
        {
            NSLog(@"Software Codec used\n");
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
                                              object:_player];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerPlaybackStateDidChangeNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerPlaybackDidFinishNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerLoadStateDidChangeNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMovieNaturalSizeAvailableNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerFirstVideoFrameRenderedNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerFirstAudioFrameRenderedNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerSuggestReloadNotification)
                                              object:_player];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerPlaybackStatusNotification)
                                              object:_player];
}

- (void)releaseObservers 
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                 object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                 object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackDidFinishNotification
                                                 object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerLoadStateDidChangeNotification
                                                 object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMovieNaturalSizeAvailableNotification
                                                 object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerFirstVideoFrameRenderedNotification
                                                 object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerFirstAudioFrameRenderedNotification
                                                 object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerSuggestReloadNotification
                                                 object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackStatusNotification
                                                 object:_player];
}

- (void)initPlayerWithURL:(NSURL *)aURL {
    lastSize = 0.0;
    self.player = [[KSYMoviePlayerController alloc] initWithContentURL: aURL];
    [self setupObservers];
    
    _player.logBlock = ^(NSString *logJson){
        NSLog(@"logJson is %@",logJson);
    };
    
#if 0
    _player.videoDataBlock = ^(CMSampleBufferRef sampleBuffer){
        CMItemCount count;
        CMSampleTimingInfo timing_info;
        OSErr ret = CMSampleBufferGetOutputSampleTimingInfoArray(sampleBuffer, 1, &timing_info, &count);
        if ( ret == noErr) {
            NSLog(@"video Pts %d %lld",  timing_info.presentationTimeStamp.timescale, timing_info.presentationTimeStamp.value );
        }
    };
    
    _player.audioDataBlock = ^(CMSampleBufferRef sampleBuffer){
        CMItemCount count;
        CMSampleTimingInfo timing_info;
        OSErr ret = CMSampleBufferGetOutputSampleTimingInfoArray(sampleBuffer, 1, &timing_info, &count);
        if ( ret == noErr) {
            NSLog(@"audio Pts %d %lld",  timing_info.presentationTimeStamp.timescale, timing_info.presentationTimeStamp.value );
        }
    };
#endif
    stat.text = [NSString stringWithFormat:@"url %@", aURL];
    _player.controlStyle = MPMovieControlStyleNone;
    [_player.view setFrame: videoView.bounds];  // player's frame must match parent's
    [videoView addSubview: _player.view];
    [videoView bringSubviewToFront:stat];
    videoView.autoresizesSubviews = TRUE;
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _player.shouldAutoplay = TRUE;
    _player.shouldEnableVideoPostProcessing = TRUE;
    _player.scalingMode = MPMovieScalingModeAspectFit;
    content_mode = _player.scalingMode + 1;
    if(content_mode > MPMovieScalingModeFill)
        content_mode = MPMovieScalingModeNone;
    
    _player.videoDecoderMode = switchHwCodec.isOn? MPMovieVideoDecoderMode_Hardware : MPMovieVideoDecoderMode_Software;
    _player.shouldMute = shouldMute;
//    _player.rotateDegress = 90;
//    _player.mirror = YES;
    _player.shouldEnableKSYStatModule = TRUE;
    _player.shouldLoop = NO;
    _player.deinterlaceMode = MPMovieVideoDeinterlaceMode_Auto;
    [_player setTimeout:10 readTimeout:60];
    
    NSKeyValueObservingOptions opts = NSKeyValueObservingOptionNew;
    [_player addObserver:self forKeyPath:@"currentPlaybackTime" options:opts context:nil];
    [_player addObserver:self forKeyPath:@"clientIP" options:opts context:nil];
    [_player addObserver:self forKeyPath:@"localDNSIP" options:opts context:nil];
    
    NSLog(@"sdk version:%@", [_player getVersion]);
    prepared_time = (long long int)([self getCurrentTime] * 1000);
    [_player prepareToPlay];
}

- (IBAction)onShotScreen:(id)sender {
    if (_player) {
        UIImage *thumbnailImage = _player.thumbnailImageAtCurrentTime;
        UIImageWriteToSavedPhotosAlbum(thumbnailImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    if (error == nil) {
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"O(∩_∩)O~~"
                                                        message:@"截图已保存至手机相册"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [toast show];
        
    }else{
        
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"￣へ￣"
                                                        message:@"截图失败！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [toast show];
    }
    
}

- (IBAction)onPlayVideo:(id)sender {
    
    if(nil == _player)
    {
        [self initPlayerWithURL:_url];
    } else {
        [_player setUrl:[NSURL URLWithString:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"]];
        [_player prepareToPlay];
    }
}

- (IBAction)onReloadVideo:(id)sender {
    if (_player) {
        [_player reload:_reloadUrl flush:YES mode:MPMovieReloadMode_Accurate];
    }
}

- (IBAction)onPauseVideo:(id)sender {
    if (_player) {
        [_player pause];
    }
}

- (IBAction)onResumeVideo:(id)sender {
    if (_player) {
        [_player play];
        [self StartTimer];
    }
}

- (IBAction)onStopVideo:(id)sender {
    if (_player) {
        NSLog(@"player download flow size: %f MB", _player.readSize);
        NSLog(@"buffer monitor  result: \n   empty count: %d, lasting: %f seconds",
              (int)_player.bufferEmptyCount,
              _player.bufferEmptyDuration);
        
        if(usingReset)
            [_player reset:NO];
        else
        {
            [_player stop];
            
            [_player removeObserver:self forKeyPath:@"currentPlaybackTime" context:nil];
            [_player removeObserver:self forKeyPath:@"clientIP" context:nil];
            [_player removeObserver:self forKeyPath:@"localDNSIP" context:nil];
            
            [self releaseObservers];
            
            [_player.view removeFromSuperview];
            self.player = nil;
        }
        [self StopTimer];
    }
}

- (void)StartTimer
{
    progressView.totalTimeInSeconds = _player.duration;
    if(timer != nil){
        return;
    }
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
    NSDictionary *meta = [_player getMetadata];
    KSYQosInfo *info = _player.qosInfo;
    stat.text = [NSString stringWithFormat:@
                 "SDK版本:v%@\n"
                 "播放器实例:%p\n"
                 "拉流URL:%@\n"
                 "服务器IP:%@\n"
                 "客户端IP:%@\n"
                 "本地DNS IP:%@\n"
                 "分辨率:(宽-高: %.0f-%.0f)\n"
                 "已播时长:%.1fs\n"
                 "缓存时长:%.1fs\n"
                 "视频总长%.1fs\n"
                 "cache次数:%.1fs/%ld\n"
                 "最大缓冲时长:%.1fs\n"
                 "速度: %0.1f kbps\n视频/音频渲染用时:%dms/%dms\n"
                 "HTTP连接用时:%ldms\n"
                 "DNS解析用时:%ldms\n"
                 "首包到达用时（连接建立后）:%ldms\n"
                 "音频缓冲队列长度:%.1fMB\n"
                 "音频缓冲队列时长:%.1fs\n"
                 "音频缓冲区数据量:%.1fMB\n"
                 "视频缓冲队列长度:%.1fMB\n"
                 "视频缓冲队列时长:%.1fs\n"
                 "视频缓冲区数据量:%.1fMB\n"
                 "缓冲区总数据量%.1fMB\n"
                 "解码帧率:%.2f 显示帧率:%.2f\n",

                 [_player getVersion],
                 _player,
                 [[_player contentURL] absoluteString],
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
                 (long)[(NSNumber *)[meta objectForKey:kKSYPLYHttpConnectTime] integerValue],
                 (long)[(NSNumber *)[meta objectForKey:kKSYPLYHttpAnalyzeDns] integerValue],
                 (long)[(NSNumber *)[meta objectForKey:kKSYPLYHttpFirstDataTime] integerValue],
                 (float)info.audioBufferByteLength / 1e6,
                 (float)info.audioBufferTimeLength / 1e3,
                 (float)info.audioTotalDataSize / 1e6,
                 (float)info.videoBufferByteLength / 1e6,
                 (float)info.videoBufferTimeLength / 1e3,
                 (float)info.videoTotalDataSize / 1e6,
                 (float)info.totalDataSize / 1e6,
                 info.videoDecodeFPS,
                 info.videoRefreshFPS];
    lastCheckTime = [self getCurrentTime];
    lastSize = flowSize;
    
    [self updateCacheProgress];
}

- (void)updateCacheProgress {
    progressView.cacheProgress = _player.playableDuration / _player.duration;
}

- (IBAction)onQuit:(id)sender {
    if(_player)
    {
        [_player stop];
        
        [_player removeObserver:self forKeyPath:@"currentPlaybackTime" context:nil];
        [_player removeObserver:self forKeyPath:@"clientIP" context:nil];
        [_player removeObserver:self forKeyPath:@"localDNSIP" context:nil];
        
        [self releaseObservers];
        
        [_player.view removeFromSuperview];
        self.player = nil;
    }
    
    [self StopTimer];
    [self dismissViewControllerAnimated:FALSE completion:nil];
    stat.text = nil;
}

- (IBAction)onRotate:(id)sender {
    if (_player) {
        rotate_degress = _player.rotateDegress;
        rotate_degress += 90;
        if(rotate_degress >= 360)
            rotate_degress = 0;

        _player.rotateDegress = rotate_degress;
    }
}

- (IBAction)onMute:(id)sender {
    if (_player) {
        shouldMute = shouldMute ? NO : YES;
        _player.shouldMute = shouldMute;
    }
}

- (IBAction)onMirror:(id)sender {
    if (_player) {
        _player.mirror = (!_player.mirror);
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
//        NSTimeInterval position = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        //NSLog(@"current playback position is:%.1fs\n", position);
        progressView.playProgress = _player.currentPlaybackTime / _player.duration;
    }
    else if([keyPath isEqual:@"clientIP"])
    {
        NSLog(@"client IP is %@\n", [change objectForKey:NSKeyValueChangeNewKey]);
    }
    else if([keyPath isEqual:@"localDNSIP"])
    {
        NSLog(@"local DNS IP is %@\n", [change objectForKey:NSKeyValueChangeNewKey]);
    }
    else if ([keyPath isEqualToString:@"player"]) {
        if (_player) {
            progressView.hidden = NO;
            __weak typeof(_player) weakPlayer = _player;
            progressView.dragingSliderCallback = ^(float progress){
                typeof(weakPlayer) strongPlayer = weakPlayer;
                double seekPos = progress * strongPlayer.duration;
                //strongPlayer.currentPlaybackTime = progress * strongPlayer.duration;
                //使用currentPlaybackTime设置为依靠关键帧定位
                //使用seekTo:accurate并且将accurate设置为YES时为精确定位
                [strongPlayer seekTo:seekPos accurate:YES];
            };
        } else {
            progressView.hidden = YES;
        }
    }
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)swpie {
    if (swpie.direction == UISwipeGestureRecognizerDirectionRight) {
        CGRect originalFrame = stat.frame;
        stat.frame = CGRectMake(0, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height);
    }
    if (swpie.direction == UISwipeGestureRecognizerDirectionLeft) {
        CGRect originalFrame = stat.frame;
        stat.frame = CGRectMake(-originalFrame.size.width, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height);
    }
}

@end
