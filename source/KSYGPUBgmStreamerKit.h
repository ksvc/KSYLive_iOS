//
//  KSYGPUBgmStreamerKit.h
//  KSYStreamer
//
//  Created by jiangdong on 28/12/16.
//  Copyright © 2016 ksyun. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <libksygpulive/KSYGPUStreamerKit.h>

@interface KSYGPUBgmStreamerKit : KSYGPUStreamerKit

/**
 @abstract 背景音乐播放器
 */
@property (nonatomic, strong) KSYMoviePlayerController *ksyBgmPlayer;

/**
 @abstract   开始播放背景音乐
 @param      path 背景音乐的路径
 */
- (void) startPlayBgm:(NSString*) path;

/**
 @abstract   停止播放背景音乐
 */
- (void) stopPlayBgm;

/**
 @abstract   获取状态对应的字符串
 @param      stat 状态
 */
- (NSString*) getBgmStateName : (MPMoviePlaybackState) stat;

/**
 @abstract   获取当前状态对应的字符串
 */
- (NSString*) getCurBgmStateName;

/**
 @abstract    播放状态
 */
@property (nonatomic, readonly) MPMoviePlaybackState BgmState;

@end
