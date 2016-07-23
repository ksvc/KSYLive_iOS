//
//  KSYGPUBeautifyProFilter.h
//  KSYStreamer
//
//  Created by yiqian on 6/20/16.
//  Copyright © 2016 yiqian. All rights reserved.
//

#import "KSYGPUFilter.h"

@interface KSYGPUBeautifyProFilter : KSYGPUFilter
{
    GLint singleStepOffsetUniform;
    GLint lightenRatioUniform;
};

@property (readwrite, nonatomic) CGPoint singleStepOffset;
@property (readwrite, nonatomic) CGFloat lightenRatio;

-(void) setTexelSize:(CGPoint)size;
-(void)setlightenRatio:(CGFloat)newlightenRatio;

@end
