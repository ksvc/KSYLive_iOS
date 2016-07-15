//
//  KSYFilterView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYFilterView.h"
#import "KSYNameSlider.h"
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/libksygpuimage.h>

@interface KSYFilterView() {
    UIButton * _curBtn;
}

@end

@implementation KSYFilterView

- (id)init{
    self = [super init];
    _filterBtns[0]  = [self addButton:@"美颜"];
    _filterBtns[1]  = [self addButton:@"关闭"];
    
    [self  selectFilter:_filterBtns[0]];  // 默认开启
    
    // 修改美颜参数
    _filterLevel = [self addSliderName:@"参数" From:0 To:100 Init:50];
    return self;
}
- (void)layoutUI{
    [super layoutUI];
    [self putRow1:_filterLevel];
    self.btnH = 30;
    [self putRow2:_filterBtns[0]
              and:_filterBtns[1]];
}
- (IBAction)onBtn:(id)sender {
    [self  selectFilter:sender];
    [super onBtn:sender];
}
- (void) selectFilter:(id)sender {
    // 标识当前被选择的滤镜
    int cnt = sizeof(_filterBtns)/sizeof(_filterBtns[0]);
    for (int i = 0; i < cnt; ++i){
        if(_filterBtns[i]){
            _filterBtns[i].enabled = YES;
        }
    }
    _curBtn = sender;
    _curBtn.enabled = NO;
    if (sender == _filterBtns[0]){
        _curFilter = [[KSYGPUBeautifyExtFilter alloc] init];
    }
    else if (sender == _filterBtns[1]){
        _curFilter  = nil;
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
    if (_curBtn == _filterBtns[0]){
        int val = (nalVal*5) + 1; // level 1~5
        [(KSYGPUBeautifyExtFilter *)_curFilter setBeautylevel: val];
    }
    //
    [super onSlider:sender];
}
@end
