//
//  KSYSpecialEffects.h
//  GPUImage
//
//  Created by gene on 16/8/29.
//  Copyright © 2016年 ksyun. All rights reserved.
//
#import <GPUImage/GPUImage.h>

/** 金山云特效滤镜
 
 通过导入查找表资源实现的特效滤镜
 */
@interface KSYSpecialEffects : GPUImageFilterGroup

/// show version of this filter
+(void) showVersion;

#pragma mark - custom special effects
/**
 @abstract   初始化并指定特效素材
 @param      image 特效素材
 @return     构造的滤镜
 */
- (id)initWithUIImage:(UIImage *)image;

/**
 @abstract   初始化并指定特效素材
 @param      name 特效素材的文件名
 @return     构造的滤镜
 */
- (id)initWithImageName:(NSString *)name;

/**
 @abstract   指定特效素材
 @param      image 特效素材
 */
-(void)setSpecialEffectsUIImage:(UIImage *)image;

/// 特效参数
@property(readwrite, nonatomic) CGFloat intensity;

@end
