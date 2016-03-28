//
//  GPUImageAmaroFilter.h
//  GPUImage
//
//  Created by yulin on 16/2/26.
//  Copyright © 2016年 Brad Larson. All rights reserved.
//

 /* GPUImageAmaroFilter_h */
#import "GPUImageFilter.h"

@interface GPUImageBeautifyFilter : GPUImageFilter
{
    GLint paramsUniform, singleStepOffsetUniform;
}

@property (readwrite, nonatomic) CGPoint singleStepOffset;
@property (readwrite, nonatomic) GPUVector4 params;

@end