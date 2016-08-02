//
//  libksygpuimage.h
//  libksygpulive
//
//  Created by yiqian on 11/3/15.
//  Copyright (c) 2015 kingsoft. All rights reserved.
//

// 在import了GPUImage.h 之后再import本文件

// streamer
#import <UIKit/UIKit.h>
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/KSYGPUCamera.h>
#import <libksygpulive/KSYGPUYUVInput.h>

//simple interface
#import <libksygpulive/KSYGPUStreamerKit.h>

// filters
#import <libksygpulive/KSYGPUFilter.h>
#import <libksygpulive/KSYGPUTwoFilter.h>
#import <libksygpulive/KSYGPUTwoPassFilter.h>
#import <libksygpulive/KSYGPUBeautifyFilter.h>
#import <libksygpulive/KSYGPUBeautifyExtFilter.h>
#import <libksygpulive/KSYGPUDnoiseFilter.h>
#import <libksygpulive/KSYGPUBeautifyPlusFilter.h>
#import <libksygpulive/KSYGPUPipBlendFilter.h>
