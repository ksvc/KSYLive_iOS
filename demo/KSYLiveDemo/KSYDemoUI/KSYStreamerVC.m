//
//  ViewController.m
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 ksyun. All rights reserved.
//

#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/libksygpuimage.h>
#import "KSYUIView.h"
#import "KSYUIVC.h"
#import "KSYPresetCfgView.h"
#import "KSYStreamerVC.h"
#import <GPUImage/GPUImage.h>
#import "KSYFilterView.h"
#import "KSYBgmView.h"
#import "KSYPipView.h"
#import "KSYNameSlider.h"
#import "KSYReverbView.h"

@interface KSYStreamerVC () {
    StreamState _lastStD;
    double      _startTime;
    int         _notGoodCnt;
    int         _raiseCnt;
    int         _dropCnt;
    
    BOOL        _bgmPlayNext;
    UISwipeGestureRecognizer *_swipeGest;
    
}

@property KSYAudioReverb*  audioReverb;


@end


@implementation KSYStreamerVC

- (id) initWithCfg:(KSYPresetCfgView*)presetCfgView{
    self = [super init];
    _presetCfgView = presetCfgView;
    self.view.backgroundColor = [UIColor whiteColor];
    _lastState = &_lastStD;
    [self initStreamStat];
    _bgmPlayNext = YES;
    return self;
}
// 将推流状态信息清0
- (void) initStreamStat{
    memset(_lastState, 0, sizeof(_lastStD));
    _startTime  = [[NSDate date]timeIntervalSince1970];
    _notGoodCnt = 0;
    _raiseCnt   = 0;
    _dropCnt    = 0;
}

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViews];
    [self addSwipeGesture];
}

- (void) addSwipeGesture{
    SEL onSwip =@selector(swipeController:);
    _swipeGest = [[UISwipeGestureRecognizer alloc]initWithTarget:self
                                                          action:onSwip];
    _swipeGest.direction |= UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:_swipeGest];
}

- (void)addSubViews{
    [self initCtrView];
    _ksyMenuView    = [[KSYMenuView alloc]initWithParent:_ctrlView];
    _ksyMenuView.hidden = NO; // menu
    _ksyFilterView  = [[KSYFilterView alloc]initWithParent:_ksyMenuView];
    _ksyBgmView     = [[KSYBgmView alloc]initWithParent:_ksyMenuView];
    _ksyPipView     = [[KSYPipView alloc]initWithParent:_ksyMenuView];
    _audioMixerView = [[KSYAudioMixerView alloc]initWithParent:_ksyMenuView];
    _reverbView     = [[KSYReverbView alloc]initWithParent:_ksyMenuView];
    _miscView       = [[KSYMiscView alloc]initWithParent:_ksyMenuView];
    
    __weak KSYStreamerVC *weakself = self;
    _ksyMenuView.onBtnBlock=^(id sender){
        [weakself onMenuBtnPress:sender];
    };
    // 背景音乐控制页面
    _ksyBgmView.onBtnBlock = ^(id sender) {
        [weakself onBgmBtnPress:sender];
    };
    _ksyBgmView.onSliderBlock = ^(id sender) {
        [weakself onBgmVolume:sender];
    };
//    _ksyBgmView.onSegCtrlBlock = ^(id sender) {
//        [weakself onBgmCtrSle:sender];
//    };
    // 滤镜相关参数改变
    _ksyFilterView.onBtnBlock=^(id sender) {
        [weakself onFilterChange:sender];
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
    // 画中画播放控制视图
    _ksyPipView.onBtnBlock = ^(id sender){
        [weakself onPipBtnPress:sender];
    };
    _ksyPipView.onSliderBlock = ^(id sender) {
        [weakself pipVolChange:sender];
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
}

- (void)initCtrView{
    _ctrlView  = [[KSYCtrlView alloc] init];
    [self.view addSubview:_ctrlView];
    _ctrlView.frame = self.view.frame;
    if ([_presetCfgView cameraPos] == AVCaptureDevicePositionFront) {
        [_ctrlView.btnFlash setEnabled:NO];
    }
    // connect UI
    __weak KSYStreamerVC * vc = self;
    _ctrlView.onBtnBlock = ^(id btn){
        [vc onBasicCtrl:btn];
    };
}


- (void) addObservers {
    [super addObservers];
    //KSYStreamer state changes
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(onCaptureStateChange:)
               name:KSYCaptureStateDidChangeNotification
             object:nil];
    [dc addObserver:self
           selector:@selector(onStreamStateChange:)
               name:KSYStreamStateDidChangeNotification
             object:nil];
    [dc addObserver:self
           selector:@selector(onNetStateEvent:)
               name:KSYNetStateEventNotification
             object:nil];
    [dc addObserver:self
           selector:@selector(onBgmPlayerStateChange:)
               name:KSYAudioStateDidChangeNotification
             object:nil];
    [dc addObserver:self
           selector:@selector(onPipPlayerNotify:)
               name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
             object:nil];
    [dc addObserver:self
           selector:@selector(onPipPlayerNotify:)
               name:MPMoviePlayerPlaybackDidFinishNotification
             object:nil];
}
- (void) rmObservers {
    [super rmObservers];
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    [dc removeObserver:self
                  name:KSYCaptureStateDidChangeNotification
                object:nil];
    [dc removeObserver:self
                  name:KSYStreamStateDidChangeNotification
                object:nil];
    [dc removeObserver:self
                  name:KSYNetStateEventNotification
                object:nil];
    [dc removeObserver:self
                  name:KSYAudioStateDidChangeNotification
                object:nil];
    [dc removeObserver:self
                  name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                object:nil];
    [dc removeObserver:self
                  name:MPMoviePlayerPlaybackDidFinishNotification
                object:nil];
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


#pragma mark - add UIs to view
- (void) initUI {
    [self layoutUI];
}

- (void) layoutUI {
    if(_ctrlView){
        [_ctrlView layoutUI];
        _ctrlView.yPos   = _ksyMenuView.gap*6+_ksyMenuView.btnH;
        _ctrlView.btnH   = _ctrlView.height-_ctrlView.yPos-_ksyMenuView.btnH;
        [_ctrlView putRow1:_ksyMenuView];
        [_ksyMenuView    layoutUI];
    }
}

#pragma mark - Capture & stream setup
- (void) setCaptureCfg { // see blk/kit
    [_presetCfgView capResolution];
    [_presetCfgView cameraPos];
    [_presetCfgView frameRate];
}
- (void) defaultStramCfg{
    // stream default settings
    _streamerBase.videoCodec = KSYVideoCodec_AUTO;
    _streamerBase.videoInitBitrate =  800;
    _streamerBase.videoMaxBitrate  = 1000;
    _streamerBase.videoMinBitrate  =    0;
    _streamerBase.audiokBPS        =   48;
    _streamerBase.enAutoApplyEstimateBW     = YES;
    _streamerBase.shouldEnableKSYStatModule = YES;
    _streamerBase.videoFPS = 15;
    _streamerBase.logBlock = ^(NSString* str){
        NSLog(@"%@", str);
    };
    _hostURL = [NSURL URLWithString:@"rtmp://test.uplive.ksyun.com/live/123"];
}
- (void) setStreamerCfg { // must set after capture
    if (_streamerBase == nil) {
        return;
    }
    if (_presetCfgView){ // cfg from presetcfgview
        _streamerBase.videoCodec       = [_presetCfgView videoCodec];
        _streamerBase.videoInitBitrate = [_presetCfgView videoKbps]*6/10;//60%
        _streamerBase.videoMaxBitrate  = [_presetCfgView videoKbps];
        _streamerBase.videoMinBitrate  = 0; //
        _streamerBase.audiokBPS        = [_presetCfgView audioKbps];
        _streamerBase.videoFPS         = [_presetCfgView frameRate];
        _streamerBase.enAutoApplyEstimateBW = YES;
        _streamerBase.shouldEnableKSYStatModule = YES;
        _streamerBase.logBlock = ^(NSString* str){ };
        _hostURL = [NSURL URLWithString:[_presetCfgView hostUrl]];
    }
    else {
        [self defaultStramCfg];
    }
}

#pragma mark -  state change
- (void) onCaptureStateChange:(NSNotification *)notification{
}
- (void) onNetStateEvent     :(NSNotification *)notification{
    switch (_streamerBase.netStateCode) {
        case KSYNetStateCode_SEND_PACKET_SLOW: {
            NSLog(@"send slow");
            break;
        }
        case KSYNetStateCode_EST_BW_RAISE: {
            NSLog(@"est bw raise");
            break;
        }
        case KSYNetStateCode_EST_BW_DROP: {
            NSLog(@"est bw drop");
            break;
        }
        case KSYNetStateCode_IN_AUDIO_DISCONTINUOUS: {
            NSLog(@"missing audio data");
            break;
        }
        default:break;
    }
}
- (void) onBgmPlayerStateChange  :(NSNotification *)notification{
    NSString * st = [_bgmPlayer getCurBgmStateName];
    _ksyBgmView.bgmStatus = [st substringFromIndex:17];
    if ( _bgmPlayer.bgmPlayerState == KSYBgmPlayerStateStopped){
        if (_bgmPlayNext){
            [self onBgmPlay];
        }
    }
}
- (void) onStreamStateChange :(NSNotification *)notification{
    if (_streamerBase){
        NSLog(@"stream State %@", [_streamerBase getCurStreamStateName]);
    }
    _ctrlView.lblStat.text = [_streamerBase getCurStreamStateName];
    if(_streamerBase.streamState == KSYStreamStateError) {
        [self onStreamError:_streamerBase.streamErrorCode];
    }
    else if (_streamerBase.streamState == KSYStreamStateConnecting) {
        [self initStreamStat]; // 尝试开始连接时,重置统计数据
    }
    else if (_streamerBase.streamState == KSYStreamStateConnected) {
        if ([self.miscView.swiAudio isOn] ){
            _streamerBase.bWithVideo = NO;
        }
    }
}

- (void) onStreamError:(KSYStreamErrorCode) errCode{
    _ctrlView.lblStat.text  = [_streamerBase getCurKSYStreamErrorCodeName];
    if (errCode == KSYStreamErrorCode_CONNECT_BREAK) {
        // Reconnect
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            _streamerBase.bWithVideo = YES;
            [_streamerBase startStream:self.hostURL];
        });
    }
}
- (void) onPipPlayerNotify:(NSNotification *)notification{ // see blk/kit
}
#pragma mark - timer respond per second
- (void)onTimer:(NSTimer *)theTimer{
    if (_streamerBase.streamState == KSYStreamStateConnected ) {
        StreamState curState = {0};
        curState.timeSecond     = [[NSDate date]timeIntervalSince1970];
        curState.uploadKByte    = [_streamerBase uploadedKByte];
        curState.encodedFrames  = [_streamerBase encodedFrames];
        curState.droppedVFrames = [_streamerBase droppedVideoFrames];
        StreamState deltaS  = {0};
        deltaS.timeSecond    = curState.timeSecond    -_lastStD.timeSecond    ;
        deltaS.uploadKByte   = curState.uploadKByte   -_lastStD.uploadKByte   ;
        deltaS.encodedFrames = curState.encodedFrames -_lastStD.encodedFrames ;
        deltaS.droppedVFrames= curState.droppedVFrames-_lastStD.droppedVFrames;
        _lastStD = curState;
        
        double realTKbps   = deltaS.uploadKByte*8 / deltaS.timeSecond;
        double encFps      = deltaS.encodedFrames / deltaS.timeSecond;
        double dropRate    = (deltaS.droppedVFrames ) / deltaS.timeSecond;
        double dropPercent = deltaS.droppedVFrames * 100.0 / curState.droppedVFrames;
        NSString* liveTime =[self timeFormatted: (int)(curState.timeSecond-_startTime) ] ;
        NSString *uploadDateSize = [ self sizeFormatted:curState.uploadKByte];
        NSString* stateurl  = [NSString stringWithFormat:@"%@ (%@)\n", [_hostURL absoluteString], liveTime];
        NSString* statekbps = [NSString stringWithFormat:@"实时码率(kbps):%4.1f  A%4.1f V%4.1f\n", realTKbps, [_streamerBase encodeAKbps], [_streamerBase encodeVKbps] ];
        NSString* statefps  = [NSString stringWithFormat:@"实时帧率%2.1f fps  总上传:%@\n", encFps, uploadDateSize ];
        NSString* statedrop = [NSString stringWithFormat:@"丢帧 %4d | %3.1f | %2.1f%% \n", curState.droppedVFrames, dropRate, dropPercent ];
        NSString* netEvent = [NSString stringWithFormat:@"网络事件 %d bad | %d raise | %d drop\n", _notGoodCnt, _raiseCnt, _dropCnt];
        NSString *cpu_use = [NSString stringWithFormat:@"cpu_use: %.2f",[self cpu_usage]];
        UILabel *stat = _ctrlView.lblStat;
        stat.text = [ stateurl    stringByAppendingString:statekbps ];
        stat.text = [ stat.text  stringByAppendingString:statefps  ];
        stat.text = [ stat.text  stringByAppendingString:statedrop ];
        stat.text = [ stat.text  stringByAppendingString:netEvent  ];
        stat.text = [ stat.text  stringByAppendingString:cpu_use  ];
    }
    if (_bgmPlayer && _bgmPlayer.bgmPlayerState ==KSYBgmPlayerStatePlaying ) {
        _ksyBgmView.progressV.progress = _bgmPlayer.bgmProcess;
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
}

//menuView control
- (void)onMenuBtnPress:(UIButton *)btn{
    KSYUIView * view = nil;
    if (btn == _ksyMenuView.bgmBtn ){
        view = _ksyBgmView; // 背景音乐播放相关
    }
    else if (btn == _ksyMenuView.filterBtn ){
        view = _ksyFilterView; // 美颜滤镜相关
    }
    else if (btn == _ksyMenuView.pipBtn ){
        view = _ksyPipView;   // 画中画播放相关
    }
    else if (btn == _ksyMenuView.mixBtn ){
        view = _audioMixerView;    // 混音控制台
        _audioMixerView.micType = _capDev.currentMicType;
        [_audioMixerView initMicInput];
    }
    else if (btn == _ksyMenuView.miscBtn ){
        view = _miscView;
        [_miscView initMicmOutput];
    }
    else if (btn == _ksyMenuView.reverbBtn ){
        view = _reverbView;
    }
    // 将菜单的按钮隐藏, 将触发二级菜单的view显示
    if (view){
        [_ksyMenuView hideAllBtn:YES];
        view.hidden = NO;
        view.frame = _ksyMenuView.frame;
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
//bgmView Control
- (void)onBgmBtnPress:(UIButton *)btn{
    if (btn == _ksyBgmView.previousBtn) {
        [self onBgmStop];
    }
    else if (btn == _ksyBgmView.playBtn){
        [self onBgmPlay];
    }
    else if (btn ==  _ksyBgmView.pauseBtn){
        if (_bgmPlayer && _bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePlaying) {
            [_bgmPlayer pauseBgm];
        }
        else if (_bgmPlayer && _bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePaused){
            [_bgmPlayer resumeBgm];
        }
    }
    else if (btn == _ksyBgmView.stopBtn){
        [self onBgmStop];
    }
    else if (btn == _ksyBgmView.nextBtn){
        [self onBgmStop];
    }
    else if (btn == _ksyBgmView.muteBtn){
        // 仅仅是静音了本地播放, 推流中仍然有音乐
        _bgmPlayer.bMutBgmPlay = !_bgmPlayer.bMutBgmPlay;
    }
}
- (void) onBgmPlay{
    NSString* path = _ksyBgmView.bgmPath;
    if (!path) {
        [self onBgmStop];
    }
    if (_bgmPlayer) {
        _bgmPlayer.bgmFinishBlock = ^{
            NSLog(@"bgm over %@", path);
        };
        [_bgmPlayer startPlayBgm:path isLoop:NO];
    }
}

- (void) onBgmStop{
    if (_bgmPlayer && _bgmPlayer.bgmPlayerState == KSYBgmPlayerStatePlaying) {
        [_bgmPlayer stopPlayBgm];
    }
}

// 背景音乐音量调节
- (void)onBgmVolume:(id )sl{
    if (sl == _ksyBgmView.volumSl){
        _bgmPlayer.bgmVolume = _ksyBgmView.volumSl.normalValue;
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
- (void)onPipPlay{// see kit & block
}
- (void)onPipPause{ // see kit & block
}
- (void)onPipStop{ // see kit & block
}
- (void)onPipNext{ // see kit & block
}
- (void)onBgpNext{ // see kit & block
}
//pipView slider  control
- (void)pipVolChange:(id)sender{ // see kit & block
}

#pragma mark - subviews: basic ctrl
- (void) onFlash { //  see kit or block
}
- (void) onCameraToggle{ // see kit or block
    if (_capDev && _capDev.cameraPosition == AVCaptureDevicePositionBack) {
        [_ctrlView.btnFlash setEnabled:YES];
    }
    else{
        [_ctrlView.btnFlash setEnabled:NO];
    }
}
- (void) onCapture{ // see kit or block
}
- (void) onStream{ // see kit or block
}
- (void) onQuit{  // quit current demo
    if (self.bgmPlayer){
        [self onBgmStop];
    }
    if (self.streamerBase){
        [self.streamerBase stopStream];
        self.streamerBase = nil;
    }
    [self rmObservers];
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

#pragma mark - UI respond : gpu filters
- (void) onFilterChange:(id)sender{
    // see kit or block
    self.filter = self.ksyFilterView.curFilter;
}

#pragma mark - UI respond : audio mixer
- (void)onAMixerSwitch:(UISwitch *)sw{
    if (sw == _audioMixerView.muteStream){
        BOOL mute = _audioMixerView.muteStream.isOn;
        [_streamerBase muteStreame:mute];
    }
    else if (sw == _audioMixerView.bgmMix){
        // 背景音乐 是否 参与混音
        [_aMixer setTrack:_bgmTrack enable: sw.isOn];
    }
    else if (sw == _audioMixerView.pipMix){
        // 画中画音乐 是否 参与混音
        [_aMixer setTrack:_pipTrack enable: sw.isOn];
    }
}
- (void)onAMixerSegCtrl:(UISegmentedControl *)seg{
    if (_capDev && seg == _audioMixerView.micInput) {
        _capDev.currentMicType = _audioMixerView.micType;
    }
}
- (void)onAMixerSlider:(KSYNameSlider *)slider{
    // see kit or block
}

#pragma mark - reverb action
- (void)onReverbType:(UISegmentedControl *)seg{
    if (seg != _reverbView.reverbType){
        return;
    }
    int t = (int)_reverbView.reverbType.selectedSegmentIndex;
    if (t == 0){
        _reverb = nil;
    }
    else {
        _reverb = [[ KSYAudioReverb alloc] initWithType:t];
    }
}

#pragma mark - misc features
- (void)onMiscBtns:(id)sender {
    if (sender == _miscView.btn0){
        [self onSnapshot:sender];
    }
    else if (sender == _miscView.btn1){
        __weak KSYStreamerVC *weakself = self;
        [_streamerBase getSnapshotWithCompletion:^(UIImage * img){
            [weakself saveImage: img
                             to: @"snap1.png" ];
        }];
    }
    else if (sender == _miscView.btn2) {
        [_filter useNextFrameForImageCapture];
        [self saveImage: _filter.imageFromCurrentFramebuffer
                     to: @"snap2.png" ];
    }
}

- (void)onSnapshot:(id)sender {
    NSString* path =@"snapshot/c.jpg";
    [_streamerBase takePhotoWithQuality:1 fileName:path];
    NSLog(@"Snapshot save to %@", path);
}

- (void)saveImage: (UIImage *)image
               to: (NSString*)path {
    NSString * dir = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
    NSString * file = [dir stringByAppendingPathComponent:path];
    NSData *imageData = UIImagePNGRepresentation(image);
    BOOL ret = [imageData writeToFile:file atomically:YES];
    NSLog(@"write %@ %@", file, ret ? @"OK":@"failed");
}

#pragma mark - micMonitor
- (void)onMiscSwitch:(UISwitch *)sw{  // see kit & block
    if (sw == _miscView.swiAudio && _streamerBase) {
        if (sw.on == YES) {
            // disable video, only stream with audio
            _streamerBase.bWithVideo = NO;
        }else{
            _streamerBase.bWithVideo = YES;
        }
        sw.on = !_streamerBase.bWithVideo;
    }
}
- (void)onMiscSlider:(KSYNameSlider *)slider {  // see kit & block
}
@end
