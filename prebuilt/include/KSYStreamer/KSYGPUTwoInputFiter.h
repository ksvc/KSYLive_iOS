//
//  KSYGPUTwoInputFiter.h
//  GPUImage
//
//  Created by gene on 16/8/22.
//  Copyright © 2016年 Brad Larson. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface KSYGPUTwoInputFiter :GPUImageTwoInputFilter{
    ;
}

-(NSString *)encodeFilterString:(NSString *)strString;

- (instancetype)init;

- (void)reload:(NSString *)fragmentShaderString;

- (void)reloadVS:(NSString *)vertexShaderString
           andFS:(NSString *)fragmentShaderString;

@end
