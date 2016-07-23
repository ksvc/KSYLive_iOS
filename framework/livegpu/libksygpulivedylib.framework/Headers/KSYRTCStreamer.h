//
//  KSYRTCSteamer.h
//  KSYStreamer
//
//  Created by ksyun on 16/6/17.
//  Copyright © 2016年 yiqian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^RTCVideoDataBlock)(CVPixelBufferRef pixelBuffer);

typedef void (^RTCVoiceDataBlock)(uint8_t* pData,int blockBufSize,uint64_t pts);

@interface KSYRTCSteamer: NSObject
/*
  @abstract 注册服务器地址
 */
@property(nonatomic,copy) NSString * registerURL;
/*
 @abstract 本地url地址
 */
@property(nonatomic,copy) NSString * localUserName;
/*
 @abstract video的fps值
 */
@property (nonatomic, assign) int videoFPS;
/*
 @abstract 传输平均比特率
 */
@property (nonatomic, assign) int AvgBps;
/*
 @abstract 传输最大比特率
 */
@property (nonatomic, assign) int MaxBps;

/*
 @abstract audio的采样率
 */
@property (nonatomic, assign) int sampleRate;

/*
 @abstract 是否打开RTC的日志
 */
@property (nonatomic, assign) BOOL openRtcLog;

/*
 @abstract 对端视频数据宽度
 */
@property (nonatomic, assign) int remoteWidth;

/*
 @abstract 对端视频数据高度
 */
@property (nonatomic, assign) int remoteHeight;

#pragma  mark -  callback
/*
 @abstract 接收注册结果的回调函数
 */
@property (nonatomic, copy)void (^onRegister)(int status);

/*
 @abstract 接收反注册结果的回调函数
 */
@property (nonatomic, copy)void (^onUnRegister)(int status);

/*
 @abstract start call的回调函数
 @discuss 如果使用kit类，请不要覆盖该函数，会导致无法显示小窗口
 */
@property (nonatomic, copy)void (^onCallStart)(int status);

/*
 @abstract stop call的回调函数
 */
@property (nonatomic, copy)void (^onCallStop)(int status);

/*
 @abstract call coming的回调函数，返回远端的remoteURI
 */
@property (nonatomic, copy)void (^onCallInComing)(char* remoteURI);
/*
 @abstract mediaMeta的回调函数，返回媒体信息
 */
@property (nonatomic, copy)void (^onMediaMetaType)(int type, void* meta);

/*
 @abstract 返回视频数据供上游渲染
 */
@property (nonatomic, copy)RTCVideoDataBlock videoDataBlock;

/*
 @abstract 音频数据回调
 */
@property (nonatomic, copy)RTCVoiceDataBlock voiceDataBlock;

#pragma  mark -  rtc function
/*
 @abstract 初始化alphaRTC协议栈
 @discuss 在初始化之前，registerURL要确保有效
 */
-(int)initRTC;

/*
 @abstract 注册alpahRTC
 @discuss registerURL，localURL要确保有效
 */
-(int)registerRTC;

/*
 @abstract 反注册alpahRTC
 */
-(int)unRegisterRTC;

/*
 @abstract 发起呼叫
 */
-(int) startCall:(const char*) remote_uri;

/*
 @abstract 接收呼叫
 */
-(int)answerCall;

/*
 @abstract 拒绝呼叫
 */
-(int)rejectCall;

/*
 @abstract 停止呼叫
 */
-(int)stopCall;

/*
 @abstract 反注册rtc
 */
-(int)unInitRTC;

#pragma  mark - audio/video process

/**
 @abstract   对原始采用数据进行scale处理
 @param      sampleBuffer 原始采集到的视频数据
 
 @see CMSampleBufferRef
 */
-(int) processVideo:(CMSampleBufferRef)sampleBuffer;

/**
 @abstract   对原始音频数据进行rtp传输
 @param      sampleBuffer 原始采集到的音频数据
 
 @see CMSampleBufferRef
 */
-(int) processAudio:(CMSampleBufferRef)sampleBuffer;

@end

