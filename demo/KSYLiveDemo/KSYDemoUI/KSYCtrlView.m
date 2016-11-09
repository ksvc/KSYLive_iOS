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
    KSYUIView * _curSubMenuView;
}

@end

@implementation KSYCtrlView

- (id) initWithMenu:(NSArray *) menuNames {
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
    NSMutableArray * btnArray = [[NSMutableArray alloc] init];
    for (NSString * name in menuNames){
        [btnArray addObject: [self addButton:name] ];
    }
    _menuBtns = [NSArray arrayWithArray:btnArray];
    
    _backBtn   = [self addButton:@"菜单"
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
    [self putRow: @[_backBtn, _btnFlash, _btnCameraToggle,_btnQuit] ];
    
    [self putRow: _menuBtns ];
    [self hideMenuBtn:!_backBtn.hidden];
    
    self.yPos -= self.btnH;
    CGFloat freeHgt = self.height - self.yPos - self.btnH - self.gap;
    _lblStat.frame = CGRectMake( self.gap, self.yPos, self.winWdt - self.gap*2, freeHgt);
    self.yPos += freeHgt;
    
    // put at bottom
    [self putRow3:_btnCapture
              and:_lblNetwork
              and:_btnStream];
    if (_curSubMenuView) {
        _curSubMenuView.frame = _lblStat.frame;
        [_curSubMenuView layoutUI];
    }
}

- (void)hideMenuBtn: (BOOL) bHide {
    _backBtn.hidden   = !bHide; // 返回
    // hide menu
    for (UIButton * btn in _menuBtns){
        btn.hidden = bHide;
    }
}

- (IBAction)onBack:(id)sender {
    if (_curSubMenuView){
        _curSubMenuView.hidden = YES;
    }
    [self hideMenuBtn:NO];
}
- (void) showSubMenuView: (KSYUIView*) view {
    _curSubMenuView = view;
    [self hideMenuBtn:YES];
    view.hidden = NO;
    view.frame = _lblStat.frame;
    [view layoutUI];
}
@end
