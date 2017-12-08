//
//  KSYDrawingView.h
//  KSYGPUStreamerDemo
//
//  Created by 江东 on 17/6/19.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYUIView.h"
#import <UIKit/UIKit.h>

@interface KSYDrawingView: KSYUIView

/**
 擦除全部线条
 */
- (void) clearAllPath;

/**
 @abstract   视图更新通知
 */
@property(nonatomic, copy) void(^viewUpdateCallback)();

@end

