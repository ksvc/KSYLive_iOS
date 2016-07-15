//
//  KSYAudioView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYBgmView.h"
#import "KSYNameSlider.h"

@interface KSYBgmView(){
    NSString* _bgmDir;  //app的"Documents/bgms"
    NSMutableArray * _bgmList; // bgmDir目录下存放的文件列表
    int       _bgmIdx;  // 当前正在播放的音乐文件的索引
    UILabel * _bgmTitle;
    NSString* _bgmFileInfo;
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
    [self loadBgmFiles];
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

- (void) loadBgmFiles{
    _bgmDir = [NSHomeDirectory() stringByAppendingString:@"/Documents/bgms/"];
    NSFileManager * fmgr = [NSFileManager defaultManager];
    NSArray * list = [fmgr contentsOfDirectoryAtPath:_bgmDir
                                               error:nil];
    _bgmList = [NSMutableArray array];
    // filter all files
    for (NSString*f in list) {
        for (NSString*p in _bgmPattern) {
            if ( [f hasSuffix:p]){
                [_bgmList addObject:f];
                break;
            }
        }
    }
    _bgmIdx = -1;
    [self nextFile];
    NSLog(@"find %lu bgm files", (unsigned long)[_bgmList count]);
}
- (void) nextFile{
    NSInteger cnt =[_bgmList count];
    if (cnt == 0) { // no file
        _bgmFileInfo = @"can't find music";
        _bgmPath = nil;
        return;
    }
    // find a new file
    _bgmIdx = (_bgmIdx+1)%cnt;
    NSString * name = _bgmList[_bgmIdx];
    _bgmFileInfo = [NSString stringWithFormat:@" %@(%d/%lu)",name,_bgmIdx,cnt];
    _bgmPath = [_bgmDir stringByAppendingString:name];
}

- (IBAction)onBtn:(id)sender {
    if (sender == _nextBtn){
        [self nextFile];
    }
    _bgmTitle.text = [_bgmStatus stringByAppendingString:_bgmFileInfo];
    [super onBtn:sender];
}

@synthesize bgmStatus = _bgmStatus;
- (void) setBgmStatus:(NSString *)bgmStatus{
    _bgmStatus = bgmStatus;
    _bgmTitle.text = [_bgmStatus stringByAppendingString:_bgmFileInfo];
}
- (NSString *) bgmStatus{
    return _bgmStatus;
}
@end
