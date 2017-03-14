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
#import "KSYBgmStreamerVC.h"
#import "KSYFilterView.h"
#import "KSYBgmView.h"
#import "KSYNameSlider.h"

@interface KSYBgmStreamerVC () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
}
@end

@implementation KSYBgmStreamerVC

- (id) initWithCfg:(KSYPresetCfgView*)presetCfgView{
    self = [super initWithCfg:presetCfgView];
    self.view.backgroundColor = [UIColor whiteColor];
    return self;
}

#pragma mark - UIViewController
- (void)viewDidLoad {
    _bgmKit = [[KSYGPUBgmStreamerKit alloc] initWithDefaultCfg];
    self.kit = _bgmKit;
    _bgmFinishBlock = nil;
    [super viewDidLoad];
}

- (void)addSubViews{
    [super addSubViews];
    // connect UI
    @WeakObj(self);
    // 背景音乐控制页面
    self.ksyBgmView.onBtnBlock = ^(id sender) {
        [selfWeak onBgmBtnPress:sender];
    };
    self.ksyBgmView.onSliderBlock = ^(id sender) {
        [selfWeak onBgmVolume:sender];
    };
    self.ksyBgmView.onSegCtrlBlock = ^(id sender) {
        [selfWeak onBgmCtrSle:sender];
    };
}

- (void) initObservers{
    [super initObservers];
    [self.obsDict setObject:SEL_VALUE(onKsyBgmPlayerStateChange:) forKey:MPMoviePlayerPlaybackStateDidChangeNotification];
    [self.obsDict setObject:SEL_VALUE(onKsyBgmPlayerFinish:) forKey:MPMoviePlayerPlaybackDidFinishNotification];

}

-(void)onKsyBgmPlayerFinish: (NSNotification *)notification{
    if (!_bgmKit.ksyBgmPlayer) {
        return;
    }
    if (_bgmFinishBlock) {
        _bgmFinishBlock();
    }
}

#pragma mark -  state change
- (void) onKsyBgmPlayerStateChange  :(NSNotification *)notification{
    NSString * st = [_bgmKit getCurBgmStateName];
    self.ksyBgmView.bgmStatus = [st substringFromIndex:20];
}

#pragma mark - timer respond per second
- (void)onTimer:(NSTimer *)theTimer{
    [super onTimer:theTimer];
    if (_bgmKit.ksyBgmPlayer && _bgmKit.ksyBgmPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        self.ksyBgmView.progressBar.playProgress = _bgmKit.ksyBgmPlayer.currentPlaybackTime/_bgmKit.ksyBgmPlayer.duration;
    }
}

#pragma mark - subviews: bgmview

- (void)onBgmCtrSle:(UISegmentedControl*)sender {
    if ( sender == self.ksyBgmView.loopType){
        @WeakObj(self);
        if ( sender.selectedSegmentIndex == 0) { // signal play
            _bgmFinishBlock = ^{};
        }
        else { // loop to next
                _bgmFinishBlock = ^{
                    [selfWeak.ksyBgmView loopNextBgmPath];
                    [selfWeak onBgmPlay];
                };
            }
        }
    }

//bgmView Control
- (void)onBgmBtnPress:(UIButton *)btn{
    if (btn == self.ksyBgmView.playBtn){
        [self onBgmPlay];
    }
    else if (btn ==  self.ksyBgmView.pauseBtn){
        if (_bgmKit.ksyBgmPlayer.playbackState == MPMoviePlaybackStatePlaying) {
            [_bgmKit.ksyBgmPlayer pause];
        }
        else if (_bgmKit.ksyBgmPlayer.playbackState == MPMoviePlaybackStatePaused){
            [_bgmKit.ksyBgmPlayer play];
        }
    }
    else if (btn == self.ksyBgmView.stopBtn){
        [self onBgmStop];
    }
    else if (btn == self.ksyBgmView.nextBtn){
        [self.ksyBgmView nextBgmPath];
        [self playNextBgm];
    }
    else if (btn == self.ksyBgmView.previousBtn) {
        [self.ksyBgmView previousBgmPath];
        [self playNextBgm];
    }
}

- (void) playNextBgm {
    if (_bgmKit.ksyBgmPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self onBgmStop];
        [self onBgmPlay];
    }
}

- (void) onBgmPlay{
    NSString* path = self.ksyBgmView.bgmPath;
    if (!path) {
        [self onBgmStop];
    }
    [_bgmKit startPlayBgm:path];
}

- (void) onBgmStop{
    [_bgmKit stopPlayBgm];
}

// 背景音乐音量调节
- (void)onBgmVolume:(id )sl{
    if (_bgmKit.ksyBgmPlayer && sl == self.ksyBgmView.volumSl) {
        float vol = self.ksyBgmView.volumSl.normalValue;
        [_bgmKit.ksyBgmPlayer setVolume:vol rigthVolume:vol];
    }
}

#pragma mark - subviews: basic ctrl
- (void) onQuit{
    [_bgmKit stopPlayBgm];
    [super onQuit];
}

@end
