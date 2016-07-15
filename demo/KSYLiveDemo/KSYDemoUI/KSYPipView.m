//
//  KSYPipView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYPipView.h"
#import "KSYNameSlider.h"
@interface KSYPipView (){
    NSString* _pipDir;  //app的"Documents/movies"
    NSMutableArray * _pipList; // pipDir目录下存放的文件列表
    int       _pipIdx;  // 当前正在播放的视频文件的索引
    
    NSString* _bgpDir;  //app的"Documents/movies"
    NSMutableArray * _bgpList; // bgpDir目录下存放的文件列表
    int       _bgpIdx;  // 当前显示的背景图片的索引
    
    UILabel * _pipTitle;
    NSString* _pipFileInfo;
    NSString* _bgpFileInfo;
}
@end
@implementation KSYPipView
-(id)init{
    self = [super init];
    _pipStatus  = @"idle";
    _pipTitle   = [self addLable:@"画中画地址 Documents/movies"];
    _pipTitle.numberOfLines = 2;
    _pipTitle.textAlignment = NSTextAlignmentLeft;
    
    _progressV  = [[UIProgressView alloc] init];
    [self addSubview:_progressV];
    _pipPlay    = [self addButton:@"播放"];
    _pipPause   = [self addButton:@"暂停"];
    _pipStop    = [self addButton:@"停止"];
    _pipNext    = [self addButton:@"下一个视频文件"];
    _bgpNext    = [self addButton:@"下一个背景图片"];
    _volumSl    = [self addSliderName:@"音量" From:0 To:100 Init:50];
    _pipPattern = @[@".mp4", @".flv"];
    _bgpPattern = @[@".jpg",@".jpeg", @".png"];
    [self loadFiles];
    return self;
}
- (void)layoutUI{
    [super layoutUI];
    self.btnH = 10;
    [self putRow1:_progressV];
    self.btnH = 60;
    [self putRow1:_pipTitle];
    self.btnH = 30;
    [self putRow:@[_pipPlay,_pipPause, _pipStop] ];
    [self putRow1:_volumSl];
    [self putRow2:_pipNext
              and:_bgpNext];
}
- (void) loadFiles{
    _pipDir = [NSHomeDirectory() stringByAppendingString:@"/Documents/movies/"];
    NSFileManager * fmgr = [NSFileManager defaultManager];
    NSArray * pipL = [fmgr contentsOfDirectoryAtPath:_pipDir
                                               error:nil];
    _pipList = [NSMutableArray array];
    // filter all files
    for (NSString*f in pipL) {
        for (NSString*p in _pipPattern) {
            if ( [f hasSuffix:p]){
                [_pipList addObject:f];
                break;
            }
        }
    }
    _pipIdx = -1;
    [self nextPipFile];
    NSLog(@"find %lu movies", (unsigned long)[_pipList count]);
    
    _bgpDir = [NSHomeDirectory() stringByAppendingString:@"/Documents/images/"];
    NSArray * bgpL = [fmgr contentsOfDirectoryAtPath:_bgpDir
                                               error:nil];
    _bgpList = [NSMutableArray array];
    // filter all files
    for (NSString*f in bgpL) {
        for (NSString*p in _bgpPattern) {
            if ( [f hasSuffix:p]){
                [_bgpList addObject:f];
                break;
            }
        }
    }
    _bgpIdx = -1;
    [self nextBgpFile];
    NSLog(@"find %lu background pictures", (unsigned long)[_bgpList count]);
}
- (void) nextPipFile{
    NSInteger cnt =[_pipList count];
    if (cnt == 0) { // no file
        _pipURL = nil;
        _pipFileInfo = @"can't find movies";
        return;
    }
    // find a new file
    _pipIdx = (_pipIdx+1)%cnt;
    NSString * name = _pipList[_pipIdx];
    NSString *pipPath = [_pipDir stringByAppendingString:name];
    _pipURL = [NSURL fileURLWithPath:pipPath];
    _pipFileInfo = [NSString stringWithFormat:@" %@(%d/%lu)",name,_pipIdx,cnt];
}
- (void) nextBgpFile{
    NSInteger cnt =[_bgpList count];
    if (cnt == 0) { // no file
        _bgpURL = nil;
        _bgpFileInfo = @"can't find picture";
        return;
    }
    // find a new file
    _bgpIdx = (_bgpIdx+1)%cnt;
    NSString * name = _bgpList[_bgpIdx];
    NSString *bgpPath = [_bgpDir stringByAppendingString:name];
    _bgpURL = [NSURL fileURLWithPath:bgpPath];
    _bgpFileInfo = [NSString stringWithFormat:@" %@(%d/%lu)",name,_bgpIdx,cnt];
}

- (IBAction)onBtn:(id)sender {
    if (sender == _pipNext){
        [self nextPipFile];
    }
    if (sender == _bgpNext){
        [self nextBgpFile];
    }
    _pipTitle.text = [NSString stringWithFormat:@"%@: %@\n%@", _pipStatus, _pipFileInfo, _bgpFileInfo ];
    [super onBtn:sender];
}
@end
