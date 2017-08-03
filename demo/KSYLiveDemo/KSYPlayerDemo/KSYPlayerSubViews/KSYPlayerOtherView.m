//
//  KSYPlayerOtherView.m
//
//  Created by 施雪梅 on 17/7/12.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYPlayerOtherView.h"

@interface KSYPlayerOtherView(){
    UILabel   *_labelRec;                           //录制
}
@end

@implementation KSYPlayerOtherView

- (id)init{
    self = [super init];
    
    [self setupUI];
    return self;
}

- (void) setupUI {
    
    _btnReload = [self addButton:@"reload"];
    _btnFloat = [self addButton:@"悬窗"];
    _labelRec = [self addLable:@"开启/关闭录制"];
    _btnPrintMeta = [self addButton:@"显示媒体信息"];
    _switchRec = [self addSwitch:NO];
    
    _labelMeta = [self addLable:nil];
    _labelMeta.backgroundColor = [UIColor lightGrayColor];
    _labelMeta.textAlignment = NSTextAlignmentLeft;
    _labelMeta.numberOfLines = 0;
    _labelMeta.font = [_labelMeta.font fontWithSize:8];
    
    [self layoutUI];
}

- (void)layoutUI{
    [super layoutUI];
    self.yPos = 0;
    
    [self putRow:@[_btnReload, _btnFloat, _btnPrintMeta]];
    [self putLable:_labelRec andView:_switchRec];
    _labelMeta.layer.cornerRadius = 5;
    _labelMeta.clipsToBounds = YES;
    CGFloat width = self.width / 3;
    _labelMeta.frame = CGRectMake(self.width - width, CGRectGetMinY(_switchRec.frame), width, 100);
    _labelMeta.hidden = YES;
}

@end
