//
//  UIBarButtonItem+Item.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/6.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "UIBarButtonItem+Item.h"

@implementation UIBarButtonItem (Item)
+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image highImage:(UIImage *)highImage target:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    // btn
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn setBackgroundImage:highImage forState:UIControlStateHighlighted];
    [btn sizeToFit];
    
    [btn addTarget:target action:action forControlEvents:controlEvents];
    
    return  [[UIBarButtonItem alloc] initWithCustomView:btn];
    
}

+(UIBarButtonItem *)barButtonItemWithImageName:(NSString*)imageName frame:(CGRect)frame target:(id)target action:(SEL)action{
    UIButton* barButton = [[UIButton alloc]init];
    barButton.frame = frame;
    [barButton setImage:[UIImage imageNamed:imageName] forState: UIControlStateNormal];
    [barButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc]initWithCustomView:barButton];
    
    return item;
}

@end
