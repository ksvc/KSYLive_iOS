//
//  KSYGPUStreamerKit.h
//  KSYStreamer
//
//  Created by pengbin on 09/01/16.
//  Copyright © 2016 ksyun. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "libksygpuimage.h"

/** KSY 直播推流工具类
 
 * kit类将直播推流SDK中提供的各种组件进行组合串联, 功能覆盖了绝大部分秀场直播场景的需求
 * 可以直接使用Kit类来开发基础功能的推流APP
 * 亦可以参考kit类的代码, 了解每个组件API的使用方法, 自行开发进阶需求的功能
 
 * 本 kit 类中, 演示了3个图层内容和2个音频通道的叠加直播
 * 图像通道: ([]中的数字为图层编号)
 vCapDev --> cropFilter --> filters[0] -->| vPreMixer |-> preview
                       logo picture[1] -->|
                    logo text label[2] -->| vStrMixer |-> picOutput --> streamer
 
 * 音频通道: ([]中的数字为音轨编号)
   aCapDev [0] -->|
 bgmplayer [1] -->| aMixer --> streamer
 
 */
@interface KSYGPUStreamerKit : NSObject

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
 @abstract   视频采集设备
 @discussion 通过该指针可以对摄像头进行操作 (操作接口参见GPUImage)
 */
@property (nonatomic, readonly) KSYAVFCapture      *vCapDev;

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
@property (nonatomic, readonly) GPUImageView          *preview;

/**
 @abstract   采集到的图像上传GPU
 @discussion 用于衔接GPU和capture
 */
@property (nonatomic, readonly)KSYGPUPicInput          *capToGpu;

/**
 @abstract   获取渲染的图像
 @discussion 用于衔接GPU和streamer
 */
@property (nonatomic, readonly)KSYGPUPicOutput         *gpuToStr;


#pragma mark - sub modules - audio
/**
 @abstract  配置管理 AVAudioSession的工具类
 */
@property (nonatomic, readonly) KSYAVAudioSession      *avAudioSession;

/**
 @abstract  音频采集设备 Audio Unit 音频采集
 */
@property (nonatomic, readonly) KSYAUAudioCapture      *aCapDev;

/**
 @abstract  背景音乐播放器
 */
@property (nonatomic, readonly) KSYBgmPlayer           *bgmPlayer;

/**
 @abstract   音频混合器
 @discussion 用于将多路音频进行混合,将混合后的音频送入streamerBase
 */
@property (nonatomic, readonly) KSYAudioMixer          *aMixer;

/**
 @abstract   获取初始化时创建的底层推流工具
 @discussion 1. 通过它来设置推流参数
 @discussion 2. 通过它来启动，停止推流
 */
@property (nonatomic, readonly) KSYStreamerBase        *streamerBase;

#pragma mark - layer & track ids
/** 摄像头图层 */
@property (nonatomic, readonly) NSInteger cameraLayer;
/** logo 图片的图层 */
@property (nonatomic, readonly) NSInteger logoPicLayer;
/** logo 文字的图层 */
@property (nonatomic, readonly) NSInteger logoTxtLayer;

/** 麦克风通道 */
@property (nonatomic, readonly) int micTrack;
/** 背景音乐通道 */
@property (nonatomic, readonly) int bgmTrack;

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
 @abstract   停止预览，停止采集设备，并清理会话
 @discussion 若推流未结束，则先停止推流
 @see stopStream
 */
- (void) stopPreview;

/**
 @abstract   进入后台: 暂停图像采集
 @discussion 暂停图像采集和预览
 @discussion 如果需要释放mic资源请直接调用停止采集
 @see aCapDev
 */
- (void) appEnterBackground;

/**
 @abstract   回到前台: 恢复采集
 @discussion 恢复图像采集和预览
 @discussion 恢复音频采集
 */
- (void) appBecomeActive;

#pragma mark - capture & preview & stream settings

/**
 @abstract   采集分辨率 (仅在开始采集前设置有效)
 @discussion 参见iOS的 AVCaptureSessionPresetXXX的定义
 @discussion https://developer.apple.com/reference/avfoundation/avcapturesession/1669314-video_input_presets?language=objc
 @discussion 透传到 KSYGPUCamera. 默认值为AVCaptureSessionPreset640x480
 @discussion 不同设备支持的预设分辨率可能不同, 请尽量与预览分辨率一致
 */
@property (nonatomic, assign) NSString * capPreset;

/**
 @abstract   查询实际的采集分辨率
 @discussion 参见iOS的 AVCaptureSessionPresetXXX的定义
 */
- (CGSize) captureDimension;

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
 @discussion 目前只支持 kCVPixelFormatType_32BGRA 和 kCVPixelFormatType_4444AYpCbCr8
 @discussion kCVPixelFormatType_4444AYpCbCr8 的排列顺序为 (A Y' Cb Cr)
 @discussion 其他非法都会被当做 kCVPixelFormatType_32BGRA 处理
 @discussion 仅在开始推流前设置有效
 */
@property(nonatomic, assign) OSType gpuOutputPixelFormat;

/**
 @abstract   采集视频帧率 (开始采集前设置有效)
 @discussion video frame per seconds 有效范围[1~30], 超出范围会取边界有效值
 @discussion 默认值为15
 */
@property (nonatomic, assign)   int    videoFPS;

/**
 @abstract   摄像头位置  (仅在开始采集前设置有效)
 @discussion 前后摄像头, 默认值为前置
 */
@property (nonatomic, assign) AVCaptureDevicePosition   cameraPosition;

/**
 @abstract   摄像头朝向
 @discussion 参见UIInterfaceOrientation
 @discussion 竖屏时: width < height
 @discussion 横屏时: width > height
 @discussion 需要与UI方向一致
 */
@property (nonatomic, readwrite) UIInterfaceOrientation videoOrientation;

#pragma mark - camera operation
/**
 @abstract   切换摄像头
 @return     TRUE: 成功切换摄像头， FALSE：当前参数，下一个摄像头不支持，切换失败
 @discussion 在前后摄像头间切换，从当前的摄像头切换到另一个，切换成功则修改cameraPosition的值
 @discussion 开始预览后开始有效，推流过程中也响应切换请求
 
 @see cameraPosition
 */
- (BOOL) switchCamera;

/**
 @abstract   当前采集设备是否支持闪光灯
 @return     YES / NO
 @discussion 通常只有后置摄像头支持闪光灯
 
 @see setTorchMode
 */
- (BOOL) isTorchSupported;

/**
 @abstract   开关闪光灯
 @discussion 切换闪光灯的开关状态 开 <--> 关
 
 @see setTorchMode
 */
- (void) toggleTorch;

/**
 @abstract   设置闪光灯
 @param      mode  AVCaptureTorchModeOn/Off
 @discussion 设置闪光灯的开关状态
 @discussion 开始预览后开始有效
 
 @see AVCaptureTorchMode
 */
- (void) setTorchMode: (AVCaptureTorchMode)mode;

/**
 @abstract   获取当前采集设备的指针
 
 @discussion 开放本指针的目的是开放类似下列添加到AVCaptureDevice的 categories：
 - AVCaptureDeviceFlash
 - AVCaptureDeviceTorch
 - AVCaptureDeviceFocus
 - AVCaptureDeviceExposure
 - AVCaptureDeviceWhiteBalance
 - etc.
 
 @return AVCaptureDevice* 预览开始前调用返回为nil，开始预览后，返回当前正在使用的摄像头
 
 @warning  请勿修改摄像头的像素格式，帧率，分辨率等参数，修改后会导致推流工作异常或崩溃
 @see AVCaptureDevice  AVCaptureDeviceTorch AVCaptureDeviceFocus
 */
- (AVCaptureDevice*) getCurrentCameraDevices;

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

/**
 @abstract   摄像头采集被打断的消息通知
 @discussion bInterrupt 为YES, 表明被打断, 摄像头采集暂停
 @discussion bInterrupt 为NO, 表明恢复采集
 */
@property(nonatomic, copy) void(^interruptCallback)(BOOL bInterrupt);

#pragma mark -  filters
/**
 @abstract   设置当前使用的滤镜
 @discussion 若filter 为nil， 则关闭滤镜
 @discussion 若filter 为GPUImageFilter的实例，则使用该滤镜做处理
 @discussion filter 也可以是GPUImageFilterGroup的实例，可以将多个滤镜组合
 
 @see GPUImageFilter
 */
- (void) setupFilter:(GPUImageOutput<GPUImageInput>*) filter;

#pragma mark -  mirror & rotate
/**
 @abstract 预览设置成镜像模式，默认为NO
*/
@property (nonatomic, assign) BOOL previewMirrored;

/**
  @abstract 推流设置成镜像模式,默认为NO
*/
@property (nonatomic, assign) BOOL streamerMirrored;

/**
 @abstract   根据UI的朝向旋转预览视图, 保证预览视图全屏铺满窗口
 @param      orie 旋转到目标朝向, 需要从demo中获取UI的朝向传入
 @discussion 采集到的图像的朝向还是和启动时的朝向一致
 */
- (void) rotatePreviewTo: (UIInterfaceOrientation) orie;

/**
 @abstract 根据UI的朝向旋转推流画面
 @param    orie 旋转到目标朝向, 需要从demo中获取UI的朝向传入
 */
- (void) rotateStreamTo: (UIInterfaceOrientation) orie;

#pragma mark - pictures & logo
/**
 @abstract   水印logo的图片
 @discussion 设置为nil为清除水印图片
 @discussion 请注意背景图片的尺寸, 太大的图片会导致内存占用过高
 @see
 */
@property (nonatomic, readwrite) GPUImagePicture      *logoPic;

/**
 @abstract   水印logo的图片的位置和大小
 @discussion 位置和大小的单位为预览视图的百分比, 左上角为(0,0), 右下角为(1.0, 1.0)
 @discussion 如果宽为0, 则根据图像的宽高比, 和设置的高度比例, 计算得到宽度的比例
 @discussion 如果高为0, 方法同上
 */
@property (nonatomic, readwrite) CGRect               logoRect;

/**
 @abstract   水印logo的图片的位置
 @discussion alpha为透明度(0-1),0完全透明，1完全不透明
 @see
 */
@property (nonatomic, readwrite) CGFloat              logoAlpha;

/**
 @abstract   水印文字的label
 @discussion 借用UILabel来指定文字的颜色,字体, 透明度, 对齐方式等属性
 @discussion 请注意保证背景图片的尺寸, 太大的图片会导致内存占用过高
 @warning    如果使用非等宽字体, 可能导致闪烁(默认为Courier)
 @warning    picMixer和UILabel都有alpha属性, 建议只选用其中一个, 固定另一个为1.0,
             为了减少接口, 建议直接使用UILabel的属性, 
             如果两者同时使用, 最终图层的alpha为两者乘积
 @see updateTextLabel
 */
@property (nonatomic, readwrite) UILabel             *textLabel;

/**
 @abstract   水印文字的图片的位置和大小
 @discussion 位置和大小的单位为预览视图的百分比, 左上角为(0,0), 右下角为(1.0, 1.0)
 @discussion 如果宽为0, 则根据文字图像的宽高比, 和设置的高度比例, 计算得到宽度的比例
 @discussion 如果高为0, 方法同上
 */
@property (nonatomic, readwrite) CGRect               textRect;

/**
 @abstract   刷新水印文字的内容
 @discussion 先修改文字的内容或格式,调用该方法后生效
 @see textLable
 */
- (void) updateTextLabel;

/**
 @abstract   当前采集设备是否支持自动变焦
 @param      point相机对焦的位置
 @return     YES / NO
 @discussion 通常只有后置摄像头支持自动变焦
  */
- (BOOL)focusAtPoint:(CGPoint )point;

/**
 @abstract   当前采集设备是否支持自动曝光
 @param      point相机曝光的位置
 @return     YES / NO
 @discussion 通常前后置摄像头都支持自动曝光
 */
- (BOOL)exposureAtPoint:(CGPoint )point;

/**
 @abstract 触摸缩放因子
 */
@property (nonatomic, assign)   CGFloat pinchZoomFactor;

@end
