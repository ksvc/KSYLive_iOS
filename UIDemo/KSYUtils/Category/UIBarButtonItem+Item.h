//
//  UIBarButtonItem+Item.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/6.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Item)


+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image highImage:(UIImage *)highImage target:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

+(UIBarButtonItem *)barButtonItemWithImageName:(NSString*)imageName frame:(CGRect)frame target:(id)target action:(SEL)action;


@end
