//
//  KSYGPUBgpStreamerKit.h
//  KSYStreamer
//
//  Created by 江东 on 17/4/21.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "libksygpulive.h"
#import "libksystreamerengine.h"
#import "libksygpufilter.h"

@interface KSYGPUBgpStreamerKit : NSObject
/**
 @abstract 初始化方法
 @discussion 创建带有默认参数的 kit，不会打断其他后台的音乐播放
 
 @warning kit只支持单实例推流，构造多个实例会出现异常
 */
- (instancetype) initWithDefaultCfg;

/**
 @abstract 初始化方法
 @discussion 创建带有默认参数的 kit，会打断其他后台的音乐播放
 
 @warning kit只支持单实例推流，构造多个实例会出现异常
 */
- (instancetype) initWithInterruptCfg;

/**
 @abstract   获取SDK版本号
 */
- (NSString*) getKSYVersion;

#pragma mark - sub modules - video
/**
 @abstract   获取当前使用的滤镜
 @discussion 通过此指针可以对滤镜参数进行设置
 @waning     请确保外部保留了filter的真实类型的指针, 否则会出现奔溃
 */
@property (nonatomic, readonly) GPUImageOutput<GPUImageInput>* filter;

/**
 @abstract   图像混合器 for 预览
 @discussion 将多图层的内容叠加
 */
@property (nonatomic, readonly) KSYGPUPicMixer        *vPreviewMixer;

/**
 @abstract   图像混合器 for 推流
 @discussion 将多图层的内容叠加
 */
@property (nonatomic, readonly) KSYGPUPicMixer        *vStreamMixer;

/**
 @abstract   预览视图
 @discussion 通过此指针可以对预览视图进行操作
 */
@property (nonatomic, readonly) KSYGPUView          *preview;

/**
 @abstract   获取渲染的图像
 @discussion 用于衔接GPU和streamer
 */
@property (nonatomic, readonly)KSYGPUPicOutput         *gpuToStr;


#pragma mark - sub modules - audio
/**
 @abstract  音频采集设备 Audio Unit 音频采集
 */
@property (nonatomic, readonly) KSYAUAudioCapture      *aCapDev;

/**
 @abstract   音频混合器
 @discussion 用于将多路音频进行混合,将混合后的音频送入streamerBase
 */
@property (nonatomic, readonly) KSYAudioMixer          *aMixer;

/**
 @abstract   消息通道
 @discussion 用于采集消息，并将数据送入streamerBase
 */
@property (nonatomic, readonly) KSYMessage                 *msgStreamer;

/**
 @abstract   获取初始化时创建的底层推流工具
 @discussion 1. 通过它来设置推流参数
 @discussion 2. 通过它来启动，停止推流
 */
@property (nonatomic, readonly) KSYStreamerBase        *streamerBase;

#pragma mark - reconnect
/**
 @abstract 自动重连次数 关闭(0), 开启(>0), 默认为0
 @discussion 当内部发现推流错误后, 会在一段时间后尝试重连
 自动重连不会重新获取推流地址, 仍然使用上次推流的地址
 @warning  如果在推流地址有过期时间, 请勿开启
 */
@property (nonatomic, assign) int          maxAutoRetry;

/**
 @abstract 自动重连延时, 发现连接错误后, 重试的延时
 @discussion 单位为秒, 默认为2s, 最小值为0.1s
 */
@property (nonatomic, assign) double          autoRetryDelay;

#pragma mark - layer & track ids
/** 摄像头图层 */
@property (nonatomic, readonly) NSInteger cameraLayer;

/** 麦克风通道 */
@property (nonatomic, readonly) int micTrack;

#pragma mark - capture state
/**
 @abstract 当前采集设备状况
 @discussion 可以通过该属性获取采集设备的工作状况
 
 @discussion 通知：
 * KSYCaptureStateDidChangeNotification 当采集设备工作状态发生变化时提供通知
 * 收到通知后，通过本属性查询新的状态，并作出相应的动作
 */
@property (nonatomic, readonly) KSYCaptureState captureState;

/**
 @abstract   获取采集状态对应的字符串
 */
- (NSString*) getCaptureStateName : (KSYCaptureState) stat;

/**
 @abstract   获取当前采集状态对应的字符串
 */
- (NSString*) getCurCaptureStateName;

// Posted when capture state changes
FOUNDATION_EXPORT NSString *const KSYCaptureStateDidChangeNotification NS_AVAILABLE_IOS(7_0);

#pragma mark - capture actions
/**
 @abstract 启动预览
 @param view 预览画面作为subview，插入到 view 的最底层
 @discussion 设置完成采集参数之后，按照设置值启动预览，启动后对采集参数修改不会生效
 @discussion 需要访问摄像头和麦克风的权限，若授权失败，其他API都会拒绝服务
 
 @warning: 开始推流前必须先启动预览
 @see videoDimension, cameraPosition, videoOrientation, videoFPS
 */
- (void) startPreview: (UIView*) view;

/**
 @abstract 开启视频配置和采集
 @discussion 设置完成视频采集参数之后，按照设置值启动视频预览，启动后对视频采集参数修改不会生效
 @discussion 需要访问摄像头的权限，若授权失败，其他API都会拒绝服务
 @discussion 视频采集成功返回YES，不成功返回NO
 */
- (BOOL) startVideoCap;

/**
 @abstract 开始音频配置和采集
 @discussion 设置完成音频采集参数之后，按照设置值启动音频预览，启动后对音频采集参数修改不会生效
 @discussion 需要访问麦克风的权限，若授权失败，其他API都会拒绝服务
 @discussion 音频采集成功返回YES，不成功返回NO
 */
- (BOOL) startAudioCap;

/**
 @abstract   停止预览，停止采集设备，并清理会话
 @discussion 若推流未结束，则先停止推流
 @see stopStream
 */
- (void) stopPreview;

/**
 @abstract   进入后台: 暂停图像采集
 @discussion 暂停图像采集和预览, 中断旁路录制
 @discussion 如果需要释放mic资源请直接调用停止采集
 @discussion kit内部在收到UIApplicationDidEnterBackgroundNotification 或采集被打断等事件时,会主动调用本接口
 */
- (void) appEnterBackground;

/**
 @abstract   回到前台: 恢复采集
 @discussion 恢复图像采集和预览
 @discussion 恢复音频采集
 @discussion kit内部在收到UIApplicationDidBecomeActiveNotification等事件时,会主动调用本接口
 */
- (void) appBecomeActive;

#pragma mark - capture & preview & stream settings
/**
 @abstract   预览分辨率 (仅在开始采集前设置有效)
 @discussion 内部始终将较大的值作为宽度 (若需要竖屏，请设置 videoOrientation）
 @discussion 宽高都会向上取整为4的整数倍
 @discussion 有效范围: 宽度[160, 1920] 高度[ 90,  1080], 超出范围会取边界有效值
 @discussion 当预览分辨率与采集分辨率不一致时:
 若宽高比不同, 先进行裁剪, 再进行缩放
 若宽高比相同, 直接进行缩放
 @discussion 默认值为(640, 360)
 */
@property (nonatomic, assign)   CGSize previewDimension;

/**
 @abstract   用户定义的视频 **推流** 分辨率
 @discussion 有效范围: 宽度[160, 1280] 高度[ 90,  720], 超出范围会取边界有效值
 @discussion 其他与previewDimension限定一致,
 @discussion 当与previewDimension不一致时, 同样先裁剪到相同宽高比, 再进行缩放
 @discussion 默认值为(640, 360)
 @see previewDimension
 */
@property (nonatomic, assign)   CGSize streamDimension;

/**
 @abstract  gpu output pixel format (默认:kCVPixelFormatType_32BGRA)
 @discussion 目前支持 BGRA , NV12 和 I420
 @discussion 仅在开始推流前设置有效
 */
@property(nonatomic, assign) OSType gpuOutputPixelFormat;

/**
 @abstract   采集及编码视频帧率 (开始采集前设置有效)
 @discussion video frame per seconds 有效范围[1~30], 超出范围会取边界有效值
 @discussion 默认值为15
 */
@property (nonatomic, assign)   int    videoFPS;

#pragma mark - raw data
/**
 @abstract   视频处理回调接口
 @param      sampleBuffer 原始采集到的视频数据
 @discussion 对sampleBuffer内的图像数据的修改将传递到观众端
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题
 @discussion 请参考 CMSampleBufferRef
 */
@property(nonatomic, copy) void(^videoProcessingCallback)(CMSampleBufferRef sampleBuffer);

/**
 @abstract   音频处理回调接口
 @discussion sampleBuffer 原始采集到的音频数据
 @discussion 对sampleBuffer内的pcm数据的修改将传递到观众端
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题
 @discussion 请参考 CMSampleBufferRef
 */
@property(nonatomic, copy) void(^audioProcessingCallback)(CMSampleBufferRef sampleBuffer);

#pragma mark -  filters
/**
 @abstract   设置当前使用的滤镜
 @discussion 若filter 为nil， 则关闭滤镜
 @discussion 若filter 为GPUImageFilter的实例，则使用该滤镜做处理
 @discussion filter 也可以是GPUImageFilterGroup的实例，可以将多个滤镜组合
 
 @see GPUImageFilter
 */
- (void) setupFilter:(GPUImageOutput<GPUImageInput>*) filter;

#pragma mark - message

/**
 @abstract 用户待发送的消息
 @param      messageData待发送的消息
 @return     YES / NO
 */
- (BOOL) processMessageData:(NSDictionary *)messageData;

/**
 @abstract   背景图片，用于背景图片推流
 @discussion 设置为nil为清除背景图片
 */
@property (nonatomic, readwrite) GPUImagePicture      *bgPic;

/**
 @abstract   背景图片朝向
 */
@property (nonatomic, readwrite) GPUImageRotationMode bgPicRotate;

/**
 @abstract   读取图像的朝向
 */
+ (GPUImageRotationMode) getRotationMode:(UIImage*) img;

@end
