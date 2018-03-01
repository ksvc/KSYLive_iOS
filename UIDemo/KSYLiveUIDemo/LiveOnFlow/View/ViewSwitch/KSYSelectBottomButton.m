//
//  KSYSelectBottomButton.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/15.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYSelectBottomButton.h"


//#define radioButtonImageWH          (16.0)
//#define radio_ICON_TITLE_MARGIN     (5.0)
static NSMutableDictionary* _groupRadioDic=nil;

@implementation KSYSelectBottomButton


-(id)initWithFrame:(CGRect)frame title:(NSString*)title titleColor:(UIColor*)titleColor selectedColor:(UIColor*)selectedColor font:(UIFont*)font delegate:(id)delegate groupId:(NSString *)groupId{
    if (self = [super init]) {
        self.delegate = delegate;
        self.groudId = [groupId copy];
        [self addToGroup];
        
        //初始化按钮
        self.frame = frame;
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:titleColor forState:UIControlStateNormal];
        [self setTitleColor:selectedColor forState:UIControlStateSelected];
        self.titleLabel.font = font;

        [self addTarget:self action:@selector(radioBtnChecked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)addToGroup{
    if (!_groupRadioDic) {
        _groupRadioDic = [NSMutableDictionary dictionary];
    }
    NSMutableArray* radioArray = [_groupRadioDic objectForKey:_groudId];
    if (!radioArray) {
        radioArray = [NSMutableArray array];
    }
    [radioArray addObject:self];
    [_groupRadioDic setObject:radioArray forKey:_groudId];
}

//点击按钮的事件
-(void)setChecked:(BOOL)checked{
    if (_checked == checked) {
        return;
    }
    _checked = checked;
    self.selected = checked;
    if (self.selected) {
        [self unCheckOtherRadios];
    }
    if (self.selected && _delegate && [_delegate respondsToSelector:@selector(didSelectedBottomButton:groupId:)]) {
       [_delegate didSelectedBottomButton:self groupId:_groudId];
    }
}
-(void)radioBtnChecked{
    if (_checked) {
        return;
    }
    self.selected = !self.selected;
    _checked = self.selected;
    if (self.selected) {
        [self unCheckOtherRadios];
    }
    if (self.selected && _delegate && [_delegate respondsToSelector:@selector(didSelectedBottomButton:groupId:)]) {
        [_delegate didSelectedBottomButton:self groupId:_groudId];
    }
}

-(void)unCheckOtherRadios{
    NSMutableArray* unCheckArray = [_groupRadioDic objectForKey:_groudId];
    if (unCheckArray.count>0) {
        for (KSYSelectBottomButton* button in unCheckArray) {
            if (button.checked && ![button isEqual:self]) {
                button.checked = NO;
            }
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
