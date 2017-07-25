//
//  KSYTranscoder.h
//
//
//  Created by shixuemei on 07/17/17.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

/*!
 * @abstract  转码状态
 */
typedef NS_ENUM(NSInteger, KSYTranscodeState) {
    /// 初始状态
    KSYTranscodeState_Idle,
    /// 转码中
    KSYTranscodeState_Transcoding,
    /// 转码完成
    KSYTranscodeState_Completed,
    /// 转码失败
    KSYTranscodeState_Error,
};

/*!
 * @abstract  转码错误码，用于说明转码失败的原因
 */
typedef NS_ENUM(NSInteger, KSYTranscodeErrorCode) {
    /// 正常无错误
    KSYTranscodeErrorCode_None = 0,
    /// 无效的文件地址(输入或输出地址为空)
    KSYTranscodeErrorCode_InvalidAddress = -1,
    /// 打开输入文件失败
    KSYTranscodeErrorCode_InputFile_OpenFailed = -2,
    /// 无效的媒体数据
    KSYTranscodeErrorCode_InvalidData  = -3,
    /// 不支持的输出文件格式
    KSYTranscodeErrorCode_OutputFile_UnsupportedFormat = -4,
    /// 打开输出文件失败
    KSYTranscodeErrorCode_OutputFile_OpenFailed = -5,
    /// 输出文件添加流失败
    KSYTranscodeErrorCode_OutputFile_AddStreamFailed = -6,
    /// 输出文件头写入失败(通常为不支持的codec)
    KSYTranscodeErrorCode_OutputFile_StartWriteFailed = -7,
    /// 转码过程中出现错误
    KSYTranscodeErrorCode_Transcoding_Failed = -8,
};

/** 不同音视频文件格式间的转码
 
     1. 输入可以是本地文件/HTTP/RTMP/HLS
     2. 输出只能是本地文件
     3. 只提供不同封装格式间转换的功能，不涉及音视频编码格式的转换
     4. 目前只支持单路音视频流的转换
     5. 输出格式目前只支持FLV和MOV
 
 */
@interface KSYTranscoder : NSObject

/**
 @abstract   开始转换
 @param      inputFilePath 输入文件路径
 @param      outputFilePath 输出文件路径
 */
- (void) startTranscode:(NSURL *)inputFilePath outputFilePath:(NSURL *)outputFilePath;

/**
 @abstract   停止转换
 @discussion 与startTransform配对调用，除Idle状态外，其他状态下结束转码时都需要调用，否则可能会造成内存泄露
 */
- (void) stopTranscode;

#pragma mark - transcoder info
/**
 @abstract    转换文件的总时长，单位是秒
 */
@property (nonatomic, readonly) float duration;

/**
 @abstract    当前转换位置，单位是秒
 */
@property (nonatomic, readonly) float position;

/**
 @abstract    转换进度
 @discussion  取值从0.0~1.0，大小为position/duration;
 */
@property (nonatomic, readonly) float progress;

#pragma mark - status

FOUNDATION_EXPORT NSString * const KSYTranscodeStateDidChangeNotification;
FOUNDATION_EXPORT NSString * const KSYTranscodeStateUserInfoKey;
FOUNDATION_EXPORT NSString * const KSYTranscodeErrorCodeUserInfoKey;

/**
 @abstract 当前转码状况
 @discussion 可以通过该属性获取转码器的工作状况
 @discussion 通知：
 * KSYTranscodeStateDidChangeNotification 当转码器状态发生变化时提供通知
 * 可通过userInfo获取转换后的状态，关键字为KSYTranscodeStateUserInfoKey
 * 也可以收到通知后，通过本属性查询新的状态，并作出相应的动作
@discussion 状态机转换：
 * 创建转码对象后状态为KSYTranscodeState_Idle
 * 只能在KSYTranscodeState_Idle状态下调用 startTranscode 方法,
     - 成功状态转为KSYTranscodeState_Transcoding
     - 失败则转为KSYTranscodeState_Error
 * 开始转码后
     - 转码完成状态转为KSYTranscodeState_Completed
     - 转码过程中出现问题状态转为KSYTranscodeState_Error
 * 调用 stopTranscode 可将状态转为KSYTranscodeState_Idle
 */
@property (nonatomic, readonly) KSYTranscodeState transcodeState;

/**
 @abstract   转码器的错误码
 @discussion 可以通过该属性获取转码失败的原因
 @discussion
 * 当transcoderStatus为KSYTranscodeState_Error时可查询
 * 当transcoderStatus为其他值时，错误码为KSYTranscodingErrorCode_NONE
 @discussion 通知：
  * KSYTranscodeStateDidChangeNotification 当转码器状态发生变化时提供通知
  * 可通过userInfo获取当前错误码，关键字为KSYTranscodeErrorCodeInfoKey
 @see transcodeState
 */
@property (nonatomic, readonly) KSYTranscodeErrorCode transcodeErrorCode;

@end
