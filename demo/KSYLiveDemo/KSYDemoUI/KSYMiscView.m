//
//  KSYFilterView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYMiscView.h"

@interface KSYMiscView() {
    UIButton * _curBtn;
}

@end

@implementation KSYMiscView

- (id)init{
    self = [super init];
    _btn0  = [self addButton:@"str截图为文件"];
    _btn1  = [self addButton:@"str截图为UIImage"];
    _btn2  = [self addButton:@"filter截图"];
    return self;
}
- (void)layoutUI{
    [super layoutUI];
    self.btnH = 30;
    [self putRow3:_btn0
              and:_btn1
              and:_btn2];
}

@end
