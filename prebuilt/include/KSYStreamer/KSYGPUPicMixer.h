//
//  KSYGPUPipBlendFilter.h
//  GPUImage
//
//  Created by pengbin on 16/8/26.
//  Copyright © 2016年 ksyun. All rights reserved.
#import <GPUImage/GPUImage.h>
/**  图像混合filter
 
   * 将多个图层的内容进行叠加
   * 每个图层有index, [0~n]
   * 叠加顺序为0在最下层, index 越大在更上层
   * 可以每个图层分别指定位置和大小
   * 可以每个图层分别制定透明度
   * 可以动态交换图层
   * 可以动态刷新图层内容(支持视频)
   * 输出的刷新率 与 masterLayer 保持一致
 */
@interface KSYGPUPicMixer : GPUImageFilter {
};

/**
 @abstract   初始化
 @discussion 输出大小等于主要图层的大小
 */
- (id)init;

/**
 @abstract   初始化,并制定输出图像的大小
 @param      sz 输出图像的大小
 */
- (id)initWithOutputSize:(CGSize)sz;

/**
 @abstract   设置主要图层 (默认为0)
 @discussion 主要图层一般为视频图层, 当主要图层的输入刷新时, 输出才刷新
 */
@property (nonatomic, assign) NSUInteger masterLayer;

/**
 @abstract   设置图层的位置和大小 (单位为: 像素值 或者百分比)
 @param      rect 大小和位置
 @param      idx 图层的索引
 @discussion 缩放变形到对应的位置, 数值有如下两种表示方式
  - 像素值:rect中宽度或高度的值必须大于1.0, 则认为是像素值
  - 百分比:rect中宽度或高度的值必须小于等于1.0, 则认为是对应输出图像大小的百分比
 @discussion 保持宽高比的设置方法
  - 宽为0, 则按照高度和输入图像的宽高比计算出宽度
  - 高为0, 则按照宽度和输入图像的宽高比计算出高度
 @discussion 左上角的位置如果为非负值,则和宽高一样;如果为负数, 则自动居中放置
 */
-(void)setPicRect: (CGRect) rect
          ofLayer: (NSInteger) idx;
/**
 @abstract   获取图层的位置和大小 (单位为: 像素值 或者百分比)
 @param      idx 图层的索引
 @return     位置和大小
 */
-(CGRect) getPicRectOfLayer:(NSInteger) idx;

/**
 @abstract   设置图层的透明度 (默认为1.0)
 @param      alpha 透明度(0~1.0), 0为全透明
 @param      idx 图层的索引
 */
-(void)setPicAlpha: (CGFloat) alpha
           ofLayer: (NSInteger) idx;
/**
 @abstract   获取图层的透明度
 @param      idx 图层的索引
 @return     透明度
 */
-(CGFloat) getPicAlphaOfLayer:(NSInteger) idx;

/**
 @abstract   设置图层的旋转 (默认为norotation)
 @param      rotation 透明度(0~1.0), 0为全透明
 @param      idx 图层的索引
 @discussion 可用于设置镜像 (kGPUImageFlipHorizonal)
 */
-(void)setPicRotation: (GPUImageRotationMode) rotation
              ofLayer: (NSInteger) idx;
/**
 @abstract   获取图层的旋转模式
 @param      idx 图层的索引
 @return     旋转模式
 */
-(GPUImageRotationMode) getPicRotationOfLayer:(NSInteger) idx;

/**
 @abstract   清除特定图层的画面内容
 @param      index 指定被清除的图层
 @discussion 比如切换不同的视频内容时，避免出现黑色背景
 */
-(void)clearPicOfLayer:(NSInteger) index;

@end
