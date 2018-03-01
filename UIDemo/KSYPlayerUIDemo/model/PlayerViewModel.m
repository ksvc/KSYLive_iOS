//
//  PlayerViewModel.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/23.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "PlayerViewModel.h"
#import "VodPlayOperationView.h"
#import "VodPlayController.h"
#import "LivePlayController.h"
#import "Masonry.h"

@interface PlayerViewModel ()

@end

@implementation PlayerViewModel

- (instancetype)initWithPlayingVideoModel:(VideoModel *)playingVideoModel
                       videoListViewModel:(VideoListViewModel *)videoListViewModel
                            selectedIndex:(NSInteger)selectedIndex {
    if (self = [super init]) {
        _playingVideoModel = playingVideoModel;
        _videoListViewModel = videoListViewModel;
        _currPlayingIndex = selectedIndex;
    }
    return self;
}

- (void)fullScreenHandlerForPlayController:(UIViewController *)playController
                              isFullScreen:(BOOL) isFullScreen {
    [playController.view removeFromSuperview];
    [playController removeFromParentViewController];
    UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
    if (isFullScreen) {
        UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
        [keywindow addSubview:playController.view];
        [_owner addChildViewController:playController];
        [playController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(keywindow);
        }];
        orientation = UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft;
    } else {
        [_owner.view addSubview:playController.view];
        [_owner addChildViewController:playController];
        [playController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            if ([[KSYGetDeviceName getDeviceName] isEqual:@"iPhoneX"]) {
                make.leading.trailing.equalTo(_owner.view);
                make.top.equalTo(_owner.view).offset(SafeAreaStatusBarTopHeight);
                make.height.mas_equalTo(211);
            }
            else {
                make.leading.trailing.top.equalTo(_owner.view);
                make.height.mas_equalTo(211);
            }
            
        }];
        orientation = UIInterfaceOrientationPortrait;
    }
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
    if ([playController isKindOfClass:[VodPlayController class]]) {
        VodPlayController *vpc = (VodPlayController *)playController;
        vpc.fullScreen = (orientation != UIInterfaceOrientationPortrait);
    }
}

- (void)fullScreenButtonClickedHandlerForVodPlayController:(VodPlayController *)vodPlayController isFullScreen:(BOOL)isFullScreen
{
    [vodPlayController.view removeFromSuperview];
    [vodPlayController removeFromParentViewController];
    
    UIInterfaceOrientation orientation = UIInterfaceOrientationLandscapeRight;
    if (!isFullScreen) {
        orientation = UIInterfaceOrientationPortrait;
    }
    
    if (isFullScreen) {
        UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
        [keywindow addSubview:vodPlayController.view];
        [_owner addChildViewController:vodPlayController];
        [vodPlayController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(keywindow);
        }];
    } else {
        [_owner.view addSubview:vodPlayController.view];
        [_owner addChildViewController:vodPlayController];
        [vodPlayController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            if ([[KSYGetDeviceName getDeviceName] isEqual:@"iPhoneX"]) {
                make.leading.trailing.equalTo(_owner.view);
                make.top.equalTo(_owner.view).offset(SafeAreaStatusBarTopHeight);
                make.height.mas_equalTo(211);
            }
            else {
                make.leading.trailing.top.equalTo(_owner.view);
                make.height.mas_equalTo(211);
            }
        }];
    }
    
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
    if ([vodPlayController isKindOfClass:[VodPlayController class]]) {
        VodPlayController *vpc = (VodPlayController *)vodPlayController;
        vpc.fullScreen = isFullScreen;
    }
}

- (void)fullScreenHandlerForLivePlayController:(LivePlayController *)playController
                                  isFullScreen:(BOOL) isFullScreen {
    
    UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
    if (isFullScreen) {
        orientation = UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft;
    } else {
        orientation = UIInterfaceOrientationPortrait;
    }
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
    if ([playController isKindOfClass:[LivePlayController class]]) {
        LivePlayController *vpc = (LivePlayController *)playController;
        vpc.fullScreen = (orientation != UIInterfaceOrientationPortrait);
    }
}

- (VideoModel *)nextVideoModel {
    VideoModel *next = nil;
    if (_currPlayingIndex + 1 < _videoListViewModel.listViewDataSource.count && _currPlayingIndex + 1 >= 0)
    {
        next = _videoListViewModel.listViewDataSource[_currPlayingIndex + 1];
    }
    return next;
}


@end
