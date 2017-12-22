//
//  KSYGPUPipStreamerKit.m
//  KSYStreamer
//
//  Created by jaingdong on 28/12/16.
//  Copyright © 2016 ksyun. All rights reserved.
//
#import "KSYGPUPipStreamerKit.h"

#define CASE_RETURN( ENU ) case ENU : {return @#ENU;}
#define weakObj(o) __weak typeof(o) o##Weak = o;

@interface KSYGPUPipStreamerKit (){
    NSLock   *       _quitLock;  // ensure capDev closed before dealloc
}
@end

@implementation KSYGPUPipStreamerKit
- (instancetype) initWithDefaultCfg {
    self = [super initWithDefaultCfg];
    _bgPicLayer = 0;
    _pipLayer   = 1;
    _pipTrack   = 2;
    _yuvInput   = nil;
    _player     = nil;
    _bgPic      = nil;
    
    return self;
}

@synthesize bgPicRect = _bgPicRect;
- (CGRect) bgPicRect {
    return [self.vPreviewMixer getPicRectOfLayer:_bgPicLayer];
}
- (void) setBgPicRect:(CGRect)logoRect{
    [self.vPreviewMixer setPicRect:logoRect
                       ofLayer:_bgPicLayer];
    [self.vStreamMixer setPicRect:logoRect
                      ofLayer:_bgPicLayer];
}

@synthesize pipRect = _pipRect;
- (CGRect) pipRect {
    return [self.vPreviewMixer getPicRectOfLayer:_pipLayer];
}
- (void) setPipRect:(CGRect)logoRect{
    [self.vPreviewMixer setPicRect:logoRect
                           ofLayer:_pipLayer];
    [self.vStreamMixer setPicRect:logoRect
                          ofLayer:_pipLayer];
}

@synthesize cameraRect = _cameraRect;
- (CGRect) cameraRect {
    return [self.vPreviewMixer getPicRectOfLayer:self.cameraLayer];
}
- (void) setCameraRect:(CGRect)logoRect{
    [self.vPreviewMixer setPicRect:logoRect
                           ofLayer:self.cameraLayer];
    [self.vStreamMixer setPicRect:logoRect
                          ofLayer:self.cameraLayer];
}

//设置图层的位置
-(void) setLayerRect{
    self.bgPicRect = CGRectMake(0.0, 0.0, 1.0, 1.0);
    self.pipRect = CGRectMake(-1.0, -1.0, 0.0, 0.0);
    self.cameraRect = CGRectMake(0.7, 0.7, 0.24, 0.24);
}

-(void)startPipWithPlayerUrl:( NSURL* _Nullable )playerUrl
                       bgPic:( NSURL* _Nullable )bgUrl
{
    if (_player) {
        [self stopPip];
    }
    
    if(playerUrl) {
        [self.aMixer setTrack:_pipTrack enable:YES];
        [self.aMixer setMixVolume:1 of:_pipTrack];
        BOOL shouldUseHWCodec = YES;
        BOOL shouldAutoplay = YES;
        BOOL shouldMute = NO;
        _yuvInput = [[KSYGPUPicInput alloc] init];
        _player = [[KSYMoviePlayerController alloc]initWithContentURL:playerUrl];
        _player.videoDecoderMode = shouldUseHWCodec ? MPMovieVideoDecoderMode_Hardware : MPMovieVideoDecoderMode_Software;
        _player.shouldAutoplay = shouldAutoplay;
        _player.shouldMute = shouldMute;
        weakObj(self);
        _player.videoDataBlock = ^(CMSampleBufferRef buf){
            CVPixelBufferRef pb = CMSampleBufferGetImageBuffer(buf);
            [selfWeak.yuvInput forceProcessingAtSize:CGSizeMake(CVPixelBufferGetWidth(pb), CVPixelBufferGetHeight(pb))];
            [selfWeak.yuvInput processPixelBuffer:CMSampleBufferGetImageBuffer(buf) time:CMTimeMake(2, 10)];
        };
        _player.audioDataBlock = ^(CMSampleBufferRef buf){
            if ([selfWeak.streamerBase isStreaming]){
                [selfWeak.aMixer processAudioSampleBuffer:buf of:selfWeak.pipTrack];
            }
        };
    }
    
    if(bgUrl) {
        _bgPic =  [[GPUImagePicture alloc] initWithURL:bgUrl];
    }
    [self setLayerRect];
    [self setupPipFilter:self.filter];
    [_player prepareToPlay];
}

-(void)stopPip
{
    if (_player) {
        [_player stop];
        _player    = nil;
    }
    _yuvInput = nil;
    _bgPic     = nil;
    [self.aMixer setTrack:_pipTrack enable:NO];
    self.cameraRect = CGRectMake(0.0, 0.0, 1.0, 1.0);
    [self setupPipFilter:self.filter];
}

- (void) setupPipFilter:(GPUImageOutput<GPUImageInput> *) filter {
    
    if (self.vCapDev  == nil) {
        return;
    }
    // 采集的图像先经过前处理
    [self.capToGpu removeAllTargets];
    GPUImageOutput* src = self.capToGpu;
    if (filter) {
        [filter removeAllTargets];
        [src addTarget:filter];
        src = filter;
    }
    
    // 组装图层
    if (_bgPic){
        [self addPic:self.bgPic     ToMixerAt:self.bgPicLayer];
    }
    if (_yuvInput){
        [self addPic:self.yuvInput  ToMixerAt:self.pipLayer];
    }
    
    self.vPreviewMixer.masterLayer = self.cameraLayer;
    self.vStreamMixer.masterLayer = self.cameraLayer;
    [self addPic:src            ToMixerAt:self.cameraLayer];

    [self addPic:self.logoPic   ToMixerAt:self.logoPicLayer];
    [self addPic:self.textPic   ToMixerAt:self.logoTxtLayer];

    // 混合后的图像输出到预览和推流
    [self.vPreviewMixer removeAllTargets];
    [self.vPreviewMixer addTarget:self.preview];
    
    [self.vStreamMixer  removeAllTargets];
    [self.vStreamMixer  addTarget:self.gpuToStr];
    // 设置镜像
    [self setPreviewMirrored:self.previewMirrored];
    [self setStreamerMirrored:self.streamerMirrored];
    [self setPreviewOrientation:self.previewOrientation];
    [self setStreamOrientation:self.streamOrientation];
}

// 添加图层到 vMixer 中
- (void) addPic:(GPUImageOutput*)pic ToMixerAt: (NSInteger)idx{
    KSYGPUPicMixer * vMixer[2] = {self.vPreviewMixer, self.vStreamMixer};
    if (pic == nil){
        for (int i = 0; i<2; ++i) {
            [vMixer[i]  clearPicOfLayer:idx];
        }
        return;
    }
    [pic removeAllTargets];
    for (int i = 0; i<2; ++i) {
        [pic addTarget:vMixer[i] atTextureLocation:idx];
    }
}

- (void)dealloc {
    [_quitLock lock];
    [self closePipKit];
    [_quitLock unlock];
    _quitLock = nil;
}

- (void) closePipKit{
    if (_player){
        [self stopPip];
    }
    [self resetFilters ];
}

- (void) resetFilters {
    _yuvInput  = nil;
    _bgPic     = nil;
    _player    = nil;
}

/**
 @abstract   获取状态对应的字符串
 @param      stat 状态
 */
- (NSString*) getPipStateName : (MPMoviePlaybackState) stat {
    switch (stat){
            CASE_RETURN(MPMoviePlaybackStateStopped)
            CASE_RETURN(MPMoviePlaybackStatePlaying)
            CASE_RETURN(MPMoviePlaybackStatePaused)
        default: {    return @"unknow"; }
    }
}
/**
 @abstract   获取当前状态对应的字符串
 */
- (NSString*) getCurPipStateName {
    return [self getPipStateName: _player.playbackState];
}

@end
