//
//  KSYBeautifyProFilter.h
//  GPUImage
//
//  Created by gene on 16/12/8.
//  Copyright © 2016年 Brad Larson. All rights reserved.
//

#import <GPUImage/GPUImage.h>
@interface KSYBeautifyProFilter : GPUImageFilterGroup

/// init
- (id)init;

/**
 @abstract   初始化并指定 1~4 的index来创建对应美颜滤镜
 @param      idx 效果的索引 (非法值无效)
 */
- (id)initWithIdx:(NSInteger)idx;

/// show version of this filter
+(void) showVersion;

/// grindRatio ranges from 0.0 to 1.0, with 0.5 as the normal level
@property(readwrite,nonatomic) CGFloat grindRatio;


/// whitenRatio ranges from 0.0 to 1.0, with 0.3 as the normal level
@property(readwrite,nonatomic) CGFloat whitenRatio;

#pragma mark
/// ruddyRatio ranges from -1.0 to 1.0, with -0.3 as the normal level
@property(readwrite,nonatomic) CGFloat ruddyRatio;

/**
几组推荐的效果参数  美白：whitenRatio=1.0,ruddyRatio=0.0;
                粉嫩：whitenRatio=0.3,ruddyRatio=-0.3；
                红润：whitenRatio=0.3,ruddyRatio=0.4；
其中init 效果参数默认是粉嫩，磨皮参数默认是0.5；
*/
@end
