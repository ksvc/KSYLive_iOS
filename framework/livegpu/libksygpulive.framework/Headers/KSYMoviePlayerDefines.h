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
    KSYMPErrorCode3xxOverFlow               = -10016,
};

/**
 * status类型
 */
typedef NS_ENUM(NSInteger, MPMovieStatus) {
    ///视频解码出错
    MPMovieStatusVideoDecodeWrong,
    ///音频解码出错
    MPMovieStatusAudioDecodeWrong,
};

//----------------------------------------------
