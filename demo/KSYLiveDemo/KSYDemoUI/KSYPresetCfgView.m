//
//  KSYPresetCfgView.m
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 ksyun. All rights reserved.
//

#import "KSYUIView.h"
#import "KSYPresetCfgView.h"

@interface KSYPresetCfgView(){
    
}
@property UILabel* configLable;
@property UILabel* demoLable;
@end

#define FLOAT_EQ( f0, f1 ) ( (f0 - f1 < 0.001)&& (f0 - f1 > -0.001) )

@implementation KSYPresetCfgView
- (id) init {
    self = [super init];
    self.backgroundColor = [UIColor whiteColor];
    _configLable =[self addLable:@"settings"];
    _configLable.textAlignment = NSTextAlignmentCenter;
    // hostURL = rtmpSrv + streamName(随机数,避免多个demo推向同一个流
    NSString *rtmpSrv = @"rtmp://test.uplive.ksyun.com/live";
    NSString *devCode = [ [KSYUIView getUuid] substringToIndex:3];
    NSString *url     = [  NSString stringWithFormat:@"%@/%@", rtmpSrv, devCode];
    _hostUrlUI = [self addTextField:url ];
    
    _btn0 =  [self addButton:@"kitDemo"  ];
    _btn1 =  [self addButton:@"blockDemo"];
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
    _lblCameraPosUI = [self addLable:@"选取摄像头"];
    _cameraPosUI  = [self addSegCtrlWithItems:@[@"前置摄像头",@"后置摄像头"]];
    _frameRateUI  = [self addSliderName:@"视频帧率fps" From:1.0 To:30.0 Init:15.0];
    _lblVideoCodecUI = [self addLable:@"视频编码器"];
    _videoCodecUI = [self addSegCtrlWithItems:@[@"自动",@"软264",@"硬264",@"软265"]];
    _lblAudioCodecUI = [self addLable:@"音频编码器"];
    _audioCodecUI = [self addSegCtrlWithItems:@[@"AAC-HE",@"AAC-LC"]];
    _videoKbpsUI  = [self addSliderName:@"视频码率kbps" From:100.0 To:1500.0 Init:800.0];
    _lblAudioKbpsUI= [self addLable:@"音频kbps"];
    _audioKbpsUI  = [self addSegCtrlWithItems:@[@"12",@"24",@"32", @"48", @"64", @"128"]];
    _audioKbpsUI.selectedSegmentIndex = 2;
    _demoLable    = [self addLable:@"选择demo开始"];
    _demoLable.textAlignment = NSTextAlignmentCenter;
    return self;
}

- (void) layoutUI {
    [super layoutUI];
    if (self.width > self.height){
        self.winWdt = self.width/2;
    }
    [self putRow1:_configLable];
    self.btnH = 35*2;
    [self putRow1:_hostUrlUI];
    self.btnH=35;
    [self putLable:_lblResolutionUI andView:_resolutionUI];
    [self putLable:_lblStreamResoUI andView:_streamResoUI];
    [self putLable:_lblCameraPosUI  andView:_cameraPosUI];

    [self putRow1:_frameRateUI];
    [self putLable:_lblVideoCodecUI andView:_videoCodecUI];
    [self putLable:_lblAudioCodecUI andView:_audioCodecUI];
    [self putRow1:_videoKbpsUI];
    [self putLable:_lblAudioKbpsUI  andView:_audioKbpsUI];
    
    [self putRow1:_demoLable];
    
    //剩余空间全部用来放按钮
    CGFloat yPos = self.yPos > self.height ? self.yPos - self.height : self.yPos;
    self.btnH = (self.height - yPos - self.gap*2);
    [self putRow3:_btn0 and:_btn1 and:_btn2];
    //[self putRow2:_btn3 and:_btn4];
}

- (NSString*) hostUrl {
    return _hostUrlUI.text;
}
- (KSYVideoDimension) capResolution {
    return [self resolution: _resolutionUI.selectedSegmentIndex];
}
- (KSYVideoDimension) strResolution {
    return [self resolution: _streamResoUI.selectedSegmentIndex];
}
- (CGSize) strResolutionSize {
    NSInteger idx = _streamResoUI.selectedSegmentIndex;
    return [self dimensionToSize:[self resolution:idx ]];
}
- (CGSize) dimensionToSize:(KSYVideoDimension) dim {
    switch ( dim) {
        case KSYVideoDimension_16_9__640x360:
            return  CGSizeMake(640, 360);
        case KSYVideoDimension_16_9__960x540:
            return  CGSizeMake(960, 540);
        case KSYVideoDimension_16_9__1280x720:
            return  CGSizeMake(1280, 720);
        case KSYVideoDimension_4_3__640x480:
            return  CGSizeMake(640, 480);
        default:
            return  CGSizeMake(640, 360);
    }
}

- (KSYVideoDimension) resolution: (NSInteger)idx {
    //@"360p",@"540p",@"720p"
    switch ( idx) {
        case 0:
            return  KSYVideoDimension_16_9__640x360;
        case 1:
            return  KSYVideoDimension_16_9__960x540;
        case 2:
            return  KSYVideoDimension_16_9__1280x720;
        case 3:
            return  KSYVideoDimension_4_3__640x480;
        default:
            return  KSYVideoDimension_16_9__640x360;
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

@end
