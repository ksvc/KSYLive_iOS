//
//  KSYKitDemoVC.m
//  KSYGPUStreamerDemo
//
//  Created by yiqian on 6/23/16.
//  Copyright © 2016 ksyun. All rights reserved.
//

#import "KSYKitDemoVC.h"
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/libksygpuimage.h>


@interface KSYKitDemoVC () {
    id _filterBtn;
    UILabel* label;
}

@end

@implementation KSYKitDemoVC


#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _kit = [[KSYGPUStreamerKit alloc] initWithDefaultCfg];
    // 获取streamerBase, 方便进行推流相关操作, 也可以直接 _kit.streamerBase.xxx
    self.streamerBase = _kit.streamerBase;
    // 采集相关设置初始化
    [self setCaptureCfg];
    //推流相关设置初始化
    [self setStreamerCfg];
    
    // 获取背景音乐播放器
    self.bgmPlayer = _kit.bgmPlayer;

    // 打印版本号信息
    NSLog(@"version: %@", [_kit getKSYVersion]);
    [self setupLogo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_kit) {
        // init with default filter
        self.filter =self.ksyFilterView.curFilter;
        [_kit setupFilter:self.ksyFilterView.curFilter];
        [_kit startPreview:self.view];
    }
}

- (void) setCaptureCfg {
    _kit.videoDimension = [self.presetCfgView resolution];
    _kit.videoFPS       = [self.presetCfgView frameRate];
    _kit.cameraPosition = [self.presetCfgView cameraPos];
    _kit.bInterruptOtherAudio = NO;
    _kit.videoProcessingCallback = ^(CMSampleBufferRef sampleBuffer){
    };
    _kit.audioProcessingCallback =^(CMSampleBufferRef buf){
    };
}
- (void) setupLogo{
    NSString *aPath3=[NSHomeDirectory() stringByAppendingString:@"/Documents/ksvc.png"];
    UIImage *imgFromUrl3=[[UIImage alloc]initWithContentsOfFile:aPath3];
    CGPoint pz = CGPointMake(10, 10);
    [_kit addLogo:imgFromUrl3 pos:pz trans:0.5];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0,100, 500, 100)];
    label.textColor = [UIColor whiteColor];
    //label.font = [UIFont systemFontOfSize:17.0]; // 非等宽字体, 可能导致闪烁
    label.font = [UIFont fontWithName:@"Courier-Bold" size:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.hidden = NO;
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd HH:mm:ss";
    NSDate *now = [[NSDate alloc] init];
    label.text = [dateFormatter stringFromDate:now];
    [_kit addTimeLabel:label dateFormat:dateFormatter.dateFormat];
}

#pragma mark -  state change
- (void)onTimer:(NSTimer *)theTimer{
    [super onTimer:theTimer];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM-dd HH:mm:ss";
    NSDate *now = [[NSDate alloc] init];
    label.text = [dateFormatter stringFromDate:now];
    [_kit updateTextLable:label];
}

- (void) onCaptureStateChange:(NSNotification *)notification{
    NSLog(@"new capStat: %@", _kit.getCurCaptureStateName );
    self.ctrlView.lblStat.text = [_kit getCurCaptureStateName];
    if (_kit.captureState == KSYCaptureStateCapturing){
        self.capDev = _kit.capDev;
    }
    else {
        self.capDev = nil;
    }
}

- (void) onPipPlayerNotify:(NSNotification *)notification{
    if (MPMediaPlaybackIsPreparedToPlayDidChangeNotification == notification.name) {
        [_kit.player play]; // 准备好后开始播放
    }
    if (MPMoviePlayerPlaybackDidFinishNotification == notification.name) {
        [_kit.player stop]; // 播放完成
    }
}

- (void) onFlash {
    [_kit toggleTorch];
}

- (void) onCameraToggle{
    [_kit switchCamera];
    [super onCameraToggle];
}

- (void) onCapture{
    if (!_kit.capDev.isRunning){
        [_kit startPreview:self.view];
    }
    else {
        [_kit stopPreview];
    }
}
- (void) onStream{
    if (_kit.streamerBase.streamState == KSYStreamStateIdle ||
        _kit.streamerBase.streamState == KSYStreamStateError) {
        [_kit.streamerBase startStream:self.hostURL];
        self.streamerBase = _kit.streamerBase;
    }
    else {
        [_kit.streamerBase stopStream];
        self.streamerBase = nil;
    }
}


- (void) onQuit{  // quit current demo
    [_kit stopPreview];
    if (_kit.player){
        [self onPipStop];
    }
    [super onQuit];
}

- (void) onFilterChange:(id)sender{
    if (self.ksyFilterView.curFilter != _kit.filter){
        // use a new filter
        self.filter = self.ksyFilterView.curFilter;
        [_kit setupFilter:self.ksyFilterView.curFilter];
    }
}

// volume change
- (void)onAMixerSlider:(KSYNameSlider *)slider {
    float val = 0.0;
    if ([slider isKindOfClass:[KSYNameSlider class]]) {
        val = slider.normalValue;
    }
    else {
        return;
    }
    if ( slider == self.audioMixerView.bgmVol){
        [_kit.audioMixer setMixVolume:val of: _kit.bgmTrack];
    }
    else if ( slider == self.audioMixerView.micVol){
        [_kit.audioMixer setMixVolume:val of: _kit.micTrack];
    }
    else if ( slider == self.audioMixerView.pipVol){
        [_kit.audioMixer setMixVolume:val of: _kit.pipTrack];
    }
}
#pragma mark - pip ctrl
// pip start
- (void)onPipPlay{
    [_kit startPipWithPlayerUrl:self.ksyPipView.pipURL
                          bgPic:self.ksyPipView.bgpURL
                        capRect:CGRectMake(0.6, 0.6, 0.3, 0.3)];

}
- (void)onPipStop{
    [_kit stopPip];
}
- (void)onPipNext{
    [_kit stopPip];
    [self onPipPlay];
}
- (void)onBgpNext{
    [_kit startPipWithPlayerUrl:nil
                          bgPic:self.ksyPipView.bgpURL
                        capRect:CGRectMake(0.6, 0.6, 0.3, 0.3)];
}
- (void)pipVolChange:(id)sender{
    if (_kit.player && sender == self.ksyPipView.volumSl) {
        float vol = self.ksyPipView.volumSl.normalValue;
        [_kit.player setVolume:vol rigthVolume:vol];
    }
}
@end
