//
//  UIButton+Extension.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/6.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "UIButton+Extension.h"
#import <objc/runtime.h>

@interface UIButton ()

@property (nonatomic, copy) void (^callbackBlock)(UIButton * button);


@end

@implementation UIButton (Extension)


#pragma mark -有文字，有颜色，有字体，有背景颜色
-(instancetype)initButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font backGroundColor:(UIColor*)color callBack:(void(^)(UIButton*))callBlock{
    if (self = [super init]) {
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:titleColor forState:UIControlStateNormal];
        self.titleLabel.font = font;
        self.adjustsImageWhenHighlighted = NO;
        self.callbackBlock = callBlock;
        [self addTarget:self action:@selector(didClickAction:) forControlEvents:UIControlEventTouchUpInside];
       // [self setBackgroundColor:color];
    }

    return self;
}

/**
 按钮的响应事件
 */
-(void)didClickAction:(UIButton*)button{
    if (self.callbackBlock) {
        self.callbackBlock(button);
    }
}
//- (void (^)(UIButton *))callbackBlock {
//    return objc_getAssociatedObject(self, @selector(callbackBlock));
//}
//
//- (void)setCallbackBlock:(void (^)(UIButton *))callbackBlock {
//    objc_setAssociatedObject(self, @selector(callbackBlock), callbackBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//关联属性
-(void)setCallbackBlock:(void (^)(UIButton *))callbackBlock{
    objc_setAssociatedObject(self, @selector(callbackBlock), callbackBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(void (^)(UIButton *))callbackBlock{
    return objc_getAssociatedObject(self, @selector(callbackBlock));
}





#pragma mark --- 创建默认按钮--有字体、颜色--有图片---有背景
+ (instancetype)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font imageName:(NSString *)imageName backGroundColor:(UIColor*)color target:(id)target action:(SEL)action backImageName:(NSString *)backImageName  {
    
    UIButton *button = [[UIButton alloc] init];
    // 设置标题
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.titleLabel.font = font;
    button.adjustsImageWhenHighlighted = NO;
    // 图片
    if (imageName != nil) {
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        NSString *highlighted = [NSString stringWithFormat:@"%@_highlighted", imageName];
        [button setImage:[UIImage imageNamed:highlighted] forState:UIControlStateHighlighted];
    }
    
    // 背景图片
    if (backImageName != nil) {
        [button setBackgroundImage:[UIImage imageNamed:backImageName] forState:UIControlStateNormal];
        
        NSString *backHighlighted = [NSString stringWithFormat:@"%@_highlighted", backImageName];
        [button setBackgroundImage:[UIImage imageNamed:backHighlighted] forState:UIControlStateHighlighted];
    }
    
    // 监听方法
    if (action != nil) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    // 背景图片
    if (color != nil) {
        [button setBackgroundColor:color];
       
    }
    return button;
}

#pragma mark  --- 有文字,有颜色，有字体，有图片，没有背景图片
+ (instancetype)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font imageName:(NSString *)imageName target:(id)target action:(SEL)action {
    return [self buttonWithTitle:title titleColor:titleColor font:font imageName:imageName backGroundColor:nil target:target action:action backImageName:nil];
}


#pragma mark  --- 有文字,有颜色，有字体，没有图片，没有背景
+ (instancetype)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font target:(id)target action:(SEL)action {
    return [self buttonWithTitle:title titleColor:titleColor font:font imageName:nil backGroundColor:nil target:target action:action backImageName:nil];
}

#pragma mark  --- 有文字,有颜色,有字体,没图片，有背景
+ (instancetype)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font target:(id)target action:(SEL)action backImageName:(NSString *)backImageName {
    return [self buttonWithTitle:title titleColor:titleColor font:font imageName:nil backGroundColor:nil target:target action:action backImageName:backImageName];
}
#pragma mark ---有文字，有颜色，有字体，有背景颜色
+ (instancetype)buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font backGroundColor:(UIColor*)color target:(id)target action:(SEL)action backImageName:(NSString *)backImageName{
        return [self buttonWithTitle:title titleColor:titleColor font:font imageName:nil backGroundColor:color target:target action:action backImageName:backImageName];
}


-(instancetype)initButtonWithTitleName:(NSString*)title buttonWithImageName:(NSString*)imageName buttonTag:(int)tag {
    if (self = [super init]) {
        self = [UIButton buttonWithType:UIButtonTypeCustom];
        [self setTitle:title forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        self.tag = tag;
    }
    return self;
}

@end
