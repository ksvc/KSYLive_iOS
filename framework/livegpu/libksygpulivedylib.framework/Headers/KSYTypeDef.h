//
//  KSYTypeDef.h
//  KSStreamer
//
//  Created by pengbin on 10/15/15.
//  Copyright © 2015 ksyun. All rights reserved.
//

#ifndef _KSYTypeDef_h_
#define _KSYTypeDef_h_

#pragma mark - Authorization

/// 设备授权状态
typedef NS_ENUM(NSUInteger, KSYDevAuthStatus) {
    /// 还没有确定是否授权
    KSYDevAuthStatusNotDetermined = 0,
    /// 设备受限，一般在家长模式下设备会受限
    KSYDevAuthStatusRestricted,
    /// 拒绝授权
    KSYDevAuthStatusDenied,
    /// 已授权
    KSYDevAuthStatusAuthorized
};

#pragma mark - Video Dimension

/// 采集分辨率
typedef NS_ENUM(NSUInteger, KSYVideoDimension) {
    /// 16 : 9 宽高比，1280 x 720 分辨率
    KSYVideoDimension_16_9__1280x720 = 0,
    /// 16 : 9 宽高比，960 x 540 分辨率
    KSYVideoDimension_16_9__960x540,
    /// 4 : 3 宽高比，640 x 480 分辨率
    KSYVideoDimension_4_3__640x480,
    /// 16 : 9 宽高比，640 x 360 分辨率
    KSYVideoDimension_16_9__640x360,
    /// 4 : 3 宽高比，320 x 240 分辨率
    KSYVideoDimension_5_4__352x288,
    
    /// 缩放自定义分辨率 从设备支持的最近分辨率缩放获得, 若设备没有对应宽高比的分辨率，则裁剪后进行缩放
    KSYVideoDimension_UserDefine_Scale,
    /// 裁剪自定义分辨率 从设备支持的最近分辨率裁剪获得
    KSYVideoDimension_UserDefine_Crop,
    /// 注意： 选择缩放自定义分辨率时可能会有额外CPU代价
    
    /// 默认分辨率，默认为 4 : 3 宽高比，640 x 480 分辨率
    KSYVideoDimension_Default = KSYVideoDimension_4_3__640x480,
};

#pragma mark - Video & Audio Codec ID
/*!
 * @abstract  视频编码器类型
 */
typedef NS_ENUM(NSUInteger, KSYVideoCodec) {
    /// 视频编码器 - h264 软件编码器
    KSYVideoCodec_X264 = 0,
    /// 视频编码器 - KSY265 软件编码器
    KSYVideoCodec_QY265,
    /// 视频编码器 - iOS VT264硬件编码器 (iOS 8.0以上支持)
    KSYVideoCodec_VT264,
    /// 视频编码器 - 由SDK自动选择（ VT264 > X264）
    KSYVideoCodec_AUTO = 100,
};

/*!
 * @abstract  音频编码器类型
 */
typedef NS_ENUM(NSUInteger, KSYAudioCodec) {
    /// 音频编码器 - AAC
    KSYAudioCodec_AAC = 0,
    /// 音频编码器 - AAC_HE
    KSYAudioCodec_AAC_HE,
};

#pragma mark - QYPublisher State

/*!
 * @abstract  采集设备状态
 */
typedef NS_ENUM(NSUInteger, KSYCaptureState) {
    /// 设备空闲中
    KSYCaptureStateIdle,
    /// 设备工作中
    KSYCaptureStateCapturing,
    /// 设备授权被拒绝
    KSYCaptureStateDevAuthDenied,
    /// 关闭采集设备中
    KSYCaptureStateClosingCapture,
    /// 参数错误，无法打开（比如设置的分辨率，码率当前设备不支持）
    KSYCaptureStateParameterError,
    /// 设备正忙，请稍后尝试 ( 该状态在发出通知0.5秒后被清除 ）
    KSYCaptureStateDevBusy,
};

/*!
 * @abstract  推流状态
 */
typedef NS_ENUM(NSUInteger, KSYStreamState) {
    /// 初始化时状态为空闲
    KSYStreamStateIdle = 0,
    /// 连接中
    KSYStreamStateConnecting,
    /// 已连接
    KSYStreamStateConnected,
    /// 断开连接中
    KSYStreamStateDisconnecting,
    /// 推流出错
    KSYStreamStateError,
};

/*!
 * @abstract  推流错误码，用于指示推流失败的原因
 */
typedef NS_ENUM(NSUInteger, KSYStreamErrorCode) {
    /// 正常无错误
    KSYStreamErrorCode_NONE = 0,
    /// SDK 鉴权失败 (暂时正常推流5~8分钟后终止推流)
    KSYStreamErrorCode_KSYAUTHFAILED,
    /// 当前帧编码失败
    KSYStreamErrorCode_ENCODE_FRAMES_FAILED,
    /// 无法打开配置指示的CODEC
    KSYStreamErrorCode_CODEC_OPEN_FAILED,
    /// 连接出错，检查地址
    KSYStreamErrorCode_CONNECT_FAILED,
    /// 网络连接中断
    KSYStreamErrorCode_CONNECT_BREAK,
    /// rtmp 推流域名不存在 (KSY 自定义)
    KSYStreamErrorCode_RTMP_NonExistDomain,
    /// rtmp 应用名不存在(KSY 自定义)
    KSYStreamErrorCode_RTMP_NonExistApplication,
    /// rtmp 流名已存在(KSY 自定义)
    KSYStreamErrorCode_RTMP_AlreadyExistStreamName,
    /// rtmp 被黑名单拒绝(KSY 自定义)
    KSYStreamErrorCode_RTMP_ForbiddenByBlacklist,
    /// rtmp 内部错误(KSY 自定义)
    KSYStreamErrorCode_RTMP_InternalError,
    /// rtmp URL 地址已过期(KSY 自定义)
    KSYStreamErrorCode_RTMP_URLExpired,
    /// rtmp URL 地址签名错误(KSY 自定义)
    KSYStreamErrorCode_RTMP_SignatureDoesNotMatch,
    /// rtmp URL 中AccessKeyId非法(KSY 自定义)
    KSYStreamErrorCode_RTMP_InvalidAccessKeyId,
    /// rtmp URL 中参数错误(KSY 自定义)
    KSYStreamErrorCode_RTMP_BadParams,
    /// rtmp URL 中的推流不在发布点内（KSY 自定义）
    KSYStreamErrorCode_RTMP_ForbiddenByRegion,
    /// SDK 因为鉴权失败停止推流
    KSYStreamErrorCode_FRAMES_THRESHOLD,
    /// 没有输入的数据，无法开始推流
    KSYStreamErrorCode_NO_INPUT_SAMPLE,
    /// 对于URL中的域名解析失败
    KSYStreamErrorCode_DNS_Parse_failed,
    /// 对于URL对应的服务器连接失败(无法建立TCP连接)
    KSYStreamErrorCode_Connect_Server_failed,
    /// 跟RTMP服务器完成握手后,向{appname}/{streamname} 推流失败
    KSYStreamErrorCode_RTMP_Publish_failed,
};

/*!
 * @abstract  网络状况事件码，用于指示当前网络健康状况
 */
typedef NS_ENUM(NSUInteger, KSYNetStateCode) {
    /// 正常无错误
    KSYNetStateCode_NONE = 0,
    /// 发送包时间过长，( 单次发送超过 500毫秒 ）
    KSYNetStateCode_SEND_PACKET_SLOW,
    /// 估计带宽调整，上调
    KSYNetStateCode_EST_BW_RAISE,
    /// 估计带宽调整，下调
    KSYNetStateCode_EST_BW_DROP,
    /// SDK 鉴权失败 (暂时正常推流5~8分钟后终止推流)
    KSYNetStateCode_KSYAUTHFAILED,
    /// 输入音频不连续
    KSYNetStateCode_IN_AUDIO_DISCONTINUOUS,
};

/*!
 * @abstract  音频播放状态
 */
typedef NS_ENUM(NSUInteger, KSYBgmPlayerState) {
    /// 初始状态
    KSYBgmPlayerStateInit,
    /// 背景音正在播放
    KSYBgmPlayerStateStarting,
    /// 背景音停止
    KSYBgmPlayerStateStopped,
    /// 背景音正在播放
    KSYBgmPlayerStatePlaying,
    /// 背景音暂停
    KSYBgmPlayerStatePaused,
    /// 背景音播放出错
    KSYBgmPlayerStateError,
    /// 背景音被打断
    KSYBgmPlayerStateInterrupted
};


/*!
 * @abstract  音频输入设备类型
 * @see AVAudioSessionPortBuiltInMic
 */
typedef NS_ENUM(NSUInteger, KSYMicType) {
    /// Built-in microphone on an iOS device
    KSYMicType_builtinMic = 0,
    /// Microphone on a wired headset
    KSYMicType_headsetMic,
    /// 蓝牙设备
    KSYMicType_bluetoothMic,
    
    /// 未知设备
    KSYMicType_unknow = -1,
};

#pragma mark - KSY_EXTERN
#ifndef KSY_EXTERN
#ifdef __cplusplus
#define KSY_EXTERN     extern "C" __attribute__((visibility ("default")))
#else
#define KSY_EXTERN     extern __attribute__((visibility ("default")))
#endif
#endif

#endif
