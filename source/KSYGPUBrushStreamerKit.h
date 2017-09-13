//
//  KSYGPUBrushStreamerKit.h
//  KSYStreamer
//
//  Created by jiangdong on 28/12/16.
//  Copyright © 2016 ksyun. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <libksygpulive/KSYGPUStreamerKit.h>

@interface KSYGPUBrushStreamerKit : KSYGPUStreamerKit

/**
 @abstract   绘制图片的位置和大小
 @discussion 位置和大小的单位为预览视图的百分比, 左上角为(0,0), 右下角为(1.0, 1.0)
 @discussion 如果宽为0, 则根据图像的宽高比, 和设置的高度比例, 计算得到宽度的比例
 @discussion 如果高为0, 方法同上
 */
@property (nonatomic, readwrite) CGRect   drawPicRect;

/**
 @abstract   画笔图层
 */
@property (nonatomic, readonly) NSInteger drawLayer;

/**
 @abstract   绘制的图片
 @discussion 设置为nil为清除内容图片
 */
@property (nonatomic, readwrite) KSYGPUViewCapture      *drawPic;

/**
 @abstract   去掉画笔图层
 */
- (void)removeDrawLayer;

@end
