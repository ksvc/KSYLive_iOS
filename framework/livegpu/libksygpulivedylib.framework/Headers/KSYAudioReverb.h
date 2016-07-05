//
//  KSYAudioReverb.h
//  KSYStreamer
//
//  Created by yulin on 16/3/10.
//  Copyright © 2016年 yiqian. All rights reserved.
//

#ifndef KSYAudioReverb_h
#define KSYAudioReverb_h

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>


/** 音效处理 - 混响
 混响功能一般是对mic采集的人声进行处理，
 经处理后的效果，类似于主播在KTV或小礼堂内演唱时，有少量回音叠加的感觉
 
 目前提供了4种类型的混响场景， type值，和场景的对应关系如下：
 * 1 录音棚
 * 2 KTV
 * 3 小舞台
 * 4 演唱会
 
 目前只支持 单通道 S16格式的PCM数据
 */
@interface KSYAudioReverb : NSObject

/*
 @abstract 构造混响类
 @param 混响场景类型
 */
- (instancetype) initWithType:(int)type;

/*
 @abstract 处理一段音频数据,添加混响音效
 @param  pInPcm 输入音频数据
 @param  nbSample 样本个数
 */
- (void) ReverbWithSrc : ( int16_t*) pInPcm
              nbSample : ( int) nbSample;

/**
 @abstract 处理一段音频数据,添加混响音效
 @param sampleBuffer Buffer to process
 */
- (void)processAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
#endif /* KSYAudioReverb_h */
