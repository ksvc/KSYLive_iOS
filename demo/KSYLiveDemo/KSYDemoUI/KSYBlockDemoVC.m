//
//  KSYBlockDemoVC.m
//  KSYGPUStreamerDemo
//
//  Created by yiqian on 6/23/16.
//  Copyright © 2016 ksyun. All rights reserved.
//

#import "KSYBlockDemoVC.h"


@interface KSYBlockDemoVC()

@property (nonatomic, retain) KSYMoviePlayerController *player;

@property GPUImageCropFilter * cropfilter;
@property GPUImageView       * preview;
@property KSYGPUPicOutput    * yuvOutput;
@end

@implementation KSYBlockDemoVC

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /////1. 数据源 ///////////
    // 创建采集模块 (从presetCfg中获取参数)
    [self  setCaptureCfg];
    // 创建背景音乐播放模块
    self.bgmPlayer = [[KSYBgmPlayer   alloc] init];
    
    /////2. 数据出口 ///////////
    // 创建 推流模块
    self.streamerBase = [[KSYStreamerBase alloc] initWithDefaultCfg];
    
    
    // 创建 预览模块, 并放到视图底部
    _preview = [[GPUImageView alloc] init];
    _preview.frame = self.view.frame;
    [self.view addSubview:_preview];
    [self.view sendSubviewToBack:_preview];
    // get pic data from filter
    _yuvOutput =[[KSYGPUPicOutput alloc] init];
    [self setStreamerCfg];
    ///// 3. 数据处理和通路 ///////////
    ///// 3.1 视频通路 ///////////
    // 核心部件:视频叠加混合 (初始化时不开启)
    // self.pipFilter = [[KSYGPUPipBlendFilter alloc]init];
    // 组装视频通道
    [self setupVideoPath];
    
    ///// 3.2 音频通路 ///////////
    // 核心部件:音频叠加混合
    self.aMixer = [[KSYAudioMixer alloc]init];
    // 混响
    self.reverb    = nil;
    // 耳返
    self.micMonitor = nil;

    // 组装音频通道
    [self setupAudioPath];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.ctrlView.btnQuit setTitle: @"退出block"
                           forState: UIControlStateNormal];
    if (self.capDev) {
        self.filter = self.ksyFilterView.curFilter;
        [self setupVideoPath];
        [self.capDev startCameraCapture];
    }
}
// 根据UI的朝向 , 决定是否需要宽高对调
// 假设输入的都是横屏方式 (wdt> hgt)
- (CGRect) getRectByOrientaion: (CGRect)rect {
    UIInterfaceOrientation orien = [[UIApplication sharedApplication] statusBarOrientation];
    if (orien == UIInterfaceOrientationPortrait ||
        orien == UIInterfaceOrientationPortraitUpsideDown) {
        CGPoint pt = CGPointMake(rect.origin.y, rect.origin.x);
        CGSize  sz = CGSizeMake(rect.size.height, rect.size.width);
        rect.origin = pt;
        rect.size   = sz;
    }
    return rect;
}
// 计算 需要裁掉的边的长度
// 输入的size 都认为 wdt > hgt
- (CGRect) calcCrop: (CGSize) src
                 to: (CGSize) dst {
    CGFloat x = (src.width-dst.width)/2/dst.width;
    CGFloat y = (src.height-dst.height)/2/src.height;
    CGFloat wdt = dst.width/src.width;
    CGFloat hgt = dst.height/src.height;
    return [self getRectByOrientaion: CGRectMake(x, y, wdt, hgt)];
}

- (void) setCaptureCfg {
    NSString * preset = nil;
    KSYVideoDimension dim = [self.presetCfgView capResolution];
    if ( dim == KSYVideoDimension_16_9__640x360){
        preset = AVCaptureSessionPreset640x480;
        CGRect rect = [self calcCrop:CGSizeMake(640, 480)
                                  to:CGSizeMake(640, 360)];
        _cropfilter = [[GPUImageCropFilter alloc] initWithCropRegion:rect];
    }
    else if ( dim == KSYVideoDimension_16_9__960x540){
        preset = AVCaptureSessionPresetiFrame960x540;
    }
    else if ( dim == KSYVideoDimension_16_9__1280x720){
        preset = AVCaptureSessionPreset1280x720;
    }
    else if ( dim == KSYVideoDimension_4_3__640x480){
        preset = AVCaptureSessionPreset640x480;
    }
    AVCaptureDevicePosition pos = [self.presetCfgView cameraPos];
    self.capDev = [[KSYGPUCamera alloc] initWithSessionPreset:preset
                                           cameraPosition:pos];
    if (self.capDev == nil) {
        return;
    }
    self.capDev.frameRate      = [self.presetCfgView frameRate];
    self.capDev.bInterruptOtherAudio = NO;
    self.capDev.outputImageOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    self.capDev.bStreamVideo = NO;
    self.capDev.bStreamAudio = NO;  // use mixer instead
    self.capDev.horizontallyMirrorFrontFacingCamera = NO;
    self.capDev.horizontallyMirrorRearFacingCamera  = NO;
    [self.capDev addAudioInputsAndOutputs];
}
- (void) setStreamerCfg { // must set after capture
    [super setStreamerCfg];
    KSYVideoDimension dim = [self.presetCfgView strResolution];
    if (dim == [self.presetCfgView capResolution]){
        _yuvOutput.bCustomOutputSize = NO;
        return;
    }
    CGSize sz = CGSizeMake(640, 360);
    if ( dim == KSYVideoDimension_16_9__640x360){
         sz = CGSizeMake(640, 360);
    }
    else if ( dim == KSYVideoDimension_16_9__960x540){
        sz  = CGSizeMake(960, 540);
    }
    else if ( dim == KSYVideoDimension_16_9__1280x720){
        sz  = CGSizeMake(1280, 720);
    }
    else if ( dim == KSYVideoDimension_4_3__640x480){
        sz  = CGSizeMake(640, 480);
    }
    CGRect rect = {{0,0}, sz};
    rect = [ self getRectByOrientaion:rect];
    _yuvOutput.bCustomOutputSize = YES;
    _yuvOutput.outputSize = rect.size;
}

-(void) setupVideoPath{
    [self.capDev removeAllTargets];
    GPUImageOutput* src = self.capDev;
    if (_cropfilter){
        [_cropfilter removeAllTargets];
        [src addTarget:_cropfilter];
        src = _cropfilter;
    }
    if (self.filter){
        [self.filter removeAllTargets];
        [src addTarget:self.filter];
        src = self.filter;
    }
    if (self.pipFilter){
        [self.pipFilter removeAllTargets]; // 1st (top) layer: camera input
        [src addTarget:self.pipFilter atTextureLocation:0];
        [self.yuvInput  removeAllTargets]; // 2nd (middle) layer: movie player
        [self.yuvInput addTarget:self.pipFilter atTextureLocation:1];
        [self.pipFilter clearSecondTexture];
        if(self.bgPic) {
            [self.bgPic    removeAllTargets];  // 3rd (bottom) layer: picture
            [self.bgPic    addTarget:self.pipFilter atTextureLocation:2];
        }
        src = self.pipFilter;
    }
    [src     addTarget:_preview];
    [src     addTarget:_yuvOutput];
    
    __weak KSYBlockDemoVC * vc = self;
    _yuvOutput.videoProcessingCallback = ^(CVPixelBufferRef pixelBuffer, CMTime timeInfo ){
        [vc.streamerBase processVideoPixelBuffer:pixelBuffer timeInfo:timeInfo];
    };
}
- (void) setupAudioPath {
    __weak KSYBlockDemoVC * vc = self;
    //1. 采集设备的麦克风音频数据, 通过混响处理后, 送入混音器
    self.micTrack = 0;
    self.capDev.audioProcessingCallback = ^(CMSampleBufferRef buf){
        if (![vc.streamerBase isStreaming]){
            return;
        }
        if (vc.reverb){
            [vc.reverb processAudioSampleBuffer:buf];
        }
        if (vc.aMixer){
            [vc.aMixer processAudioSampleBuffer:buf of:vc.micTrack];
        }
    };
    //2. 背景音乐播放,音乐数据送入混音器
    self.bgmTrack = 1;
    self.bgmPlayer.audioDataBlock = ^(CMSampleBufferRef buf){
        if (![vc.streamerBase isStreaming]){
            return;
        }
        [vc.aMixer processAudioSampleBuffer:buf of:vc.bgmTrack];
    };
    //3. 画中画的音频
    self.pipTrack = 2;
    // 混音结果送入streamer
    self.aMixer.audioProcessingCallback = ^(CMSampleBufferRef buf){
        [vc.streamerBase processAudioSampleBuffer:buf];
    };
    // mixer 的主通道为麦克风,时间戳以住通道为准
    self.aMixer.mainTrack = self.micTrack;
    [self.aMixer setTrack:self.micTrack enable:YES];
    [self.aMixer setTrack:self.bgmTrack enable:YES];
    [self.aMixer setTrack:self.pipTrack enable:YES];
    
    // default volume
    [self.aMixer setMixVolume:1.0 of:self.micTrack];
    [self.aMixer setMixVolume:0.2 of:self.bgmTrack];
    [self.aMixer setMixVolume:1.0 of:self.pipTrack];
    self.audioMixerView.bgmVol.slider.value = 0.2;
}
#pragma mark - basic ctrl
- (void) onPipPlayerNotify:(NSNotification *)notification{
    if (MPMediaPlaybackIsPreparedToPlayDidChangeNotification == notification.name) {
        [self.player play]; // 准备好后开始播放
    }
    if (MPMoviePlayerPlaybackDidFinishNotification == notification.name) {
        [self.player stop]; // 播放完成
    }
}

- (void) onFlash {
    [self.capDev toggleTorch];
}

- (void) onCameraToggle{
    [self.capDev rotateCamera];
    [super onCameraToggle];
}

- (void) onCapture{
    if (!self.capDev.isRunning){
        [self.capDev startCameraCapture];
    }
    else {
        [self.capDev stopCameraCapture];
    }
}
- (void) onStream{
    if (self.streamerBase.streamState == KSYStreamStateIdle ||
        self.streamerBase.streamState == KSYStreamStateError) {
        [self.streamerBase startStream:self.hostURL];
    }
    else {
        [self.streamerBase stopStream];
    }
}
- (void) onQuit{  // quit current demo
    [self onPipStop];
    [self.micMonitor stop];
    if (self.streamerBase){
        [self.streamerBase stopStream];
        self.streamerBase = nil;
    }
    if (self.capDev){
        [self.capDev stopCameraCapture];
        self.capDev = nil;
    }
    [super onQuit];
}
- (void) onFilterChange:(id)sender{
    if (self.ksyFilterView.curFilter != self.filter) {
        self.filter = self.ksyFilterView.curFilter;
        [self setupVideoPath];
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
        [self.aMixer setMixVolume:val of: self.bgmTrack];
    }
    else if ( slider == self.audioMixerView.micVol){
        [self.aMixer setMixVolume:val of: self.micTrack];
    }
    else if ( slider == self.audioMixerView.pipVol){
        [self.aMixer setMixVolume:val of: self.pipTrack];
    }
}

#pragma mark - pip ctrl

- (void)setupPip{
    if (self.pipFilter == nil) {
        //pipFilter
        CGRect rect = CGRectMake(0.6, 0.6, 0.3, 0.3);
        self.pipFilter = [[KSYGPUPipBlendFilter alloc] initWithPipRect:rect];
        self.yuvInput  = [[KSYGPUYUVInput alloc] init];
        
        //player
        self.player = [[KSYMoviePlayerController alloc] initWithContentURL: self.ksyPipView.pipURL];
        self.player.controlStyle = MPMovieControlStyleNone;
        self.player.videoDecoderMode = MPMovieVideoDecoderMode_Hardware;
        self.player.shouldAutoplay = YES;
        self.player.shouldMute     = NO;
        [self.aMixer setTrack:self.pipTrack enable:YES];
        __weak KSYBlockDemoVC * vc = self;
        self.player.videoDataBlock = ^(CMSampleBufferRef buf){
            [vc.yuvInput processPixelBuffer:CMSampleBufferGetImageBuffer(buf) time:CMTimeMake(2, 10)];
        };
        self.player.audioDataBlock = ^(CMSampleBufferRef buf){
            [vc.aMixer processAudioSampleBuffer:buf of:vc.pipTrack];
        };
        if (self.ksyPipView.bgpURL){
            self.bgPic = [[GPUImagePicture alloc] initWithURL: self.ksyPipView.bgpURL];
        }
        else {
            self.bgPic = nil;
        }
    }
    [self.player prepareToPlay];
    [self setupVideoPath];
    [self.capDev setAVAudioSessionOption];
}

- (void)onPipPlay{
    [self setupPip];
    [self.player play];
}

- (void)onPipPause{
    if (self.player && self.player.playbackState == MPMoviePlaybackStatePlaying) {
        [self.player pause];
    }
    else if (self.player && self.player.playbackState == MPMoviePlaybackStatePaused){
        [self.player play];
    }
}
- (void)onPipStop{
    if (self.player){
        [self.player stop];
    }
    self.player    = nil;
    self.pipFilter = nil;
    self.yuvInput  = nil;
    self.bgPic     = nil;
    [self setupVideoPath];
}

- (void)onPipNext{
    if (self.player){
        [self onPipStop];
        [self onPipPlay];
    }
}

- (void)pipVolChange:(id)sender{
    if (self.player && sender == self.ksyPipView.volumSl) {
        float vol = self.ksyPipView.volumSl.normalValue;
        [self.player setVolume:vol rigthVolume:vol];
    }
}
- (void)onBgpNext{
    if (self.pipFilter == nil){
        return;
    }
    self.bgPic = [[GPUImagePicture alloc] initWithURL:self.ksyPipView.bgpURL];
    [self.bgPic    removeAllTargets];  // 3rd (bottom) layer: picture
    [self.bgPic    addTarget:self.pipFilter atTextureLocation:2];
}

#pragma mark - micMonitor
// 是否开启耳返
- (void)onMiscSwitch:(UISwitch *)sw{
    if (sw == self.miscView.micmMix){
        if ( [KSYMicMonitor isHeadsetPluggedIn] == NO ){
            return;
        }
        if (sw.isOn){
            if (self.micMonitor == nil){
                self.micMonitor = [[KSYMicMonitor alloc] init];
            }
            [self.micMonitor start];
        }
        else{
            [self.micMonitor stop];
        }
    }
    [super onMiscSwitch:sw];
}

// 调节耳返音量
- (void)onMiscSlider:(KSYNameSlider *)slider {
    if (slider == self.miscView.micmVol){
        if (self.micMonitor){
            [self.micMonitor setVolume:slider.normalValue];
        }
    }
}
@end
