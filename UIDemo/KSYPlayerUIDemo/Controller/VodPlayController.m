//
//  VodPlayController.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/11.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "VodPlayController.h"
#import "VodPlayOperationView.h"
#import "PlayerViewModel.h"
#import "VideoModel.h"
#import "KSYUIVC.h"
#import "RecordeViewController.h"

@interface VodPlayController ()
@property (nonatomic, assign) BOOL                       switchingDefination;
@property (nonatomic, assign) NSTimeInterval             playedTime;
@property (nonatomic, strong) RecordeViewController     *recordeController;
@end

@implementation VodPlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupOperationBlock];
}

- (void)dealloc {
    NSLog(@"VodPlayController dealloced");
}

- (void)setupUI {
    [self.view addSubview:self.playOperationView];
    [self.playOperationView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        //        if (IS_IPHONEX) {
        //           //make.edges
        //        }
        //        else {
        make.edges.equalTo(self.view);
        //  }
    }];
}

- (VodPlayOperationView *)playOperationView {
    if (!_playOperationView) {
        __weak typeof(self) weakSelf = self;
        _playOperationView = [[VodPlayOperationView alloc] initWithFullScreenBlock:^(BOOL isFullScreen) {
            typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.playerViewModel fullScreenButtonClickedHandlerForVodPlayController:strongSelf isFullScreen:isFullScreen];
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
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationPortrait) {
            [strongSelf.playerViewModel fullScreenHandlerForPlayController:strongSelf isFullScreen:NO];
        }
    }];
    
    self.playOperationView.playStateBlock = ^(VCPlayHandlerState state) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (state == VCPlayHandlerStatePause) {
            [strongSelf.player pause];
        } else if (state == VCPlayHandlerStatePlay) {
            [strongSelf.player play];
        }
    };
    
    self.playOperationView.dragSliderBlock = ^(float progress){
        typeof(weakSelf) strongSelf = weakSelf;
        double seekPos = progress * strongSelf.player.duration;
        [strongSelf.player seekTo:seekPos accurate:YES];
    };
    
    self.playOperationView.nextButtonBLock = ^{
        typeof(weakSelf) strongSelf = weakSelf;
        VideoModel *nextVideo = [strongSelf.playerViewModel nextVideoModel];
        if (nextVideo) {
            [strongSelf.player reload:[NSURL URLWithString:nextVideo.PlayURL.lastObject]];
            strongSelf.playerViewModel.playingVideoModel = nextVideo;
            [strongSelf.playOperationView configeVideoModel:nextVideo];
            if (strongSelf.playerViewModel.currPlayingIndex < strongSelf.playerViewModel.videoListViewModel.listViewDataSource.count) {
                strongSelf.playerViewModel.currPlayingIndex += 1;
            } else {
                strongSelf.playerViewModel.currPlayingIndex = 0;
            }
        }
    };
    
    self.playOperationView.definitionChoiceBlock = ^(VideoDefinitionType definition) {
        typeof(weakSelf) strongSelf = weakSelf;
        NSInteger definitionIndex = (NSInteger)definition;
        if (definitionIndex < strongSelf.playerViewModel.playingVideoModel.PlayURL.count && definitionIndex != strongSelf.playerViewModel.playingVideoModel.definitation.integerValue) {
            strongSelf.switchingDefination = YES;
            NSString *definitionUrl = strongSelf.playerViewModel.playingVideoModel.PlayURL[definitionIndex];
            [strongSelf.player reset:YES];
            [strongSelf.player setUrl:[NSURL URLWithString:definitionUrl]];
            [strongSelf.player prepareToPlay];
            strongSelf.playerViewModel.playingVideoModel.definitation = @(definition);
        }
    };
    self.playOperationView.speedChoiceBlock = ^(float speed) {
        typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.player.playbackSpeed = speed;
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
    
    [self.playOperationView configeVideoModel:self.playerViewModel.playingVideoModel];
}

- (void)setFullScreen:(BOOL)fullScreen {
    self.playOperationView.fullScreen = fullScreen;
}

#pragma mark --
#pragma mark - notification handler

-(void)handlePlayerNotify:(NSNotification*)notify
{
    if (!self.player) {
        return;
    }
    if (MPMediaPlaybackIsPreparedToPlayDidChangeNotification ==  notify.name) {
        if (self.switchingDefination) {
            [self.player seekTo:_playedTime accurate:YES];
            self.switchingDefination = NO;
        }
        [self.playOperationView updateTotalPlayTime:self.player.duration];
        if(self.player.shouldAutoplay == NO)
            [self.player play];
    }
    [self notifyHandler:notify];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if([keyPath isEqual:@"currentPlaybackTime"]) {
        if (!self.switchingDefination) {
            self.playedTime = self.player.currentPlaybackTime;
        }
        [self.playOperationView updatePlayedTime:_playedTime];
    }
}

#pragma mark ------
#pragma mark - public method

- (void)suspendHandler {
    [self.playOperationView suspendHandler];
}

- (void)recoveryHandler {
    [self.playOperationView recoveryHandler];
}

- (void)stopSuspend {
    [self.player stop];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
@end
