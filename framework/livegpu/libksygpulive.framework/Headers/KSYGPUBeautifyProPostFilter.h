//
//  KSYGPUBeautifyProPostFilter.h
//  磨皮后处理类
//
//  Created by yiqian on 6/20/16.
//  Copyright © 2016 yiqian. All rights reserved.
//

#import "KSYGPUTwoPassFilter.h"
@interface KSYGPUBeautifyProPostFilter : KSYGPUTwoPassFilter
{
    GLint lightenRatioUniform, singleStepOffsetUniform, singleStepOffsetUniform1;
};
@property (readwrite, nonatomic) CGFloat lightenRatio;
@property (readwrite, nonatomic) CGPoint singleStepOffset;

-(void)setlightenRatio:(CGFloat)newlightenRatio;
-(void) setTexelSize:(CGPoint)size;

/*
 @abstract 磨皮后处理类型
 @discussion 0(锐化) 1（锐化和美白）
 */
- (id)initWithProPostType:(NSUInteger)type;


@end
