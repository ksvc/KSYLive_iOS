//
//  KSYGPUBgmStreamerKit.m
//  KSYStreamer
//
//  Created by jiangdong on 28/12/16.
//  Copyright © 2016 ksyun. All rights reserved.
//
#import "KSYGPUBgmStreamerKit.h"

#define CASE_RETURN( ENU ) case ENU : {return @#ENU;}
#define weakObj(o) __weak typeof(o) o##Weak = o;

@interface KSYGPUBgmStreamerKit (){
    NSLock   *       _quitLock;  // ensure capDev closed before dealloc
}
@end

@implementation KSYGPUBgmStreamerKit
- (instancetype) initWithDefaultCfg {
    self = [super initWithDefaultCfg];
    return self;
}

// 将声音送入混音器
- (void) mixAudio:(CMSampleBufferRef)buf to:(int)idx{
    if (![self.streamerBase isStreaming]){
        return;
    }
    [self.aMixer processAudioSampleBuffer:buf of:idx];
}

- (void) startPlayBgm:(NSString*) path {
    if (_ksyBgmPlayer){
        [_ksyBgmPlayer stop];
    }
    BOOL shouldUseHWCodec = YES;
    BOOL shouldAutoplay = YES;
    BOOL shouldMute = NO;
    NSURL *url = [NSURL URLWithString:path];
    [self.aMixer setTrack:self.bgmTrack enable:YES];
    
    // 创建背景音乐播放模块
    _ksyBgmPlayer = [[KSYMoviePlayerController alloc] initWithContentURL:url sharegroup:[[[GPUImageContext sharedImageProcessingContext] context] sharegroup]];
    // 背景音乐播放,音乐数据送入混音器
    weakObj(self);
    _ksyBgmPlayer.audioDataBlock = ^(CMSampleBufferRef buf){
        [selfWeak mixAudio:buf to:selfWeak.bgmTrack];
    };
    _ksyBgmPlayer.videoDecoderMode = shouldUseHWCodec ? MPMovieVideoDecoderMode_Hardware : MPMovieVideoDecoderMode_Software;
    _ksyBgmPlayer.shouldAutoplay = shouldAutoplay;
    _ksyBgmPlayer.shouldMute = shouldMute;
    [_ksyBgmPlayer prepareToPlay];
}

- (void) stopPlayBgm {
    if (_ksyBgmPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [_ksyBgmPlayer stop];
    }
    _ksyBgmPlayer = nil;
}

/**
 @abstract   获取状态对应的字符串
 @param      stat 状态
 */
- (NSString*) getBgmStateName : (MPMoviePlaybackState) stat {
    switch (stat){
            CASE_RETURN(MPMoviePlaybackStateStopped)
            CASE_RETURN(MPMoviePlaybackStatePlaying)
            CASE_RETURN(MPMoviePlaybackStatePaused)
        default: { return @"unknow"; }
    }
}
/**
 @abstract   获取当前状态对应的字符串
 */
- (NSString*) getCurBgmStateName {
    return [self getBgmStateName: _ksyBgmPlayer.playbackState];
}

- (void)dealloc {
    [_quitLock lock];
    [self closeBgmKit];
    [_quitLock unlock];
    _quitLock = nil;
}

- (void) closeBgmKit{
    if (_ksyBgmPlayer){
        [self stopPlayBgm];
    }
}

@end
