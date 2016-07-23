//
//  KSYGPUBeautifyProFilter.h
//  KSYStreamer
//
//  Created by yiqian on 6/20/16.
//  Copyright © 2016 yiqian. All rights reserved.
//
/*
@class  GPUImageTwoPassTextureSamplingFilter;

@interface KSYGPUBeautifyProFilterB : GPUImageTwoPassTextureSamplingFilter
{
    GLint lightenRatioUniform;
};
*/

#import "KSYGPUTwoPassFilter.h"
@interface KSYGPUBeautifyProFilterB : KSYGPUTwoPassFilter
{
    GLint lightenRatioUniform;
};
@property (readwrite, nonatomic) CGFloat lightenRatio;

-(void)setlightenRatio:(CGFloat)newlightenRatio;

@end
