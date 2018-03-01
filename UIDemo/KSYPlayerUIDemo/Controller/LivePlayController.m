//
//  LivePlayController.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/11.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "LivePlayController.h"
#import "RecordeViewController.h"
#import "LivePlayOperationView.h"
#import "KSYUIVC.h"
#import "AppDelegate.h"
#import "PlayerViewModel.h"
#import "VideoModel.h"

@interface LivePlayController ()
@property (nonatomic, strong) RecordeViewController     *recordeController;
@property (nonatomic, strong) LivePlayOperationView     *playOperationView;
@property (nonatomic, assign) NSInteger                  rotateIndex;
@end

@implementation LivePlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rotateIndex = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:)name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [self setupUI];
    [self setupOperationBlock];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.allowRotation = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL fullScreen = (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft);
    if (fullScreen) {
        [self.playerViewModel fullScreenHandlerForLivePlayController:self isFullScreen:!fullScreen];
    }
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.allowRotation = NO;
    if (self.willDisappearBlocked) {
        self.willDisappearBlocked();
    }
    
    //允许手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
    }
    
}

- (void)dealloc {
    NSLog(@"LivePlayController dealloced");
}

- (void)setFullScreen:(BOOL)fullScreen {
    self.playOperationView.fullScreen = fullScreen;
}

- (void)statusBarOrientationChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL fullScreen = (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft);
    [self.playerViewModel fullScreenHandlerForLivePlayController:self isFullScreen:fullScreen];
}

- (void)setupUI {
    [self.view addSubview:self.playOperationView];
    [self.playOperationView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
        if ([[KSYGetDeviceName getDeviceName] isEqual:@"iPhoneX"]) {
            if (@available(iOS 11.0, *)) {
                
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
                
            } else {
                // Fallback on earlier versions
            }
        }
        else {
            make.edges.equalTo(self.view);
        }
    }];
}

- (LivePlayOperationView *)playOperationView {
    if (!_playOperationView) {
         __weak typeof(self) weakSelf = self;
        _playOperationView = [[LivePlayOperationView alloc] initWithVideoModel:self.currentVideoModel FullScreenBlock:^(BOOL isFullScreen) {
            typeof(weakSelf) strongSelf = weakSelf;
           [strongSelf.playerViewModel fullScreenHandlerForLivePlayController:self isFullScreen:isFullScreen];
        }];
    
    }
    return _playOperationView;
}

- (void)setupOperationBlock  {
    
    __weak typeof(self) weakSelf = self;
    
    self.recordeController = [[RecordeViewController alloc] initWithPlayer:self.player screenRecordeFinishedBlock:^{
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.view sendSubviewToBack:strongSelf.playOperationView];
        [strongSelf.view sendSubviewToBack:strongSelf.player.view];
    }];
    
    self.playOperationView.playStateBlock = ^(VCPlayHandlerState state) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (state == VCPlayHandlerStatePause) {
            [strongSelf.player pause];
        } else if (state == VCPlayHandlerStatePlay) {
            [strongSelf.player play];
        }
    };
    self.playOperationView.screenShotBlock = ^{
        typeof(weakSelf) strongSelf = weakSelf;
        UIImage *thumbnailImage = strongSelf.player.thumbnailImageAtCurrentTime;
        [KSYUIVC saveImageToPhotosAlbum:thumbnailImage];
    };
    self.playOperationView.screenRecordeBlock = ^{
        typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.view addSubview:strongSelf.recordeController.view];
        [strongSelf addChildViewController:strongSelf.recordeController];
        [strongSelf.recordeController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(strongSelf.view);
        }];
        [strongSelf.recordeController startRecorde];
    };
    // 镜像block
    self.playOperationView.mirrorBlock = ^{
        typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.player.mirror = !strongSelf.player.mirror;
    };
    // 画面旋转block
    self.playOperationView.pictureRotateBlock = ^{
        typeof(weakSelf) strongSelf = weakSelf;
        NSArray *rotates = @[@0, @90, @180, @270];
        if (strongSelf.rotateIndex < rotates.count) {
            strongSelf.player.rotateDegress = [rotates[strongSelf.rotateIndex] intValue];
            strongSelf.rotateIndex += 1;
        } else {
            strongSelf.rotateIndex = 0;
            strongSelf.player.rotateDegress = [rotates[strongSelf.rotateIndex] intValue];
            strongSelf.rotateIndex += 1;
        }
    };
}

- (void)setPlayerViewModel:(PlayerViewModel *)playerViewModel {
    _playerViewModel = playerViewModel;
    [self configeVideoModel:_playerViewModel.playingVideoModel];
}

#pragma mark --
#pragma mark - notification handler

-(void)handlePlayerNotify:(NSNotification*)notify {
    if (MPMovieNaturalSizeAvailableNotification ==  notify.name) {
        if(((self.player.naturalRotate / 90) % 2  == 0 && self.player.naturalSize.width > self.player.naturalSize.height) ||
           ((self.player.naturalRotate / 90) % 2 != 0 && self.player.naturalSize.width < self.player.naturalSize.height))
        {
            //如果想要在宽大于高的时候横屏播放，你可以在这里旋转
            UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
            orientation = UIInterfaceOrientationLandscapeRight;
            [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
        }
    }
    [self notifyHandler:notify];
}

#pragma mark ------
#pragma mark - public method

- (void)recoveryHandler {
    [self.playOperationView recoveryHandler];
}

- (void)suspendHandler {
    [self.playOperationView suspendHandler];
}

- (void)stopSuspend {
    [self.player stop];
}

- (void)pushFromSuspendHandler {
    [self.view insertSubview:self.player.view atIndex:0];
    [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)reloadPushFromSuspendHandler {
    [self.view insertSubview:self.player.view atIndex:0];
    [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    NSInteger definitationIndex = self.currentVideoModel.definitation.integerValue;
    NSString *urlStr = nil;
    if (definitationIndex >= self.currentVideoModel.PlayURL.count) {
        return;
    }
    
    urlStr = self.currentVideoModel.PlayURL[definitationIndex];
    [self.player reset:NO];
    [self.player setUrl:[NSURL URLWithString:urlStr]];
    [self.player prepareToPlay];
    [self.playOperationView configeWithVideoModel:self.currentVideoModel];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        
    }
}




@end
