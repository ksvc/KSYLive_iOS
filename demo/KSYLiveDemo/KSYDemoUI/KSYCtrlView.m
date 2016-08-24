//
//  controlView.m
//  KSYDemo
//
//  Created by 孙健 on 16/4/6.
//  Copyright © 2016年 孙健. All rights reserved.
//

#import "KSYCtrlView.h"

@interface KSYCtrlView ()

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
    _lblStat   =  [self addLable:@""  ];
    
    
    // stat string  formats
    _lblStat.backgroundColor = [UIColor clearColor];
    _lblStat.textColor = [UIColor redColor];
    _lblStat.numberOfLines = 7;
    _lblStat.textAlignment = NSTextAlignmentLeft;
    // format
    _lblNetwork.textAlignment = NSTextAlignmentCenter;
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
    self.yPos = self.height - self.btnH - self.gap;
    [self putRow3:_btnCapture
              and:_lblNetwork
              and:_btnStream];
    self.btnH *= 7;
    self.yPos -= (self.btnH +self.gap*2);
    [self putRow1:_lblStat];
}

@end
