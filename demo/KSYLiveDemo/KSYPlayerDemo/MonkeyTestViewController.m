//
//  MonkeyTestViewController.m
//  KSYPlayerDemo
//
//  Created by isExist on 16/8/24.
//  Copyright © 2016年 kingsoft. All rights reserved.
//
#import "MonkeyTestViewController.h"
#import "URLTableViewController.h"
#import "QRViewController.h"

#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define RandomBooleanValue (arc4random() % 2 == 1 ? YES : NO)
#define RandomScalingMode (arc4random() % 4)
#define RandomMovieVideoDecoderMode (arc4random() % 3)
#define RandomPrepareTimeout (arc4random() % 20)
#define RandomReadTimeout (arc4random() % 60)

#define UseResetToStop 1

static const CGFloat kViewSpacing = 10.f;
static const CGFloat kButtonHeight = 30.f;

@interface MonkeyTestViewController () <UITextViewDelegate>

@property (nonatomic, strong) KSYMoviePlayerController *player;
@property (nonatomic, strong) NSMutableArray<NSURL *> *URLs;
@property (nonatomic, strong) NSTimer *repeatTimer;
@property (nonatomic, assign) BOOL isRunning;

@end

@implementation MonkeyTestViewController {
    UIView *        _videoView;
    UITextView *    _logView;
    UIButton *      _controlButton;
    UIButton *      _quitButton;
    UIButton *      _scanButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _URLs = [NSMutableArray arrayWithObjects:
             [NSURL URLWithString:@"http://maichang.kssws.ks-cdn.com/upload20150716161913.mp4"],
//             [NSURL URLWithString:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"],
//             [NSURL URLWithString:@"http://cxy.kss.ksyun.com/h265_56c1f0717c63f102.mp4"],
             nil];
    
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initUI];
    
    [self layoutUI];
    
    [self addObserver:self forKeyPath:@"isRunning" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMediaPlaybackIsPreparedToPlayDidChangeNotification)
                                              object:_player];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"isRunning"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isRunning"]) {
        if (_isRunning) {
            [_controlButton setTitle:@"停止" forState:UIControlStateNormal];
        } else {
            [_controlButton setTitle:@"运行" forState:UIControlStateNormal];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)initUI {
    _videoView = [[UIView alloc] init];
    _videoView.layer.borderColor = [UIColor blackColor].CGColor;
    _videoView.layer.borderWidth = 1.f;
    [self.view addSubview:_videoView];
    
    _controlButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_controlButton setTitle:@"运行" forState:UIControlStateNormal];
    _controlButton.layer.borderColor = [UIColor blackColor].CGColor;
    _controlButton.layer.borderWidth = 1.f;
    [self.view addSubview:_controlButton];
    [_controlButton addTarget:self action:@selector(onControlButton:) forControlEvents:UIControlEventTouchUpInside];
    
    _quitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_quitButton setTitle:@"退出" forState:UIControlStateNormal];
    _quitButton.layer.borderColor = [UIColor blackColor].CGColor;
    _quitButton.layer.borderWidth = 1.f;
    [self.view addSubview:_quitButton];
    [_quitButton addTarget:self action:@selector(onQuitButton:) forControlEvents:UIControlEventTouchUpInside];
    
    _scanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_scanButton setTitle:@"扫码" forState:UIControlStateNormal];
    _scanButton.layer.borderColor = [UIColor blackColor].CGColor;
    _scanButton.layer.borderWidth = 1.f;
    [self.view addSubview:_scanButton];
    [_scanButton addTarget:self action:@selector(onScanButton:) forControlEvents:UIControlEventTouchUpInside];
    
    _logView = [[UITextView alloc] init];
    _logView.layer.borderColor = [UIColor blackColor].CGColor;
    _logView.layer.borderWidth = 1.f;
    [self.view addSubview:_logView];
    _logView.delegate = self;
}

- (void)layoutUI {
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat totalWidth = self.view.frame.size.width;
    CGFloat totalHeight = self.view.frame.size.height;
    _videoView.frame = CGRectMake(kViewSpacing,
                                  statusBarHeight + kViewSpacing,
                                  totalWidth - 2 * kViewSpacing,
                                  totalHeight / 3);
    
    _controlButton.frame = CGRectMake(kViewSpacing,
                                      totalHeight - kViewSpacing - kButtonHeight,
                                      (totalWidth - 4 * kViewSpacing) / 3,
                                      kButtonHeight);
    
    _scanButton.frame = CGRectMake(_controlButton.frame.origin.x + _controlButton.frame.size.width + kViewSpacing,
                                   totalHeight - kViewSpacing - kButtonHeight,
                                   _controlButton.frame.size.width,
                                   kButtonHeight);
    
    _quitButton.frame = CGRectMake(_scanButton.frame.origin.x + _scanButton.frame.size.width + kViewSpacing,
                                   totalHeight - kViewSpacing - kButtonHeight,
                                   _controlButton.frame.size.width,
                                   kButtonHeight);
    
    CGFloat logViewOriginY = _videoView.frame.origin.y + _videoView.frame.size.height + kViewSpacing;
    CGFloat logViewHeight = _controlButton.frame.origin.y - kViewSpacing - logViewOriginY;
    _logView.frame = CGRectMake(kViewSpacing, logViewOriginY, totalWidth - 2 * kViewSpacing, logViewHeight);
}

- (void)appendDebugInfoWithString:(NSString *)infoString {
    NSString *newString = [_logView.text stringByAppendingString:infoString];
    _logView.text = newString;
    [_logView scrollRectToVisible:CGRectMake(0, _logView.contentSize.height - 15, _logView.contentSize.width, 10) animated:YES];
}

-(void)handlePlayerNotify:(NSNotification*)notify
{
    if (!_player) {
        return;
    }
    if (notify.name == MPMediaPlaybackIsPreparedToPlayDidChangeNotification) {
        if ([_player isPreparedToPlay]) {
            [_player play];
        }
    }
}

#pragma mark - Player configuration

- (void)configurePlayerRandomly {
    NSInteger randomIndex = arc4random() % _URLs.count;
    NSURL *randomURL = [_URLs objectAtIndex:randomIndex];
    if (_player) {
        [_player setUrl:randomURL];
    } else {
        _player = [[KSYMoviePlayerController alloc] initWithContentURL:randomURL];
    }
    
    [_player.view setFrame: _videoView.bounds];
    [_videoView addSubview: _player.view];
    _videoView.autoresizesSubviews = TRUE;
    
    _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _player.controlStyle = MPMovieControlStyleNone;
    _player.shouldEnableVideoPostProcessing = TRUE;
    
    // Random parameters
    _player.shouldAutoplay = RandomBooleanValue;
    _player.shouldEnableKSYStatModule = RandomBooleanValue;
    _player.shouldLoop = RandomBooleanValue;
    _player.scalingMode = RandomScalingMode;
    _player.videoDecoderMode = RandomMovieVideoDecoderMode;
    _player.shouldMute = RandomBooleanValue;
    [_player setTimeout:RandomPrepareTimeout readTimeout:RandomReadTimeout];
    
//    _player.shouldAutoplay = YES;
//    _player.shouldEnableKSYStatModule = YES;
//    _player.shouldLoop = NO;
//    _player.scalingMode = MPMovieScalingModeAspectFit;
//    _player.videoDecoderMode = MPMovieVideoDecoderMode_Hardware;
//    [_player setTimeout:10 readTimeout:60];
    
    [self appendDebugInfoWithString:[NSString stringWithFormat:@"******************\n"
                                     "URL: %@\n"
                                     "shouldAutoplay = %@\n"
                                     "shouldEnableKSYStatModule = %@\n"
                                     "shouldLoop = %@\n"
                                     "shouldMute = %@\n",
                                     randomURL,
                                     _player.shouldAutoplay ? @"YES" : @"NO",
                                     _player.shouldEnableKSYStatModule ? @"YES" : @"NO",
                                     _player.shouldLoop ? @"YES" : @"NO",
                                     _player.shouldMute ? @"YES" : @"NO"]];
    
    [_player prepareToPlay];
    
    if (!_player.shouldAutoplay) {
        [_player play];
    }
}

#pragma mark - Playback controll

- (void)stopPlaying {
#if UseResetToStop
    [_player reset:YES];
#else
    [_player stop];
    _player = nil;
#endif
    if (_isRunning) {
        [self appendDebugInfoWithString:@"stop\n"];
        [self appendDebugInfoWithString:@"******************\n\n"];
    }
}

- (void)rotate {
    if (_player) {
        int degree = arc4random() % 4 * 90;
        _player.rotateDegress = degree;
        [self appendDebugInfoWithString:[NSString stringWithFormat:@"rotate %d degrees\n", degree]];
    }
}

- (void)pause {
    if (_player) {
        [_player pause];
        [self appendDebugInfoWithString:@"pause\n"];
    }
}

- (void)resume {
    if (_player && !_player.isPlaying) {
        [_player play];
        [self appendDebugInfoWithString:@"resume\n"];
    }
}

- (void)stopAndReconfigurePlayer {
    [self stopPlaying];
    [self configurePlayerRandomly];
}

- (void)changeVolumeTo:(CGFloat)volumeValue {
    if (_player){
        [_player setVolume:volumeValue rigthVolume:volumeValue];
        [self appendDebugInfoWithString:[NSString stringWithFormat:@"volume = %f\n", volumeValue]];
    }
}

- (void)muteSetting {
    if (_player) {
        _player.shouldMute = _player.shouldMute ? NO : YES;
        [self appendDebugInfoWithString:[NSString stringWithFormat:@"%@\n", _player.shouldMute ? @"mute" : @"unmute"]];
    }
}

- (void)reload {
    if (_player) {
        NSURL *URL = _player.contentURL;
        BOOL shouldFlush = RandomBooleanValue;
        [_player reload:URL flush:shouldFlush];
        [self appendDebugInfoWithString:[NSString stringWithFormat:@"reload %@ flush\n", shouldFlush ? @"whit" : @"without"]];
    }
}

- (void)randomPlaybackControl {
    if (arc4random() % 3 == 0) {
        dispatch_main_sync_safe(^{
            [self stopAndReconfigurePlayer];
        })
    } else {
        NSInteger randomNum = arc4random() % 6;
        switch (randomNum) {
            case 0:
                [self pause];
                break;
            case 1:
                [self resume];
                break;
            case 2:
                [self muteSetting];
                break;
            case 3:
                [self rotate];
                break;
            case 4:
                [self changeVolumeTo:arc4random() % 101 / 100.f];
                break;
            case 5:
                [self reload];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Control action methods

- (IBAction)onControlButton:(id)sender {
    if (!self.isRunning) {
        [self configurePlayerRandomly];
        _repeatTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                        target:self
                                                      selector:@selector(randomPlaybackControl)
                                                      userInfo:nil
                                                       repeats:YES];
        self.isRunning = YES;
    } else {
        [self stopPlaying];
        [_repeatTimer invalidate];
        self.isRunning = NO;
    }
}

- (IBAction)onQuitButton:(id)sender {
    [self stopPlaying];
    [_repeatTimer invalidate];
    self.isRunning = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onScanButton:(id)sender {
    URLTableViewController *URLTableVC = [[URLTableViewController alloc] initWithURLs:_URLs];
    URLTableVC.getURLs = ^(NSArray<NSURL *> *scannedURLs){
        [_URLs removeAllObjects];
        for (NSURL *url in scannedURLs) {
            [_URLs addObject:url];
        }
    };
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:URLTableVC];
    [self presentViewController:navVC animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
