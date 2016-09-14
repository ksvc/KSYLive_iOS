//
//  KSYGPULogoFilter.h
//  KSYStreamer
//
//  Created by yiqian on 6/20/16.
//  Copyright © 2016 yiqian. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <GPUImage/GPUImage.h>

/** 叠加logo的滤镜
 
 1. 输入的 UIImage 叠加到输入KSYGPULogoFilter的纹理上
 2. 可以指定UIImage在纹理上的位置和透明度
 3. 通过clearLogo, 可以清除纹理上的图片
 */
@interface KSYGPULogoFilter : GPUImageTwoInputFilter

#pragma mark - property
/// 叠加的图片
@property (nonatomic, readonly) UIImage*    logoImage;
/// 图片的位置和大小, 需要归一化到 0~1.0 之间
@property (nonatomic, readonly) CGRect      logoRect;
/// 图片的透明度
@property (nonatomic, readonly) float       logoAlpha;

#pragma mark - methods
/**
 @abstract   初始化输入的logo相关属性
 @param      logo  图片
 @param      lRect 图片的位置
 @param      alpha 透明度
 @return     构造出来的滤镜
 */
- (id)initWithLogo:(UIImage*)logo
            toRect:(CGRect) lRect
             alpha:(float)alpha;
/**
 @abstract   更新图像
 @param      logo  图片
 */
-(void)setLogoImage:(UIImage*)logo;
/**
 @abstract   设置图像的透明度
 @param      alpha 透明度
 */
-(void)setLogoAlpha:(float)  alpha;
/**
 @abstract   设置图像的位置
 @param      rect 位置
 */
-(void)setLogoRect :(CGRect) rect;

/// 清除图片
-(void)clearLogo;
@end
