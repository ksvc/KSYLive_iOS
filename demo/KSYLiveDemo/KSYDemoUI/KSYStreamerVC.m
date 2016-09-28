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
#import "KSYStreamerVC.h"
#import "KSYFilterView.h"
#import "KSYBgmView.h"
#import "KSYPipView.h"
#import "KSYNameSlider.h"
#import "KSYReverbView.h"
#import "KSYGPUStreamerKit.h"

@interface KSYStreamerVC () {
    UISwipeGestureRecognizer *_swipeGest;
    NSDateFormatter * _dateFormatter;
    int64_t _seconds;
    NSMutableDictionary *_obsDict;
}
@end

@implementation KSYStreamerVC

- (id) initWithCfg:(KSYPresetCfgView*)presetCfgView{
    self = [super init];
    _presetCfgView = presetCfgView;
    [self initObservers];
    self.view.backgroundColor = [UIColor whiteColor];
    return self;
}

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _kit = [[KSYGPUStreamerKit alloc] initWithDefaultCfg];
    [self addSubViews];
    [self addSwipeGesture];
    // 采集相关设置初始化
    [self setCaptureCfg];
    //推流相关设置初始化
    [self setStreamerCfg];
    // 打印版本号信息
    NSLog(@"version: %@", [_kit getKSYVersion]);
    [self setupLogo];
    if (_kit) { // init with default filter
        _kit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [_kit setupFilter:self.ksyFilterView.curFilter];
        [_kit startPreview:self.view];
    }
}

- (void) addSwipeGesture{
    SEL onSwip =@selector(swipeController:);
    _swipeGest = [[UISwipeGestureRecognizer alloc]initWithTarget:self
                                                          action:onSwip];
    _swipeGest.direction |= UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:_swipeGest];
}

- (void)addSubViews{
    _ctrlView  = [[KSYCtrlView alloc] init];
    [self.view addSubview:_ctrlView];
    _ctrlView.frame = self.view.frame;
    _ksyFilterView  = [[KSYFilterView alloc]initWithParent:_ctrlView];
    _ksyBgmView     = [[KSYBgmView alloc]initWithParent:_ctrlView];
    _audioMixerView = [[KSYAudioMixerView alloc]initWithParent:_ctrlView];
    _reverbView     = [[KSYReverbView alloc]initWithParent:_ctrlView];
    _miscView       = [[KSYMiscView alloc]initWithParent:_ctrlView];

    // connect UI
    __weak KSYStreamerVC *weakself = self;
    _ctrlView.onBtnBlock = ^(id btn){
        [weakself onBasicCtrl:btn];
    };
    // 背景音乐控制页面
    _ksyBgmView.onBtnBlock = ^(id sender) {
        [weakself onBgmBtnPress:sender];
    };
    _ksyBgmView.onSliderBlock = ^(id sender) {
        [weakself onBgmVolume:sender];
    };
    _ksyBgmView.onSegCtrlBlock = ^(id sender) {
        [weakself onBgmCtrSle:sender];
    };
    // 滤镜相关参数改变
    _ksyFilterView.onSegCtrlBlock=^(id sender) {
        [weakself onFilterChange:sender];
    };
    _ksyFilterView.onBtnBlock=^(id sender) {
        [weakself onFilterBtn:sender];
    };
    _ksyFilterView.onSwitchBlock=^(id sender) {
        [weakself onFilterSwitch:sender];
    };
    // 混音相关参数改变
    _audioMixerView.onSwitchBlock=^(id sender){
        [weakself onAMixerSwitch:sender];
    };
    _audioMixerView.onSliderBlock=^(id sender){
        [weakself onAMixerSlider:sender];
    };
    //混响的实现
    _reverbView.onSegCtrlBlock = ^(id sender){
        [weakself onReverbType:sender];
    };
    //混音实现
    _audioMixerView.onSegCtrlBlock=^(id sender){
        [weakself onAMixerSegCtrl:sender];
    };
    // 其他杂项
    _miscView.onBtnBlock = ^(id sender) {
        [weakself onMiscBtns: sender];
    };
    _miscView.onSwitchBlock = ^(id sender) {
        [weakself onMiscSwitch: sender];
    };
    _miscView.onSliderBlock = ^(id sender) {
        [weakself onMiscSlider: sender];
    };
    self.onNetworkChange = ^(NSString * msg){
        weakself.ctrlView.lblNetwork.text = msg;
    };
}
#define SEL_VALUE(SEL_NAME) [NSValue valueWithPointer:@selector(SEL_NAME)]

- (void) initObservers{
    _obsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    SEL_VALUE(onCaptureStateChange:) ,  KSYCaptureStateDidChangeNotification,
    SEL_VALUE(onStreamStateChange:) ,   KSYStreamStateDidChangeNotification,
    SEL_VALUE(onNetStateEvent:) ,       KSYNetStateEventNotification,
    SEL_VALUE(onBgmPlayerStateChange:) ,KSYAudioStateDidChangeNotification,
    SEL_VALUE(enterBg:) ,           UIApplicationDidEnterBackgroundNotification,
    SEL_VALUE(becameActive:) ,      UIApplicationDidBecomeActiveNotification,
    nil];
}

- (void) addObservers {
    [super addObservers];
    //KSYStreamer state changes
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    for (NSString* key in _obsDict) {
        SEL aSel = [[_obsDict objectForKey:key] pointerValue];
        [dc addObserver:self
               selector:aSel
                   name:key
                 object:nil];
    }
}

- (void) rmObservers {
    [super rmObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)enterBg:(NSNotification *)not{  //app will resigned
    // 进入后台时, 将预览从图像混合器中脱离, 避免后台OpenGL渲染崩溃
    [_kit.vMixer removeAllTargets];
}

- (void) becameActive:(NSNotification *)not{ //app becameAction
    // 回到前台, 重新连接预览
    [_kit setupFilter:self.ksyFilterView.curFilter];
}

- (void)viewDidAppear:(BOOL)animated {
    [self layoutUI];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].idleTimerDisabled=NO;
}

- (BOOL)shouldAutorotate {
    [self layoutUI];
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) layoutUI {
    if(_ctrlView){
        [_ctrlView layoutUI];
    }
}
#pragma mark - Capture & stream setup
- (void) setCaptureCfg {
    _kit.capPreset        = [self.presetCfgView capResolution];
    _kit.previewDimension = [self.presetCfgView capResolutionSize];
    _kit.streamDimension  = [self.presetCfgView strResolutionSize ];
    _kit.videoFPS       = [self.presetCfgView frameRate];
    _kit.cameraPosition = [self.presetCfgView cameraPos];
    _kit.gpuOutputPixelFormat = [self.presetCfgView gpuOutputPixelFmt];
    _kit.videoProcessingCallback = ^(CMSampleBufferRef buf){
    };
}

- (void) setupLogo{
    CGFloat yPos = 0.05;
    CGFloat hgt  = 0.1;
    NSString *logoFile=[NSHomeDirectory() stringByAppendingString:@"/Documents/ksvc.png"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:logoFile]){
        NSURL *url =[[NSURL alloc] initFileURLWithPath:logoFile];
        _kit.logoPic  = [[GPUImagePicture alloc] initWithURL: url];
        _kit.logoRect = CGRectMake(0.05, yPos, 0, hgt);
        _kit.logoAlpha= 0.5;
        yPos += hgt;
    }
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = @"HH:mm:ss";
    NSDate *now = [[NSDate alloc] init];
    _kit.textLabel.text = [_dateFormatter stringFromDate:now];
    hgt = 20.0 / 640;
    _kit.textRect = CGRectMake(0.05, yPos, 0, hgt);
    [_kit updateTextLabel];
}

- (void) defaultStramCfg{
    // stream default settings
    _kit.streamerBase.videoCodec = KSYVideoCodec_AUTO;
    _kit.streamerBase.videoInitBitrate =  800;
    _kit.streamerBase.videoMaxBitrate  = 1000;
    _kit.streamerBase.videoMinBitrate  =    0;
    _kit.streamerBase.audiokBPS        =   48;
    _kit.streamerBase.enAutoApplyEstimateBW     = YES;
    _kit.streamerBase.shouldEnableKSYStatModule = YES;
    _kit.streamerBase.videoFPS = 15;
    _kit.streamerBase.logBlock = ^(NSString* str){
        NSLog(@"%@", str);
    };
    _hostURL = [NSURL URLWithString:@"rtmp://test.uplive.ksyun.com/live/123"];
}
- (void) setStreamerCfg { // must set after capture
    if (_kit.streamerBase == nil) {
        return;
    }
    if (_presetCfgView){ // cfg from presetcfgview
        _kit.streamerBase.videoCodec       = [_presetCfgView videoCodec];
        _kit.streamerBase.videoInitBitrate = [_presetCfgView videoKbps]*6/10;//60%
        _kit.streamerBase.videoMaxBitrate  = [_presetCfgView videoKbps];
        _kit.streamerBase.videoMinBitrate  = 0; //
        _kit.streamerBase.audioCodec       = [_presetCfgView audioCodec];
        _kit.streamerBase.audiokBPS        = [_presetCfgView audioKbps];
        _kit.streamerBase.videoFPS         = [_presetCfgView frameRate];
        _kit.streamerBase.bwEstimateMode   = [_presetCfgView bwEstMode];
        _kit.streamerBase.enAutoApplyEstimateBW = YES;
        _kit.streamerBase.shouldEnableKSYStatModule = YES;
        _kit.streamerBase.logBlock = ^(NSString* str){ };
        _hostURL = [NSURL URLWithString:[_presetCfgView hostUrl]];
    }
    else {
        [self defaultStramCfg];
    }
}

- (void) updateStreamCfg: (BOOL) bStart {
    _kit.streamerBase.liveScene       =  self.miscView.liveScene;
    _kit.streamerBase.videoEncodePerf =  self.miscView.vEncPerf;
    _kit.streamerBase.bWithVideo      = !self.miscView.swAudioOnly.on;
    _seconds = 0;
    self.miscView.liveSceneSeg.enabled = !bStart;
    self.miscView.vEncPerfSeg.enabled = !bStart;
}

#pragma mark -  state change
- (void) onCaptureStateChange:(NSNotification *)notification{
    NSLog(@"new capStat: %@", _kit.getCurCaptureStateName );
    self.ctrlView.lblStat.text = [_kit getCurCaptureStateName];
}

- (void) onNetStateEvent     :(NSNotification *)notification{
    switch (_kit.streamerBase.netStateCode) {
        case KSYNetStateCode_SEND_PACKET_SLOW: {
            _ctrlView.lblStat.notGoodCnt++;
            break;
        }
        case KSYNetStateCode_EST_BW_RAISE: {
            _ctrlView.lblStat.bwRaiseCnt++;
            break;
        }
        case KSYNetStateCode_EST_BW_DROP: {
            _ctrlView.lblStat.bwDropCnt++;
            break;
        }
        default:break;
    }
}
- (void) onBgmPlayerStateChange  :(NSNotification *)notification{
    NSString * st = [_kit.bgmPlayer getCurBgmStateName];
    _ksyBgmView.bgmStatus = [st substringFromIndex:17];
}
- (void) onStreamStateChange :(NSNotification *)notification{
    if (_kit.streamerBase){
        NSLog(@"stream State %@", [_kit.streamerBase getCurStreamStateName]);
    }
    _ctrlView.lblStat.text = [_kit.streamerBase getCurStreamStateName];
    if(_kit.streamerBase.streamState == KSYStreamStateError) {
        [self onStreamError:_kit.streamerBase.streamErrorCode];
    }
    else if (_kit.streamerBase.streamState == KSYStreamStateConnecting) {
        [_ctrlView.lblStat initStreamStat]; // 尝试开始连接时,重置统计数据
    }
    else if (_kit.streamerBase.streamState == KSYStreamStateConnected) {
        if ([self.miscView.swAudioOnly isOn] ){
            _kit.streamerBase.bWithVideo = NO;
        }
    }
}

- (void) onStreamError:(KSYStreamErrorCode) errCode{
    _ctrlView.lblStat.text  = [_kit.streamerBase getCurKSYStreamErrorCodeName];
    if (errCode == KSYStreamErrorCode_CONNECT_BREAK) {
        // Reconnect
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            _kit.streamerBase.bWithVideo = YES;
            [_kit.streamerBase startStream:self.hostURL];
        });
    }
    else if (errCode == KSYStreamErrorCode_AV_SYNC_ERROR) {
        NSLog(@"audio video is not synced, please check timestamp");
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            NSLog(@"try again");
            _kit.streamerBase.bWithVideo = YES;
            [_kit.streamerBase startStream:self.hostURL];
        });
    }
}
#pragma mark - timer respond per second
- (void)onTimer:(NSTimer *)theTimer{
    if (_kit.streamerBase.streamState == KSYStreamStateConnected ) {
        [_ctrlView.lblStat updateState: _kit.streamerBase];
    }
    if (_kit.bgmPlayer && _kit.bgmPlayer.bgmPlayerState ==KSYBgmPlayerStatePlaying ) {
        _ksyBgmView.progressV.progress = _kit.bgmPlayer.bgmProcess;
    }
    _seconds++;
    UIApplicationState appState = [UIApplication sharedApplication].applicationState;
    if (_seconds%5 == 0 && // update label every 5 second
        appState == UIApplicationStateActive){
        NSDate *now = [[NSDate alloc] init];
        _kit.textLabel.text = [_dateFormatter stringFromDate:now];
        [_kit updateTextLabel];
    }
}

#pragma mark - UI respond
//ctrView control (for basic ctrl)
- (void) onBasicCtrl: (id) btn {
    if (btn == _ctrlView.btnFlash){
        [self onFlash];
    }
    else if (btn == _ctrlView.btnCameraToggle){
        [self onCameraToggle];
    }
    else if (btn == _ctrlView.btnQuit){
        [self onQuit];
    }
    else if(btn == _ctrlView.btnCapture){
        [self onCapture];
    }
    else if(btn == _ctrlView.btnStream){
        [self onStream];
    }
    else { // other btns
        [self onMenuBtnPress:btn];
    }
}

//menuView control
- (void)onMenuBtnPress:(UIButton *)btn{
    KSYUIView * view = nil;
    if (btn == _ctrlView.bgmBtn ){
        view = _ksyBgmView; // 背景音乐播放相关
    }
    else if (btn == _ctrlView.filterBtn ){
        view = _ksyFilterView; // 美颜滤镜相关
    }
    else if (btn == _ctrlView.mixBtn ){
        view = _audioMixerView;    // 混音控制台
        _audioMixerView.micType = _kit.avAudioSession.currentMicType;
        [_audioMixerView initMicInput];
    }
    else if (btn == _ctrlView.miscBtn ){
        view = _miscView;
        //[_miscView initMicmOutput];
    }
    else if (btn == _ctrlView.reverbBtn ){
        view = _reverbView;
    }
    // 将菜单的按钮隐藏, 将触发二级菜单的view显示
    if (view){
        [_ctrlView showSubMenuView:view];
        [view     layoutUI];
    }
}

- (void)swipeController:(UISwipeGestureRecognizer *)swipGestRec{
    if (swipGestRec == _swipeGest){
        CGRect rect = self.view.frame;
        if ( CGRectEqualToRect(rect, _ctrlView.frame)){
            rect.origin.x = rect.size.width; // hide
        }
        [UIView animateWithDuration:0.1 animations:^{
            _ctrlView.frame = rect;
        }];
    }
}
#pragma mark - subviews: bgmview
- (void)onBgmCtrSle:(UISegmentedControl*)sender {
    if ( sender == _ksyBgmView.loopType){
        __weak KSYStreamerVC *weakself = self;
        if ( sender.selectedSegmentIndex == 0) { // signal play
            _kit.bgmPlayer.bgmFinishBlock = ^{};
        }
        else { // loop to next
            _kit.bgmPlayer.bgmFinishBlock = ^{
                [weakself.ksyBgmView loopNextBgmPath];
                [weakself onBgmPlay];
            };
        }
    }
}
//bgmView Control
- (void)onBgmBtnPress:(UIButton *)btn{
    __weak KSYStreamerVC *weakself = self;
    if (btn == _ksyBgmView.playBtn){
        [self onBgmPlay];
    }
    else if (btn ==  _ksyBgmView.pauseBtn){
        if (_kit.bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePlaying) {
            [_kit.bgmPlayer pauseBgm];
        }
        else if (_kit.bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePaused){
            [_kit.bgmPlayer resumeBgm];
        }
    }
    else if (btn == _ksyBgmView.stopBtn){
        [self onBgmStop];
    }
    else if (btn == _ksyBgmView.nextBtn){
        [self.ksyBgmView nextBgmPath];
        [self playNextBgm];
    }
    else if (btn == _ksyBgmView.previousBtn) {
        [self.ksyBgmView previousBgmPath];
        [self playNextBgm];
    }
    else if (btn == _ksyBgmView.muteBtn){
        // 仅仅是静音了本地播放, 推流中仍然有音乐
        _kit.bgmPlayer.bMutBgmPlay = !_kit.bgmPlayer.bMutBgmPlay;
    }
}
- (void) playNextBgm {
    if (_kit.bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePlaying) {
        [_kit.bgmPlayer stopPlayBgm];
        [self onBgmPlay];
    }
}
- (void) onBgmPlay{
    NSString* path = _ksyBgmView.bgmPath;
    if (!path) {
        [self onBgmStop];
    }
    [_kit.bgmPlayer startPlayBgm:path isLoop:NO];
}

- (void) onBgmStop{
    if (_kit.bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePlaying) {
        [_kit.bgmPlayer stopPlayBgm];
    }
}

// 背景音乐音量调节
- (void)onBgmVolume:(id )sl{
    if (sl == _ksyBgmView.volumSl){
        _kit.bgmPlayer.bgmVolume = _ksyBgmView.volumSl.normalValue;
    }
}

#pragma mark - subviews: basic ctrl
- (void) onFlash {
    [_kit toggleTorch];
}
- (void) onCameraToggle{ // see kit or block
    [_kit switchCamera];
    if (_kit.vCapDev && _kit.vCapDev.cameraPosition == AVCaptureDevicePositionBack) {
        [_ctrlView.btnFlash setEnabled:YES];
    }
    else{
        [_ctrlView.btnFlash setEnabled:NO];
    }
}
- (void) onCapture{
    if (!_kit.vCapDev.isRunning){
        _kit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [_kit startPreview:self.view];
    }
    else {
        [_kit stopPreview];
    }
}
- (void) onStream{
    if (_kit.streamerBase.streamState == KSYStreamStateIdle ||
        _kit.streamerBase.streamState == KSYStreamStateError) {
        [self updateStreamCfg:YES];
        [_kit.streamerBase startStream:self.hostURL];
    }
    else {
        [self updateStreamCfg:NO];
        [_kit.streamerBase stopStream];
    }
}
- (void) onQuit{
    [_kit stopPreview];
    _kit = nil;
    [self rmObservers];
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

#pragma mark - UI respond : gpu filters
- (void) onFilterChange:(id)sender{
    if (self.ksyFilterView.curFilter != _kit.filter){
        // use a new filter
        [_kit setupFilter:self.ksyFilterView.curFilter];
    }
}
- (void) onFilterBtn:(id)sender{
}
- (void) onFilterSwitch:(id)sender{
    UISwitch* sw = sender;
    if (sw == self.ksyFilterView.swPrevewFlip){
        [_kit setPreviewMirrored:sw.on];
    }
    else if (sw == self.ksyFilterView.swStreamFlip){
        [_kit setStreamerMirrored:sw.on];
    }
}
#pragma mark - UI respond : audio mixer
- (void)onAMixerSwitch:(UISwitch *)sw{
    if (sw == _audioMixerView.muteStream){
        BOOL mute = _audioMixerView.muteStream.isOn;
        [_kit.streamerBase muteStreame:mute];
    }
    else if (sw == _audioMixerView.bgmMix){
        // 背景音乐 是否 参与混音
        [_kit.aMixer setTrack:_kit.bgmTrack enable: sw.isOn];
    }
}
- (void)onAMixerSegCtrl:(UISegmentedControl *)seg{
    if (_kit && seg == _audioMixerView.micInput) {
        _kit.avAudioSession.currentMicType = _audioMixerView.micType;
    }
}
- (void)onAMixerSlider:(KSYNameSlider *)slider{
    float val = 0.0;
    if ([slider isKindOfClass:[KSYNameSlider class]]) {
        val = slider.normalValue;
    }
    else {
        return;
    }
    if ( slider == self.audioMixerView.bgmVol){
        [_kit.aMixer setMixVolume:val of: _kit.bgmTrack];
    }
    else if ( slider == self.audioMixerView.micVol){
        [_kit.aMixer setMixVolume:val of: _kit.micTrack];
    }
}

#pragma mark - reverb action
- (void)onReverbType:(UISegmentedControl *)seg{
    if (seg == self.reverbView.reverbType){
        int t = (int)seg.selectedSegmentIndex;
        _kit.aCapDev.reverbType = t;
        return;
    }
}

#pragma mark - misc features
- (void)onMiscBtns:(id)sender {
    // 截图的三种方法:
    if (sender == _miscView.btn0){
        // 方法1: 开始预览后, 从streamer 直接将待编码的图片存为本地的文件
        NSString* path =@"snapshot/c.jpg";
        [_kit.streamerBase takePhotoWithQuality:1 fileName:path];
        NSLog(@"Snapshot save to %@", path);
    }
    else if (sender == _miscView.btn1){
        // 方法2: 开始预览后, 从streamer获取UIImage对象
        [_kit.streamerBase getSnapshotWithCompletion:^(UIImage * img){
            [KSYUIVC saveImage: img
                            to: @"snap1.png" ];
        }];
    }
    else if (sender == _miscView.btn2) {
        // 方法3: 如果有美颜滤镜, 可以从滤镜上获取截图(UIImage)
        GPUImageOutput * filter = self.ksyFilterView.curFilter;
        if (filter){
            [filter useNextFrameForImageCapture];
            [KSYUIVC saveImage: filter.imageFromCurrentFramebuffer
                            to: @"snap2.png" ];
        }
    }
}
#pragma mark - misc features
- (void)onMiscSwitch:(UISwitch *)sw{  // see kit & block
    if (sw == _miscView.swAudioOnly && _kit.streamerBase) {
        if (sw.on == YES) {
            // disable video, only stream with audio
            _kit.streamerBase.bWithVideo = NO;
        }else{
            _kit.streamerBase.bWithVideo = YES;
        }
        // 如果修改bWithVideo属性失败, 开关状态恢复真实结果
        sw.on = !_kit.streamerBase.bWithVideo;
    }
    else if (sw == self.miscView.swPlayCapture){
        if ( ![KSYAUAudioCapture isHeadsetPluggedIn] ) {
            [KSYUIVC toast:@"没有耳机, 开启耳返会有刺耳的声音"];
            sw.on = NO;
            _kit.aCapDev.bPlayCapturedAudio = NO;
            return;
        }
        _kit.aCapDev.bPlayCapturedAudio = sw.isOn;
    }
}
- (void)onMiscSlider:(KSYNameSlider *)slider {
    if (slider == self.miscView.micmVol){
        if (_kit.aCapDev){
            _kit.aCapDev.micVolume = slider.normalValue;
        }
    }
}
@end
