//
//  PlayController.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/11.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "PlayController.h"
#import "VideoModel.h"
#import "AppDelegate.h"
#import "RecordeViewController.h"

@interface PlayController ()
@property (nonatomic, strong) VideoModel               *videoModel;
@property (nonatomic, assign) int64_t   prepared_time;
@property (nonatomic, assign) NSTimeInterval playedTime;
@property (nonatomic, strong) RecordeViewController     *recordeController;

@property (nonatomic, strong) UILabel                   *labelStat;
@property (nonatomic, strong) UILabel                   *labelMsg;
@property (nonatomic, strong) NSTimer                   *timer;
@property (nonatomic, strong) KSYReachability           *reach;
@property (nonatomic, assign) KSYNetworkStatus           preStatue;
@property (nonatomic, assign) NSTimeInterval             lastCheckTime;

@property (nonatomic, assign) int                        fvr_costtime;
@property (nonatomic, assign) int                        far_costtime;
@property (nonatomic, assign) int                        msgNum;
@property (nonatomic, assign) double                     lastSize;
@property (nonatomic, assign) BOOL                       reloading;
@property (nonatomic, copy)   NSString                  *serverIp;
@property (nonatomic, copy)   NSDictionary              *mediaMeta;
@property (nonatomic, strong) NSURL                     *reloadUrl;

@end

@implementation PlayController

- (instancetype)initWithVideoModel:(VideoModel *)videoModel {
    if (self = [super init]) {
        _videoModel = videoModel;
        _reloadUrl = [NSURL URLWithString:videoModel.PlayURL[videoModel.definitation.integerValue]];
    }
    return self;
}

- (VideoModel *)currentVideoModel {
    return _videoModel;
}

- (void)configeVideoModel:(VideoModel *)videoModel {
    _videoModel = videoModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerHandGesture];
    [self addObservers];
    [self setupPlayer];
    [self setupDebugeUI];
}

- (void)dealloc {
    [self.player stop];
    [self.player removeObserver:self forKeyPath:@"currentPlaybackTime"];
    [self removeObserver:self forKeyPath:@"player"];
    if (_timer) {
        [self rmObservers];
    }
    _reach = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupDebugeUI {
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    SettingModel *model = delegate.settingModel;
    if (!model.showDebugLog) {
        return;
    }
    
    self.labelStat = [self addLabelWithText:nil textColor:[UIColor redColor]];
    [self.view addSubview:_labelStat];
    
    self.labelMsg = [self addLabelWithText:nil textColor:[UIColor blueColor]];
    [self.view addSubview:_labelMsg];
    
    [self.labelStat mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.labelMsg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (UILabel *)addLabelWithText:(NSString *)text textColor:(UIColor*)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = textColor;
    label.numberOfLines = -1;
    label.text = text;
    label .textAlignment = NSTextAlignmentLeft;
    return label;
}

- (void)rmObservers {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)addObservers {
    // statistics update every seconds
    [self addObserver:self forKeyPath:@"player" options:NSKeyValueObservingOptionNew context:nil];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                               target:self
                                             selector:@selector(onTimer:)
                                             userInfo:nil
                                              repeats:YES];
    NSNotificationCenter * dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(netWorkChange)
               name:kKSYReachabilityChangedNotification
             object:nil];
    _reach = [KSYReachability reachabilityWithHostName:@"http://www.kingsoft.com"];
    [_reach startNotifier];
}

- (void)netWorkChange{
    KSYNetworkStatus currentStatus = [_reach currentReachabilityStatus];
    if (currentStatus == _preStatue) {
        return;
    }
    _preStatue = currentStatus;
    switch (currentStatus) {
        case KSYNotReachable:
            _networkStatus = @"无网络";
            break;
        case KSYReachableViaWWAN:
            _networkStatus = @"移动网络";
            break;
        case KSYReachableViaWiFi:
            _networkStatus = @"WIFI";
            break;
        default:
            return;
    }
    if( _onNetworkChange ){
        _onNetworkChange(_networkStatus);
    }
}

- (void)setupPlayer {
    //初始化播放器并设置播放地址
    self.player = [[KSYMoviePlayerController alloc] initWithContentURL: [NSURL URLWithString:_videoModel.PlayURL.firstObject] fileList:nil sharegroup:nil];
    [self setupObservers:_player];
    _player.controlStyle = MPMovieControlStyleNone;
    [self.view addSubview:_player.view];
    [_player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    SettingModel *settingModel = delegate.settingModel;
    
    if(settingModel) {
        _player.videoDecoderMode = settingModel.videoDecoderMode;
        _player.shouldLoop = settingModel.shouldLoop;
        _player.bufferTimeMax = settingModel.bufferTimeMax;
        _player.bufferSizeMax = settingModel.bufferSizeMax;
        [_player setTimeout:(int)settingModel.preparetimeOut readTimeout:(int)settingModel.readtimeOut];
    }
    NSKeyValueObservingOptions opts = NSKeyValueObservingOptionNew;
    [_player addObserver:self forKeyPath:@"currentPlaybackTime" options:opts context:nil];
    self.prepared_time = (long long int)([[NSDate date] timeIntervalSince1970] * 1000);
    [_player prepareToPlay];
}

- (void)registerObserver:(NSString *)notification player:(KSYMoviePlayerController*)player {
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(notification)
                                              object:player];
}

- (void)setupObservers:(KSYMoviePlayerController*)player {
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

- (void)notifyHandler:(NSNotification*)notify {
    if (!_player) {
        return;
    }
    if (MPMediaPlaybackIsPreparedToPlayDidChangeNotification ==  notify.name) {
        self.labelStat.text = [NSString stringWithFormat:@"player prepared"];
        if(_player.shouldAutoplay == NO)
            [_player play];
        self.serverIp = [_player serverAddress];
        NSLog(@"KSYPlayerVC: %@ -- ip:%@", [[_player contentURL] absoluteString], _serverIp);
        self.mediaMeta  = [_player getMetadata];
        self.reloading = NO;
    }
    if (MPMoviePlayerPlaybackStateDidChangeNotification ==  notify.name) {
        NSLog(@"------------------------");
        NSLog(@"player playback state: %ld", (long)_player.playbackState);
        NSLog(@"------------------------");
    }
    if (MPMoviePlayerLoadStateDidChangeNotification ==  notify.name) {
        NSLog(@"player load state: %ld", (long)_player.loadState);
        if (MPMovieLoadStateStalled & _player.loadState) {
            self.labelStat.text = [NSString stringWithFormat:@"player start caching"];
            NSLog(@"player start caching");
        }
        
        if (_player.bufferEmptyCount &&
            (MPMovieLoadStatePlayable & _player.loadState ||
             MPMovieLoadStatePlaythroughOK & _player.loadState)){
//                NSLog(@"player finish caching");
//                NSString *message = [[NSString alloc]initWithFormat:@"loading occurs, %d - %0.3fs",
//                                     (int)_player.bufferEmptyCount,
//                                     _player.bufferEmptyDuration];
//                [self toast:message];
            }
    }
    if (MPMoviePlayerPlaybackDidFinishNotification ==  notify.name) {
        NSLog(@"player finish state: %ld", (long)_player.playbackState);
        NSLog(@"player download flow size: %f MB", _player.readSize);
        NSLog(@"buffer monitor  result: \n   empty count: %d, lasting: %f seconds",
              (int)_player.bufferEmptyCount,
              _player.bufferEmptyDuration);
        //结束播放的原因
        int reason = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
        if (reason ==  MPMovieFinishReasonPlaybackEnded) {
            self.labelStat.text = [NSString stringWithFormat:@"player finish"];
        }else if (reason == MPMovieFinishReasonPlaybackError){
            self.labelStat.text = [NSString stringWithFormat:@"player Error : %@", [[notify userInfo] valueForKey:@"error"]];
        }else if (reason == MPMovieFinishReasonUserExited){
            self.labelStat.text = [NSString stringWithFormat:@"player userExited"];
            
        }
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
        self.fvr_costtime = (int)((long long int)([self getCurrentTime] * 1000) - _prepared_time);
        NSLog(@"first video frame show, cost time : %dms!\n", _fvr_costtime);
    }
    
    if (MPMoviePlayerFirstAudioFrameRenderedNotification == notify.name)
    {
        self.far_costtime = (int)((long long int)([self getCurrentTime] * 1000) - _prepared_time);
        NSLog(@"first audio frame render, cost time : %dms!\n", _far_costtime);
    }
    
    if (MPMoviePlayerSuggestReloadNotification == notify.name)
    {
        NSLog(@"suggest using reload function!\n");
        if(!_reloading)
        {
            self.reloading = YES;
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

-(void)handlePlayerNotify:(NSNotification*)notify {}

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

#pragma mark --
#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
}

#pragma mark -
#pragma mark - public method

- (void)reload:(NSURL *)aUrl {
    [_player reset:NO];
    [_player setUrl:aUrl];
    [_player prepareToPlay];
}

#pragma mark -------------
#pragma mark - debug info log

- (void)onTimer:(NSTimer *)t
{
    if (nil == _player)
        return;
    
    if ( 0 == self.lastCheckTime) {
        self.lastCheckTime = [self getCurrentTime];
        return;
    }
    
    if(_player.playbackState != MPMoviePlaybackStateStopped && _player.isPreparedToPlay)
    {
        double flowSize = [_player readSize];
        KSYQosInfo *info = _player.qosInfo;
        self.labelStat.text = [NSString stringWithFormat:@
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
                          "已下载音频数据量:%.1fMB\n"
                          "视频缓冲队列长度:%.1fMB\n"
                          "视频缓冲队列时长:%.1fs\n"
                          "已下载视频数据量:%.1fMB\n"
                          "已下载总数据量%.1fMB\n"
                          "解码帧率:%.2f 显示帧率:%.2f\n"
                          "网络连通性:%@\n",
                          
                          [_player getVersion],
                          _player,
                          [[_player contentURL] absoluteString],
                          _serverIp,
                          _player.clientIP,
                          _player.localDNSIP,
                          _player.naturalSize.width,_player.naturalSize.height,
                          _player.currentPlaybackTime,
                          _player.playableDuration,
                          _player.duration,
                          _player.bufferEmptyDuration,
                          (long)_player.bufferEmptyCount,
                          _player.bufferTimeMax,
                          8*1024.0*(flowSize - self.lastSize)/([self getCurrentTime] - self.lastCheckTime),
                          _fvr_costtime, _far_costtime,
                          (long)[(NSNumber *)[_mediaMeta objectForKey:kKSYPLYHttpConnectTime] integerValue],
                          (long)[(NSNumber *)[_mediaMeta objectForKey:kKSYPLYHttpAnalyzeDns] integerValue],
                          (long)[(NSNumber *)[_mediaMeta objectForKey:kKSYPLYHttpFirstDataTime] integerValue],
                          (float)info.audioBufferByteLength / 1e6,
                          (float)info.audioBufferTimeLength / 1e3,
                          (float)info.audioTotalDataSize / 1e6,
                          (float)info.videoBufferByteLength / 1e6,
                          (float)info.videoBufferTimeLength / 1e3,
                          (float)info.videoTotalDataSize / 1e6,
                          (float)info.totalDataSize / 1e6,
                          info.videoDecodeFPS,
                          info.videoRefreshFPS,
                          [self netStatus2Str:_player.networkStatus]];
        self.lastCheckTime = [self getCurrentTime];
        self.lastSize = flowSize;
    }
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

- (NSTimeInterval) getCurrentTime{
    return [[NSDate date] timeIntervalSince1970];
}

#pragma mark on hand gesture
- (void)registerHandGesture{
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:leftSwipeRecognizer];
    [self.view addGestureRecognizer:rightSwipeRecognizer];
}

//左右滑动
- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)swpie {
    if (swpie.direction == UISwipeGestureRecognizerDirectionRight) {
        [_labelStat mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    if (swpie.direction == UISwipeGestureRecognizerDirectionLeft) {
        [_labelStat mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.view);
            make.trailing.equalTo(self.view.mas_leading);
            make.width.equalTo(self.view);
        }];
    }
}

@end
