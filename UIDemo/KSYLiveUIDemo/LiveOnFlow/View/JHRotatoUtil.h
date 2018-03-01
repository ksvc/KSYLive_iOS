//
//  JHRotatoUtil.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/23.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JHRotatoUtil : NSObject

/**
 *  切换横竖屏
 *
 *  @param orientation ：UIInterfaceOrientation
 */
+ (void)forceOrientation: (UIInterfaceOrientation)orientation;

/**
 *  判断是否竖屏
 *
 *  @return 布尔值
 */
+ (BOOL)isOrientationLandscape;

@end
