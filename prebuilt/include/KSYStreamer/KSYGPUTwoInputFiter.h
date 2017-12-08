//
//  KSYGPUTwoInputFiter.h
//  GPUImage
//
//  Created by gene on 16/8/22.
//  Copyright © 2016年 Brad Larson. All rights reserved.
//

#import <GPUImage/GPUImage.h>

/** 双输入滤镜
 
 1. 继承自GPUImageTwoInputFilter
 2. 添加了重新载入shader的接口
 */
@interface KSYGPUTwoInputFiter :GPUImageTwoInputFilter{
    ;
}

/**
 重新载入加密的shader串

 @param fragmentShaderString 加密的片原shader
 */
- (void)reload:(NSString *)fragmentShaderString;

/**
 重新载入加密的shader串

 @param vertexShaderString 顶点shader(未加密)
 @param fragmentShaderString 片原shader(加密的)
 */
- (void)reloadVS:(NSString *)vertexShaderString
           andFS:(NSString *)fragmentShaderString;

@end
