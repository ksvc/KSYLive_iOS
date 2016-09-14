//
//  controlView.m
//  KSYDemo
//
//  Created by 孙健 on 16/4/6.
//  Copyright © 2016年 孙健. All rights reserved.
//

#import "KSYCtrlView.h"
#import "KSYStateLableView.h"

@interface KSYCtrlView () {
    UIView * _curSubMenuView;
}

@end

@implementation KSYCtrlView

- (id) init {
    self = [super init];
    _btnFlash  =  [self addButton:@"闪光灯" ];
    _btnCameraToggle =  [self addButton:@"前后摄像头" ];
    _btnQuit   =  [self addButton:@"退出" ];
    _lblNetwork=  [self addLable:@""  ];
    _btnStream =  [self addButton:@"推流"  ];
    _btnCapture=  [self addButton:@"采集"  ];
    _lblStat   =  [[KSYStateLableView alloc] init];
    [self addSubview:_lblStat];
    // format
    _lblNetwork.textAlignment = NSTextAlignmentCenter;
    
    // add menu
    _bgmBtn   = [self addButton:@"背景音乐"];
    _filterBtn = [self addButton:@"滤镜/美颜"];
    _miscBtn   = [self addButton:@"其他"];
    _mixBtn    = [self addButton:@"混音"];
    _reverbBtn = [self addButton:@"混响"];
    _backBtn   = [self addButton:@"返回菜单"
                          action:@selector(onBack:)];
    _backBtn.hidden = YES;
    _curSubMenuView = nil;
    return self;
}

- (void) layoutUI {
    [super layoutUI];
    if ( self.width <self.height ){
        self.yPos =self.gap*5; // skip status bar
    }
    [self putRow3: _btnFlash
              and:_btnCameraToggle
              and: _btnQuit];
    
    [self putRow: @[_bgmBtn, _reverbBtn, _mixBtn,_backBtn] ];
    [self putRow: @[_filterBtn,  _miscBtn, [NSNull null], [NSNull null] ] ];
    [self hideMenuBtn:!_backBtn.hidden];
    
    CGFloat normalBtnH = self.btnH;
    self.btnH = self.height - self.yPos - self.btnH - self.gap;
    [self putRow1:_lblStat];
    
    // put at bottom
    self.btnH = normalBtnH;
    [self putRow3:_btnCapture
              and:_lblNetwork
              and:_btnStream];
}

- (void)hideMenuBtn: (BOOL) bHide {
    _backBtn.hidden   = !bHide; // 返回
    // hide menu
    _bgmBtn.hidden    = bHide;
    _filterBtn.hidden = bHide;
    _miscBtn.hidden   = bHide;
    _mixBtn.hidden    = bHide;
    _reverbBtn.hidden = bHide;
}

- (IBAction)onBack:(id)sender {
    if (_curSubMenuView){
        _curSubMenuView.hidden = YES;
    }
    [self hideMenuBtn:NO];
}
- (void) showSubMenuView: (UIView*) view {
    _curSubMenuView = view;
    [self hideMenuBtn:YES];
    view.hidden = NO;
    view.frame = _lblStat.frame;
}
@end
