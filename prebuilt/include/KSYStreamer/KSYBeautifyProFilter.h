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

/// show version of this filter
+(void) showVersion;

/// grindRatio ranges from 0.0 to 1.0, with 0.8 as the normal level
@property(readwrite,nonatomic) CGFloat grindRatio;


/// whitenRatio ranges from 0.0 to 1.0, with 0.8 as the normal level
@property(readwrite,nonatomic) CGFloat whitenRatio;

#pragma mark
/// ruddyRatio ranges from 0.0 to 1.0, with 0.5 as the normal level, need to use the initWithRubbyMaterial
@property(readwrite,nonatomic) CGFloat ruddyRatio;

@end
