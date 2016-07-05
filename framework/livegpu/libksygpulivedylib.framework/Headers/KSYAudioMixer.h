//
//  KSYAudioMixer.h
//  KSYStreamer
//
//
//  Created by pengbin on 10/15/15.
//  Copyright © 2015 ksy. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class KSYBgmPlayer;

#pragma mark - audio format
typedef struct  _KSYAudioFormat {
    int      sampleFmt; // enum AVSampleFormat
    int      sampleSize;// size of each sample in byte
    int      chCnt;     // channle number
    int64_t  chLayout;
    int      sampleRate;
} KSYAudioFormat;


/** 多路pcm混音
 1. 用trackId来表示某一路音频，从0开始编号
 2. 要求一定要有一路麦克风的音频，其他音频都叠加到麦克风上
 3. 将输入的音频pcm数据存入buffer，每一路音频的buffer独立
 4. 每次麦克风的音频输入，都会触发从所有buffer中取数据，混合，发送的动作
 5. 每一路音频可以单独配置音量
 6. 输出格式固定为 44.1KHz, 单声道， S16

 */
@interface KSYAudioMixer : NSObject

/**
 @abstract  获取最大支持的混合路数
 **/
- (int)getMaxMixTrack;

/**
 @abstract  设置混音音量（默认音量为1.0）
 @param     vol 音量比例（0.0~1.0）
 @param     trackId, 设置对应track的
 @return    NO为设置失败，如track不存在，或vol超出范围
 **/
- (BOOL) setMixVolume:(float) vol
                  of:(int) trackId;

/**
 @abstract  查询track的音量
 @param     trackId, 设置对应track的
 @return    负数为查询失败，如track不存在
 **/
- (float) getMixVolume:(int) trackId;

/**
 @abstract  开启/关闭一路声音
 @param     onOff, 开关， 0号track默认开启
 @param     trackId, 开关对应track
 @return    NO为设置失败，比如trackID不存在
 **/
- (BOOL) setTrack:(int) trackId
           enable:(BOOL)onOff;
/**
 @abstract  查询track是否开启
 @param     trackId, 开关对应track
 **/
- (BOOL) getTrackEnable:(int) trackId;

/**
 @abstract  查询track中缓存数据的长度（单位为一次输出的samplebuffer数）
 @param     trackId, 开关对应track
 @return    <0, 表示查询失败
            =0，表示残余的数据不足一次输出
            >0, 表示可以buffer中的数据还可以输出n次
 **/
- (int) getBufLength:(int) trackId;

/**
 @abstract  输入音频PCM
 @param     sampleBuffer 音频数据
 @param     trackId 设置对应track的
 @return    NO为设置失败，比如trackID不存在
 */
- (BOOL)processAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer
                              of:(int) trackId;

/**
 @abstract  输入音频PCM
 @param     pData 原始数据
 @param     len   数据的长度，单位为字节
 @param     fmt   原始数据的格式
 @param     pts   原始数据的时间戳
 @param     trackId 设置对应track的
 @return    NO为设置失败，比如trackID不存在
 @discussion 传入数据为NULL时，仅仅检查是否有数据输出
 */
- (BOOL)processAudioData:(uint8_t**)pData
                nbSample:(int)len
              withFormat:(KSYAudioFormat*)fmt
                timeinfo:(CMTime)pts
                      of:(int) trackId;

/**
 @abstract   音频处理回调接口
 @param      sampleBuffer 混音后的音频数据
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题
 
 @see CMSampleBufferRef
 */
@property(nonatomic, copy) void(^audioProcessingCallback)(CMSampleBufferRef sampleBuffer);

/**
 @abstract   主轨的trackId （默认为0）
 @discussion 比如micphone的track，所有track都同步到主轨的时间轴
 */
@property(nonatomic, assign) int mainTrack;

/**
 @abstract   混音后输出PCM的格式
 @discussion 暂时为固定一种格式
 */
@property (nonatomic, readonly) KSYAudioFormat  outFmt;
@end
