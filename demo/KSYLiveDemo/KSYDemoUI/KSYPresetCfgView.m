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

@interface KSYPresetCfgView(){
    
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
    _btn0 =  [self addButton:@"开始直播"  ];
#ifdef KSYSTREAMER_DEMO
    _btn2 =  [self addButton:@"forTest"  ];
#else
    _btn2 =  [self addButton:@"返回"  ];
#endif
    
    CGRect screenRect = [[UIScreen mainScreen]bounds];
    CGFloat ratio = screenRect.size.width / screenRect.size.height;
    _lblResolutionUI = [self addLable:@"采集分辨率"];
    _lblStreamResoUI = [self addLable:@"推流分辨率"];
    if ( FLOAT_EQ( ratio, 16.0/9 ) || FLOAT_EQ( ratio,  9.0/16) ){
        _resolutionUI = [self addSegCtrlWithItems:@[@"360p",@"540p",@"720p"]];
        _streamResoUI = [self addSegCtrlWithItems:@[@"360p",@"540p",@"720p"]];
    }
    else {
        // 360p: 640x360(16:9)  480p: 640x480(4:3)
        _resolutionUI = [self addSegCtrlWithItems:@[@"360p",@"540p",@"720p",@"480p"]];
        _resolutionUI.selectedSegmentIndex = 3; // default to
        
        _streamResoUI = [self addSegCtrlWithItems:@[@"360p",@"540p",@"720p",@"480p"]];
        _streamResoUI.selectedSegmentIndex = 3; // default to 480
    }
    _lblCameraPosUI = [self addLable:@"摄像头"];
    _cameraPosUI    = [self addSegCtrlWithItems:@[@"前置",@"后置"]];
    _lblGpuPixFmtUI = [self addLable:@"像素格式"];
    _gpuPixFmtUI  = [self addSegCtrlWithItems:@[@"rgba",@"yuva"]];
    _frameRateUI  = [self addSliderName:@"视频帧率fps" From:1.0 To:30.0 Init:15.0];
    _lblVideoCodecUI = [self addLable:@"视频编码器"];
    _videoCodecUI = [self addSegCtrlWithItems:@[@"自动",@"软264",@"硬264",@"软265"]];
    _lblAudioCodecUI = [self addLable:@"音频编码器"];
    _audioCodecUI = [self addSegCtrlWithItems:@[@"软AAC-HE",@"软AAC-LC",@"硬AAC-LC"]];
    _videoKbpsUI  = [self addSliderName:@"视频码率kbps" From:100.0 To:1500.0 Init:800.0];
    _lblAudioKbpsUI= [self addLable:@"音频码率kbps"];
    _audioKbpsUI  = [self addSegCtrlWithItems:@[@"12",@"24",@"32", @"48", @"64", @"128"]];
    _audioKbpsUI.selectedSegmentIndex = 2;
    _lblBwEstMode = [self addLable:@"带宽估计模式"];
    _bwEstModeUI = [self addSegCtrlWithItems:@[@"默认", @"流畅", @"关闭"]];
    _demoLable    = [self addLable:@"选择demo开始"];
    _demoLable.textAlignment = NSTextAlignmentCenter;
    return self;
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
    [self putLable:_lblResolutionUI andView:_resolutionUI];
    [self putLable:_lblStreamResoUI andView:_streamResoUI];
    //[self putLable:_lblCameraPosUI  andView:_cameraPosUI];
    [self putRow:@[_lblCameraPosUI,_cameraPosUI,
                   _lblGpuPixFmtUI,_gpuPixFmtUI] ];
    [self putRow1:_frameRateUI];
    [self putLable:_lblVideoCodecUI andView:_videoCodecUI];
    [self putLable:_lblAudioCodecUI andView:_audioCodecUI];
    [self putRow1:_videoKbpsUI];
    [self putLable:_lblAudioKbpsUI  andView:_audioKbpsUI];
    [self putLable:_lblBwEstMode andView:_bwEstModeUI];
    
    [self putRow1:_demoLable];
    
    //剩余空间全部用来放按钮
    CGFloat yPos = self.yPos > self.height ? self.yPos - self.height : self.yPos;
    self.btnH = (self.height - yPos - self.gap*2);
    [self putRow: @[_btn0,_btn2] ];
}

- (NSString*) hostUrl {
    return _hostUrlUI.text;
}
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
- (CGSize) capResolutionSize {
    NSInteger idx = _resolutionUI.selectedSegmentIndex;
    return [self dimensionToSize:idx];
}
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
            return  CGSizeMake(640, 360);
    }
}

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
- (int) frameRate {
    return (int)_frameRateUI.slider.value;
}
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
- (KSYAudioCodec) audioCodec {
    switch ( _audioCodecUI.selectedSegmentIndex) {
        case 0:
            return  KSYAudioCodec_AAC_HE;
        case 1:
            return  KSYAudioCodec_AAC;
        case 2:
            return  KSYAudioCodec_AT_AAC;
        default:
            return  KSYAudioCodec_AAC_HE;
    }
}
- (int) videoKbps {
    return (int)_videoKbpsUI.slider.value;
}

- (int) audioKbps {
    //@"12",@"24",@"32", @"48", @"64", @"128"
    NSString * title = [_audioKbpsUI titleForSegmentAtIndex:_audioKbpsUI.selectedSegmentIndex ];
    int aKbps = [title intValue];
    if (aKbps == 0){
        return 32;
    }
    return aKbps;
}
- (OSType) gpuOutputPixelFmt {
    if(_gpuPixFmtUI.selectedSegmentIndex == 0) {
        return kCVPixelFormatType_32BGRA;
    }
    else if(_gpuPixFmtUI.selectedSegmentIndex == 1) {
        return kCVPixelFormatType_4444AYpCbCr8;
    }
    return kCVPixelFormatType_32BGRA;
}

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
}

@end
