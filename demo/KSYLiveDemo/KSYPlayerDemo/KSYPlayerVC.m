//
//  KSYPlayerVC.m
//
//  Created by zengfanping on 11/3/15.
//  Copyright (c) 2015 zengfanping. All rights reserved.
//

#import "KSYUIView.h"
#import "KSYPlayerVC.h"
#import "KSYProgressView.h"
#import "KSYFloatVC.h"
#import "KSYAVWriter.h"
#import "KSYPlayerPicView.h"
#import "KSYPlayerAudioView.h"
#import "KSYPlayerSubtitleView.h"
#import "KSYPlayerOtherView.h"

#define ELEMENT_GAP  6

@interface KSYPlayerVC()
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSURL *reloadUrl;
@property(strong, nonatomic) NSArray *fileList;
@property (nonatomic, readwrite) KSYPlayerCfgVC *config;
@property(nonatomic,strong) KSYAVWriter *AVWriter;
@property (nonatomic, readwrite)  BOOL bRecording;
@property (nonatomic,strong) KSYUIView *subView; //二级视图
@end

@implementation KSYPlayerVC{
    KSYUIView *ctrlView;
    
    UIView *videoView;
    
    UIButton *btnVideo;
    UIButton *btnAudio;
    UIButton *btnSubtitle;
    UIButton *btnOthers;
    
    UILabel *labelStat;
    UILabel *labelMsg;
    
    UIButton *btnPlay;
    UIButton *btnPause;
    UIButton *btnResume;
    UIButton *btnStop;
    UIButton *btnQuit;

    KSYProgressView *progressView;
    
    double lastSize;
    NSTimeInterval lastCheckTime;
    NSString* serverIp;
    
    BOOL reloading;
    
    long long int prepared_time;
    int fvr_costtime;
    int far_costtime;
    
    int msgNum;
    
    BOOL bStopped;
    
    NSMutableArray *registeredNotifications;
    NSDictionary  *mediaMeta;
    
    UILabel *labelSubtitle;
    
    KSYPlayerPicView *picView;
    KSYPlayerAudioView *audioView;
    KSYPlayerSubtitleView *subtitleView;
    KSYPlayerOtherView *otherView;
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
    
    [self addSubViews];
    
    //添加手势操作
    [self registerHandGesture];
    
    [self addObserver:self forKeyPath:@"player" options:NSKeyValueObservingOptionNew context:nil];
    
    [self initPlayerWithURL:_url fileList:_fileList config:_config];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_player)
    {
        [_player.view setFrame: videoView.bounds];
        [videoView addSubview: _player.view];
    }
}
- (void)viewDidLayoutSubviews {
    self.subView.frame = CGRectMake(0,  ctrlView.gap + CGRectGetMaxY(btnVideo.frame), ctrlView.width, CGRectGetMinY(progressView.frame) - ctrlView.gap - CGRectGetMaxY(btnVideo.frame));
    [self.subView layoutUI];
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
    
    btnVideo = [ctrlView addButton:@"图像"];
    btnAudio = [ctrlView addButton:@"声音"];
    btnSubtitle = [ctrlView addButton:@"字幕"];
    btnOthers = [ctrlView addButton:@"其它"];
    
    btnPlay = [ctrlView addButton:@"播放"];
    btnPause = [ctrlView addButton:@"暂停"];
    btnResume = [ctrlView addButton:@"继续"];
    btnStop = [ctrlView addButton:@"停止"];
    btnQuit = [ctrlView addButton:@"退出"];

    progressView = [[KSYProgressView alloc] init];
    [ctrlView addSubview:progressView];
    
    labelStat = [self addLabelWithText:nil textColor:[UIColor redColor]];
    [ctrlView addSubview:labelStat];
    
    labelMsg = [self addLabelWithText:nil textColor:[UIColor blueColor]];
    [ctrlView addSubview:labelMsg];
    
    labelSubtitle = [self addLabelWithText:nil textColor:[UIColor greenColor]];
    labelSubtitle.textAlignment = NSTextAlignmentCenter;
    labelSubtitle.font =  [UIFont systemFontOfSize:16];
    labelSubtitle.numberOfLines = 0;
    [ctrlView addSubview:labelSubtitle];
    
    [self layoutUI];

    [self.view addSubview: ctrlView];
}

- (void) layoutUI {
    ctrlView.frame = self.view.frame;
    [ctrlView layoutUI];
    
    videoView.transform = CGAffineTransformIdentity;
    videoView.frame  = ctrlView.frame;
    [ctrlView putRow:@[btnVideo, btnAudio, btnSubtitle, btnOthers]];
    
    //下部控件为3行
    ctrlView.yPos = ctrlView.frame.size.height - ctrlView.gap * 2 - ctrlView.btnH * 2;
    [ctrlView putRow:@[progressView]];
    [ctrlView putRow:@[btnPlay, btnPause, btnResume, btnStop, btnQuit]];
    
    labelStat.frame = self.view.frame;
    labelMsg.frame = self.view.frame;
    labelSubtitle.text = @"";
    labelSubtitle.frame = CGRectMake(0, CGRectGetMaxY(btnVideo.frame), self.view.frame.size.width, CGRectGetMinY(progressView.frame) - CGRectGetMaxY(btnVideo.frame));
}

- (void)addSubViews {
    picView = [[KSYPlayerPicView alloc] initWithParent:ctrlView];
    audioView = [[KSYPlayerAudioView alloc] initWithParent:ctrlView];
    subtitleView = [[KSYPlayerSubtitleView alloc] initWithParent:ctrlView];
    otherView = [[KSYPlayerOtherView alloc] initWithParent:ctrlView];
    
    weakObj(self);
    // 图像控制页面
    picView.onBtnBlock = ^(id sender) {
        [selfWeak onPicBtnPress:sender];
    };
    picView.onSegCtrlBlock = ^(id sender) {
        [selfWeak onPicSegCtrl:sender];
    };
    
    // 声音控制页面
    audioView.onSegCtrlBlock = ^(id sender) {
        [selfWeak onAudioSegCtrl:sender];
    };
    audioView.onSliderBlock = ^(id sender) {
        [selfWeak onAudioSlider:sender];
    };
    audioView.onSwitchBlock = ^(id sender) {
        [selfWeak onAudioSwitch:sender];
    };
    
    subtitleView.onSliderBlock = ^(id sender) {
        [selfWeak onSubtitleSlider:sender];
    };
    
    subtitleView.fontColorBlock = ^(UIColor *fontColor) {
        [selfWeak onSubtitleFontColor:fontColor];
    };
    
    subtitleView.fontBlock = ^(NSString *font) {
        [selfWeak onSubtitleFont:font];
    };
    
    subtitleView.subtitleFileSelectedBlock = ^(NSString *subtitleFilePath) {
        [selfWeak subtitleFileSelectd:subtitleFilePath];
    };
    
    subtitleView.closeSubtitleBlock = ^(){
        [selfWeak closeSubtitle];
    };
    
    subtitleView.onSegCtrlBlock = ^(id sender) {
        [selfWeak onSubtitleSegCtrl:sender];
    };
    
    subtitleView.subtitleNumBlock = ^() {
        [selfWeak getSubtitleInfo];
    };
    
    //其他控制页面
    otherView.onBtnBlock = ^(id sender) {
        [selfWeak onOtherBtnPress:sender];
    };
    otherView.onSwitchBlock = ^(id sender) {
        [selfWeak onOtherSwitch:sender];
    };
}

- (void)rmSubViews {
    [picView removeFromSuperview];
    picView = nil;
    [audioView removeFromSuperview];
    audioView = nil;
    [subtitleView removeFromSuperview];
    subtitleView = nil;
    [otherView removeFromSuperview];
    otherView = nil;
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
    lastSize = 0.0;
    //初始化播放器并设置播放地址
    self.player = [[KSYMoviePlayerController alloc] initWithContentURL: aURL fileList:fileList sharegroup:nil];
    registeredNotifications = [[NSMutableArray alloc] init];
    [self setupObservers:_player];
    
    _player.logBlock = ^(NSString *logJson){
        NSLog(@"logJson is %@",logJson);
    };
    
    __weak typeof(self) weakSelf = self;
    _player.videoDataBlock = ^(CMSampleBufferRef sampleBuffer){
        //写入视频sampleBuffer
        if(weakSelf && weakSelf.AVWriter && weakSelf.bRecording)
            [weakSelf.AVWriter processVideoSampleBuffer:sampleBuffer];
    };
    
    _player.audioDataBlock = ^(CMSampleBufferRef sampleBuffer){
        //写入音频sampleBuffer
        if(weakSelf && weakSelf.AVWriter && weakSelf.bRecording)
            [weakSelf.AVWriter processAudioSampleBuffer:sampleBuffer];
    };
    _player.messageDataBlock = ^(NSDictionary *message, int64_t pts, int64_t param){
        if(message)
        {
            NSMutableString *msgString = [[NSMutableString alloc] init];
            NSEnumerator * enumeratorKey = [message keyEnumerator];
            //快速枚举遍历所有KEY的值
            for (NSObject *object in enumeratorKey) {
                [msgString appendFormat:@"\"%@\":\"%@\"\n", object, [message objectForKey:object]];
            }
            
            if(weakSelf)
                [weakSelf updateMsg:msgString];
        }
    };
    //播放视频的实时信息
    labelStat.text = [NSString stringWithFormat:@"url %@", aURL];
    _player.controlStyle = MPMovieControlStyleNone;
    [_player.view setFrame: videoView.bounds];  // player's frame must match parent's
    [videoView addSubview: _player.view];
    [videoView bringSubviewToFront:labelStat];
    videoView.autoresizesSubviews = TRUE;
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    if(config)
    {
        //设置播放参数
        _player.videoDecoderMode = config.decodeMode;
        _player.scalingMode = config.contentMode;
        picView.contentMode = _player.scalingMode;
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
    [registeredNotifications addObject:notification];
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
    [self registerObserver:MPMoviePlayerPlaybackTimedTextNotification player:player];
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
        labelStat.text = [NSString stringWithFormat:@"player prepared"];
        progressView.totalTimeInSeconds = _player.duration;
        if(_player.shouldAutoplay == NO)
            [_player play];
        serverIp = [_player serverAddress];
        NSLog(@"KSYPlayerVC: %@ -- ip:%@", [[_player contentURL] absoluteString], serverIp);
        mediaMeta  = [_player getMetadata];
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
            labelStat.text = [NSString stringWithFormat:@"player start caching"];
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
        //结束播放的原因
        int reason = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
        if (reason ==  MPMovieFinishReasonPlaybackEnded) {
            labelStat.text = [NSString stringWithFormat:@"player finish"];
        }else if (reason == MPMovieFinishReasonPlaybackError){
            labelStat.text = [NSString stringWithFormat:@"player Error : %@", [[notify userInfo] valueForKey:@"error"]];
        }else if (reason == MPMovieFinishReasonUserExited){
            labelStat.text = [NSString stringWithFormat:@"player userExited"];
            
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
    
    if (MPMoviePlayerPlaybackTimedTextNotification == notify.name)
    {
        NSString *timedText = [[notify userInfo] valueForKey:MPMoviePlayerPlaybackTimedTextUserInfoKey];
        
        NSDictionary *attrs = @{NSFontAttributeName : labelSubtitle.font};
        CGSize size = [timedText boundingRectWithSize:CGSizeMake(labelSubtitle.frame.size.width, MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:attrs context:nil].size;
        [labelSubtitle setFrame:CGRectMake(labelSubtitle.frame.origin.x, CGRectGetMinY(progressView.frame) - size.height, labelSubtitle.frame.size.width, size.height)];
        
        labelSubtitle.text = timedText;
    }
}

#pragma mark on picSubView
- (void)onPicBtnPress:(UIButton *)btn{
    if(!_player)
        return ;
    
    if(picView.btnShotScreen == btn)
    {
        UIImage *thumbnailImage = _player.thumbnailImageAtCurrentTime;
        [KSYUIVC saveImageToPhotosAlbum:thumbnailImage];
     }
}

- (void)onPicSegCtrl:(UISegmentedControl *)sender {
    if (!_player)
        return ;
    
    if(picView.segContentMode == sender)
        _player.scalingMode = picView.contentMode;
    else if(picView.segRotate == sender)
        _player.rotateDegress = picView.rotateDegress;
    else if(picView.segMirror == sender)
        _player.mirror = picView.bMirror;
}

#pragma mark on audioSubView
- (void)onAudioSegCtrl:(UISegmentedControl *)sender {
    if (!_player)
        return ;
    
    if(audioView.segAudioPan == sender)
        _player.audioPan = audioView.audioPan;
}

- (void)onAudioSlider:(UISlider *)sender {
    if(!_player)
        return ;
    
    if(audioView.sliderVolume.slider == sender)
         [_player setVolume:sender.value/100 rigthVolume:sender.value/100];
}

- (void)onAudioSwitch:(UISwitch *)sender {
    if(!_player)
        return ;
    
    if(audioView.switchMute == sender)
        _player.shouldMute = sender.isOn;
}

#pragma mark on subtitleSubView
- (void)onSubtitleSlider:(UISlider *)sender {
    if(!_player)
        return ;
    
    if(subtitleView.sliderFontSize.slider == sender)
        labelSubtitle.font = [labelSubtitle.font fontWithSize:sender.value];
}

- (void)onSubtitleFontColor:(UIColor *) color {
    if(!_player)
        return ;
    
    labelSubtitle.textColor = color;
}

- (void)onSubtitleFont:(NSString *) font {
    if(!_player)
        return ;
    
    labelSubtitle.font = [UIFont fontWithName:font size:subtitleView.sliderFontSize.slider.value];
}

- (void)subtitleFileSelectd:(NSString *)subtitleFilePath {
    if(!_player)
        return ;
    [_player setExtSubtitleFilePath:subtitleFilePath];
}

- (void)closeSubtitle{
    if(!_player)
        return ;
    NSDictionary *subtitleMeta = [_player getMetadata:MPMovieMetaType_Subtitle];
    if(subtitleMeta)
    {
        [ _player setTrackSelected:[[subtitleMeta objectForKey:kKSYPLYStreamIndex] integerValue] selected:NO];
        labelSubtitle.text = @"";
    }
}

- (void)onSubtitleSegCtrl:(UISegmentedControl *)sender {
    if (!_player)
        return ;
    
    //先关闭当前字幕，内嵌字幕间切换可以直接忽略这一步骤，但是由外挂字幕切换到内嵌字幕必须要有这一步骤！
    NSDictionary *subtitleMeta = [_player getMetadata:MPMovieMetaType_Subtitle];
    if(subtitleMeta)
        [_player setTrackSelected:[[subtitleMeta objectForKey:kKSYPLYStreamIndex] integerValue] selected:NO];
        
    int stream_index = -1;
    int subtitle_index = 0;
    NSDictionary *meta = [_player getMetadata];
    NSMutableArray *streams = [meta objectForKey:kKSYPLYStreams];
    for(NSDictionary *stream in streams)
    {
        if([[stream objectForKey:kKSYPLYStreamType] isEqualToString:@"subtitle"])
        {
            if(subtitle_index == subtitleView.segSubtitle.selectedSegmentIndex)
            {
                stream_index = (int)[[stream objectForKey:kKSYPLYStreamIndex] integerValue];
                break;
            }
             subtitle_index++;
        }
    }
    if(stream_index >= 0)
        [_player setTrackSelected:stream_index selected:YES];
}

- (void)getSubtitleInfo {
    if(mediaMeta)
    {
        subtitleView.selectedSubtitleIndex = 0;
        subtitleView.subtitleNum = 0;
        NSDictionary *subtitleMeta = [_player getMetadata:MPMovieMetaType_Subtitle];
        NSMutableArray *streams = [mediaMeta objectForKey:kKSYPLYStreams];
        for(NSDictionary *stream in streams)
        {
            if([[stream objectForKey:kKSYPLYStreamType] isEqualToString:@"subtitle"])
                subtitleView.subtitleNum ++;
        }
        
        if(subtitleMeta)
        {
            for(NSDictionary *stream in streams)
            {
                if([[stream objectForKey:kKSYPLYStreamType] isEqualToString:@"subtitle"])
                {
                    if([[subtitleMeta objectForKey:kKSYPLYStreamIndex] integerValue] ==
                       [[stream objectForKey:kKSYPLYStreamIndex] integerValue])
                        break;
                    subtitleView.selectedSubtitleIndex ++;
                }
            }
        }
    }
}

#pragma mark on OtherSubView
- (void)onOtherBtnPress:(UIButton *)btn{
    if(!_player)
        return ;
    
    if(otherView.btnFloat == btn)
    {
        //悬浮窗
        KSYFloatVC *_floatVC = [[KSYFloatVC alloc] init];
        _floatVC.playerVC = self;
        [self presentViewController:_floatVC animated:NO completion:nil];
    }
    else if(otherView.btnReload == btn)
    {
         [_player reload:_reloadUrl flush:YES mode:MPMovieReloadMode_Accurate];
    }
    else if(otherView.btnPrintMeta == btn)
    {
        otherView.btnPrintMeta.selected = !otherView.btnPrintMeta.selected;
        otherView.labelMeta.hidden = !otherView.btnPrintMeta.selected;
        if(otherView.btnPrintMeta.selected)
            [self printfMeta];
    }
}

- (void)onOtherSwitch:(UISwitch *)sender {
    if(!_player)
        return ;
    
    [self onRec];
}

- (void)printfMeta{
    NSDictionary *meta = [_player getMetadata];
    if(meta){
        NSString *metaString = [NSString stringWithFormat:@"format:%@\n", [mediaMeta objectForKey:kKSYPLYFormat]];
        NSMutableArray *streams = [meta objectForKey:kKSYPLYStreams];
        for(NSDictionary *stream in streams) {
            NSString *streamType = [stream objectForKey:kKSYPLYStreamType];
            NSString *codecName = [stream objectForKey:kKSYPLYCodecName];
            long streamIndex = [[stream objectForKey:kKSYPLYStreamIndex] integerValue];
            if([streamType isEqualToString:@"video"]) {
                NSInteger width = [[stream objectForKey:kKSYPLYVideoWidth] integerValue];
                NSInteger height = [[stream objectForKey:kKSYPLYVideoHeight] integerValue];
                metaString = [metaString stringByAppendingFormat:@"video: %ld %@ %ld*%ld\n", streamIndex, codecName, width, height];
            }else if([streamType isEqualToString:@"audio"]) {
                NSInteger channels = [[stream objectForKey:kKSYPLYAudioChannels] integerValue];
                NSInteger samplerate = [[stream objectForKey:kKSYPLYAudioSampleRate] integerValue];
                metaString = [metaString stringByAppendingFormat:@"Audio: %ld %@ %ld %ld\n", streamIndex, codecName, channels, samplerate];
            }else if([streamType isEqualToString:@"subtitle"])
               metaString = [metaString stringByAppendingFormat:@"Subtitle: %ld %@\n", streamIndex, codecName];
            else if([streamType isEqualToString:@"external_timed_text"])
                metaString = [metaString stringByAppendingFormat:@"external_timed_text: %ld %@\n", streamIndex, codecName];
        }
        
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:metaString
                                                         attributes:@{NSFontAttributeName:otherView.labelMeta.font}];
        CGSize size = [attributedText boundingRectWithSize:CGSizeMake(otherView.labelMeta.frame.size.width, MAXFLOAT)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil].size;
        
       [otherView.labelMeta setFrame:CGRectMake(otherView.labelMeta.frame.origin.x, otherView.labelMeta.frame.origin.y, otherView.labelMeta.frame.size.width, size.height)];
        otherView.labelMeta.text = metaString;
    }
}

- (void)onBtn:(UIButton *)btn{
    if(btn == btnPlay)
        [self onPlayVideo:btn];
    else if(btn == btnPause)
        [self onPauseVideo:btn];
    else if(btn == btnResume)
        [self onResumeVideo:btn];
    else if(btn == btnStop)
        [self onStopVideo:btn];
    else if(btn == btnQuit)
        [self onQuit:btn];
    else if(btn == btnVideo || btn == btnAudio || btn == btnSubtitle || btn == btnOthers) {
        
        KSYUIView *subView = nil;
        if(btn == btnVideo)
            subView = picView;
        else if(btn == btnAudio)
            subView = audioView;
        else if(btn == btnSubtitle)
            subView = subtitleView;
        else
            subView = otherView;
    
        self.subView = subView;
        [self hideElements:btn view:self.subView];
    }
}

- (void) hideElements:(UIControl *)button view:(KSYUIView*)subView
{
    NSMutableArray *arrayBtn = [NSMutableArray arrayWithObjects:btnVideo, btnAudio, btnSubtitle, btnOthers, nil];
    NSMutableArray *arrayView = [NSMutableArray arrayWithObjects:picView, audioView, subtitleView, otherView, nil];
    
    [arrayBtn removeObject:button];
    [arrayView removeObject:subView];
    
    for(UIControl *btn in arrayBtn)
        btn.selected = NO;
    
    for(UIView *view in arrayView)
        view.hidden = YES;
    
    button.selected = !button.selected;
    subView.hidden = !button.selected;
    if(button.selected == YES)
    {
        subView.frame = CGRectMake(0,  ctrlView.gap + CGRectGetMaxY(btnVideo.frame), ctrlView.width, CGRectGetMinY(progressView.frame) - ctrlView.gap - CGRectGetMaxY(btnVideo.frame));
        [subView layoutUI];
    }
}

- (IBAction)onPlayVideo:(id)sender {
    if(nil == _player)
        [self initPlayerWithURL:_url fileList:_fileList config:_config];
    if(_player)
    {
        NSLog(@"sdk version:%@", [_player getVersion]);
        //如果再次播放的话，设置下次播放的地址
        if(bStopped == YES)
             [_player setUrl:_url];
        prepared_time = (long long int)([self getCurrentTime] * 1000);
        [_player prepareToPlay];
        bStopped = NO;
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
    }
}

- (IBAction)onStopVideo:(id)sender {
    if (_player) {
        [otherView.switchRec setOn:NO];
        [self onRec];
        NSLog(@"player download flow size: %f MB", _player.readSize);
        NSLog(@"buffer monitor  result: \n   empty count: %d, lasting: %f seconds",
              (int)_player.bufferEmptyCount,
              _player.bufferEmptyDuration);
        
        [_player reset:NO];
        labelSubtitle.text = @"";
        bStopped = YES;
    }
}

- (IBAction)onQuit:(id)sender {
    if(_player)
    {
        [otherView.switchRec setOn:NO];
        [self onRec];
        [_player stop];
        [_player removeObserver:self forKeyPath:@"currentPlaybackTime" context:nil];
        [_player removeObserver:self forKeyPath:@"clientIP" context:nil];
        [_player removeObserver:self forKeyPath:@"localDNSIP" context:nil];
        
        [self releaseObservers:_player];
        
        [_player.view removeFromSuperview];
        self.player = nil;
        [self rmSubViews];
    }
    
    [self dismissViewControllerAnimated:FALSE completion:nil];
    [self rmObservers];
    labelStat.text = nil;
}

- (void)onRec{
    if(otherView.switchRec.isOn)
    {
        if(!_bRecording && _player.isPreparedToPlay)
        {
            //初始化KSYAVWriter类
            _AVWriter = [[KSYAVWriter alloc]initWithDefaultCfg];
            //设置待写入的文件名
            [_AVWriter setUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%s", NSHomeDirectory(), "/Documents/PlayerRec.mp4"]]];
            //开始写入
            [_AVWriter setMeta:[_player getMetadata:MPMovieMetaType_Audio] type:KSYAVWriter_MetaType_Audio];
            [_AVWriter setMeta:[_player getMetadata:MPMovieMetaType_Video] type:KSYAVWriter_MetaType_Video];
            //_AVWriter.bWithVideo = NO;
            [_AVWriter startRecord];
            _bRecording = YES;
        }
    }
    else
    {
        if(_bRecording)
            [_AVWriter stopRecord];
        _AVWriter = nil;
        _bRecording = NO;
    }
}

#pragma mark update label
- (void)onTimer:(NSTimer *)t
{
    if (nil == _player)
        return;
    
    if ( 0 == lastCheckTime) {
        lastCheckTime = [self getCurrentTime];
        return;
    }
    
    if(_player.playbackState != MPMoviePlaybackStateStopped && _player.isPreparedToPlay)
    {
        double flowSize = [_player readSize];
        KSYQosInfo *info = _player.qosInfo;
        labelStat.text = [NSString stringWithFormat:@
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
                          serverIp,
                          _player.clientIP,
                          _player.localDNSIP,
                          _player.naturalSize.width,_player.naturalSize.height,
                          _player.currentPlaybackTime,
                          _player.playableDuration,
                          _player.duration,
                          _player.bufferEmptyDuration,
                          (long)_player.bufferEmptyCount,
                          _player.bufferTimeMax,
                          8*1024.0*(flowSize - lastSize)/([self getCurrentTime] - lastCheckTime),
                          fvr_costtime, far_costtime,
                          (long)[(NSNumber *)[mediaMeta objectForKey:kKSYPLYHttpConnectTime] integerValue],
                          (long)[(NSNumber *)[mediaMeta objectForKey:kKSYPLYHttpAnalyzeDns] integerValue],
                          (long)[(NSNumber *)[mediaMeta objectForKey:kKSYPLYHttpFirstDataTime] integerValue],
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
        lastCheckTime = [self getCurrentTime];
        lastSize = flowSize;
    }
    
    [self updateCacheProgress];
}

- (void)updateMsg : (NSString *)msgString {
    if(msgNum == 0)
        labelMsg.text = @"message is : \n";
    labelMsg.text = [labelMsg.text stringByAppendingString:@"\n"];
    labelMsg.text = [labelMsg.text stringByAppendingString:msgString];
    if(++msgNum >= 3)
        msgNum  = 0;
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

#pragma mark on hand gesture
- (void)registerHandGesture{
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *upSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    upSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    UISwipeGestureRecognizer *downSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    downSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:leftSwipeRecognizer];
    [self.view addGestureRecognizer:rightSwipeRecognizer];
    [self.view addGestureRecognizer:upSwipeRecognizer];
    [self.view addGestureRecognizer:downSwipeRecognizer];
    
    //捏合缩放
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:pinchGesture];
    //旋转
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    [self.view addGestureRecognizer:rotationGesture];
}

//上下左右滑动
- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)swpie {
    if (swpie.direction == UISwipeGestureRecognizerDirectionRight) {
        CGRect originalFrame = labelStat.frame;
        labelStat.frame = CGRectMake(0, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height);
    }
    if (swpie.direction == UISwipeGestureRecognizerDirectionLeft) {
        CGRect originalFrame = labelStat.frame;
        labelStat.frame = CGRectMake(-originalFrame.size.width, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height);
    }
    if(swpie.direction == UISwipeGestureRecognizerDirectionDown) {
        CGRect originalFrame = labelMsg.frame;
        labelMsg.frame =  CGRectMake(0, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height);
    }
    if(swpie.direction == UISwipeGestureRecognizerDirectionUp) {
        CGRect originalFrame = labelMsg.frame;
        labelMsg.frame =  CGRectMake(-originalFrame.size.width, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height);
    }
}

// 处理捏合缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = videoView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
}

// 处理旋转手势
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    UIView *view = videoView;
    if([rotationGestureRecognizer state] == UIGestureRecognizerStateEnded) {
        view.transform = CGAffineTransformIdentity;
        return;
    }
    
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
        [rotationGestureRecognizer setRotation:0];
    }
}
@end
