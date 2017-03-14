//
//  ViewController.m
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 ksyun. All rights reserved.
//
#import "KSYUIView.h"
#import "KSYUIVC.h"

#import "KSYPresetCfgView.h"
#import "KSYPipStreamerVC.h"
#import "KSYFilterView.h"
#import "KSYBgmView.h"
#import "KSYPipView.h"
#import "KSYNameSlider.h"

@interface KSYPipStreamerVC () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    NSUInteger _pipBtnIdx;
}
@end

@implementation KSYPipStreamerVC

- (id) initWithCfg:(KSYPresetCfgView*)presetCfgView{
    self = [super initWithCfg:presetCfgView];
    self.view.backgroundColor = [UIColor whiteColor];
    return self;
}

#pragma mark - UIViewController
- (void)viewDidLoad {
    self.menuNames = [self.menuNames arrayByAddingObject:@"画中画"];
    _pipBtnIdx = self.menuNames.count;
    _pipKit = [[KSYGPUPipStreamerKit alloc] initWithDefaultCfg];
    self.kit = _pipKit;
    [super viewDidLoad];
}

- (void)addSubViews{
    [super addSubViews];
    _ksyPipView     = [[KSYPipView alloc]initWithParent:self.ctrlView];
    // connect UI
    @WeakObj(self);
    // 画中画播放控制视图
    _ksyPipView.onBtnBlock = ^(id sender){
        [selfWeak onPipBtnPress:sender];
    };
    _ksyPipView.onSliderBlock = ^(id sender) {
        [selfWeak pipVolChange:sender];
    };
}

- (void) initObservers{
    [super initObservers];
    [self.obsDict setObject:SEL_VALUE(onPipStateChange:) forKey:MPMoviePlayerPlaybackStateDidChangeNotification];
}

#pragma mark -  state change
- (void) onPipStateChange  :(NSNotification *)notification{
    NSString * st = [_pipKit getCurPipStateName];
    _ksyPipView.pipStatus = [st substringFromIndex:20];
}

#pragma mark - timer respond per second
- (void)onTimer:(NSTimer *)theTimer{
    [super onTimer:theTimer];
    if (_pipKit.player && _pipKit.player.playbackState == MPMoviePlaybackStatePlaying ) {
        if (_pipKit.player.duration) {
            _ksyPipView.progressV.progress = _pipKit.player.currentPlaybackTime/_pipKit.player.duration;
        }
    }
}

#pragma mark - UI respond
//menuView control
- (void)onMenuBtnPress:(UIButton *)btn{
    [super onMenuBtnPress:btn];
    KSYUIView * view = nil;
    if (btn == self.ctrlView.menuBtns[_pipBtnIdx-1] ){
        view = _ksyPipView;   // 画中画播放相关
    }
    // 将菜单的按钮隐藏, 将触发二级菜单的view显示
    if (view){
        [self.ctrlView showSubMenuView:view];
    }
}
#pragma mark - subviews: pipView
//pipView btn Control
- (void)onPipBtnPress:(UIButton *)btn{
    if (btn == _ksyPipView.pipPlay){
        [self onPipPlay];
    }
    else if (btn == _ksyPipView.pipPause){
        [self onPipPause];
    }
    else if (btn == _ksyPipView.pipStop){
        [self onPipStop];
    }
    else if (btn == _ksyPipView.pipNext){
        [self onPipNext];
    }
    else if (btn == _ksyPipView.bgpNext){
        [self onBgpNext];
    }
}

- (void)onPipPlay{
    [_pipKit startPipWithPlayerUrl:self.ksyPipView.pipURL
                          bgPic:self.ksyPipView.bgpURL];
}
- (void)onPipStop{
    [_pipKit stopPip];
}
- (void)onPipNext{
    if (_pipKit.player){
        [_pipKit stopPip];
        [self onPipPlay];
    }
}

- (void)onPipPause{
    if (_pipKit.player && _pipKit.player.playbackState == MPMoviePlaybackStatePlaying) {
        [_pipKit.player pause];
    }
    else if (_pipKit.player && _pipKit.player.playbackState == MPMoviePlaybackStatePaused){
        [_pipKit.player play];
    }
}

- (void)onBgpNext{
    if ( _pipKit.player ){
        [_pipKit startPipWithPlayerUrl:nil
                              bgPic:self.ksyPipView.bgpURL];
    }
}

- (void)pipVolChange:(id)sender{
    if (_pipKit.player && sender == self.ksyPipView.volumSl) {
        float vol = self.ksyPipView.volumSl.normalValue;
        [_pipKit.player setVolume:vol rigthVolume:vol];
    }
}

#pragma mark - subviews: basic ctrl
- (void) onQuit{
    [_pipKit stopPip];
    [super onQuit];
}

@end
