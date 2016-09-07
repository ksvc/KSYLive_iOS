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

@property (nonatomic) UILabel * lbPrevewFlip;
@property (nonatomic) UILabel * lbStreamFlip;
@end

@implementation KSYFilterView

- (id)init{
    self = [super init];
    // 修改美颜参数
    _filterLevel = [self addSliderName:@"参数" From:0 To:100 Init:50];
    _filterParam = [self addSliderName:@"美白" From:0 To:100 Init:50];
    _filterParam.hidden = YES;
    
    _lblSeg = [self addLable:@"滤镜"];
    _filterGroupType = [self addSegCtrlWithItems:
  @[ @"关闭",
     @"美颜",
     @"组合",
     @"金山",
     ]];
    _filterGroupType.selectedSegmentIndex = 1;
    [self selectFilter:1];
    
    _lbPrevewFlip = [self addLable:@"预览镜像"];
    _lbStreamFlip = [self addLable:@"推流镜像"];
    _swPrevewFlip = [self addSwitch:NO];
    _swStreamFlip = [self addSwitch:NO];
    return self;
}
- (void)layoutUI{
    [super layoutUI];
    [self putRow1:_filterLevel];
    [self putRow1:_filterParam];
    self.btnH = 30;
    [self putLable:_lblSeg andView: _filterGroupType];
    [self putRow: @[_lbPrevewFlip, _swPrevewFlip,
                    _lbStreamFlip, _swStreamFlip ]];
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
    _filterLevel.nameL.text = @"参数";
    _filterParam.hidden = YES;
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
    else if (idx == 3){
        KSYBeautifyFaceFilter * f = [[KSYBeautifyFaceFilter alloc] init];
        _filterParam.hidden = NO;
        _filterLevel.nameL.text = @"磨皮";
        f.grindRatio = _filterLevel.normalValue;;
        f.whitenRatio = _filterParam.normalValue;
        _curFilter = f;
    }
    else { // 关闭
        _curFilter  = nil;
    }
}

- (IBAction)onSlider:(id)sender {
    if (sender != _filterLevel &&
        sender != _filterParam ) {
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
    else if (_curIdx == 3){
        KSYBeautifyFaceFilter * f =(KSYBeautifyFaceFilter*)_curFilter;
        if (sender == _filterLevel){
            f.grindRatio = _filterLevel.normalValue;
        }
        if (sender == _filterParam ) {
            f.whitenRatio = _filterParam.normalValue;
        }
    }
    [super onSlider:sender];
}
@end
