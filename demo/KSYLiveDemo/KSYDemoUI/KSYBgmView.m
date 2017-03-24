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
}
@end

@implementation KSYBgmView
-(id)init{
    self = [super init];
    _bgmTitle   = [self addLable:@"背景音乐地址 Documents/bgms"];
    _previousBtn= [self addButton:@"上一首"];
    _playBtn    = [self addButton:@"播放"];
    _pauseBtn   = [self addButton:@"暂停"];
    _stopBtn    = [self addButton:@"停止"];
    _volumSl    = [self addSliderName:@"音量" From:0 To:100 Init:50];
    _pitchSl    = [self addSliderName:@"音调" From:-3 To:3 Init:0];
    _pitchSl.precision = 0;
    _pitchSl.slider.enabled = NO;
    _pitchStep  = [[UIStepper alloc] init];
    _pitchStep.continuous = NO;
    _pitchStep.maximumValue = 3;
    _pitchStep.minimumValue = -3;
    [self addSubview:_pitchStep];
    [_pitchStep addTarget:self
                   action:@selector(onStep:)
         forControlEvents:UIControlEventValueChanged];
    _nextBtn    = [self addButton:@"下一首"];
    _bgmStatus  = @"idle";
    _bgmPattern = @[@".mp3", @".m4a", @".aac"];
    _bgmSel     = [[KSYFileSelector alloc] initWithDir:@"/Documents/bgms/"
                                             andSuffix:_bgmPattern];
    _bgmPath    = _bgmSel.filePath;
    _cnt        = _bgmSel.fileList.count;
    _loopType = [self addSegCtrlWithItems:@[@"单曲播放", @"单曲循环", @"随机播放",@"循环播放"]];
    _loopType.selectedSegmentIndex = 4;
    _progressBar = [[KSYProgressView alloc] init];
    [self addSubview:_progressBar];
    if (_cnt == 0) {
        [self downloadBgm];
    }
    return self;
}

- (void)layoutUI{
    [super layoutUI];
    [self putRow1:_progressBar];
    [self putRow1:_bgmTitle];
    [self putRow:@[_previousBtn,_playBtn,_pauseBtn, _stopBtn, _nextBtn] ];
    [self putRow1:_volumSl];
    [self putRow1:_loopType];
    [self putWide:_pitchSl  andNarrow:_pitchStep];
}

- (NSString*) loopNextBgmPath {
    //@"单曲播放", @"单曲循环", @"随机播放",@"循环播放"]
    if (_loopType.selectedSegmentIndex == 0) {
    }
    else if (_loopType.selectedSegmentIndex == 1) {
    }
    else if (_loopType.selectedSegmentIndex == 2) {
        [_bgmSel selectFileWithType:KSYSelectType_RANDOM];
    }
    else if (_loopType.selectedSegmentIndex == 3){
        [_bgmSel selectFileWithType:KSYSelectType_NEXT];
    }
    return [self updateBgmPath];
}
- (NSString*) nextBgmPath {
    [_bgmSel selectFileWithType:KSYSelectType_NEXT];
    return [self updateBgmPath];
}
- (NSString*) previousBgmPath{
    [_bgmSel selectFileWithType:KSYSelectType_PREVIOUS];
    return [self updateBgmPath];
}
- (NSString*) updateBgmPath{
    _bgmTitle.text = [_bgmStatus stringByAppendingString:_bgmSel.fileInfo];
    _bgmPath    = _bgmSel.filePath;
    return _bgmSel.filePath;
}

@synthesize bgmStatus = _bgmStatus;
- (void) setBgmStatus:(NSString *)bgmStatus{
    _bgmStatus = bgmStatus;
    _bgmTitle.text = [_bgmStatus stringByAppendingString:_bgmSel.fileInfo];
    
}
- (NSString *) bgmStatus{
    return _bgmStatus;
}
- (IBAction)onStep:(id)sender {
    if (sender == _pitchStep) {
        _pitchSl.value = _pitchStep.value;
    }
}
- (void) relaodFile {
    [_bgmSel reload];
    _bgmPath = _bgmSel.filePath;
    _cnt     = _bgmSel.fileList.count;
}

- (void) downloadBgm {
    NSString *urlStr = @"https://ks3-cn-beijing.ksyun.com/ksy.vcloud.sdk/Ios/bgm.aac";
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *Url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:Url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downLoadTask;
    weakObj(self);
    downLoadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSError *saveError;
            NSString * saveDir = [NSHomeDirectory() stringByAppendingString:@"/Documents/bgms"];
            NSString * savePath = [saveDir stringByAppendingString:@"/bgm.aac"];
            NSURL *saveURL = [NSURL fileURLWithPath:savePath];
            NSFileManager * fm = [NSFileManager defaultManager];
            [fm createDirectoryAtPath:saveDir
          withIntermediateDirectories:YES
                           attributes:nil
                                error:nil];
            [fm copyItemAtURL:location toURL:saveURL error:&saveError];
            if (!saveError) {
                NSLog(@"bgm.aac 下载成功");
                [selfWeak relaodFile];
            } else {
                NSLog(@"error is %@", saveError.localizedDescription);
            }
        } else {
            NSLog(@"error is : %@", error.localizedDescription);
        }
    }];
    [downLoadTask resume];
}
@end
