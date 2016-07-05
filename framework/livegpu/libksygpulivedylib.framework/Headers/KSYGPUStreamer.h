#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "KSYStreamerBase.h"

@protocol GPUImageInput;
@class KSYStreamerBase;

@interface KSYGPUStreamer : NSObject <GPUImageInput>
/**
 @abstract 初始化方法
 @discussion 初始化，创建带有默认参数的 KSYGPUStreamer
 
 @warning KSYGPUStreamer只支持单实例推流，构造多个实例会出现异常
 */
- (instancetype) initWithDefaultCfg;

#pragma mark - get sub modules
/**
 @abstract   获取初始化时创建的底层推流工具
 @discussion 1. 通过它来设置推流参数
 @discussion 2. 通过它来启动，停止推流
 */
@property (nonatomic, readonly) KSYStreamerBase*   streamerBase;

/**
 @abstract   获取底层推流实例
 @discussion
 */
- (KSYStreamerBase* ) getStreamer;

/**
 @abstract   GPUImageInput - (BOOL)enabled;
 */
@property(nonatomic) BOOL enabled;

#pragma mark - raw data
/**
 @abstract   视频处理回调接口
 @param      pixelBuffer 美颜处理后，编码之前的视频数据
 @param      timeInfo    时间戳
 @warnning   请注意本函数的执行时间，如果太长可能导致不可预知的问题
 @see        CVPixelBufferRef
 */
@property(nonatomic, copy) void(^videoProcessingCallback)(CVPixelBufferRef pixelBuffer, CMTime timeInfo );
@end
