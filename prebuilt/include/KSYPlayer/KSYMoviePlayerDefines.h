//
//  KSYMoviePlayerDefine.h
//  KSYPlayerCore
//
//  Copyright © 2016 kingsoft. All rights reserved.
//

//----------------------------------------------
//Types

/**
 * 错误码
 */
typedef NS_ENUM(NSInteger, KSYMPErrorCode) {
    ///正常
	KSYMPOK                             = 0,
    ///未知错误
	KSYMPErrorCodeUnknownError          = 1,
    ///读写数据异常
	KSYMPErrorCodeFileIOError           = -1004,
    ///不支持的流媒体协议
	KSYMPErrorCodeUnsupportProtocol     = -10001,
	///DNS解析失败
    KSYMPErrorCodeDNSParseFailed        = -10002,
	///创建socket失败
    KSYMPErrorCodeCreateSocketFailed    = -10003,
	///连接服务器失败
    KSYMPErrorCodeConnectServerFailed   = -10004,
	///http请求返回400
    KSYMPErrorCodeBadRequest            = -10005,
	///http请求返回401
    KSYMPErrorCodeUnauthorizedClient    = -10006,
	///http请求返回403
    KSYMPErrorCodeAccessForbidden       = -10007,
	///http请求返回404
    KSYMPErrorCodeTargetNotFound        = -10008,
	///http请求返回4xx
    KSYMPErrorCodeOtherErrorCode        = -10009,
	///http请求返回5xx
    KSYMPErrorCodeServerException       = -10010,
	///无效的媒体数据
    KSYMPErrorCodeInvalidData           = -10011,
	///不支持的视频编码类型
    KSYMPErrorCodeUnsupportVideoCodec   = -10012,
	///不支持的音频编码类型
    KSYMPErrorCodeUnsupportAudioCodec   = -10013,
    ///视频解码失败
    KSYMPErrorCodeVideoDecodeFailed   	= -10014,
    ///音频解码失败
    KSYMPErrorCodeAudioDecodeFailed  	= -10015,
    ///次数过多的3xx跳转(8次)
    KSYMPErrorCode3xxOverFlow           = -10016,
    ///无效的url
    KSYMPErrorInvalidURL                = -10050,
    ///网络不通
    KSYMPErrorNetworkUnReachable        = -10051,
};

/**
 * status类型
 */
typedef NS_ENUM(NSInteger, MPMovieStatus) {
    ///视频解码出错
    MPMovieStatusVideoDecodeWrong,
    ///音频解码出错
    MPMovieStatusAudioDecodeWrong,
    ///使用硬件解码
    MPMovieStatusHWCodecUsed,
    ///使用软件解码
    MPMovieStatusSWCodecUsed,
    ///使用AVSampleBufferDisplayLayer解码渲染
    MPMovieStatusDLCodecUsed,
};

/**
 * 视频解码模式
 */
typedef NS_ENUM(NSUInteger, MPMovieVideoDecoderMode) {
    ///视频解码方式采用软解
    MPMovieVideoDecoderMode_Software = 0,
    ///视频解码方式采用硬解
    MPMovieVideoDecoderMode_Hardware,
    ///自动选择解码方式，8.0以上的系统优先选择硬解
    MPMovieVideoDecoderMode_AUTO,
    ///使用系统接口进行解码和渲染，只适用于8.0及以上系统，低于8.0的系统自动使用软解
    MPMovieVideoDecoderMode_DisplayLayer,
};

/**
 * reload模式
 */
typedef NS_ENUM(NSUInteger, MPMovieReloadMode) {
    ///加速播放模式
    MPMovieReloadMode_Fast,
    ///精确检测模式
    MPMovieReloadMode_Accurate,
};

/**
 * 视频反交错模式
 */
typedef NS_ENUM(NSUInteger, MPMovieVideoDeinterlaceMode) {
    ///关闭反交错
    MPMovieVideoDeinterlaceMode_None = 0,
    ///自动判断是否打开反交错
    MPMovieVideoDeinterlaceMode_Auto,
};

/**
 * 立体声平衡
 */
typedef NS_ENUM(NSInteger, MPMovieAudioPan) {
    ///完全左声道
    MPMovieAudioPan_Left = -1,
    ///左右声道平衡
    MPMovieAudioPan_Stereo,
    ///完全右声道
    MPMovieAudioPan_Right,
};

/**
 * Meta类型
 */
typedef NS_ENUM(NSInteger, MPMovieMetaType) {
    ///当前播放文件的Meta
    MPMovieMetaType_Media = 0,
    ///当前播放的视频Meta
    MPMovieMetaType_Video,
    ///当前播放的音频Meta
    MPMovieMetaType_Audio,
    ///当前播放的字幕Meta
    MPMovieMetaType_Subtitle,
};

//----------------------------------------------

/**
 * all notification
 */
// Posted when the prepared state changes of an object conforming to the MPMediaPlayback protocol changes.
// This supersedes MPMoviePlayerContentPreloadDidFinishNotification.
MP_EXTERN NSString *const MPMediaPlaybackIsPreparedToPlayDidChangeNotification;

// Posted when the playback state changes, either programatically or by the user.
MP_EXTERN NSString * const MPMoviePlayerPlaybackStateDidChangeNotification;

// Posted when movie playback ends or a user exits playback.
MP_EXTERN NSString * const MPMoviePlayerPlaybackDidFinishNotification;
MP_EXTERN NSString * const MPMoviePlayerPlaybackDidFinishReasonUserInfoKey; // NSNumber (MPMovieFinishReason)

// Posted when the network load state changes.
MP_EXTERN NSString * const MPMoviePlayerLoadStateDidChangeNotification;

// Posted when video size available or change
MP_EXTERN NSString * const MPMovieNaturalSizeAvailableNotification;

// Posted when first video/audio render
MP_EXTERN NSString * const MPMoviePlayerFirstVideoFrameRenderedNotification;
MP_EXTERN NSString * const MPMoviePlayerFirstAudioFrameRenderedNotification;

// Posted when should reload url
MP_EXTERN NSString * const MPMoviePlayerSuggestReloadNotification;

// Posted when playback status change
MP_EXTERN NSString * const MPMoviePlayerPlaybackStatusNotification;
MP_EXTERN NSString * const MPMoviePlayerPlaybackStatusUserInfoKey; // NSNumber (MPMovieStatus)

//Posted when the network status change
MP_EXTERN NSString * const MPMoviePlayerNetworkStatusChangeNotification;
MP_EXTERN NSString * const MPMoviePlayerCurrNetworkStatusUserInfoKey; // NSNumber (KSYNetworkStatus)
MP_EXTERN NSString * const MPMoviePlayerLastNetworkStatusUserInfoKey; // NSNumber (KSYNetworkStatus)

MP_EXTERN NSString * const MPMoviePlayerSeekCompleteNotification;

MP_EXTERN NSString *const MPMoviePlayerPlaybackTimedTextNotification;
MP_EXTERN NSString *const MPMoviePlayerPlaybackTimedTextUserInfoKey;

/**
 * getMetadata方法对应的关键字
 */
MP_EXTERN const NSString *const kKSYPLYFormat;
MP_EXTERN const NSString *const kKSYPLYHttpFirstDataTime;
MP_EXTERN const NSString *const kKSYPLYHttpAnalyzeDns;
MP_EXTERN const NSString *const kKSYPLYHttpConnectTime;
MP_EXTERN const NSString *const kKSYPLYStreams;
MP_EXTERN const NSString *const kKSYPLYStreamType;
MP_EXTERN const NSString *const kKSYPLYCodecName;
MP_EXTERN const NSString *const kKSYPLYStreamIndex;
MP_EXTERN const NSString *const kKSYPLYVideoWidth;
MP_EXTERN const NSString *const kKSYPLYVideoHeight;
MP_EXTERN const NSString *const kKSYPLYAudioSampleRate;
MP_EXTERN const NSString *const kKSYPLYAudioChannelLayout;
MP_EXTERN const NSString *const kKSYPLYAudioChannels;

