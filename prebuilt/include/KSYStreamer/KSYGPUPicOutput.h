#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <GPUImage/GPUImage.h>

/** GPU图像输出
 
 从GPU中取得处理后的图像, 通过回调函数将pixelBuffer和时间戳送出
 
 * 本模块含有一个GPUImageInput的接口, 从其他filter接收渲染结果
 * 通过inputSize  查询输入的图像尺寸
 * 通过outputSize 设置输出的图像尺寸
 * 通过cropRegion 设置裁剪区域
 * 初始化时可指定输出数据的像素格式
 * 支持的输出颜色格式包括:
   - kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange: (NV12)
   - kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:(NV12)
   - kCVPixelFormatType_420YpCbCr8Planar:(I420)
   - kCVPixelFormatType_420YpCbCr8PlanarFullRange:(I420)
   - kCVPixelFormatType_32BGRA:(BGRA)
   - kCVPixelFormatType_4444AYpCbCr8:(AYUV) 排列顺序为 (A Y' Cb Cr)
 */
@interface KSYGPUPicOutput : NSObject <GPUImageInput>
/// @name Initialization
/**
 @abstract 初始化方法
 */
- (id) init;

/**
 @abstract 指定输出格式的初始化
 @param  fmt 输出格式
 @see outputPixelFormat
 */
- (id) initWithOutFmt:(OSType) fmt;

/// @name query and settings

/**
 @abstract output format (默认:kCVPixelFormatType_32BGRA)
 @discussion 非法颜色格式都会被当做 kCVPixelFormatType_32BGRA 处理
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
 @discussion 可以对裁剪后的图像再进行缩放
 @discussion 输出尺寸必须为4的整数倍, 内部会进行向上取整
 @see bCustomOutputSize
 */
@property(nonatomic, assign) CGSize outputSize;

/**
 @abstract   裁剪区域 将输入的图像按照区域裁剪出中间的一块
 @discussion cropRegion 标记了左上角的位置和宽高, 范围都是0.0 到1.0
 */
@property(readwrite, nonatomic) CGRect cropRegion;

/**
 @abstract input picture size
 */
@property(nonatomic, readonly) CGSize inputSize;

/** 是否冻结图像(主动提供重复图像) 
 @discussion 比如:视频采集被打断时, bAutoRepeat为NO,则停止提供图像; 为YES, 则主动提供最后一帧图像
 */
@property(nonatomic, readwrite) BOOL bAutoRepeat;

/** 0表示根据过去输入的图像来猜测帧率, 1~30 表示按照设定的帧率提供重复的帧, 默认为0 */
@property(nonatomic, readwrite) int targetFps;

/**
 @abstract input roation mode
 @return 图像的旋转模式
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
