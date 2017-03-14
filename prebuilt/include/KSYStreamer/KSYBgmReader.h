//
//  KSYBgmPlayer.h
//  KSYStreamer
//
//
//  Created by pengbin on 10/15/15.
//  Copyright © 2015 ksyun. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "KSYTypeDef.h"


/** 背景音乐文件解码
 
    提供背景音乐文件解码的功能,将解码后的音频数据通过回调送出
    输出数据的格式满足如下规律:
 
    * 一定是S16的线性PCM
    * 如果是双通道,一定是交织的数据
 */
@interface KSYBgmReader : NSObject

/**
 @abstract   构造音乐文件对应的reader
 @param      path 本地音乐的路径
 @param      loop 是否循环播放此音乐
 @return     self
 */
- (id) initWithFile:(NSString*) path
             isLoop:(BOOL) loop;

/**
 @abstract   reload 一个新的文件到reader中
 @param      path 本地音乐的路径
 @return     path对应的文件是否有效
 */
- (BOOL) reloadFile:(NSString*) path;

/**
 @abstract   关闭文件
 */
- (void) closeFile;

/**
 @abstract  seek到指定时间 (拖动进度条)
 @param     time 时间, 请参考 bgmDuration (单位,秒)
 @return    是否seek 成功
 */
- (BOOL) seekTo:(float)time;

#pragma mark - audio data output
/**
 @abstract    音乐的格式信息 (一定为S16的数据格式)
 */
@property (nonatomic, readonly)  AudioStreamBasicDescription bgmFmt;

/**
 @abstract  从文件中读取一段音频数据 (二选一)
 @param     buf, 待填充的音频数据 请保证buf.mDataByteSize 先设置为需要读取的字节数
 @return    -1: 解码遇到错误, 请检查音乐文件是否有效
             0: 文件读取完毕, 无法提供更多数据 (loop时不会返回0)
             1: 读取正常
 */
- (int) readPCMData:(AudioBufferList*)buf nbSample:(UInt32)cnt;

/**
 @abstract  从文件中读取一段音频数据 (二选一)
 @param     buf, 待填充的音频数据(只会输出交织后的数据, 因此只有一个数据指针)
 @param     cap, buf的空间大小
 @return    -1: 解码遇到错误, 请检查音乐文件是否有效
            >0: 读取正常, 数值为实际取到的数据字节数
 */
- (int) readPCMData:(void*)buf capacity:(UInt32)cap;

#pragma mark - bgm info
/**
 @abstract    背景音的duration信息（总时长, 单位:秒）
 */
@property (nonatomic, readonly) float bgmDuration;

/**
 @abstract    背景音的已经播放长度 (单位:秒)
 @discussion  从0开始，最大为bgmDuration长度
 */
@property (nonatomic, readonly) float bgmPlayTime;

/**
 @abstract    音频的播放进度
 @discussion  取值从0.0~1.0，大小为bgmPlayTime/bgmDuration;
 */
@property (nonatomic, readonly) float bgmProcess;

/**
 @abstract    单曲循环
 */
@property (nonatomic, assign) BOOL bLoop;

@end
