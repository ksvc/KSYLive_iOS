//
//  KSYSaveToMP4AndPCM.h
//  KSYPlayerDemo
//
//  Created by zhengWei on 2017/5/9.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <libksygpulive/KSYMoviePlayerController.h>

/**
 * status类型
 */
typedef NS_ENUM(NSInteger, KSYAVWriterStatus) {
    ///初始化状态
    KSYAVWriter_Status_Init,
    ///准备状态
    KSYAVWriter_Status_Preparing,
    ///正常状态
    KSYAVWriter_Status_OK,
    ///停止中状态
    KSYAVWriter_Status_Stoping,
    // 暂停
    KSYAVWriter_Status_Pause,
};

/**
 * meta类型
 */
typedef NS_ENUM(NSInteger, KSYAVWriterMetaType) {
    ///video meta
    KSYAVWriter_MetaType_Video,
    ///audio meta
    KSYAVWriter_MetaType_Audio,
};

@interface KSYAVWriter : NSObject

- (instancetype)initWithDefaultCfg;

//开始录制前设置是否录制视频
@property (nonatomic, readwrite) BOOL bWithVideo;

//录制的视频码率，单位是kbps，默认值为2000kbps
@property (nonatomic, readwrite) int32_t videoBitrate;

//录制的音频码率，单位是kbps，默认值为64kbps
@property (nonatomic, readwrite) int32_t audioBitrate;

//设置文件的存储路径
-(void)setUrl:(NSURL *)url;

//设置medidaInfo
-(void)setMeta:(NSDictionary *)meta type:(KSYAVWriterMetaType)type;

//开始写入
-(void)startRecord;

//开始写入（新版--暂停后重新开始录制时，不删除已录制的视频）
-(void)startRecordDeleteRecordedVideo:(BOOL)isDelete;

//接收视频sampleBuffer
-(void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

//接收音频sampleBuffer
-(void)processAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

//停止写入
-(void)stopRecord;

// 暂停写入
- (void)stopRecordPause:(BOOL)pause;

// 将录制的视频存入相册
- (void)saveVideoToPhotosAlbumWithResultBlock:(void(^)(NSError *error))resultBlock;

- (void)cancelRecorde;

@end
