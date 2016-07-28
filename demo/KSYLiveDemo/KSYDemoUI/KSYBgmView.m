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
    KSYFileSelector * _bgmSel;
}
@end

@implementation KSYBgmView
-(id)init{
    self = [super init];
    _bgmTitle   = [self addLable:@"背景音乐地址 Documents/bgms"];
    _progressV  = [[UIProgressView alloc] init];
    [self addSubview:_progressV];
    
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
    return self;
}

- (void)layoutUI{
    [super layoutUI];
    self.btnH = 10;
    [self putRow1:_progressV];
    self.btnH = 30;
    [self putRow1:_bgmTitle];
    [self putRow:@[_playBtn,_pauseBtn, _stopBtn, _nextBtn] ];
    [self putRow1:_volumSl];
}

- (IBAction)onBtn:(id)sender {
    if (sender == _nextBtn){
        [_bgmSel nextFile];
        _bgmPath    = _bgmSel.filePath;
    }
    _bgmTitle.text = [_bgmStatus stringByAppendingString:_bgmSel.fileInfo];
    [super onBtn:sender];
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
