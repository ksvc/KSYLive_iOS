//
//  KSYPlayerVC.m
//
//  Created by zengfanping on 11/3/15.
//  Copyright (c) 2015 zengfanping. All rights reserved.
//

#import "KSYPlayerVC.h"
#import <libksylive/KSYMediaPlayer.h>
#import <CommonCrypto/CommonDigest.h>

@interface KSYPlayerVC ()
@property (strong, nonatomic) NSURL *url;
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
    UIButton *btnStop;
    UIButton *btnQuit;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    _url = [NSURL URLWithString:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"];
//    _url = [NSURL URLWithString:@"rtmp://test.rtmplive.ks-cdn.com/live/yun264"];
//    _url = [NSURL URLWithString:@"http://121.42.58.232:8980/hls_test/1.m3u8"];
    _url = [NSURL URLWithString:@"http://121.40.205.48:8091/demo/h265.flv"];
//    _url = [NSURL URLWithString:@"http://121.40.49.231/player/vod/mtv_x264_1920x1080_30_1000K.mp4"];
    
    [self setupObservers];
    //NSLog(@"QY framework version: %f - %s", QYMediaPlayerVersionNumber, QYMediaPlayerVersionString);
    [self initKSYAuth];
}
- (void) initUI {
    //add UIView for player
    videoView = [[UIView alloc] init];
    videoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:videoView];

    //add play button
    btnPlay = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnPlay setTitle:@"play" forState: UIControlStateNormal];
    btnPlay.backgroundColor = [UIColor lightGrayColor];
    [btnPlay addTarget:self action:@selector(onPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPlay];
    //add pause button
    btnPause = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnPause setTitle:@"pause" forState: UIControlStateNormal];
    btnPause.backgroundColor = [UIColor lightGrayColor];
    [btnPause addTarget:self action:@selector(onPauseVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPause];
    //add stop button
    btnStop = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnStop setTitle:@"stop" forState: UIControlStateNormal];
    btnStop.backgroundColor = [UIColor lightGrayColor];
    [btnStop addTarget:self action:@selector(onStopVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnStop];
    //add quit button
    btnQuit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnQuit setTitle:@"quit" forState: UIControlStateNormal];
    btnQuit.backgroundColor = [UIColor lightGrayColor];
    [btnQuit addTarget:self action:@selector(onQuit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnQuit];
    
    stat = [[UILabel alloc] init];
    stat.backgroundColor = [UIColor clearColor];
    stat.textColor = [UIColor redColor];
    stat.numberOfLines = 6;
    stat.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:stat];

    [self layoutUI];
}
- (void) layoutUI {
    CGFloat wdt = self.view.bounds.size.width;
    CGFloat hgt = self.view.bounds.size.height;
    CGFloat gap = 10;
    CGFloat btnWdt = ( (wdt-gap) / 4) - gap;
    CGFloat btnHgt = 30;
    CGFloat xPos = gap;
    CGFloat yPos = hgt - btnHgt - gap;
    
    videoView.frame = CGRectMake(0, 0, wdt, hgt);
    btnPlay.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnPause.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnStop.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnQuit.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    stat.frame = CGRectMake(gap, hgt/4, wdt, hgt/2);
}
- (BOOL)shouldAutorotate {
    [self layoutUI];
    return YES;
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
        [self updateStat:nil];
        stat.text = [NSString stringWithFormat:@"player prepared"];
        // using autoPlay to start live stream
        //        [_player play];
        serverIp = [_player serverAddress];
        NSLog(@"%@ -- %@", _url, serverIp);
        [self StartTimer];
    }
    if (MPMoviePlayerPlaybackStateDidChangeNotification ==  notify.name) {
        NSLog(@"player playback state: %ld", (long)_player.playbackState);
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
                [self updateStat:nil];
            }
    }
    if (MPMoviePlayerPlaybackDidFinishNotification ==  notify.name) {
        NSLog(@"player finish state: %ld", (long)_player.playbackState);
        NSLog(@"player download flow size: %f MB", _player.readSize);
        NSLog(@"buffer monitor  result: \n   empty count: %d, lasting: %f seconds",
              (int)_player.bufferEmptyCount,
              _player.bufferEmptyDuration);
        stat.text = [NSString stringWithFormat:@"player finish"];
        [self StopTimer];
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
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([keyPath isEqualToString:@"playbackState"])
    {
        NSLog(@"playback state from %@ to %@", [change objectForKey:@"old"], [change objectForKey:@"new"]);
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
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
}
- (IBAction)onPlayVideo:(id)sender {
    if (_player) {
        [_player play];
        return;
    }
    _player =    [[KSYMoviePlayerController alloc] initWithContentURL: _url];
    stat.text = [NSString stringWithFormat:@"url %@", _url];
    [_player addObserver:self
              forKeyPath:@"playbackState"
                 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    _player.controlStyle = MPMovieControlStyleNone;
    [_player.view setFrame: videoView.bounds];  // player's frame must match parent's
    [videoView addSubview: _player.view];
    [videoView bringSubviewToFront:stat];
    videoView.autoresizesSubviews = TRUE;
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _player.shouldAutoplay = TRUE;
    _player.scalingMode = MPMovieScalingModeAspectFit;
    NSLog(@"going to prepare, server ip: %@", [_player serverAddress]);
    [_player prepareToPlay];
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
        [_player removeObserver:self forKeyPath:@"playbackState"];
        _player = nil;
        stat.text = [NSString stringWithFormat:@"url: %@\nstopped", _url];
        [self StopTimer];
    }
}

- (NSTimeInterval) getCurrentTime{
    //    NSLog(@"current time: %f", [self currentPlaybackTime]);
    return [[NSDate date] timeIntervalSince1970];
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
    
    stat.text = [NSString stringWithFormat:@"%@\nip:%@\nplay time:%.1fs - %.1fs\ncache time:%.1fs\nspeed: %0.1f kbps",
                 _url, serverIp,
                 _player.currentPlaybackTime, _player.duration,
                 _player.bufferEmptyDuration,
                 8*1024.0*(flowSize - lastSize)/([self getCurrentTime] - lastCheckTime)];
    
    lastCheckTime = [self getCurrentTime];
    lastSize = flowSize;
}

- (IBAction)onQuit:(id)sender {
    [self onStopVideo:nil];
    //[self.navigationController popToRootViewControllerAnimated:FALSE];
    [self dismissViewControllerAnimated:FALSE completion:nil];
}


@end
