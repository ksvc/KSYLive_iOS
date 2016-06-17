//
//  KSYGPUPipBlendFilter.h
//  GPUImage
//
//  Created by pengbin on 16/2/26.
//  Copyright © 2016年 ksyun. All rights reserved.
//


@class  GPUImageThreeInputFilter;

/** 画中画中画 混合filter  （pip）
 三输入filter，将两个视频和一个图片叠加到一起，三个依次叠加
 两个输入中，按照添加顺序：
 首先被添加的为firstTexture （视频）
 中间添加的为secondTexture  （视频）
 最后添加的为thirdTexture   （图片）
 本filter的输出纹理大小与 firstTexture 一致
 叠加方式只支持将firstTexture缩小后 叠加到 secondTexture上，再叠加 到thirdTexture上
 其中，firstTexture 保持宽高比缩小
 secondTexture 保持宽高比缩放来适应firstTexture的原始大小
 thirdTexture 不保持宽高比，填充firstTexture的原始大小
 */
@interface KSYGPUPipBlendFilter : GPUImageThreeInputFilter
{
    
};
/**
 @abstract   初始化，并设置画中画左上角点的坐标（位置和大小）
 @discussion firstTexture 在画布上的位置和大小
 */
- (id)initWithPipRect:(CGRect)rect ;

/**
 @abstract   设置画中画左上角点的坐标（位置和大小）
 @discussion firstTexture 在画布上的位置和大小
 */
-(void)setPipRect : (CGRect) rect;

/**
 @abstract   当secondTexture 需要刷新时调用
 @discussion 比如切换不同的视频内容时，避免出现黑色背景
 */
-(void)clearSecondTexture;

@end
