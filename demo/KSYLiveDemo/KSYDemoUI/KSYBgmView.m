//
//  KSYAudioView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYBgmView.h"
#import "KSYNameSlider.h"
#import "KSYFileSelector.h"



@interface KSYBgmView(){
    UILabel * _bgmTitle;
    KSYFileSelector *_bgmSel;
    NSInteger _cnt;
    NSInteger _index;
}
@end

@implementation KSYBgmView
-(id)init{
    self = [super init];
    _bgmTitle   = [self addLable:@"背景音乐地址 Documents/bgms"];
    _progressV  = [[UIProgressView alloc] init];
    [self addSubview:_progressV];
    _previousBtn= [self addButton:@"上一首"];
    _playBtn    = [self addButton:@"播放"];
    _pauseBtn   = [self addButton:@"暂停"];
    _stopBtn    = [self addButton:@"停止"];
    _volumSl    = [self addSliderName:@"音量" From:0 To:100 Init:50];
    _volumSl.slider.value = 50;
    _nextBtn    = [self addButton:@"下一首"];
    _bgmStatus  = @"idle";
    _bgmPattern = @[@".mp3", @".m4a", @".aac"];
    _bgmSel     = [[KSYFileSelector alloc] initWithDir:@"/Documents/bgms/"
                                             andSuffix:_bgmPattern];
    _bgmPath    = _bgmSel.filePath;
    _index      = 0;
    _cnt        = _bgmSel.fileList.count;
    _loopType = [self addSegCtrlWithItems:@[@"单曲循环", @"随机播放",@"顺序播放",@"循环播放"]];
    return self;
}

- (void)layoutUI{
    [super layoutUI];
    self.btnH = 10;
    [self putRow1:_progressV];
    self.btnH = 30;
    [self putRow1:_bgmTitle];
    [self putRow:@[_previousBtn,_playBtn,_pauseBtn, _stopBtn, _nextBtn] ];
    [self putRow1:_volumSl];
    [self putRow1:_loopType];
}
- (IBAction)onBtn:(id)sender {
    if (sender == _nextBtn){
        [_bgmSel selectFileWithType:KSYSelectType_NEXT];
        _bgmPath    = _bgmSel.filePath;
    }
    else if (sender == _previousBtn){
        [_bgmSel selectFileWithType:KSYSelectType_PREVIOUS];
        _bgmPath    = _bgmSel.filePath;
    }
    _bgmTitle.text = [_bgmStatus stringByAppendingString:_bgmSel.fileInfo];
    [super onBtn:sender];
}

@synthesize bgmPath = _bgmPath;
- (NSString *)bgmPath{
    //@"单曲循环", @"随机播放",@"顺序播放",@"循环播放"]
    if (_loopType.selectedSegmentIndex == 0) {
        return _bgmPath;
    }
    else if (_loopType.selectedSegmentIndex == 1) {
        [_bgmSel selectFileWithType:KSYSelectType_RANDOM];
        return _bgmSel.filePath;
    }
    else if (_loopType.selectedSegmentIndex == 2){
        [_bgmSel selectFileWithType:KSYSelectType_NEXT];
        if (++_index > _cnt - 1) {
            return nil;
        }
        return _bgmSel.filePath;
    }
    else if (_loopType.selectedSegmentIndex == 3){
        [_bgmSel selectFileWithType:KSYSelectType_NEXT];
        return _bgmSel.filePath;
    }
    _bgmTitle.text = [_bgmStatus stringByAppendingString:_bgmSel.fileInfo];
    return nil;
}
@synthesize bgmStatus = _bgmStatus;
- (void) setBgmStatus:(NSString *)bgmStatus{
    _bgmStatus = bgmStatus;
    _bgmTitle.text = [_bgmStatus stringByAppendingString:_bgmSel.fileInfo];
    
}
- (NSString *) bgmStatus{
    return _bgmStatus;
}
@end
