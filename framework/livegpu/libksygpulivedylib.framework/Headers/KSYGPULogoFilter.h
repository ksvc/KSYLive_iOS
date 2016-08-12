//
//  KSYGPULogoFilter.h
//  KSYStreamer
//
//  Created by yiqian on 6/20/16.
//  Copyright © 2016 yiqian. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class  GPUImageTwoInputFilter;


@interface KSYGPULogoFilter : GPUImageTwoInputFilter

@property (nonatomic, readonly) UIImage*    logoImage;
@property (nonatomic, readonly) CGRect      logoRect;
@property (nonatomic, readonly) float       logoAlpha;

- (id)initWithLogo:(UIImage*)logo
            toRect:(CGRect) lRect
             alpha:(float)alpha;

-(void)setLogoImage:(UIImage*)logo;
-(void)setLogoAlpha:(float)  alpha;
-(void)setLogoRect :(CGRect) rect;

-(void)clearLogo;
@end
