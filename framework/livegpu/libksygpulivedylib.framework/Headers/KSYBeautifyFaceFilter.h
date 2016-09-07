//
//  KSYBeautifyFaceFilter.h
//  GPUImage
//
//  Created by gene on 16/8/22.
//  Copyright © 2016年 Brad Larson. All rights reserved.
//
@class GPUImageFilterGroup;

@interface KSYBeautifyFaceFilter : GPUImageFilterGroup

// grindRatio ranges from 0.0 to 0.8, with 0.7 as the normal level
@property(readwrite,nonatomic) CGFloat grindRatio;


// whitenRatio ranges from 0.0 to 1.0, with 0.5 as the normal level
@property(readwrite,nonatomic) CGFloat whitenRatio;

+(void) showVersion;

@end


