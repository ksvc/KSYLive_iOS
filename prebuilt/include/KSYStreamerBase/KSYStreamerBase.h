//
//  KSYStreamerBase.h
//  KSYStreamer
//
//  Created by pengbin on 10/15/15.
//  Copyright © 2015 ksyun. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "KSYTypeDef.h"
@class KSYReachability;
/**
 金山云直播推流SDK iOS版提供了iOS移动设备上的推流功能

 * 音频编码采用AAC编码，码率可配置;
 * 视频频编码采用H.264编码，码率可配置;
 * 支持 RTMP 协议直播推流;
 * 支持写入本地flv和mp4文件;
 * 支持推流同时旁路录像功能;
 
 __Found__: 2015-10-15
 
 */
@interface KSYStreamerBase : NSObject
/**
 @abstract   获取SDK版本号
 */
- (NSString*) getKSYVersion;

#pragma mark - configures
/**
 @abstract   直播推流时为rtmp主机地址; 本地文件录制时,为输出文件路径
 @discussion 直播时将音视频流推向该主机或写入本地文件

	eg: rtmp://xxx.xxx.xxx.xxx/appname/streamKey
    eg: /var/xxxxx/xxx.mp4  /var/xxxxx/xxx.flv
 */
@property (nonatomic, readonly) NSURL*      hostURL;

/**
 @abstract   视频帧率 默认:15
 @discussion 请保持调用 processVideoSampleBuffer 或 processVideoPixelBuffer 的频率与此设置的帧率一致
 @discussion 当实际送入的视频帧率过高时会主动丢帧
 @discussion video frame per seconds 有效范围[1~30], 超出会提示参数错误
 */
@property (nonatomic, assign) int           videoFPS;

/**
 @abstract   视频帧率最小值，默认与videoFPS相同
 @discussion video frame per seconds 有效范围[1~30], 超出会提示参数错误
 @discussion 不设置该值时表示网络自适应不使用动态帧率
 */
@property (nonatomic, assign) int           videoMinFPS;

/**
 @abstract   视频帧率最大值，默认与videoFPS相同
 @discussion video frame per seconds 有效范围[1~30], 超出会提示参数错误
 @discussion 不设置该值时表示网络自适应不使用动态帧率
 */
@property (nonatomic, assign) int           videoMaxFPS;

/**
 @abstract   视频编码器 默认为 自动选择
 @discussion video codec used for encode
 @discussion 修改此选项会导致videoEncodePerf值变化
 @discussion 如果需要定制编码档次, 请在修改videoCodec之后再测设置
 @see        KSYVideoCodec,videoEncodePerf
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
 @discussion 开始推流时的视频码率，开始推流后，根据网络情况在Min~Max范围内调节
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
 @abstract  推流全局附带的metadata (默认为nil)
 @discussion key 一定要是 NSString* 类型的
 */
@property(atomic, copy) NSDictionary * streamMetaData;

/**
 @abstract  视频流附带的metadata (默认为nil)
 @discussion key 一定要是 NSString* 类型的; 目前有效
 */
@property(atomic, copy) NSDictionary * videoMetaData;

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
@abstract   带宽估计模式
@discussion 带宽估计的策略选择 (开始推流前设置有效)
*/
@property (nonatomic, assign) KSYBWEstimateMode bwEstimateMode;

/**
 @abstract   本次直播的目标场景 (默认为KSYLiveScene_Default)
 @discussion KSY内部会根据场景的特征进行参数调优,开始推流前设置有效
 */
@property (nonatomic, assign) KSYLiveScene              liveScene;

/**
 @abstract   本次录制的目标场景 (默认为KSYRecScene_ConstantBitRate)
 @discussion 用于指定录制时, 视频编码器码率控制的优先目标
 @discussion 恒定码率: 最后视频文件的码率更平稳,但复杂场景质量可能差一些
 @discussion 恒定质量: 最后视频文件的质量更平稳写, 但码率波动要大一些
 @discussion 开始录制前设置有效, 录制本地文件时有效, 直播不建议修改
 */
@property (nonatomic, assign) KSYRecScene              recScene;

/**
 @abstract   质量等级（默认:20）
 @discussion 视频恒定质量等级，范围0～51，值越小，质量越好
 @discussion 当 recScene 为 KSYRecScene_ConstantQuality, 且选择软编码器时有效
 */
@property (nonatomic, assign) int          videoCrf;

/**
 @abstract   视频编码性能档次
 @discussion 视频质量和设备资源之间的权衡,开始推流前, videoCodec设置之后,修改有效
 @discussion 选择软编码的默认为KSYVideoEncodePer_LowPower
 @discussion 选择Auto或硬编码的默认为KSYVideoEncodePer_HighPerformance
 */
@property (nonatomic, assign) KSYVideoEncodePerformance videoEncodePerf;

/**
 @abstract 是否处理视频的图像数据 (默认YES)
 @warning  如果在推流前设置为NO, 则在推流过程中无法再开启图像
 @discussion 启动推流前设置为NO, 推流过程中修改本属性无效
 */
@property (nonatomic, assign) BOOL          bWithVideo;

/**
 @abstract 是否处理音频数据 (默认YES)
 */
@property (nonatomic, assign) BOOL          bWithAudio;

/**
 @abstract 是否处理Message (默认YES)
 */
@property (nonatomic, assign)BOOL           bWithMessage;

/**
 @abstract cpu缩放比率,设置>0为按比例缩放，默认为0
 @warning  请在推流之前进行设置
 */
@property (nonatomic, assign)   float scaleRatio;


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
 @param      stat 状态码
 @return     状态名称
 */
- (NSString*) getStreamStateName : (KSYStreamState) stat;

/**
 @abstract   获取当前推流状态对应的字符串
 @return     当前状态名称
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
 @abstract   发生推流状态变化时的回调函数
 @discussion 参数为新状态
 */
@property (nonatomic, copy)void (^streamStateChange)(KSYStreamState newState);

/**
 @abstract   获取错误码对应的字符串
 @param      code 错误码
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
 @discussion KSYNetStateEventNotification
 */
@property (nonatomic, readonly) KSYNetStateCode netStateCode;

/**
 @abstract   帧率应发生变化时的回调函数
 @discussion 参数为建议设定的fps
 */
@property (nonatomic, copy)void (^videoFPSChange)(int32_t newVideoFPS);

// Posted when stream state changes
FOUNDATION_EXPORT NSString *const KSYStreamStateDidChangeNotification NS_AVAILABLE_IOS(7_0);
// Posted when there is an net state event
FOUNDATION_EXPORT NSString *const KSYNetStateEventNotification NS_AVAILABLE_IOS(7_0);

#pragma mark - methods
/**
 @abstract 初始化方法 （step1）
 @discussion 初始化，将下列属性设置为默认值

 * _videoFPS         = 15;
 * _videoCodec       = KSYVideoCodec_AUTO;
 * _audiokBPS        = 32;
 * _videoInitBitrate = 500;
 * _videoMaxBitrate  = 800;
 * _videoMinBitrate  = 200;

 @warning KSYStreamerBase只支持单实例推流，构造多个实例会出现异常
 */
- (instancetype) initWithDefaultCfg;

/**
 @abstract 启动推流 （step2）
 @param      url 目标地址
 @discussion 实现直播功能时, url为 rtmp 服务器地址 “rtmp://xxx.xx/appname/streamKey"
 @discussion 设置完成推流参数之后，将媒体流推送到 publishURL 对应的地址
 @discussion 实现本地录制功能时, url为本地文件地址 "/var/xxx/xx.mp4"
 @discussion 本地录制支持mp4和flv两种输出格式, 通过url的文件后缀指定
 @discussion 推流参数主要是视频编码器，音视频码率的设置
 @see hostURL, videoCodec,videokBPS,audiokBPS
 */
- (void) startStream: (NSURL*)     url;

/**
 @abstract 停止推流 （step3）
 @discussion 断开网络连接 或停止文件写入
 */
- (void) stopStream;

/**
 @abstract  静音推流 (仍然有音频输出发送, 只是音量为0)
 @param     bMute YES / ON
 */
- (void) muteStream:(BOOL) bMute;

/**
 @abstract  处理一个视频帧(只支持编码前的原始图像数据)
 @param sampleBuffer Buffer to process
 @discussion 应当在开始推流前定期调用此接口，比如按照采集帧率调用
 @discussion 支持的图像格式包括: BGR0,NV12,YUVA444P,YUV420P
 */
- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 @abstract  处理一个视频帧(只支持编码前的原始图像数据)
 @param sampleBuffer Buffer to process
 @param completion 当前视频帧处理完成的回调
 */
- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
                      onComplete:(void (^)(BOOL))completion;
/**
 @abstract  处理一个视频帧(只支持编码前的原始图像数据)
 @param pixelBuffer 待编码的像素数据
 @param timeStamp   待编码的时间戳
 @discussion 应当在开始推流前定期调用此接口，比如按照采集帧率调用
 @discussion 支持的图像格式包括: BGR0,NV12,YUVA444P,YUV420P
 */
- (void)processVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer
                       timeInfo:(CMTime)timeStamp;
/**
 @abstract  处理一个视频帧(只支持编码前的原始图像数据)
 @param pixelBuffer 待编码的像素数据
 @param timeStamp   待编码的时间戳
 @param completion 当前视频帧处理完成的回调
 */
- (void)processVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer
                       timeInfo:(CMTime)timeStamp
                     onComplete:(void (^)(BOOL))completion;

/**
 @abstract 处理一段音频数据
 @param sampleBuffer Buffer to process
 @discussion 应当在开始推流前定期调用此接口，与processVideoSampleBuffer 交错进行
 @warning    目前只支持 S16 格式的PCM数据
 */
- (void)processAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 @abstract  处理一段音频数据
 @param     pData 原始数据指针数组
 @param     len   数据的长度，单位为字节
 @param     fmt   原始数据的格式 (必须保证一次推流过程中数据格式不变)
 @param     pts   原始数据的时间戳
 */
- (void)processAudioData:(uint8_t**)pData
                nbSample:(int)len
              withFormat:(const AudioStreamBasicDescription*)fmt
                timeinfo:(CMTime*)pts;

/**
 @abstract 处理一个消息
 @param message message to process
 @discussion 开始推流后发生相应事件时调用此接口
 @warning
 */
- (void)processMessageData:(NSDictionary *)messageData;

#pragma mark - Status property
/**
 @abstract 获取当前用户的ak
 @warnning 默认是空的，只有在需要鉴权时，才能获取到
 */
@property (nonatomic, assign) NSString *clientAk;

/**
 @abstract 获取当前SDK过期时间
 @discussion 为nil时,可以永久使用不会过期
 @warnning sdk自行解析得到, 外部赋值无效
 */
@property (nonatomic, assign) NSDate *expireDate;

/**
 @abstract   查询当前推流的事件ID
 @discussion md5(hostURL+timestamp) 对本次推流活动的标识
 @discussion timestamp 为建立连接时的事件戳
 @see hostURL
 */
@property (nonatomic, readonly) NSString *streamID;

/**
 @abstract   查询当前是否处于推流状态 (建立连接中, 或连接中)
 */
- (BOOL) isStreaming;

/**
 @abstract   查询当前编码的视频码率大小（每秒更新）
 @discussion 该码率为编码器产生的视频码率大小，单位为kbps
 @see videoMaxBitrate
 */
@property (nonatomic, readonly) double encodeVKbps;

/**
 @abstract   查询当前编码的音频码率大小（每秒更新）
 @discussion 该码率为编码器产生的音频码率大小，单位为kbps
 @see audiokBPS
 */
@property (nonatomic, readonly) double encodeAKbps;

/**
 @abstract   查询本次推流发送的流量大小 (仅推流时有效)
 @discussion 从开始推流到现在，发送出去的数据字节数，单位为KByte
 */
@property (nonatomic, readonly) int uploadedKByte;

/**
 @abstract   查询当前上传的码率大小 (每秒更新)
 @discussion 该码率为实际上传的速度, 也就是每秒上传的字节数，单位为kbps
 */
@property (nonatomic, readonly) double currentUploadingKbps;

/**
 @abstract   查询当前编码的平均视频帧率
 @discussion 采集设备的输出帧率为videoFPS，约等于编码的目标帧率
 @discussion 编码的视频帧率不会高于采集帧率，但是当CPU资源不足时，编码帧率会低于采集帧率
 @see videoFPS
 */
@property (nonatomic, readonly) double encodingFPS;

/**
 @abstract   查询本次推流编码的视频总帧数
 @discussion 从开始推流到现在，编码过的视频总帧数
 */
@property (nonatomic, readonly) int encodedFrames;

/**
 @abstract   查询本次推流发送的丢帧数量
 @discussion 这里是指编码后，由于网络发送阻塞导致丢弃的帧数
 */
@property (nonatomic, readonly) int droppedVideoFrames;

/**
 @abstract 推流的qos信息
 @discussion 在推流过程中，查询当前推流qos信息
 */
@property (nonatomic, readonly) KSYStreamerQosInfo *qosInfo;

/**
 @abstract 查询当前推流的rtmp服务器的主机IP
 @discussion 开始推流之后获取才为有效IP, 之前为空字符串
 */
@property (atomic, readonly) NSString* rtmpHostIP;

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
 @param    jpegCompressionQuality 设置图像的压缩比例
 @param    filename 图片的文件名
 */
- (void) takePhotoWithQuality:(CGFloat)jpegCompressionQuality
                     fileName:(NSString *)filename;

/**
 @abstract 获取当前编码的截图
 @param    completion 通过完成代码块获取到截图完成的图像
 */
- (void) getSnapshotWithCompletion:(void (^)(UIImage*))completion;

#pragma mark - record
/**
 @abstract   旁路录像地址
 @discussion 开始录像后, 将直播的内容同步存储一份到本地文件
 eg: /private/var/mobile/Containers/Data/Application/APPID/tmp/test.mp4
 @discussion 如果只要存储本地文件,请继续使用原来的startStream接口
 @see hostURL, startStream
 */
@property (nonatomic, readonly) NSURL* bypassRecordURL;

/**
 @abstract   mp4文件允许快速启动 (默认NO)
 @discussion mp4格式的文件中将moov等index信息放到文件开头
 @discussion 开始录制前设置有效
 @warning    启用此开关会在结束是对文件进行处理, 如果要长时间录制,请关闭本选项
 */
@property (nonatomic, assign) BOOL bypassMp4FastStart;

/**
 @abstract 启动旁路录像
 @param      url    本地录像文件地址:/private/var/..../test.mp4
 @return     是否能尝试启动写入, 不能表明真正开始录像了,真正开始请确认bypassRecordState的值
 @discussion 启动推流后才能开始写入文件
 @discussion 文件中的内容和直播内容完全一致
 @see bypassRecordURL,stopBypassRecord, bypassRecordState
 */
- (BOOL) startBypassRecord: (NSURL*) url;

/**
 @abstract 停止旁路录像
 */
- (void) stopBypassRecord;

/** 旁路录像的文件时长 */
@property (nonatomic, readonly) double bypassRecordDuration;

/** 旁路录像的状态 */
@property (nonatomic, readonly) KSYRecordState bypassRecordState;

/** 旁路录像的错误码 */
@property (nonatomic, readonly) KSYRecordError bypassRecordErrorCode;

/** 旁路录像的错误名称 */
@property (nonatomic, readonly) NSString* bypassRecordErrorName;

/**
 @abstract   当旁路录制的状态变化时
 @discussion 只有设置 loop为NO时才有效, 在开始播放前设置有效
 */
@property(nonatomic, copy) void(^bypassRecordStateChange)(KSYRecordState recordState);

/**
 @abstract 是否允许编码前丢帧，默认开启
 @warnning 请勿在直播时使用，否则可能出现音视频不同步，仅在离线转码需要输出所有帧的情况下开启
 */
@property (nonatomic, assign) BOOL shouldEnableKSYDropModule;

//// 网络状态监控 (当SDK内部发现网络不可用时主动发出connet_break的错误码)
@property (nonatomic, readonly) KSYReachability* netReachability;

/**
 @abstract 是否能连通外网
 @discussion networkDetectURL为nil或未探测到结果前，该值为KSYNetReachState_Unknown
 */
@property (nonatomic, readonly) KSYNetReachState netReachState;

/**
 @abstract 用于检测网络连通性的地址，默认使用地址为“www.baidu.com”
 @discussion 用户可自定义地址，但不可设置无效地址，如果不清楚规则，建议使用默认值
 @discussion 设置为nil时，则关闭网络连通性的检测, netReachability为nil，netReachState为KSYNetReachState_Unknown
 @since Available in KSYLive_iOS 2.1.1 and later
 */
@property (nonatomic, readwrite) NSString* reachabilityDetectURL;
@end
