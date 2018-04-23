//
//  KSYAudioMixer.h
//  KSYStreamer
//
//
//  Created by pengbin on 10/15/15.
//  Copyright © 2015 ksy. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


#pragma mark - audio format
/** 多路pcm混音
 
 1. 用trackId来表示某一路音频，从0开始编号
 2. 要求一定要有一路麦克风的音频，其他音频都叠加到麦克风上
 3. 将输入的音频pcm数据存入buffer，每一路音频的buffer独立
 4. 每次麦克风的音频输入，都会触发从所有buffer中取数据，混合，发送的动作
 5. 每一路音频可以单独配置音量
 6. 输出格式固定为 44.1KHz, S16 (声道数可设定)

 */
@interface KSYAudioMixer : NSObject

/**
 @abstract  获取最大支持的混合路数
 **/
- (int)getMaxMixTrack;

/**
 @abstract  设置混音音量（默认音量为1.0）
 @param     vol 音量比例（0.0~2.0） (<1.0 为缩小, > 1.0为放大)
 @param     trackId 设置对应track的
 @return    NO为设置失败，如track不存在，或vol超出范围
 @warning   设置放大的音量可能会出现爆音, 请注意
 **/
- (BOOL) setMixVolume:(float) vol
                  of:(int) trackId;

/**
 @abstract  设置立体声混音音量（默认音量为1.0)，如果设置的单声道输出，则使用leftVolume进行处理
 @param    leftVolume 左声道音量比例（0.0~2.0） (<1.0 为缩小, > 1.0为放大)
 @param    rightVolume 右声道音量比例（0.0~2.0） (<1.0 为缩小, > 1.0为放大)
 @param     trackId 设置对应track的
 @return    NO为设置失败，如track不存在，或vol超出范围
 @warning   设置放大的音量可能会出现爆音, 请注意
 **/
- (BOOL) setMixVolume:(float)leftVolume rightVolume:(float)rightVolume
                   of:(int)trackId;

/**
 @abstract  查询track的音量
 @param     trackId 设置对应track的
 @return    负数为查询失败，如track不存在
 **/
- (float) getMixVolume:(int) trackId;

/**
 @abstract  查询track的音量，
 @param    leftVolume 左声道音量比例
 @param    rightVolume 右音量比例
 @param     trackId 设置对应track的
 @return    负数为查询失败，如track不存在
 **/
- (void) getMixVolume:(float *)leftVolume rightVolume:(float *)rightVolume
                   of:(int)trackId;

/**
 @abstract  开启/关闭一路声音
 @param     onOff 开关， 0号track默认开启
 @param     trackId 开关对应track
 @return    NO为设置失败，比如trackID不存在
 **/
- (BOOL) setTrack:(int) trackId
           enable:(BOOL)onOff;
/**
 @abstract  查询track是否开启
 @param     trackId 开关对应track
 **/
- (BOOL) getTrackEnable:(int) trackId;

/**
 @abstract  查询track中缓存数据的长度（单位为一次输出的samplebuffer数）
 @param     trackId 开关对应track
 @return    <0, 表示查询失败
            =0，表示残余的数据不足一次输出
            >0, 表示buffer中的数据还可以输出n次
 **/
- (int) getBufLength:(int) trackId;

/**
 @abstract  查询track中缓存数据的samplebuffer数
 @param     trackId 开关对应track
 @return    <0, 表示查询失败
 =0，表示无残余的数据
 >0, 表示buffer中sample数
 **/
- (int) getNumSamplesInBuffer:(int) trackId;

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
 @param     pData 原始数据指针数组,单通道仅pData[0]有效 当输入为多通道且非交织时, pData[i]分别表示各个通道的数据
 @param     len   数据的长度，单位为sample (bytes / sizeof(sample))
 @param     fmt   原始数据的格式
 @param     pts   原始数据的时间戳
 @param     trackId 设置对应track的
 @return    NO为设置失败，比如trackID不存在
 @discussion 传入数据为NULL时，仅仅检查是否有数据输出
 */
- (BOOL)processAudioData:(uint8_t**)pData
                nbSample:(int)len
              withFormat:(const AudioStreamBasicDescription*)fmt
                timeinfo:(CMTime)pts
                      of:(int) trackId;

/**
 @abstract   音频处理回调接口
 @discussion sampleBuffer 混音后的音频数据
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题
 @discussion 请参考 CMSampleBufferRef
 @discussion 与pcmProcessingCallback两者只能二选一, 设置 audioProcessingCallback 会清空 pcmProcessingCallback
 */
@property(nonatomic, copy) void(^audioProcessingCallback)(CMSampleBufferRef sampleBuffer);
/**
 @abstract   音频处理回调接口
 @discussion pData 为数据指针 (双通道时, 数据为交织格式), 仅pData[0] 有效
 @discussion nbSample 为数据长度, 单位为sample (bytes / sizeof(sample)/channels)
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题
 @discussion 与audioProcessingCallback两者只能二选一, 设置 pcmProcessingCallback 会清空audioProcessingCallback
 */
@property(nonatomic, copy) void(^pcmProcessingCallback)(uint8_t** pData, int nbSample, CMTime pts);

/**
 @abstract   主轨的trackId （默认为0）
 @discussion 比如micphone的track，所有track都同步到主轨的时间轴
 */
@property(nonatomic, assign) int mainTrack;

/**
 @abstract   输出音频是否为双声道立体声 (默认为NO)
 @discussion 如果输入数据都不是双声道则输出数据左右耳内容一样
 @discussion 输出立体声的数据格式一定是交织的
 */
@property(nonatomic, assign) BOOL bStereo;

/**
 @abstract   每一次输出数据(Frame)的sample数, 默认为1024
 */
@property (nonatomic, assign) int frameSize;

/**
 @abstract   输出音频的采样率, 默认为44100
 */
@property (nonatomic, assign) int sampleRate;
/**
 @abstract   混音后输出PCM的格式
 */
@property (nonatomic, readonly) AudioStreamBasicDescription* outFmtDes;

@end
