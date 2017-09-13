//
//  KSYSamplestPlayVC.m
//  KSYLiveDemo
//
//  Created by zhengwei on 2017/6/14.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYUIView.h"
#import "KSYSimplePlayVC.h"
#import "KSYProgressView.h"

#define ELEMENT_GAP  6

@interface KSYSimplePlayVC ()
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSURL *reloadUrl;
@property(strong, nonatomic) NSArray *fileList;
@property (nonatomic, readwrite) KSYPlayerCfgVC *config;
@end

@implementation KSYSimplePlayVC{
    KSYUIView *ctrlView;
    UIView *videoView;
    UIButton *btnQuit;
    NSString* serverIp;
    BOOL reloading;
    long long int prepared_time;
    int fvr_costtime;
    int far_costtime;
    BOOL bStopped;
    NSMutableArray *registeredNotifications;
    
    KSYProgressView *progressView;
}

- (instancetype)initWithURLAndConfigure:(NSURL *)url fileList:(NSArray *)fileList config:(KSYPlayerCfgVC *)config{
    if((self = [super init])) {
        self.url = url;
        self.reloadUrl = url;
        self.fileList = fileList;
        self.config = config;
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"player"];
}

#pragma mark layout
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self addObserver:self forKeyPath:@"player" options:NSKeyValueObservingOptionNew context:nil];
    [self initPlayerWithURL:_url fileList:_fileList config:_config];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_player){
        [_player.view setFrame: videoView.bounds];
        [videoView addSubview: _player.view];
    }
}

- (void) setupUI {
    ctrlView = [[KSYUIView alloc] initWithFrame:self.view.bounds];
    ctrlView.backgroundColor = [UIColor blackColor];
    ctrlView.gap = ELEMENT_GAP;
    @WeakObj(self);
    ctrlView.onBtnBlock = ^(id sender){
        [selfWeak  onBtn:sender];
    };
    //add UIView for player
    videoView = [[UIView alloc] init];
    videoView.backgroundColor = [UIColor whiteColor];
    [ctrlView addSubview:videoView];
    btnQuit = [ctrlView addButton:@"退出"];
    progressView = [[KSYProgressView alloc] init];
    [ctrlView addSubview:progressView];
    [self layoutUI];
    [self.view addSubview: ctrlView];
}

- (void) layoutUI {
    ctrlView.frame = self.view.frame;
    [ctrlView layoutUI];
    videoView.frame  = ctrlView.frame;
    CGFloat btnX = self.view.bounds.size.width - ctrlView.gap - 60;
    CGFloat btnY = 20;
    btnQuit.frame = CGRectMake(btnX, btnY, 60, 30);

    ctrlView.yPos = ctrlView.frame.size.height - ctrlView.gap - ctrlView.btnH;
    [ctrlView putRow:@[progressView]];
}

#pragma mark common
- (NSTimeInterval) getCurrentTime{
    return [[NSDate date] timeIntervalSince1970];
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

- (NSString *) netStatus2Str:(KSYNetworkStatus)networkStatus{
    NSString *netString = nil;
    if(networkStatus == KSYNotReachable)
        netString = @"NO INTERNET";
    else if(networkStatus == KSYReachableViaWiFi)
        netString = @"WIFI";
    else if(networkStatus == KSYReachableViaWWAN)
        netString = @"WWAN";
    else
        netString = @"Unknown";
    return netString;
}

#pragma mark init player
- (void)initPlayerWithURL:(NSURL *)aURL fileList:(NSArray *)fileList config:(KSYPlayerCfgVC *)config{
    //初始化播放器并设置播放地址
    self.player = [[KSYMoviePlayerController alloc] initWithContentURL: aURL fileList:fileList sharegroup:nil];
    [self setupObservers:_player];
    _player.controlStyle = MPMovieControlStyleNone;
    [_player.view setFrame: videoView.bounds];  // player's frame must match parent's
    [videoView addSubview: _player.view];
    videoView.autoresizesSubviews = TRUE;
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    if(config)
    {
        //设置播放参数
        _player.videoDecoderMode = config.decodeMode;
        _player.scalingMode = config.contentMode;
        _player.shouldAutoplay = config.bAutoPlay;
        _player.deinterlaceMode = config.deinterlaceMode;
        _player.shouldLoop = config.bLoop;
        _player.bInterruptOtherAudio = config.bAudioInterrupt;
        _player.bufferTimeMax = config.bufferTimeMax;
        _player.bufferSizeMax = config.bufferSizeMax;
        [_player setTimeout:config.connectTimeout readTimeout:config.readTimeout];
    }
    NSKeyValueObservingOptions opts = NSKeyValueObservingOptionNew;
    [_player addObserver:self forKeyPath:@"currentPlaybackTime" options:opts context:nil];
    [_player addObserver:self forKeyPath:@"clientIP" options:opts context:nil];
    [_player addObserver:self forKeyPath:@"localDNSIP" options:opts context:nil];
    prepared_time = (long long int)([self getCurrentTime] * 1000);
    [_player prepareToPlay];
}

- (void)registerObserver:(NSString *)notification player:(KSYMoviePlayerController*)player {
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(notification)
                                              object:player];
}

- (void)setupObservers:(KSYMoviePlayerController*)player
{
    [self registerObserver:MPMediaPlaybackIsPreparedToPlayDidChangeNotification player:player];
    [self registerObserver:MPMoviePlayerPlaybackStateDidChangeNotification player:player];
    [self registerObserver:MPMoviePlayerPlaybackDidFinishNotification player:player];
    [self registerObserver:MPMoviePlayerLoadStateDidChangeNotification player:player];
    [self registerObserver:MPMovieNaturalSizeAvailableNotification player:player];
    [self registerObserver:MPMoviePlayerFirstVideoFrameRenderedNotification player:player];
    [self registerObserver:MPMoviePlayerFirstAudioFrameRenderedNotification player:player];
    [self registerObserver:MPMoviePlayerSuggestReloadNotification player:player];
    [self registerObserver:MPMoviePlayerPlaybackStatusNotification player:player];
    [self registerObserver:MPMoviePlayerNetworkStatusChangeNotification player:player];
    [self registerObserver:MPMoviePlayerSeekCompleteNotification player:player];
}

- (void)releaseObservers:(KSYMoviePlayerController*)player
{
    for (NSString *name in registeredNotifications) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:name
                                                      object:player];
    }
}

-(void)handlePlayerNotify:(NSNotification*)notify
{
    if (!_player) {
        return;
    }
    if (MPMediaPlaybackIsPreparedToPlayDidChangeNotification ==  notify.name) {
        progressView.totalTimeInSeconds = _player.duration;
        if(_player.shouldAutoplay == NO)
            [_player play];
        serverIp = [_player serverAddress];
        NSLog(@"KSYPlayerVC: %@ -- ip:%@", [[_player contentURL] absoluteString], serverIp);
        reloading = NO;
    }
    if (MPMoviePlayerPlaybackStateDidChangeNotification ==  notify.name) {
        NSLog(@"------------------------");
        NSLog(@"player playback state: %ld", (long)_player.playbackState);
        NSLog(@"------------------------");
    }
    if (MPMoviePlayerLoadStateDidChangeNotification ==  notify.name) {
        NSLog(@"player load state: %ld", (long)_player.loadState);
        if (MPMovieLoadStateStalled & _player.loadState) {
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
    }
    if (MPMovieNaturalSizeAvailableNotification ==  notify.name) {
        NSLog(@"video size %.0f-%.0f, rotate:%ld\n", _player.naturalSize.width, _player.naturalSize.height, (long)_player.naturalRotate);
        if(((_player.naturalRotate / 90) % 2  == 0 && _player.naturalSize.width > _player.naturalSize.height) ||
           ((_player.naturalRotate / 90) % 2 != 0 && _player.naturalSize.width < _player.naturalSize.height))
        {
            //如果想要在宽大于高的时候横屏播放，你可以在这里旋转
        }
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
        if(!reloading)
        {
            reloading = YES;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
                if (_player) {
                    NSLog(@"reload stream");
                    [_player reload:_reloadUrl flush:YES mode:MPMovieReloadMode_Accurate];
                }
            });
        }
    }
    if(MPMoviePlayerPlaybackStatusNotification == notify.name)
    {
        int status = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackStatusUserInfoKey] intValue];
        if(MPMovieStatusVideoDecodeWrong == status)
            NSLog(@"Video Decode Wrong!\n");
        else if(MPMovieStatusAudioDecodeWrong == status)
            NSLog(@"Audio Decode Wrong!\n");
        else if (MPMovieStatusHWCodecUsed == status )
            NSLog(@"Hardware Codec used\n");
        else if (MPMovieStatusSWCodecUsed == status )
            NSLog(@"Software Codec used\n");
        else if(MPMovieStatusDLCodecUsed == status)
            NSLog(@"AVSampleBufferDisplayLayer  Codec used");
    }
    if(MPMoviePlayerNetworkStatusChangeNotification == notify.name)
    {
        int currStatus = [[[notify userInfo] valueForKey:MPMoviePlayerCurrNetworkStatusUserInfoKey] intValue];
        int lastStatus = [[[notify userInfo] valueForKey:MPMoviePlayerLastNetworkStatusUserInfoKey] intValue];
        NSLog(@"network reachable change from %@ to %@\n", [self netStatus2Str:lastStatus], [self netStatus2Str:currStatus]);
    }
    if(MPMoviePlayerSeekCompleteNotification == notify.name)
    {
        NSLog(@"Seek complete");
    }
}

#pragma mark on Button
- (void)onBtn:(UIButton *)btn{
      if(btn == btnQuit)
        [self onQuit:btn];
}

- (void)updateCacheProgress {
    CGFloat duration = _player.duration;
    CGFloat playableDuration = _player.playableDuration;
    if(duration > 0){
        progressView.cacheProgress = playableDuration / duration;
    }
    else{
        progressView.cacheProgress = 0.0;
    }
}

- (IBAction)onQuit:(id)sender {
    if(_player)
    {
        [_player stop];
        [_player removeObserver:self forKeyPath:@"currentPlaybackTime" context:nil];
        [_player removeObserver:self forKeyPath:@"clientIP" context:nil];
        [_player removeObserver:self forKeyPath:@"localDNSIP" context:nil];
        [self releaseObservers:_player];
        [_player.view removeFromSuperview];
        self.player = nil;
    }
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

- (void)onTimer:(NSTimer *)t
{
    if(nil == _player) {
        return;
    }
    
    if(_player.playbackState != MPMoviePlaybackStateStopped && _player.isPreparedToPlay)
    {
        NSLog(@"CPU usage:%0.2f%% Mem:%.1fMB Battery:%d%%",[KSYUIVC cpu_usage],[KSYUIVC memory_usage],[KSYUIVC getCurrentBatteryLevel]);
    }
}
#pragma mark kvo
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if([keyPath isEqual:@"currentPlaybackTime"])
    {
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
@end
