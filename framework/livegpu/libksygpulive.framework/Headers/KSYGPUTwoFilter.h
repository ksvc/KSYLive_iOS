//
//  KSYGPUFilter.h
//  KSYStreamer
//
//  Created by ksyun on 16/6/1.
//  Copyright © 2016年 yiqian. All rights reserved.
//

@class GPUImageTwoInputFilter;

@interface KSYGPUTwoFilter: GPUImageTwoInputFilter
{
}

-(NSString *)encodeFilterString:(NSString *)strString;

- (instancetype)init;

- (void)reload:(NSString *)fragmentShaderString;

@end
