//
//  KSYGPUYUVInput.h
//  KSYStreamer
//
//  Created by yiqian on 1/30/16.
//  Copyright © 2016 yiqian. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@class GPUImageOutput;

//extern const GLfloat kColorConversion601[];
//extern const GLfloat kColorConversion601FullRange[];
//extern const GLfloat kColorConversion709[];
extern NSString *const kGPUImageYUVVideoRangeConversionForRGFragmentShaderString;
extern NSString *const kGPUImageYUVFullRangeConversionForLAFragmentShaderString;
extern NSString *const kGPUImageYUVVideoRangeConversionForLAFragmentShaderString;

/**
 upload yuv to rgba texture
 */
@interface KSYGPUYUVInput : GPUImageOutput {
    dispatch_semaphore_t dataUpdateSemaphore;
    
    GPUImageRotationMode outputRotation, internalRotation;
    GLuint luminanceTexture, chrominanceTexture;
}

// Initialization and teardown
- (id)init;

// Image rendering
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)processPixelBuffer:(CVPixelBufferRef)pixelBuffer
                      time:(CMTime)timeInfo;
@end
