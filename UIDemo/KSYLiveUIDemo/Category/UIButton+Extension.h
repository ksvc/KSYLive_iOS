//
//  UIButton+Extension.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/6.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Extension)

/**
 *  创建按钮有文字,有颜色,有字体,有图片,没有有背景
 *
 *  @param title         标题
 *  @param titleColor     字体颜色
 *  @param font      字号
 *  @param imageName     图像
 *
 *  @return UIButton
 */
+ (instancetype)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font imageName:(NSString *)imageName target:(id)target action:(SEL)action;

/**
 *  创建按钮有文字,有颜色,有字体,有图片,有背景
 *
 *  @param title         标题
 *  @param color         字体颜色
 *  @param font      字号
 *  @param imageName     图像
 *  @param backImageName 背景图像
 *
 *  @return UIButton
 */
+ (instancetype)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font imageName:(NSString *)imageName backGroundColor:(UIColor*)color target:(id)target action:(SEL)action backImageName:(NSString *)backImageName;


/**
 *  创建按钮有文字,有颜色，有字体，没有图片，没有背景
 *
 *  @param title         标题
 *  @param titleColor    标题颜色
 *
 *  @return UIButton
 */
+ (instancetype)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font target:(id)target action:(SEL)action;

/**
 *  创建按钮有文字,有颜色，有字体，没有图片，有背景
 *
 *  @param title         标题
 *  @param titleColor    标题颜色
 *  @param backImageName 背景图像名称
 *
 *  @return UIButton
 */
+ (instancetype)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font target:(id)target action:(SEL)action backImageName:(NSString *)backImageName;

/**
 快速创建按钮

 @param title 标题
 @param titleColor 标题颜色
 @param font 标题字体
 @param target 响应对象
 @param action 相应方法
 @param backImageName 背景图片的名字
 @return UIButton
 */
+ (instancetype)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font backGroundColor:(UIColor*)color target:(id)target action:(SEL)action backImageName:(NSString *)backImageName;

/**
 便利按钮

 @param title 文字
 @param titleColor 字体颜色
 @param font 字体
 @param color 背景颜色
 @return UIButton
 */
-(instancetype)initButtonWithTitle:(NSString*)title titleColor:(UIColor *)titleColor font:(UIFont*)font backGroundColor:(UIColor*)color callBack:(void(^)(UIButton*))callback;

-(instancetype)initButtonWithTitleName:(NSString*)title buttonWithImageName:(NSString*)imageName buttonTag:(int)tag;

@end
