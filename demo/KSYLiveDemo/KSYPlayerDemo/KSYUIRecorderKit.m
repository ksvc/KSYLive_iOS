//
//  KSYUIRecorderKit.m
//  playerRecorder
//
//  Created by ksyun on 16/10/26.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYUIRecorderKit.h"

#import <GPUImage/GPUImage.h>
#import <libksygpulive/KSYGPUPicMixer.h>
#import <libksygpulive/KSYAudioMixer.h>
#import <libksygpulive/KSYGPUPicOutput.h>
#import <libksygpulive/KSYMoviePlayerController.h>
#import <libksygpulive/KSYDummyAudioSource.h>



@interface KSYUIRecorderKit()
{
    BOOL _bBackground;
}
//图层0 player
@property  GPUImageTextureInput* textureInput;
@property  NSInteger playerLayer;
//图层1 UI
@property  GPUImageUIElement* uiElementInput;
@property  NSInteger uiLayer;
//伟大的混流器
@property  KSYGPUPicMixer* uiMixer;
@property  KSYAudioMixer *aMixer;

@property  KSYDummyAudioSource* dummyAudio;
@property (nonatomic, readonly) int dummyTrack;
@property (nonatomic, readonly) int playerTrack;

@property  KSYGPUPicOutput* gpuToStr;
@property  CMTime lastPts;

@end

@implementation KSYUIRecorderKit

- (instancetype)init {
    if (!(self = [super init]))
    {
        return nil;
    }
    
    _bPlayRecord = NO;
    CGSize sz = [UIScreen mainScreen].bounds.size;
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sz.width,sz.height)];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.contentScaleFactor = 2;
    
    _playerLayer = 0 ;
    _uiLayer = 1;
    
    _dummyTrack = 0;
    _playerTrack = 1;
    
    _bBackground = NO;
    
    [self createMixer];
    
    [self createWriter];
    
    [self registerApplicationObservers];

    return self;
}

-(void)dealloc{
    if(_contentView)
        _contentView = nil;
    
    if(_uiElementInput)
        _uiElementInput = nil;
    
    if(_uiMixer){
        [_uiMixer clearPicOfLayer:_playerLayer];
        [_uiMixer clearPicOfLayer:_uiLayer];
        _uiMixer = nil;
    }
    
    if(_aMixer)
        _aMixer = nil;
    
    if(_gpuToStr)
        _gpuToStr = nil;
    
    if(_writer){
        [_writer stopWrite];
        _writer = nil;
    }
    
    if(_dummyAudio){
        [_dummyAudio stop];
        _dummyAudio = nil;
    }
    
    [self unregisterApplicationObservers];
}

-(void)startRecord:(NSURL*) path
{
    [_writer startWrite:path];
    _bPlayRecord = YES;
}

-(void)stopRecord
{
    [_writer stopWrite];
    _bPlayRecord = NO;
}

-(void)createWriter{
    _gpuToStr = [[KSYGPUPicOutput alloc] initWithOutFmt:kCVPixelFormatType_32BGRA];
    _writer = [[KSYMovieWriter alloc] init];
    _writer.videoCodec = KSYVideoCodec_VT264;
    _writer.audioCodec = KSYAudioCodec_AAC;
    _writer.bWithVideo = YES;
    _writer.bWithAudio = YES;
    
    __weak KSYUIRecorderKit * weakKit = self;
    _aMixer.audioProcessingCallback = ^(CMSampleBufferRef buf){        
        [weakKit.writer processAudioSampleBuffer:buf];
    };
    
    _gpuToStr.videoProcessingCallback = ^(CVPixelBufferRef pixelBuffer, CMTime timeInfo){
        [weakKit.writer processVideoPixelBuffer:pixelBuffer timeInfo:timeInfo];
    };
    
    [_uiMixer addTarget:_gpuToStr];
}

-(void)createMixer{
    _uiMixer = [[KSYGPUPicMixer alloc] init];
    _uiMixer.masterLayer = _uiLayer;
    [_uiMixer setPicRect:CGRectMake(-1,-1,0.0,0.0) ofLayer:_playerLayer];
    [_uiMixer setPicRotation:kGPUImageFlipVertical ofLayer:_playerLayer];
    [_uiMixer setPicAlpha:1.0 ofLayer:_playerLayer];
    
    [_uiMixer setPicRect:CGRectMake(0,0,1.0,1.0) ofLayer:_uiLayer];
    [_uiMixer setPicAlpha:1.0 ofLayer:_uiLayer];
    
    _aMixer = [[KSYAudioMixer alloc]init];
    _aMixer.mainTrack = _dummyTrack;
    
    [_aMixer setTrack:_dummyTrack enable:YES];
    [_aMixer setTrack:_playerTrack enable:YES];
    
    AudioStreamBasicDescription format;
    memset(&format, 0, sizeof(format));
    format.mSampleRate = 44100;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    format.mChannelsPerFrame = 2;
    format.mBitsPerChannel = 16;
    format.mBytesPerFrame = (format.mBitsPerChannel * format.mChannelsPerFrame / 8);
    format.mFramesPerPacket = 1;
    format.mBytesPerPacket = format.mBytesPerFrame * format.mFramesPerPacket;
    
    __weak KSYUIRecorderKit *weakKit = self;
    _dummyAudio = [[KSYDummyAudioSource alloc]initWithAudioFmt:format];
    _dummyAudio.audioProcessingCallback = ^(CMSampleBufferRef sampleBuffer){
        [weakKit.aMixer processAudioSampleBuffer:sampleBuffer of:weakKit.dummyTrack];
        weakKit.lastPts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);        
    };
    CMTime startPts = CMTimeMake((int64_t)(0 * 1000), 1000);
    [_dummyAudio startAt:startPts];
}

-(void) processAudioSampleBuffer:(CMSampleBufferRef) buf
{
    @synchronized (self) {
        if(!_bPlayRecord)
            return;
        
        [_aMixer processAudioSampleBuffer:buf of:_playerTrack];
    }
}

-(void) processWithTextureId:(GLuint)InputTexture
                 TextureSize:(CGSize)TextureSize
                        Time:(CMTime)time
{
    @synchronized (self) {
        if(!_bPlayRecord && _bBackground)
            return;
        
        if(_uiMixer)
        {
            _textureInput = [[GPUImageTextureInput alloc]initWithTexture:InputTexture size:TextureSize];
            [_uiMixer clearPicOfLayer:_playerLayer];
            [_textureInput addTarget:_uiMixer atTextureLocation:_playerLayer];
            [_textureInput processTextureWithFrameTime:time];
            
            _uiElementInput = [[GPUImageUIElement alloc] initWithView:_contentView];
            [_uiMixer clearPicOfLayer:_uiLayer];
            [_uiElementInput addTarget:_uiMixer atTextureLocation:_uiLayer];
            [_uiElementInput updateWithTimestamp:_lastPts];
        }
    }
}

- (void)registerApplicationObservers
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void)unregisterApplicationObservers
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];
}

- (void)applicationWillEnterForeground
{
    _bBackground = NO;
}

- (void)applicationDidBecomeActive
{
    _bBackground = NO;
}

- (void)applicationWillResignActive
{
    _bBackground = YES;
}

- (void)applicationDidEnterBackground
{
    _bBackground = YES;
}

- (void)applicationWillTerminate
{
    _bBackground = YES;
}

@end
