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

// 为防止将手机存储写满,限制录像时长为30s
#define REC_MAX_TIME 30 //录制视频的最大时间，单位s

@interface KSYStreamerVC () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UISwipeGestureRecognizer *_swipeGest;
    NSDateFormatter * _dateFormatter;
    NSMutableDictionary *_obsDict;
    int _strSeconds; // 推流持续的时间 , 单位s
    
    BOOL _bRecord;//是推流还是录制到本地
    NSString *_bypassRecFile;// 旁路录制
    // 旁路录制:一边推流到rtmp server, 一边录像到本地文件
    // 本地录制:直接存储到本地
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
    _menuNames = @[@"背景音乐", @"图像/美颜",@"声音",@"其他"];
    [self addSubViews];
    [self addSwipeGesture];
    // 采集相关设置初始化
    [self setCaptureCfg];
    //推流相关设置初始化
    [self setStreamerCfg];
    // 打印版本号信息
    NSLog(@"version: %@", [_kit getKSYVersion]);
    if (_kit) { // init with default filter
        _kit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [_kit setupFilter:self.ksyFilterView.curFilter];
        [_kit startPreview:self.view];
    }
    [self setupLogo];
    _bypassRecFile =[NSHomeDirectory() stringByAppendingString:@"/Library/Caches/rec.mp4"];
    _kit.streamerBase.bypassRecordStateChange = ^(KSYRecordState state) {
        [self onBypassRecordStateChange:state];
    };
}

- (void) addSwipeGesture{
    SEL onSwip =@selector(swipeController:);
    _swipeGest = [[UISwipeGestureRecognizer alloc]initWithTarget:self
                                                          action:onSwip];
    _swipeGest.direction |= UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:_swipeGest];
}

- (void)addSubViews{
    _ctrlView  = [[KSYCtrlView alloc] initWithMenu:_menuNames];
    [self.view addSubview:_ctrlView];
    _ctrlView.frame = self.view.frame;
    _ksyFilterView  = [[KSYFilterView alloc]initWithParent:_ctrlView];
    _ksyBgmView     = [[KSYBgmView alloc]initWithParent:_ctrlView];
    _audioView      = [[KSYAudioCtrlView alloc]initWithParent:_ctrlView];
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
    _audioView.onSwitchBlock=^(id sender){
        [weakself onAMixerSwitch:sender];
    };
    _audioView.onSliderBlock=^(id sender){
        [weakself onAMixerSlider:sender];
    };
    _audioView.onSegCtrlBlock=^(id sender){
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
    _miscView.onSegCtrlBlock=^(id sender){
        [weakself onMisxSegCtrl:sender];
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
    [_kit.vPreviewMixer removeAllTargets];
    [_kit.vStreamMixer removeAllTargets];
}

- (void) becameActive:(NSNotification *)not{ //app becameAction
    // 回到前台, 重新连接预览
    [_kit setupFilter:self.ksyFilterView.curFilter];
}

- (BOOL)shouldAutorotate {
    if (_ksyFilterView){
        return _ksyFilterView.swUiRotate.on;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) layoutUI {
    if(_ctrlView){
        _ctrlView.frame = self.view.frame;
        [_ctrlView layoutUI];
    }
}
#pragma mark - logo setup

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
        _miscView.alphaSl.normalValue = _kit.logoAlpha;
    }
    _kit.textLabel.numberOfLines = 2;
    _kit.textLabel.textAlignment = NSTextAlignmentCenter;
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = @"HH:mm:ss";
    NSDate *now = [[NSDate alloc] init];
    NSString * timeStr = [_dateFormatter stringFromDate:now];
    _kit.textLabel.text = [NSString stringWithFormat:@"ksyun\n%@", timeStr];
    [_kit.textLabel sizeToFit];
    CGFloat h1 = _kit.textLabel.frame.size.height;
    CGFloat h2 = _kit.previewDimension.height;
    hgt = h1 / h2;
    _kit.textRect = CGRectMake(0.05, yPos, 0, hgt);
    [_kit updateTextLabel];
}

- (void) updateLogoText {
    UIApplicationState appState = [UIApplication sharedApplication].applicationState;
    if (_strSeconds%5 != 0 || // update label every 5 second
        appState != UIApplicationStateActive){
        return;
    } // 将当前时间显示在左上角
    NSDate *now = [[NSDate alloc] init];
    NSString * timeStr = [_dateFormatter stringFromDate:now];
    _kit.textLabel.text = [NSString stringWithFormat:@"ksyun\n%@", timeStr];
    [_kit updateTextLabel];
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

- (void) defaultStramCfg{
    // stream default settings
    _kit.streamerBase.videoCodec = KSYVideoCodec_AUTO;
    _kit.streamerBase.videoInitBitrate =  800;
    _kit.streamerBase.videoMaxBitrate  = 1000;
    _kit.streamerBase.videoMinBitrate  =    0;
    _kit.streamerBase.audiokBPS        =   48;
    _kit.streamerBase.shouldEnableKSYStatModule = YES;
    _kit.streamerBase.videoFPS = 15;
    _kit.streamerBase.logBlock = ^(NSString* str){
        NSLog(@"%@", str);
    };
    _hostURL = [NSURL URLWithString:@"rtmp://test.uplive.ks-cdn.com/live/123"];
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
        _kit.streamerBase.shouldEnableKSYStatModule = YES;
        _kit.streamerBase.logBlock = ^(NSString* str){
            //NSLog(@"%@", str);
        };
        _hostURL = [NSURL URLWithString:[_presetCfgView hostUrl]];
    }
    else {
        [self defaultStramCfg];
    }
}

- (void) updateStreamCfg: (BOOL) bStart {
    _kit.streamerBase.liveScene       =  self.miscView.liveScene;
    _kit.streamerBase.videoEncodePerf =  self.miscView.vEncPerf;
    _kit.streamerBase.bWithVideo      = !self.audioView.swAudioOnly.on;
    _strSeconds = 0;
    self.miscView.liveSceneSeg.enabled = !bStart;
    self.miscView.vEncPerfSeg.enabled = !bStart;
    _miscView.swBypassRec.on = NO;
    
    //判断是直播还是录制
    NSString* title = _ctrlView.btnStream.currentTitle;
    _bRecord = [ title isEqualToString:@"开始录制"];
    _miscView.swBypassRec.enabled = !_bRecord; // 直接录制时, 不能旁路录制
    
    if (_bRecord && bStart){
        [self deleteFile:[_presetCfgView hostUrl]];
    }
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
        if ([self.audioView.swAudioOnly isOn] ){
            _kit.streamerBase.bWithVideo = NO;
        }
    }
    //状态为KSYStreamStateIdle且_bRecord为ture时，录制视频
    if (_kit.streamerBase.streamState == KSYStreamStateIdle && _bRecord){
        [self saveVideoToAlbum:[_presetCfgView hostUrl]];
    }
}
//保存视频到相簿
- (void) saveVideoToAlbum: (NSString*) path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
            SEL onDone = @selector(video:didFinishSavingWithError:contextInfo:);
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, onDone, nil);
        }
    });
}
//保存mp4文件完成时的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    NSString *message;
    if (!error) {
        message = @"Save album success!";
    }
    else {
        message = @"Failed to save the album!";
    }
    [KSYUIVC toast:message time:3];
}

- (void) onStreamError:(KSYStreamErrorCode) errCode{
    _ctrlView.lblStat.text  = [_kit.streamerBase getCurKSYStreamErrorCodeName];
    if (errCode == KSYStreamErrorCode_CONNECT_BREAK) {
        // Reconnect
        [self tryReconnect];
    }
    else if (errCode == KSYStreamErrorCode_AV_SYNC_ERROR) {
        NSLog(@"audio video is not synced, please check timestamp");
        [self tryReconnect];
    }
    else if (errCode == KSYStreamErrorCode_CODEC_OPEN_FAILED) {
        NSLog(@"video codec open failed, try software codec");
        _kit.streamerBase.videoCodec = KSYVideoCodec_X264;
        [self tryReconnect];
    }
}
- (void) tryReconnect {
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        NSLog(@"try again");
        [self updateStreamCfg:YES];
        [_kit.streamerBase startStream:self.hostURL];
    });
}
- (void) onBypassRecordStateChange: (KSYRecordState) newState {
    if (newState == KSYRecordStateRecording){
        NSLog(@"start bypass record");
    }
    else if (newState == KSYRecordStateStopped) {
        NSLog(@"stop bypass record");
        [self saveVideoToAlbum:_bypassRecFile];
    }
    else if (newState == KSYRecordStateError) {
        NSLog(@"bypass record error %@", _kit.streamerBase.bypassRecordErrorName);
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
    _strSeconds++;
    [self updateLogoText];
    [self updateRecLabel];  // 本地录制:直接存储到本地, 不推流
    [self updateBypassRecLable];//// 旁路录制:一边推流一边录像
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
    if (btn == _ctrlView.menuBtns[0] ){
        view = _ksyBgmView; // 背景音乐播放相关
    }
    else if (btn == _ctrlView.menuBtns[1] ){
        view = _ksyFilterView; // 美颜滤镜相关
    }
    else if (btn == _ctrlView.menuBtns[2] ){
        view = _audioView;    // 混音控制台
        _audioView.micType = _kit.avAudioSession.currentMicType;
        [_audioView initMicInput];
    }
    else if (btn == _ctrlView.menuBtns[3] ){
        view = _miscView;
    }
    // 将菜单的按钮隐藏, 将触发二级菜单的view显示
    if (view){
        [_ctrlView showSubMenuView:view];
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
#pragma mark - UI respond : audio ctrl
- (void)onAMixerSwitch:(UISwitch *)sw{
    if (sw == _audioView.muteStream){
        // 静音推流(发送音量为0的数据)
        BOOL mute = _audioView.muteStream.isOn;
        [_kit.streamerBase muteStreame:mute];
    }
    else if (sw == _audioView.bgmMix){
        // 背景音乐 是否 参与混音
        [_kit.aMixer setTrack:_kit.bgmTrack enable: sw.isOn];
    }
    else if (sw == _audioView.swAudioOnly && _kit.streamerBase) {
        if (sw.on == YES) {
            // disable video, only stream with audio
            _kit.streamerBase.bWithVideo = NO;
        }else{
            _kit.streamerBase.bWithVideo = YES;
        }
        // 如果修改bWithVideo属性失败, 开关状态恢复真实结果
        sw.on = !_kit.streamerBase.bWithVideo;
    }
    else if (sw == _audioView.swPlayCapture){
        if ( ![KSYAUAudioCapture isHeadsetPluggedIn] ) {
            [KSYUIVC toast:@"没有耳机, 开启耳返会有刺耳的声音" time:0.3];
            sw.on = NO;
            _kit.aCapDev.bPlayCapturedAudio = NO;
            return;
        }
        _kit.aCapDev.bPlayCapturedAudio = sw.isOn;
    }
}
- (void)onAMixerSegCtrl:(UISegmentedControl *)seg{
    if (_kit && seg == _audioView.micInput) {
        _kit.avAudioSession.currentMicType = _audioView.micType;
    }
    else if (seg == _audioView.reverbType){
        int t = (int)seg.selectedSegmentIndex;
        _kit.aCapDev.reverbType = t;
        return;
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
    if ( slider == self.audioView.bgmVol){
        [_kit.aMixer setMixVolume:val of: _kit.bgmTrack];
    }
    else if ( slider == self.audioView.micVol){
        [_kit.aMixer setMixVolume:val of: _kit.micTrack];
    }
    else if (slider == self.audioView.playCapVol){
        if (_kit.aCapDev){
            _kit.aCapDev.micVolume = slider.normalValue;
        }
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
            UIImageWriteToSavedPhotosAlbum(img,nil,nil,nil);
        }];
    }
    else if (sender == _miscView.btn2) {
        // 方法3: 如果有美颜滤镜, 可以从滤镜上获取截图(UIImage)
        GPUImageOutput * filter = self.ksyFilterView.curFilter;
        if (filter){
            [filter useNextFrameForImageCapture];
            UIImage * img =  filter.imageFromCurrentFramebuffer;
            [KSYUIVC saveImage: img
                            to: @"snap2.png" ];
            UIImageWriteToSavedPhotosAlbum(img,nil,nil,nil);
        }
    }
    else if (sender == _miscView.btn3) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)onMiscSwitch:(UISwitch *)sw{
    if (sw == _miscView.swBypassRec) {
        [self onBypassRecord];
    }
}

- (void)onMiscSlider:(KSYNameSlider *)slider {
    NSInteger layerIdx = _miscView.layerSeg.selectedSegmentIndex + 1;
    if (slider == _miscView.alphaSl){
        float flt = slider.normalValue;
        if (layerIdx == _kit.logoPicLayer) {
            _kit.logoAlpha = flt;
        }
        else {
            _kit.textLabel.alpha = flt;
            [_kit updateTextLabel];
        }
    }
}
- (void)onMisxSegCtrl:(UISegmentedControl *)seg {
    NSInteger layerIdx = _miscView.layerSeg.selectedSegmentIndex + 1;
    if (seg == _miscView.layerSeg) {
        if (layerIdx == _kit.logoPicLayer) {
            _miscView.alphaSl.normalValue = [_kit logoAlpha];
        }
        else {
            _miscView.alphaSl.normalValue =_kit.textLabel.alpha;
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate methods
-(void)imagePickerController:(UIImagePickerController *)picker
       didFinishPickingImage:(UIImage *)image
                 editingInfo:(NSDictionary *)editingInfo {
    _kit.logoPic  = [[GPUImagePicture alloc] initWithImage:image
                                       smoothlyScaleOutput:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ui rotate
- (void) onViewRotate { // 重写父类的方法, 参考父类 KSYUIView.m 中对UI旋转的响应
    [self layoutUI];
    if (_kit == nil || !_ksyFilterView.swUiRotate.on) {
        return;
    }
    UIInterfaceOrientation orie = [[UIApplication sharedApplication] statusBarOrientation];
    [_kit rotatePreviewTo:orie];
    if (_ksyFilterView.swStrRotate.on) {
        [_kit rotateStreamTo:orie];
    }
}

#pragma mark - bypass record & record
-(void) onBypassRecord {
    BOOL bRec = _kit.streamerBase.bypassRecordState == KSYRecordStateRecording;
    if (_miscView.swBypassRec.on){
        if ( _kit.streamerBase.isStreaming && !bRec){
            // 如果启动录像时使用和上次相同的路径,则会覆盖掉上一次录像的文件内容
            [self deleteFile:_bypassRecFile];
            NSURL *url =[[NSURL alloc] initFileURLWithPath:_bypassRecFile];
            [_kit.streamerBase startBypassRecord:url];
            [self updateBypassRecLable];
        }
        else {
            NSString * msg = @"推流过程中才能旁路录像";
            [KSYUIVC toast:msg time:1];
            _miscView.swBypassRec.on = NO;
        }
    }
    else if (bRec){
        [_kit.streamerBase stopBypassRecord];
    }
}
-(void) updateBypassRecLable {
    if (!_miscView.swBypassRec.on){
        return;
    }
    double dur = _kit.streamerBase.bypassRecordDuration;
    NSString* durStr=[NSString stringWithFormat:@"%3.0fs/%ds", dur,REC_MAX_TIME];
    _miscView.lblRecDur.text = durStr;
    if (dur > REC_MAX_TIME) { // 为防止将手机存储写满,限制旁路录像时长为30s
        _miscView.swBypassRec.on = NO;
        [_kit.streamerBase stopBypassRecord];
    }
    
}

- (void) updateRecLabel {
    if (!_bRecord){ // 直接录制短视频
        return;
    }
    int diff = REC_MAX_TIME - _strSeconds;
    //保持连接和限制短视频长度
    if (_kit.streamerBase.isStreaming && diff < 0){
        [self onStream];//结束录制
    }
    if (_kit.streamerBase.isStreaming){//录制时的倒计时时间
        NSString *durMsg = [NSString stringWithFormat:@"%ds\n",diff];
        _ctrlView.lblNetwork.text = durMsg;
    }
    else{
        _ctrlView.lblNetwork.text = @"";
    }
}

//删除文件,保证保存到相册里面的视频时间是更新的
-(void)deleteFile:(NSString *)file{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:file]) {
        [fileManager removeItemAtPath:file error:nil];
    }
}
@end
