//
//  KSYMenuView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYMenuView.h"

@implementation KSYMenuView

- (instancetype)init{
    self = [super init];
    if (self) {
        _bgmBtn   = [self addButton:@"背景音乐"];
        _pipBtn    = [self addButton:@"画中画"];
        _filterBtn = [self addButton:@"美颜"];
        _miscBtn   = [self addButton:@"其他"];
        _mixBtn    = [self addButton:@"混音"];
        _reverbBtn = [self addButton:@"混响"];
        
        _backBtn   = [self addButton:@"返回菜单"
                              action:@selector(onBack:)];
    }
    return self;
}
- (void)layoutUI{
    [super layoutUI];
    
    [self putRow: @[_bgmBtn, _pipBtn, _mixBtn,_backBtn] ];
    [self putRow: @[_filterBtn, _reverbBtn, _miscBtn, [NSNull null] ] ];
    [self hideAllBtn:NO];
}
- (void)hideAllBtn: (BOOL) bHide {
    _backBtn.hidden   = !bHide; // 返回
    
    _bgmBtn.hidden    = bHide;
    _pipBtn.hidden    = bHide;
    _filterBtn.hidden = bHide;
    _miscBtn.hidden   = bHide;
    _mixBtn.hidden    = bHide;
    _reverbBtn.hidden = bHide;
}
- (IBAction)onBack:(id)sender {
    for (UIView * v in self.subviews){
        v.hidden = YES;
    }
    [self hideAllBtn:NO];
}
@end
