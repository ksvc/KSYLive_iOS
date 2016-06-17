//
//  KSYGPUFilter.h
//  KSYStreamer
//
//  Created by ksyun on 16/6/1.
//  Copyright © 2016年 yiqian. All rights reserved.
//

@class GPUImageFilter;

@interface KSYGPUFilter: GPUImageFilter
{
}

-(NSString *)encodeFilterString:(NSString *)strString;

- (instancetype)init;

- (void)reload:(NSString *)fragmentShaderString;

@end
