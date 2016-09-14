//
//  KSYAVCompositon.h
//  KSYStreamer
//
//  Created by yiqian on 6/16/16.
//  Copyright © 2016 yiqian. All rights reserved.
//

#import <Foundation/Foundation.h>


/*!
 * @abstract  交织处理状态
 */
typedef NS_ENUM(NSInteger, KSYAVMuxerStatus) {
    /// 初始状态
    KSYAVMuxerStatusIdle,
    /// 处理中
    KSYAVMuxerStatusMuxing,
    /// 处理完成
    KSYAVMuxerStatusCompleted,
    /// 处理失败
    KSYAVMuxerStatusFailed,
    /// 处理任务被取消
    KSYAVMuxerStatusCancelled
};

/**
 音视频交织工具类
 
 * 将输入的纯音频文件和纯视频文件交织输出为正常的视频文件
 * 本工具类不做解码和编码,仅仅将音视频交织
 * 视频文件要求是只有单路图像, 如果有音频会被丢弃, 音频文件反之
 * 支持输出的文件格式: flv, MP4
 */
@interface KSYAVMuxer : NSObject

#pragma mark - cfgs

/**
 @abstract   当视频数据比音频数据短时,是否循环使用视频数据 （默认为NO）
 */
@property(atomic, assign) BOOL bLoopVideo;

/**
 @abstract   当音频数据比视频数据短时,是否循环使用音频数据 （默认为NO）
 @discussion 当bLoopVideo和bLoopAudio都为NO时, 比较长的数据被丢弃
 */
@property(atomic, assign) BOOL bLoopAudio;

/**
 @abstract  最后输出视频文件时附带的metadata (默认为nil)
 @discussion key 一定要是 NSString* 类型的
 */
@property(atomic, copy) NSDictionary * metadata;

#pragma mark - process
/**
 @abstract 启动处理(同步)
 @param      vFile 为输入的纯视频文件的路径
 @param      aFile 为输入的音频文件的路径
 @param      oFile 为输出文件的路径
 */
- (void) startMuxVideo:(NSURL*) vFile
              andAudio:(NSURL*) aFile
                    To:(NSURL*) oFile;

/**
 @abstract 启动处理(异步)
 @param      vFile 为输入的纯视频文件的路径
 @param      aFile 为输入的音频文件的路径
 @param      oFile 为输出文件的路径
 */
- (void) asyncMuxVideo:(NSURL*) vFile
              andAudio:(NSURL*) aFile
                    To:(NSURL*) oFile;

/**
 @abstract 中止处理
 */
- (void) cancelMux;

#pragma mark - handlers

/**
 @abstract   异步处理完成回调
 @param      status
 
 @see asyncMuxVideo
 */
@property(nonatomic, copy) void(^muxCompleteBlock)(KSYAVMuxerStatus status );

@end
