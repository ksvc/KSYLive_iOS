//
//  KSYPresetCfgView.m
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 ksyun. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "KSYUIView.h"
#import "KSYPresetCfgView.h"
#import <libksygpulive/KSYGPUStreamerKit.h>

@interface KSYPresetCfgView(){
    NSArray * _profileNames;
    BOOL _bRecord;//是推流还是录制到本地
}
@property UIButton * doneBtn;
@property UILabel* demoLable;
@end

#define FLOAT_EQ( f0, f1 ) ( (f0 - f1 < 0.001)&& (f0 - f1 > -0.001) )

@implementation KSYPresetCfgView
- (id) init {
    self = [super init];
    self.backgroundColor = [UIColor whiteColor];
    // hostURL = rtmpSrv + streamName(随机数,避免多个demo推向同一个流
    NSString *rtmpSrv = @"rtmp://test.uplive.ks-cdn.com/live";
    NSString *devCode = [ [KSYUIView getUuid] substringToIndex:3];
    NSString *url     = [  NSString stringWithFormat:@"%@/%@", rtmpSrv, devCode];
    _hostUrlUI = [self addTextField:url ];
    _doneBtn =  [self addButton:@"ok"];
    _btn0 =  [self addButton:@"开始直播"];
    _btn1 =  [self addButton:@"画中画直播"];
#ifdef KSYSTREAMER_DEMO
    _btn2 =  [self addButton:@"forTest"];
#endif
    _btn3 =  [self addButton:@"背景音乐直播"];
    _btn4 =  [self addButton:@"返回"];
    _btn5 = [self addButton:@"悬浮窗直播"];
    
    _lblCameraPosUI = [self addLable:@"摄像头"];
    _cameraPosUI    = [self addSegCtrlWithItems:@[@"前置",@"后置"]];
    _lblGpuPixFmtUI = [self addLable:@"像素格式"];
    _gpuPixFmtUI  = [self addSegCtrlWithItems:@[@"rgba",@"nv12"]];
    _lblProfileUI = [self addLable:@"配置"];
    _profileUI = [self addSegCtrlWithItems:@[@"预设等级",@"自定义"]];
    _profileUI.selectedSegmentIndex = 0;
    _profileNames = [NSArray arrayWithObjects:@"360p_auto",@"360p_1",@"360p_2",@"360p_3",
                                              @"540p_auto",@"540p_1",@"540p_2",@"540p_3",
                                              @"720p_auto",@"720p_1",@"720p_2",@"720p_3",nil];
    
    CGRect screenRect = [[UIScreen mainScreen]bounds];
    CGFloat ratio = screenRect.size.width / screenRect.size.height;
    _lblResolutionUI = [self addLable:@"采集分辨率"];
    _lblStreamResoUI = [self addLable:@"推流分辨率"];
    _resolutionUI = [self addSegCtrlWithItems:@[@"360p",@"540p",@"720p", @"480p"]];
    _streamResoUI = [self addSegCtrlWithItems:@[@"360p",@"540p",@"720p", @"480p", @"400"]];
    _resolutionUI.selectedSegmentIndex = 2;
    if ( !( FLOAT_EQ( ratio, 16.0/9 ) || FLOAT_EQ( ratio,  9.0/16)) ){
        // 360p: 640x360(16:9)  480p: 640x480(4:3)
        _streamResoUI.selectedSegmentIndex = 3;
    }
    else {
        [_resolutionUI setWidth:0.5 forSegmentAtIndex: 3];
        [_streamResoUI setWidth:0.5 forSegmentAtIndex: 3];
    }

    _frameRateUI  = [self addSliderName:@"视频帧率fps" From:1.0 To:30.0 Init:15.0];
    _lblVideoCodecUI = [self addLable:@"视频编码器"];
    _videoCodecUI = [self addSegCtrlWithItems:@[@"自动",@"软264",@"硬264",@"软265"]];
    _lblAudioCodecUI = [self addLable:@"音频编码器"];
    _audioCodecUI = [self addSegCtrlWithItems:@[@"aache",@"aaclc",@"ATaaclc", @"aachev2"]];
    _videoKbpsUI  = [self addSliderName:@"视频码率kbps" From:100.0 To:1600.0 Init:800.0];
    _lblAudioKbpsUI= [self addLable:@"音频码率kbps"];
    _audioKbpsUI  = [self addSegCtrlWithItems:@[@"12",@"24",@"32", @"48", @"64", @"128"]];
    _audioKbpsUI.selectedSegmentIndex = 2;
    _lblBwEstMode = [self addLable:@"带宽估计模式"];
    _bwEstModeUI = [self addSegCtrlWithItems:@[@"默认", @"流畅", @"关闭"]];
    _lblWithMessage  = [self addLable:@"消息通道"];
    _withMessageUI = [self addSegCtrlWithItems:@[@"打开", @"关闭"]];
    _demoLable    = [self addLable:@"选择demo开始"];
    _demoLable.textAlignment = NSTextAlignmentCenter;
    
    _profilePicker = [[UIPickerView alloc] init];
    [self addSubview: _profilePicker];
    _profilePicker.hidden     = YES;
    _profilePicker.delegate   = self;
    _profilePicker.dataSource = self;
    _profilePicker.showsSelectionIndicator= YES;
    _profilePicker.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    [_profilePicker selectRow:7 inComponent:0 animated:YES];

    _curProfileIdx = 103;
    [self selectProfile:0];
    
    return self;
}

#pragma mark - profile picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1; // 单列
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    return _profileNames.count;//
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component{
    return [_profileNames objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    if (row >= 0 && row <= 3){
        _curProfileIdx = row;
    }else if (row >= 4 && row <= 7){
        _curProfileIdx = 100 + (row - 4);
    }else if (row >= 8 && row <= 11){
        _curProfileIdx = 200 + (row - 8);
    }else{
        _curProfileIdx = 103;
    }
    [self getStreamerProfile:_curProfileIdx];
}

- (BOOL) withMessage{
    switch (_withMessageUI.selectedSegmentIndex) {
        case 0:
            return YES;
        case 1:
            return NO;
        default:
            return YES;
    }
}

//UIControlEventTouchUpInside
- (IBAction)onBtn:(id)sender{
    if (sender == _doneBtn){
        [_hostUrlUI resignFirstResponder];
        return;
    }
    [super onBtn:sender];
}

- (IBAction)onSegCtrl:(id)sender {
    if ( sender == _audioCodecUI) {
        NSInteger idx = _audioCodecUI.selectedSegmentIndex;
        if (idx == 2) {
            _audioKbpsUI.selectedSegmentIndex = 4;
        }
        else {
            _audioKbpsUI.selectedSegmentIndex = 2;
        }
    }
    if (sender == _profileUI) {
        [self selectProfile: _profileUI.selectedSegmentIndex];
    }
}

- (void) selectProfile:(NSInteger)idx {
    _lblResolutionUI.hidden = YES;
    _resolutionUI.hidden = YES;
    _lblStreamResoUI.hidden = YES;
    _streamResoUI.hidden = YES;
    _frameRateUI.hidden = YES;
    _lblVideoCodecUI.hidden = YES;
    _videoCodecUI.hidden = YES;
    _lblAudioCodecUI.hidden = YES;
    _audioCodecUI.hidden = YES;
    _videoKbpsUI.hidden = YES;
    _lblAudioKbpsUI.hidden = YES;
    _audioKbpsUI.hidden = YES;
    _lblBwEstMode.hidden = YES;
    _bwEstModeUI.hidden = YES;
    _profilePicker.hidden = YES;
    _lblWithMessage.hidden = YES;
    _withMessageUI.hidden = YES;
    
    NSString* title = _btn0.currentTitle;
    _bRecord = [ title isEqualToString:@"开始录制"];

    if (idx == 0){
        _profilePicker.hidden = NO;
        [self getStreamerProfile:_curProfileIdx];
        if (_bRecord){
            [_btn0 setTitle: @"开始录制" forState: UIControlStateNormal];
        }
        else{
            [_btn0 setTitle: @"预设配置直播" forState: UIControlStateNormal];
        }
    }else{
        _lblResolutionUI.hidden = NO;
        _resolutionUI.hidden = NO;
        _lblStreamResoUI.hidden = NO;
        _streamResoUI.hidden = NO;
        _frameRateUI.hidden = NO;
        _lblVideoCodecUI.hidden = NO;
        _videoCodecUI.hidden = NO;
        _lblAudioCodecUI.hidden = NO;
        _audioCodecUI.hidden = NO;
        _videoKbpsUI.hidden = NO;
        _lblAudioKbpsUI.hidden = NO;
        _audioKbpsUI.hidden = NO;
        _lblBwEstMode.hidden = NO;
        _bwEstModeUI.hidden = NO;
        _lblWithMessage.hidden = NO;
        _withMessageUI.hidden = NO;
        if (_bRecord){
            [_btn0 setTitle: @"开始录制" forState: UIControlStateNormal];
        }
        else{
            [_btn0 setTitle: @"自定义配置直播" forState: UIControlStateNormal];
        }
    }
    [self layoutUI];
}

//获取采集和推流配置参数
- (void)getStreamerProfile:(KSYStreamerProfile)profile{
    switch (profile) {
        case KSYStreamerProfile_360p_auto:
            _resolutionUI.selectedSegmentIndex = 0;
            _streamResoUI.selectedSegmentIndex = 0;
            _frameRateUI.slider.value = 15;
            _videoCodecUI.selectedSegmentIndex = 0;
            _videoKbpsUI.slider.value = 512;
            _audioCodecUI.selectedSegmentIndex = 2;
            _audioKbpsUI.selectedSegmentIndex = 3;
            _bwEstModeUI.selectedSegmentIndex = 0;
            break;
        case KSYStreamerProfile_360p_1:
            _resolutionUI.selectedSegmentIndex = 0;
            _streamResoUI.selectedSegmentIndex = 0;
            _frameRateUI.slider.value = 15;
            _videoCodecUI.selectedSegmentIndex = 0;
            _videoKbpsUI.slider.value = 512;
            _audioCodecUI.selectedSegmentIndex = 2;
            _audioKbpsUI.selectedSegmentIndex = 3;
            _bwEstModeUI.selectedSegmentIndex = 0;
            break;
        case KSYStreamerProfile_360p_2:
            _resolutionUI.selectedSegmentIndex = 1;
            _streamResoUI.selectedSegmentIndex = 0;
            _frameRateUI.slider.value = 15;
            _videoCodecUI.selectedSegmentIndex = 0;
            _videoKbpsUI.slider.value = 512;
            _audioCodecUI.selectedSegmentIndex = 2;
            _audioKbpsUI.selectedSegmentIndex = 3;
            _bwEstModeUI.selectedSegmentIndex = 0;
            break;
        case KSYStreamerProfile_360p_3:
            _resolutionUI.selectedSegmentIndex = 2;
            _streamResoUI.selectedSegmentIndex = 0;
            _frameRateUI.slider.value = 20;
            _videoCodecUI.selectedSegmentIndex = 0;
            _videoKbpsUI.slider.value = 768;
            _audioCodecUI.selectedSegmentIndex = 2;
            _audioKbpsUI.selectedSegmentIndex = 3;
            _bwEstModeUI.selectedSegmentIndex = 0;
            break;
        case KSYStreamerProfile_540p_auto:
            _resolutionUI.selectedSegmentIndex = 1;
            _streamResoUI.selectedSegmentIndex = 1;
            _frameRateUI.slider.value = 15;
            _videoCodecUI.selectedSegmentIndex = 0;
            _videoKbpsUI.slider.value = 768;
            _audioCodecUI.selectedSegmentIndex = 2;
            _audioKbpsUI.selectedSegmentIndex = 4;
            _bwEstModeUI.selectedSegmentIndex = 0;
            break;
        case KSYStreamerProfile_540p_1:
            _resolutionUI.selectedSegmentIndex = 1;
            _streamResoUI.selectedSegmentIndex = 1;
            _frameRateUI.slider.value = 15;
            _videoCodecUI.selectedSegmentIndex = 0;
            _videoKbpsUI.slider.value = 768;
            _audioCodecUI.selectedSegmentIndex = 2;
            _audioKbpsUI.selectedSegmentIndex = 4;
            _bwEstModeUI.selectedSegmentIndex = 0;
            break;
        case KSYStreamerProfile_540p_2:
            _resolutionUI.selectedSegmentIndex = 2;
            _streamResoUI.selectedSegmentIndex = 1;
            _frameRateUI.slider.value = 15;
            _videoCodecUI.selectedSegmentIndex = 0;
            _videoKbpsUI.slider.value = 768;
            _audioCodecUI.selectedSegmentIndex = 2;
            _audioKbpsUI.selectedSegmentIndex = 4;
            _bwEstModeUI.selectedSegmentIndex = 0;
            break;
        case KSYStreamerProfile_540p_3:
            _resolutionUI.selectedSegmentIndex = 2;
            _streamResoUI.selectedSegmentIndex = 1;
            _frameRateUI.slider.value = 20;
            _videoCodecUI.selectedSegmentIndex = 0;
            _videoKbpsUI.slider.value = 1024;
            _audioCodecUI.selectedSegmentIndex = 2;
            _audioKbpsUI.selectedSegmentIndex = 4;
            _bwEstModeUI.selectedSegmentIndex = 0;
            break;
        case KSYStreamerProfile_720p_auto:
            _resolutionUI.selectedSegmentIndex = 2;
            _streamResoUI.selectedSegmentIndex = 2;
            _frameRateUI.slider.value = 15;
            _videoCodecUI.selectedSegmentIndex = 0;
            _videoKbpsUI.slider.value = 1024;
            _audioCodecUI.selectedSegmentIndex = 2;
            _audioKbpsUI.selectedSegmentIndex = 5;
            _bwEstModeUI.selectedSegmentIndex = 0;
            break;
        case KSYStreamerProfile_720p_1:
            _resolutionUI.selectedSegmentIndex = 2;
            _streamResoUI.selectedSegmentIndex = 2;
            _frameRateUI.slider.value = 15;
            _videoCodecUI.selectedSegmentIndex = 0;
            _videoKbpsUI.slider.value = 1024;
            _audioCodecUI.selectedSegmentIndex = 2;
            _audioKbpsUI.selectedSegmentIndex = 5;
            _bwEstModeUI.selectedSegmentIndex = 0;
            break;
        case KSYStreamerProfile_720p_2:
            _resolutionUI.selectedSegmentIndex = 2;
            _streamResoUI.selectedSegmentIndex = 2;
            _frameRateUI.slider.value = 20;
            _videoCodecUI.selectedSegmentIndex = 0;
            _videoKbpsUI.slider.value = 1280;
            _audioCodecUI.selectedSegmentIndex = 2;
            _audioKbpsUI.selectedSegmentIndex = 5;
            _bwEstModeUI.selectedSegmentIndex = 0;
            break;
        case KSYStreamerProfile_720p_3:
            _resolutionUI.selectedSegmentIndex = 2;
            _streamResoUI.selectedSegmentIndex = 2;
            _frameRateUI.slider.value = 24;
            _videoCodecUI.selectedSegmentIndex = 0;
            _videoKbpsUI.slider.value = 1536;
            _audioCodecUI.selectedSegmentIndex = 2;
            _audioKbpsUI.selectedSegmentIndex = 5;
            _bwEstModeUI.selectedSegmentIndex = 0;
            break;
        default:
            NSLog(@"Get Invalid Profile");
    }
    _frameRateUI.valueL.text = [NSString stringWithFormat:@"%d", (int)_frameRateUI.slider.value];
    _videoKbpsUI.valueL.text = [NSString stringWithFormat:@"%d", (int)_videoKbpsUI.slider.value];
}


- (void) layoutUI {
    [super layoutUI];
    if (self.width > self.height){
        self.winWdt = self.width/2;
    }
    int rowHight = MIN(30, self.height/14 );
    rowHight  = MAX(rowHight, 20);
    self.btnH = rowHight*2;
    [self putSlider: _hostUrlUI andSwitch: _doneBtn];
    self.btnH = rowHight;
    [self putRow:@[_lblCameraPosUI,_cameraPosUI,
                   _lblGpuPixFmtUI,_gpuPixFmtUI] ];
    [self putLable:_lblProfileUI andView:_profileUI];
    if (_profileUI.selectedSegmentIndex){
        [self putLable:_lblResolutionUI andView:_resolutionUI];
        [self putLable:_lblStreamResoUI andView:_streamResoUI];
        [self putRow1:_frameRateUI];
        [self putLable:_lblVideoCodecUI andView:_videoCodecUI];
        [self putLable:_lblAudioCodecUI andView:_audioCodecUI];
        [self putRow1:_videoKbpsUI];
        [self putLable:_lblAudioKbpsUI  andView:_audioKbpsUI];
        [self putLable:_lblBwEstMode andView:_bwEstModeUI];
        [self putLable:_lblWithMessage andView:_withMessageUI];
    }else{
        self.btnH = 162;
        if ( self.width > self.height){
            _profilePicker.frame = CGRectMake( self.winWdt, self.yPos, self.winWdt, self.btnH);
        }
        else {
            [self putRow1:_profilePicker];
        }
    }
    self.btnH = rowHight;
    [self putRow1:_demoLable];
    
    //剩余空间全部用来放按钮
    CGFloat yPos = self.yPos > self.height ? self.yPos  - self.height : self.yPos;
    self.btnH = (self.height - yPos - self.gap*2) / 2;
    [self putRow: @[_btn0,_btn4] ];
    if (_btn2){
        [self putRow: @[_btn1,_btn3,_btn2] ];
    }
    else {
        [self putRow: @[_btn1,_btn3,_btn5] ];
    }
}

- (NSString*) hostUrl {
    return _hostUrlUI.text;
}

@synthesize capResolution =  _capResolution;
- (NSString*) capResolution {
    //@"360p",@"540p",@"720p", @"480p"
    NSInteger idx = _resolutionUI.selectedSegmentIndex;
    switch ( idx) {
        case 0:
            return  AVCaptureSessionPreset640x480;
        case 1:
            return  AVCaptureSessionPresetiFrame960x540;
        case 2:
            return  AVCaptureSessionPreset1280x720;
        case 3:
            return  AVCaptureSessionPreset640x480;
        default:
            return  AVCaptureSessionPreset640x480;
    }
}

@synthesize capResolutionSize =  _capResolutionSize;
- (CGSize) capResolutionSize {
    NSInteger idx = _resolutionUI.selectedSegmentIndex;
    return [self dimensionToSize:idx];
}

@synthesize strResolutionSize =  _strResolutionSize;
- (CGSize) strResolutionSize {
    NSInteger idx = _streamResoUI.selectedSegmentIndex;
    return [self dimensionToSize:idx];
}
- (CGSize) dimensionToSize:(NSInteger)idx {
    switch (idx) {
        case 0:
            return  CGSizeMake(640, 360);
        case 1:
            return  CGSizeMake(960, 540);
        case 2:
            return  CGSizeMake(1280, 720);
        case 3:
            return  CGSizeMake(640, 480);
        default:
            return  CGSizeMake(400, 400);
    }
}

@synthesize cameraPos =  _cameraPos;
- (AVCaptureDevicePosition) cameraPos {
    switch ( _cameraPosUI.selectedSegmentIndex) {
        case 0:
            return  AVCaptureDevicePositionFront;
        case 1:
            return  AVCaptureDevicePositionBack;
        default:
            return  AVCaptureDevicePositionFront;
    }
}

@synthesize frameRate =  _frameRate;
- (int) frameRate {
    return (int)_frameRateUI.slider.value;
}

@synthesize videoCodec =  _videoCodec;
- (KSYVideoCodec) videoCodec {
    switch ( _videoCodecUI.selectedSegmentIndex) {
        case 0:
            return  KSYVideoCodec_AUTO;
        case 1:
            return  KSYVideoCodec_X264;
        case 2:
            return  KSYVideoCodec_VT264;
        case 3:
            return  KSYVideoCodec_QY265;
        default:
            return  KSYVideoCodec_AUTO;
    }
}

@synthesize audioCodec =  _audioCodec;
- (KSYAudioCodec) audioCodec {
    switch ( _audioCodecUI.selectedSegmentIndex) {
        case 0:
            return  KSYAudioCodec_AAC_HE;
        case 1:
            return  KSYAudioCodec_AAC;
        case 2:
            return  KSYAudioCodec_AT_AAC;
        case 3:
            return  KSYAudioCodec_AAC_HE_V2;
        default:
            return  KSYAudioCodec_AAC_HE;
    }
}

@synthesize videoKbps = _videoKbps;
- (int) videoKbps {
    return (int)_videoKbpsUI.slider.value;
}

@synthesize audioKbps = _audioKbps;
- (int) audioKbps {
    //@"12",@"24",@"32", @"48", @"64", @"128"
    NSString * title = [_audioKbpsUI titleForSegmentAtIndex:_audioKbpsUI.selectedSegmentIndex ];
    int aKbps = [title intValue];
    if (aKbps == 0){
        return 32;
    }
    return aKbps;
}

@synthesize gpuOutputPixelFmt =  _gpuOutputPixelFmt;
- (OSType) gpuOutputPixelFmt {
    if(_gpuPixFmtUI.selectedSegmentIndex == 0) {
        return kCVPixelFormatType_32BGRA;
    }
    else if(_gpuPixFmtUI.selectedSegmentIndex == 1) {
        return kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
    }
    return kCVPixelFormatType_32BGRA;
}

@synthesize bwEstMode =  _bwEstMode;
- (KSYBWEstimateMode) bwEstMode{
    switch ( _bwEstModeUI.selectedSegmentIndex) {
        case 0:
            return  KSYBWEstMode_Default;
        case 1:
            return  KSYBWEstMode_Negtive;
        case 2:
            return  KSYBWEstMode_Disable;
        default:
            return  KSYBWEstMode_Default;
    }
}

@end
