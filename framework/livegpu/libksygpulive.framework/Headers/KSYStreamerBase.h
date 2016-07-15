//
//  KSYStreamerBase.h
//  KSYStreamer
//
//  Created by pengbin on 10/15/15.
//  Copyright © 2015 ksy. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "KSYTypeDef.h"


/**
 金山云直播推流SDK iOS版提供了iOS移动设备上的推流功能

 * 音频编码采用AAC编码，码率可配置;
 * 视频频编码采用H.264编码，码率可配置;
 * 支持 RTMP 协议直播推流;
 
 
 __Found__: 2015-10-15
 
 */
@class ksyAudioMixer;
@interface KSYStreamerBase : NSObject
/**
 @abstract   获取SDK版本号
 */
- (NSString*) getKSYVersion;

#pragma mark - configures
 /**
 @abstract   rtmp主机地址
 @discussion 将音视频流推向该主机

	eg: rtmp://xxx.xxx.xxx.xxx/appname/streamKey
 */
@property (nonatomic, readonly) NSURL*      hostURL;

/**
 @abstract   视频帧率 默认:15
 @discussion 请保持调用 processVideoSampleBuffer 或 processVideoPixelBuffer 的频率与此设置的帧率一致
 @discussion video frame per seconds 有效范围[1~30], 超出会提示参数错误
 */
@property (nonatomic, assign) int           videoFPS;

/**
 @abstract   视频编码器 默认为264软编码
 @discussion video codec used for encode
 @see        KSYVideoCodec
 */
@property (nonatomic, assign) KSYVideoCodec videoCodec;

/**
 @abstract   音频编码器 (默认为AAC-HE)
 @discussion audio codec used for encode
 @see        KSYAudioCodec
 */
@property (nonatomic, assign) KSYAudioCodec audioCodec;

/**
 @abstract   视频编码起始码率（单位:kbps, 默认:500）
 @discussion 开始推流时的视频码率，开始推流后，根据网络情况在 [Min, Max]范围内调节
 @discussion 视频码率上调则画面更清晰，下调则画面更模糊
 @see videoMaxBitrate, videoMinBitrate
 */
@property (nonatomic, assign) int          videoInitBitrate;   // kbit/s of video
/**
 @abstract   视频编码最高码率（单位:kbps, 默认:800）
 @discussion 视频码率自适应调整的上限, 为目标码率
 @see videoInitBitrate, videoMinBitrate
 */
@property (nonatomic, assign) int          videoMaxBitrate;   // kbit/s of video
/**
 @abstract   视频编码最低码率（单位:kbps, 默认:200）
 @discussion 视频码率自适应调整的下限
 @see videoInitBitrate, videoMaxBitrate
 */
@property (nonatomic, assign) int          videoMinBitrate;   // kbit/s of video
/**
 @abstract   最大关键帧间隔（单位:秒, 默认:3）
 @discussion 即GOP长度 画面静止时,隔n秒插入一个关键帧
 */
@property (nonatomic, assign) float          maxKeyInterval;   // seconds
/**
 @abstract   音频编码码率（单位:kbps）
 @discussion 音频目标编码码率 (比如48,96,128等)
 */
@property (nonatomic, assign) int          audiokBPS;   // kbit/s of audio
/**
 @abstract   启用自动调整码率 默认开启
 @discussion 自动根据网络状况调整码率,开始预览前设置有效
 */
@property (nonatomic, assign) BOOL         enAutoApplyEstimateBW;

/**
 @abstract 是否处理视频的图像数据 (默认YES)
 */
@property (atomic, assign) BOOL          bWithVideo;

/**
 @abstract 是否处理音频数据 (默认YES)
 */
@property (atomic, assign) BOOL          bWithAudio;

#pragma mark - Status Notification

/**
 @abstract 当前推流状况
 @discussion 可以通过该属性获取推流会话的工作状况
 
 @discussion 通知：
 * KSYStreamStateDidChangeNotification 当推流工作状态发生变化时提供通知
 * 收到通知后，通过本属性查询新的状态，并作出相应的动作
 */
@property (nonatomic, readonly) KSYStreamState streamState;

/**
 @abstract   获取推流状态对应的字符串
 */
- (NSString*) getStreamStateName : (KSYStreamState) stat;

/**
 @abstract   获取当前推流状态对应的字符串
 */
- (NSString*) getCurStreamStateName;

/**
 @abstract   当前推流的错误码
 @discussion 可以通过该属性获取推流失败的原因
 
 @discussion 当streamState 为KSYStreamStateError时可查询
 @discussion KSYStreamErrorCode_KSYAUTHFAILED 除外
 @discussion 在streamState 为KSYStreamStateConnected 时查询到
 @discussion 状态变化后清0
 @see streamState
 */
@property (nonatomic, readonly) KSYStreamErrorCode streamErrorCode;

/**
 @abstract   获取错误码对应的字符串
 */
- (NSString*) getKSYStreamErrorCodeName:(KSYStreamErrorCode)code;

/**
 @abstract   获取当前错误码对应的字符串
 */
- (NSString*) getCurKSYStreamErrorCodeName;

/**
 @abstract   当前推流的网络事件
 @discussion 可以通过该属性查询网络状况
 
 @discussion 通知：
 * KSYNetStateEventNotification 当检测到网络发生特定事件时SDK发出通知
 * 收到通知后，通过本属性查询具体事件类型
 @see KSYNetStateEventNotification
 */
@property (nonatomic, readonly) KSYNetStateCode netStateCode;


// Posted when stream state changes
FOUNDATION_EXPORT NSString *const KSYStreamStateDidChangeNotification NS_AVAILABLE_IOS(7_0);
// Posted when there is an net state event
FOUNDATION_EXPORT NSString *const KSYNetStateEventNotification NS_AVAILABLE_IOS(7_0);

#pragma mark - methods
/**
 @abstract 初始化方法 （step1）
 @discussion 初始化，将下列属性设置为默认值

 * _videoFPS         = 15;
 * _videoCodec       = KSYVideoCodec_X264;
 * _audiokBPS        = 32;
 * _videoInitBitrate = 500;
 * _videoMaxBitrate  = 800;
 * _videoMinBitrate  = 200;

 @warning KSYStreamerBase只支持单实例推流，构造多个实例会出现异常
 */
- (instancetype) initWithDefaultCfg;

/**
 @abstract 启动推流 （step2）
 @param      hostURL    rtmp 服务器地址 “rtmp://xxx.xxx.xxx.xxx/appname/streamKey"
 @discussion 设置完成推流参数之后，将媒体流推送到 publishURL 对应的地址
 @discussion 推流参数主要是视频编码器，音视频码率的设置
 @warning    开始推流前，需要保证按照采集的频率，持续通过 processVideoSampleBuffer 和 processAudioSampleBuffer 送入音视频数据，否则推流失败

 @see hostURL, videoCodec,videokBPS,audiokBPS
 */
- (void) startStream: (NSURL*)     hostURL;

/**
 @abstract 停止推流 （step3）
 @discussion 断开网络连接，停止视频编码
 */
- (void) stopStream;

/**
 @abstract  处理一个视频帧
 @param sampleBuffer Buffer to process
 @discussion 应当在开始推流前定期调用此接口，比如按照采集帧率调用
 */
- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 @abstract  处理一个视频帧
 @param pixelBuffer 待编码的像素数据
 @param timeStamp   待编码的时间戳
 @discussion 应当在开始推流前定期调用此接口，比如按照采集帧率调用
 */
- (void)processVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer
                       timeInfo:(CMTime)timeStamp;

/**
 @abstract 处理一段音频数据
 @param sampleBuffer Buffer to process
 @discussion 应当在开始推流前定期调用此接口，与processVideoSampleBuffer 交错进行
 @warning    目前只支持 单通道  S16 格式的PCM数据
 */
- (void)processAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

#pragma mark - Status property
/**
 @abstract   当前推流的事件ID
 @discussion md5(hostURL+timestamp) 对本次推流活动的标识
 @discussion timestamp 为建立连接时的事件戳
 
 @see hostURL
 */
@property (nonatomic, readonly) NSString *streamID;

/**
 @abstract   查询当前是否处于推流状态 (建立连接中, 或连接中)
 @see
 */
-(BOOL) isStreaming;

/**
 @abstract   当前编码的视频码率大小（每秒更新）
 @discussion 该码率为编码器产生的视频码率大小，单位为kbps
 
 @see videoMaxBitrate
 */
@property (nonatomic, readonly) double encodeVKbps;

/**
 @abstract   当前编码的音频码率大小（每秒更新）
 @discussion 该码率为编码器产生的音频码率大小，单位为kbps
 
 @see audiokBPS
 */
@property (nonatomic, readonly) double encodeAKbps;

/**
 @abstract   获取本次推流发送的流量大小
 @discussion 从开始推流到现在，发送出去的数据字节数，单位为KByte
 */
@property (nonatomic, readonly) int uploadedKByte;

/**
 @abstract   获取当前编码的平均视频帧率
 @discussion 采集设备的输出帧率为videoFPS，约等于编码的目标帧率
 @discussion 编码的视频帧率不会高于采集帧率，但是当CPU资源不足时，编码帧率会低于采集帧率
 
 @see videoFPS
 */
@property (nonatomic, readonly) double encodingFPS;

/**
 @abstract   获取本次推流编码的视频总帧数
 @discussion 从开始推流到现在，编码过的视频总帧数
 
 */
@property (nonatomic, readonly) int encodedFrames;

/**
 @abstract   获取本次推流发送的丢帧数量
 @discussion 这里是指编码后，由于网络发送阻塞导致丢弃的帧数
 
 */
@property (nonatomic, readonly) int droppedVideoFrames;

/**
 @abstract 当前推流的rtmp服务器的主机IP
 @discussion 开始推流之后获取才为有效IP, 之前为空字符串
 
 */
@property (atomic, readonly) NSString* rtmpHostIP;

/**
 @abstract  静音推流
 @param     bMute YES / ON
 */
- (void) muteStreame:(BOOL) bMute;

/* [此调用无效]
  @abstract 启/停混响 Reverberation
  @param  Reverberation level: 取值范围为[0~4]
  @discussion level取值为0表示关闭
              [1~4]分别为不同效果
*/
- (void) enableReverb:(int) level;

#pragma mark - logblock
/**
 @abstract 收集网络相关状态的日志，默认开启
 @discussion 可开关
 */
@property (nonatomic, assign) BOOL shouldEnableKSYStatModule;

/**
 @abstract 获取Streamer中与网络相关的日志
 @discussion 相关字段说明请联系金山云技术支持
 */
@property (nonatomic, copy)void (^logBlock)(NSString *logJson);

#pragma mark - snapshot
/**
 @abstract 截图功能，目前只支持jpg格式
 @param    设置图像的压缩比例
 @param    图片的文件名
 */
- (void) takePhotoWithQuality:(CGFloat)jpegCompressionQuality
                     fileName:(NSString *)filename;

/**
 @abstract 获取当前编码的截图
 @param    通过完成代码块获取到截图完成的图像
 */
- (void) getSnapshotWithCompletion:(void (^)(UIImage*))completion;

@end
