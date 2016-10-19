#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <GPUImage/GPUImage.h>

/** GPU图像输出
 
 从GPU中取得处理后的图像, 通过回调函数将pixelBuffer和时间戳送出
 
 * 本模块含有一个GPUImageInput的接口, 从其他filter接收渲染结果
 * 通过inputSize  查询输入的图像尺寸
 * 通过outputSize 设置输出的图像尺寸
 
 */
@interface KSYGPUPicOutput : NSObject <GPUImageInput>
/**
 @abstract 初始化方法
 */
- (id) init;

/**
 @abstract 指定输出格式的初始化
 @see outputPixelFormat
 */
- (id) initWithOutFmt:(OSType) fmt;

/**
 @abstract output format (默认:kCVPixelFormatType_32BGRA)
 @discussion 目前只支持 kCVPixelFormatType_32BGRA 和 kCVPixelFormatType_4444AYpCbCr8 
 @discussion kCVPixelFormatType_4444AYpCbCr8 的排列顺序为 (A Y' Cb Cr)
 @discussion 其他非法都会被当做 kCVPixelFormatType_32BGRA 处理
 */
@property(nonatomic, readonly) OSType outputPixelFormat;

/**
 @abstract   GPUImageInput - (BOOL)enabled;
 */
@property(nonatomic) BOOL enabled;

/**
 @abstract 是否使用自定义输出尺寸 (默认为NO)
 @discussion NO:  outputSize自动跟随输入图像的变化而变化
 @discussion YES: outputSize使用外部自定义设置,忽略输入尺寸
 */
@property(nonatomic, assign) BOOL bCustomOutputSize;

/**
 @abstract output picture size
 @discussion 当bCustomOutputSize设置为NO时,outputSize无法被修改
 @see bCustomOutputSize
 */
@property(nonatomic, assign) CGSize outputSize;

/**
 @abstract input picture size
 */
@property(nonatomic, readonly) CGSize inputSize;

/**
 @abstract input roation mode
 */
- (GPUImageRotationMode)  getInputRotation;

#pragma mark - raw data
/**
 @abstract   视频处理回调接口
 @discussion pixelBuffer 美颜处理后，编码之前的视频数据
 @discussion timeInfo    时间戳
 @warnning   请注意本函数的执行时间，如果太长可能导致不可预知的问题
 */
@property(nonatomic, copy) void(^videoProcessingCallback)(CVPixelBufferRef pixelBuffer, CMTime timeInfo );
@end
