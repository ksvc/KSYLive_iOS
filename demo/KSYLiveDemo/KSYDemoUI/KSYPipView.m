//
//  KSYPipView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYPipView.h"
#import "KSYNameSlider.h"
#import "KSYFileSelector.h"

@interface KSYPipView (){
    UILabel * _pipTitle;
    KSYFileSelector * _pipSel;
    KSYFileSelector * _bgpSel;
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
    
    _pipSel = [[KSYFileSelector alloc] initWithDir:@"/Documents/movies/"
                                         andSuffix:_pipPattern];
    _bgpSel = [[KSYFileSelector alloc] initWithDir:@"/Documents/images/"
                                         andSuffix:_bgpPattern];
    if(_pipSel.filePath){
        _pipURL = [NSURL fileURLWithPath:_pipSel.filePath];
    }
    if(_bgpSel.filePath){
        _bgpURL = [NSURL fileURLWithPath:_bgpSel.filePath];
    }
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

- (IBAction)onBtn:(id)sender {
    if (sender == _pipNext){
        if( [_pipSel selectFileWithType:KSYSelectType_NEXT]){
            _pipURL = [NSURL fileURLWithPath:_pipSel.filePath];
        }
    }
    if (sender == _bgpNext){
        if( [_bgpSel selectFileWithType:KSYSelectType_NEXT] ){
            _bgpURL = [NSURL fileURLWithPath:_bgpSel.filePath];
        }
    }
    _pipTitle.text = [NSString stringWithFormat:@"%@: %@\n%@", _pipStatus, _pipSel.fileInfo, _bgpSel.fileInfo ];
    [super onBtn:sender];
}
@end
