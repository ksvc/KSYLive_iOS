//
//  KSYClipWriter.h
//  KSYLiveDemo
//
//  Created by iVermisseDich on 2017/4/7.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "KSYTypeDef.h"

/**
 金山云转码SDK iOS版提供了iOS移动设备上的转码合成功能
 
 * 音频编码采用AAC编码，码率可配置;
 * 视频频编码采用H.264、H.265编码，码率可配置;
 * 支持写入本地flv和mp4文件;
 
 __Found__: 2017-4-7
 
 */
@interface KSYClipWriter : NSObject
/**
 @abstract   获取SDK版本号
 */
- (NSString*) getKSYVersion;

#pragma mark - configures
/**
 @abstract   本地录制,输出路径
 @discussion 将音视频流写入本地文件  
 eg: /var/xxxxx/xxx.mp4  /var/xxxxx/xxx.flv
 */
@property (nonatomic, readonly) NSURL *hostURL;

/**
 @abstract   视频帧率
 @discussion 本地录制的视频帧率，开启编码前丢帧时，帧率生效
 @discussion 编码前丢帧shouldEnableKSYDropModule为YES时，帧率设置生效
 @discussion 编码前丢帧shouldEnableKSYDropModule为NO时，帧率保持与输入帧率一致
 */
@property (nonatomic, assign) int videoFPS;

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
 @abstract   视频编码码率（单位:kbps, 默认:500）
 */
@property (nonatomic, assign) int videoInitBitrate;   // kbit/s of video


/**
 @abstract   写入全局附带的metadata (默认为nil)
 @discussion key 一定要是 NSString* 类型的
 */
@property(atomic, copy) NSDictionary * streamMetaData;

/**
 @abstract   视频流附带的metadata (默认为nil)
 @discussion key 一定要是 NSString* 类型的; 目前有效
 */
@property(atomic, copy) NSDictionary * videoMetaData;

/**
 @abstract   最大关键帧间隔（单位:秒, 默认:3）
 @discussion 即GOP长度 画面静止时,隔n秒插入一个关键帧
 */
@property (nonatomic, assign) float maxKeyInterval;   // seconds
/**
 @abstract   音频编码码率（单位:kbps）
 @discussion 音频目标编码码率 (比如48,96,128等)
 */
@property (nonatomic, assign) int audiokBPS;   // kbit/s of audio

/**
 @abstract   待编码的视频场景 (默认为KSYLiveScene_Default)
 @discussion KSY内部会根据场景的特征进行参数调优,开始录制前设置有效
 */
@property (nonatomic, assign) KSYLiveScene liveScene;

/**
 @abstract   本次录制的目标场景 (默认为KSYRecScene_ConstantBitRate)
 @discussion 用于指定录制时, 视频编码器码率控制的优先目标
 @discussion 恒定码率: 最后视频文件的码率更平稳,但复杂场景质量可能差一些
 @discussion 恒定质量: 最后视频文件的质量更平稳写, 但码率波动要大一些
 @discussion 开始录制前设置有效,
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
 @abstract   是否处理视频的图像数据 (默认YES)
 @warning    启动合成前设置为NO, 则在转码过程中无法再开启图像
 @discussion 启动合成前设置为NO, 写入过程中修改本属性无效
 */
@property (nonatomic, assign) BOOL bWithVideo;

/**
 @abstract   是否处理音频数据 (默认YES)
 */
@property (nonatomic, assign) BOOL bWithAudio;

/**
 @abstract   mp4文件允许快速启动 (默认YES)
 @discussion mp4格式的文件中将moov等index信息放到文件开头
 @warning    启用此开关会在结束是对文件进行处理, 如果要长时间录制,请关闭本选项
 */
@property (nonatomic, assign) BOOL mp4FastStart;

#pragma mark - Status Notification

/**
 @abstract   当前写入状态
 @discussion 可以通过该属性获取写入的工作状态
 
 @discussion 通知：
 * KSYStreamStateDidChangeNotification 当写入工作状态发生变化时提供通知
 * 收到通知后，通过本属性查询新的状态，并作出相应的动作
 */
@property (nonatomic, readonly) KSYStreamState writeState;

/**
 @abstract   获取写入状态对应的字符串
 @param      stat 状态码
 @return     状态名称
 */
- (NSString *)getWriteStateName:(KSYStreamState)stat;

/**
 @abstract   获取当前写入状态对应的字符串
 @return     当前状态名称
 */
- (NSString *)getCurWriteStateName;

/**
 @abstract   当前转码/写入的错误码
 @discussion 可以通过该属性获取写入失败的原因
 
 @discussion 当streamState 为KSYStreamStateError时可查询
 @discussion KSYStreamErrorCode_KSYAUTHFAILED 除外
 @discussion 在streamState 为KSYStreamStateConnected 时查询到
 @discussion 状态变化后清0
 @see streamState
 */
@property (nonatomic, readonly) KSYStreamErrorCode streamErrorCode;

/**
 @abstract   数据流写入状态变化时的回调函数
 @discussion 参数为新状态
 */
@property (nonatomic, copy) void(^writeStateChange)(KSYStreamState newState);

/**
 @abstract   获取错误码对应的字符串
 @param      code 错误码
 */
- (NSString *)getKSYWriteErrorCodeName:(KSYStreamErrorCode)code;

/**
 @abstract   获取当前错误码对应的字符串
 */
- (NSString *)getCurKSYWriteErrorCodeName;

/**
 @abstract   帧率应发生变化时的回调函数
 @discussion 参数为建议设定的fps
 */
@property (nonatomic, copy)void (^videoFPSChange)(int32_t newVideoFPS);

// Posted when stream state changes
FOUNDATION_EXPORT NSString *const KSYWriteStateDidChangeNotification NS_AVAILABLE_IOS(7_0);

#pragma mark - methods
/**
 @abstract 初始化方法 （step1）
 @discussion 初始化，将下列属性设置为默认值
 
 * _videoFPS         = 15;
 * _videoCodec       = KSYVideoCodec_AUTO;
 * _audiokBPS        = 32;
 * _videoInitBitrate = 500;
 
 @warning KSYClipWriter只支持单实例写入，构造多个实例会出现异常
 */
- (instancetype)initWithDefaultCfg;

/**
 @abstract   启动写入文件 （step2）
 @discussion 本地写入支持mp4和flv两种输出格式,通过url的文件后缀指定
 @discussion "/var/xxx/xx.mp4", "/var/xxx/xx.flv"
 @discussion 写入参数主要是视频编码器，音视频码率的设置
 @see        hostURL, videoCodec,videokBPS,audiokBPS
 */
- (void)startWritingWith:(NSURL *)url;

/**
 @abstract   停止写入 （step3）
 @discussion 停止文件写入
 */

- (void)stopWriting;
/**
 @abstract   停止写入 （step3）
 @discussion 停止文件写入
 @param complete 完成回调
 */
- (void)stopWriting:(void(^)())complete;

/**
 @abstract   静音 (仍然有音频，只是音量为0)
 @param      bMute YES / ON
 */
- (void)muteStream:(BOOL)bMute;

/**
 @abstract   处理一个视频帧(只支持编码前的原始图像数据)
 
 @param sampleBuffer Buffer to process
 @param completion 当前视频帧处理完成的回调
 
 @discussion 应当在开始写入前定期调用此接口，比如按照采集帧率调用
 @discussion 支持的图像格式包括: BGR0,NV12,YUVA444P,YUV420P
 */
- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
                      onComplete:(void (^)(BOOL))completion;

/**
 @abstract   处理一个视频帧(只支持编码前的原始图像数据)
 
 @param pixelBuffer 待编码的像素数据
 @param timeStamp   待编码的时间戳
 @param completion  当前视频帧处理完成的回调
 
 @discussion 应当在开始写入前定期调用此接口，比如按照采集帧率调用
 @discussion 支持的图像格式包括: BGR0,NV12,YUVA444P,YUV420P
 */
- (void)processVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer
                       timeInfo:(CMTime)timeStamp
                     onComplete:(void (^)(BOOL))completion;

/**
 @abstract   处理一段音频数据
 
 @param sampleBuffer Buffer to process
 
 @discussion 应当在开始写入前定期调用此接口，与processVideoSampleBuffer 交错进行
 @warning    目前只支持 单通道  S16 格式的PCM数据
 */
- (void)processAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

#pragma mark - Status property
/**
 @abstract   查询当前是否处于写入状态 (connecting, 或connected)
 */
- (BOOL)isWriting;

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
 @abstract   查询当前编码的平均视频帧率
 @discussion 采集设备的输出帧率为videoFPS，约等于编码的目标帧率
 @discussion 编码的视频帧率不会高于采集帧率，但是当CPU资源不足时，编码帧率会低于采集帧率
 @see videoFPS
 */
@property (nonatomic, readonly) double encodingFPS;

/**
 @abstract   查询本次视频写入已经编码的总帧数
 @discussion 从开始写入到现在，编码过的视频总帧数
 */
@property (nonatomic, readonly) int encodedFrames;

#pragma mark - logblock

/**
 @abstract   clip writer
 @discussion 相关字段说明请联系金山云技术支持
 */
@property (nonatomic, copy)void (^logBlock)(NSString *logJson);

/**
 @abstract 是否允许编码前丢帧，默认开启（videoFPS生效）
 @warnning 离线转码需要输出所有帧的情况下开启，videoFPS将不生效，根据输入源的fps保持一致
 */
@property (nonatomic, assign) BOOL shouldEnableKSYDropModule;

@end

