//
//  KSYFilterView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//
#import "KSYPresetCfgView.h"
#import "KSYMiscView.h"
#import "KSYFileSelector.h"

@interface KSYMiscView() {
    UIButton * _curBtn;
    UILabel  * _lblScene;
    UILabel  * _lbrScene;
    UILabel  * _lblPerf;
    UILabel  * _lblRec;
    UILabel  * _lblLogo;
    KSYFileSelector *_sel;
    BOOL     _skipBtnTap; // skip btn tap for 0.5 seconds
}

@end

@implementation KSYMiscView

- (id)init{
    self = [super init];
    _btn0  = [self addButton:@"截图1"];
    _btn1  = [self addButton:@"截图2"];
    _btn2  = [self addButton:@"filter截图"];
    
    _lblLogo = [self addLable:@"logo"];
    _btn3  = [self addButton:@"选择"];
    _btn4  = [self addButton:@"拍摄"];
    _btn5  = [self addButton:@"清除"];
    _btnAnimate  = [self addButton:@"动态图"];
    _btnNext     = [self addButton:@" 下一张 "];
    _lblAnimate  = [self addLable:@"动态logo"];
    _sel = [[KSYFileSelector alloc] initWithDir:@"/Documents/logo/"
                                      andSuffix:@[@".gif", @".png", @".apng"]];
    if (_sel.fileList.count < 3) {
        NSArray *names = @[@"ksyun.gif",@"elephant.png", @"horse.gif"];
        for (NSString* name in names ) {
            NSString * host = @"https://ks3-cn-beijing.ksyun.com/ksy.vcloud.sdk/picture/animateLogo/";
            NSString * url = [host stringByAppendingString:name];
            [_sel downloadFile:url name:name ];
        }
    }
    else {
        for (int i= 0; i < 2; ++i){
            [_sel selectFileWithType:KSYSelectType_NEXT];
        }
    }
    _lblRec       = [self addLable:@"旁路录制"];
    _swBypassRec  = [self addSwitch:NO];
    _lblRecDur    = [self addLable:@"0s"];
    
    _layerSeg = [self addSegCtrlWithItems:@[ @"logo", @"文字"]];
    _alphaSl  = [self addSliderName:@"alpha" From:0.0 To:1.0 Init:1.0];
    
    _lblScene      = [self addLable:@"直播场景"];
    _liveSceneSeg  = [self addSegCtrlWithItems:@[ @"默认", @"秀场", @"游戏"]];
    _lbrScene      = [self addLable:@"录制场景"];
    _recSceneSeg  = [self addSegCtrlWithItems:@[ @"恒定码率", @"恒定质量"]];
    _lblPerf       = [self addLable:@"编码性能"];
    _vEncPerfSeg   = [self addSegCtrlWithItems:@[ @"低功耗", @"均衡", @"高性能"]];
    _autoReconnect = [self addSliderName:@"自动重连次数" From:0.0 To:10 Init:3];
    //添加一个显示拉流地址和对应二维码的按钮
    _buttonPlayUrlAndQR = [self addButton:@"拉流地址及二维码"];
    [self updateLogoBtn];
    _buttonAe = [self addButton:@"贴纸编辑"];
    _skipBtnTap = NO;
    return self;
}

- (void)layoutUI{
    [super layoutUI];
    self.btnH = 30;
    if (self.width > self.height) {
        self.btnH = 25;
    }
    [self putRow3:_btn0
              and:_btn1
              and:_btn2];
    [self putLable:_lblScene
           andView:_liveSceneSeg];
    [self putLable:_lbrScene
           andView:_recSceneSeg];
    [self putLable:_lblPerf
           andView:_vEncPerfSeg];
    [self putRow:@[_lblLogo,_btn4,_btn3,_btn5,_btnAnimate]];
    [self putWide:_lblAnimate andNarrow:_btnNext];
    [self putNarrow:_layerSeg andWide:_alphaSl];
    [self putRow:@[_lblRec, _swBypassRec, _lblRecDur]];
    [self putRow1:_autoReconnect];
    [self putRow:@[_buttonPlayUrlAndQR, _buttonAe]];
}
- (IBAction)onBtn:(id)sender {
    if (_skipBtnTap) {
        return;
    }
    _skipBtnTap = YES;
    if (sender == _btnAnimate) {
        _btnAnimate.selected = !_btnAnimate.selected;
        [self updateLogoBtn];
    }
    else if (sender == _btnNext) {
        [_sel selectFileWithType:KSYSelectType_NEXT];
        _animatePath = _sel.filePath;
        _lblAnimate.text = _sel.fileInfo;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _skipBtnTap = NO;
    });
    [super onBtn:sender];
}
- (void) updateLogoBtn {
    if (_btnAnimate.selected) {
        _btn3.enabled = NO;
        _btn4.enabled = NO;
        _btn5.enabled = NO;
        _btnNext.enabled = YES;
        _animatePath = _sel.filePath;
        _lblAnimate.text = _sel.fileInfo;
    }
    else {
        _btn3.enabled = YES;
        _btn4.enabled = YES;
        _btn5.enabled = YES;
        _btnNext.enabled = NO;
        _lblAnimate.text = @"";
    }
}
@synthesize liveScene = _liveScene;
- (KSYLiveScene) liveScene{
    if (_liveSceneSeg.selectedSegmentIndex == 1){
        return KSYLiveScene_Showself;
    }
    else if (_liveSceneSeg.selectedSegmentIndex == 2){
        return KSYLiveScene_Game;
    }
    else {
        return KSYLiveScene_Default;
    }
}

@synthesize recScene = _recScene;
- (KSYRecScene) recScene{
    if (_recSceneSeg.selectedSegmentIndex == 0){
        return KSYRecScene_ConstantBitRate;
    }
    else if (_recSceneSeg.selectedSegmentIndex == 1){
        return KSYRecScene_ConstantQuality;
    }
    else {
        return KSYRecScene_ConstantBitRate;
    }
}

static KSYVideoEncodePerformance perfArray[] = {
    KSYVideoEncodePer_LowPower,
    KSYVideoEncodePer_Balance,
    KSYVideoEncodePer_HighPerformance
};
@synthesize vEncPerf =  _vEncPerf;
- (KSYVideoEncodePerformance) vEncPerf{
    long idx = _vEncPerfSeg.selectedSegmentIndex;
    if ( idx >= 0 && idx < 3 ) {
        return perfArray[idx];
    }
    else {
        return KSYVideoEncodePer_Balance;
    }
}
- (void) setVEncPerf:(KSYVideoEncodePerformance)vEncPerf {
    for (int i = 0 ; i< 3; ++i) {
        if ( vEncPerf == perfArray[i] ) {
            _vEncPerfSeg.selectedSegmentIndex = i;
        }
    }
}
@end
