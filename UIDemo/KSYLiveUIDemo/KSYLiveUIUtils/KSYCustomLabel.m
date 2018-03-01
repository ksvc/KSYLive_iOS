//
//  KSYCustomLabel.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/3.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYCustomLabel.h"

@implementation KSYCustomLabel

+(instancetype)labelWithText:(NSString *)text
                    textColor:(UIColor *)textColor
                         font:(UIFont *)font
                textAlignment:(NSTextAlignment)textAlignment
              backgroundColor:(UIColor *)bgColor
{
    KSYCustomLabel *customLabel=[[KSYCustomLabel alloc]init];
    customLabel.text=text;
    customLabel.textColor=textColor;
    customLabel.font=font;
    customLabel.textAlignment=textAlignment;
    customLabel.backgroundColor=bgColor;
    return customLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
