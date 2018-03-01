//
//  KSYCustomLabel.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/3.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSYCustomLabel : UILabel

/**
 自定义label

 @param text 文本内容
 @param textColor 字体颜色
 @param font 字体大小
 @param textAlignment 对齐方式
 @param bgColor 背景颜色
 @return 返回label
 */
+(instancetype)labelWithText:(NSString *)text
                    textColor:(UIColor *)textColor
                         font:(UIFont *)font
                textAlignment:(NSTextAlignment)textAlignment
              backgroundColor:(UIColor *)bgColor;


@end
