//
//  KSYFilterView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYFilterView.h"
#import "KSYNameSlider.h"
#import <GPUImage/GPUImage.h>
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/libksygpuimage.h>

@interface KSYFilterView() {
    UILabel * _lblSeg;
    NSInteger _curIdx;
}

@end

@implementation KSYFilterView

- (id)init{
    self = [super init];
    // 修改美颜参数
    _filterLevel = [self addSliderName:@"参数" From:0 To:100 Init:50];
    
    _lblSeg = [self addLable:@"滤镜"];
    _filterGroupType = [self addSegCtrlWithItems:
  @[ @"关闭",
     @"美颜",
     @"组合",
     ]];
    _filterGroupType.selectedSegmentIndex = 1;
    [self selectFilter:1];
    return self;
}
- (void)layoutUI{
    [super layoutUI];
    [self putRow1:_filterLevel];
    self.btnH = 30;
    [self putLable:_lblSeg andView: _filterGroupType];
}
- (IBAction)onSegCtrl:(id)sender {
    if (_filterGroupType == sender){
        [self selectFilter: _filterGroupType.selectedSegmentIndex];
    }
    [super onSegCtrl:sender];
}
- (void) selectFilter:(NSInteger)idx {
    if (idx == _curIdx){
        return;
    }
    _curIdx = idx;
    // 标识当前被选择的滤镜
    if (idx == 0){
        _curFilter  = nil;
    }
    else if (idx == 1){
        _curFilter = [[KSYGPUBeautifyExtFilter alloc] init];
    }
    else if (idx == 2){
        KSYGPUBeautifyExtFilter * bf = [[KSYGPUBeautifyExtFilter alloc] init];
        GPUImageSepiaFilter * pf =[[GPUImageSepiaFilter alloc] init];
        [bf addTarget:pf];
        
        GPUImageFilterGroup * fg = [[GPUImageFilterGroup alloc] init];
        [fg addFilter:bf];
        [fg addFilter:pf];
        [fg setInitialFilters:[NSArray arrayWithObject:bf]];
        [fg setTerminalFilter:pf];
        _curFilter = fg;
    }
    else { // 关闭
        _curFilter  = nil;
    }
}

- (IBAction)onSlider:(id)sender {
    if (sender != _filterLevel) {
        return;
    }
    float nalVal = _filterLevel.normalValue;
    if (_curIdx == 1){
        int val = (nalVal*5) + 1; // level 1~5
        [(KSYGPUBeautifyExtFilter *)_curFilter setBeautylevel: val];
    }
    if (_curIdx == 2){
        int val = (nalVal*5) + 1; // level 1~5
        GPUImageFilterGroup * fg = (GPUImageFilterGroup *)_curFilter;
        KSYGPUBeautifyExtFilter * cf = (KSYGPUBeautifyExtFilter *)[fg filterAtIndex:0];
        [cf setBeautylevel: val];
    }
    [super onSlider:sender];
}
@end
