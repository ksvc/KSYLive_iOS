//
//  KSYSaveToMP4AndPCM.m
//  KSYPlayerDemo
//
//  Created by zhengWei on 2017/5/9.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "KSYAVWriter.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define MIN_DELAY   10000


@implementation KSYAVWriter{
    NSURL *filePath;
    AVAssetWriter *AVWriter;
    AVAssetWriterInput *videoWriterInput;
    AVAssetWriterInput *audioWriterInput;
    
    NSDictionary *videoMeta;
    NSDictionary *audioMeta;
    
    CFAbsoluteTime startTime;
    
    KSYAVWriterStatus status;
    
    int64_t lastVideoPts;
    int64_t lastAudioPts;

    BOOL  bSetStartPts;
    
    //写为mp4文件的音频视频线程
    __block dispatch_queue_t videoQueue;
    __block dispatch_queue_t audioQueue;
}

- (instancetype)initWithDefaultCfg
{
    if((self = [super init])) {
        _bWithVideo = YES;
        _videoBitrate = 2000;
        _audioBitrate = 64;
        status =  KSYAVWriter_Status_Init;
        lastVideoPts = -1;
        lastAudioPts = -1;
    }
    return self;
}

@synthesize bWithVideo = _bWithVideo;
-(void)setBWithVideo:(BOOL)bWithVideo
{
    if(status == KSYAVWriter_Status_Init)
        _bWithVideo = bWithVideo;
}

@synthesize videoBitrate = _videoBitrate;
-(void)setVideoBitrate:(int32_t)videoBitrate
{
    if(status == KSYAVWriter_Status_Init)
        _videoBitrate = videoBitrate;
}

@synthesize audioBitrate = _audioBitrate;
-(void)setAudioBitrate:(int32_t)audioBitrate
{
    if(status == KSYAVWriter_Status_Init)
        _audioBitrate = audioBitrate;
}

//设置要保存的路径
-(void)setUrl:(NSURL *)url
{
    if(status != KSYAVWriter_Status_Init || !url)
        return ;

    NSString *urlString = [url absoluteString];
    if ([urlString rangeOfString:@".mp4"].location != NSNotFound)
            filePath  = url;

    return ;
}

//设置meta
-(void)setMeta:(NSDictionary *)meta type:(KSYAVWriterMetaType)type
{
    if(status == KSYAVWriter_Status_Init)
    {
        if(KSYAVWriter_MetaType_Video == type)
            videoMeta =  meta;
        else if(KSYAVWriter_MetaType_Audio == type)
            audioMeta = meta;
    }
}

-(int)openVideoWriter
{
    if(videoMeta)
    {
        //要录制的mp4文件的配置
        NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithDouble:_videoBitrate * 1000], AVVideoAverageBitRateKey,
                                               nil];
        
        NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       AVVideoCodecH264, AVVideoCodecKey,
                                       [videoMeta objectForKey:kKSYPLYVideoWidth], AVVideoWidthKey,
                                       [videoMeta objectForKey:kKSYPLYVideoHeight], AVVideoHeightKey,
                                       videoCompressionProps, AVVideoCompressionPropertiesKey,
                                       nil];
        //视频输入源
        videoWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        videoWriterInput.expectsMediaDataInRealTime = YES;
        
        if ([AVWriter canAddInput:videoWriterInput])
        {
            [AVWriter addInput:videoWriterInput];
            videoQueue = dispatch_queue_create("com.ksyun.AVAssetWriter.processVideoQueue", DISPATCH_QUEUE_SERIAL);
            return 0;
        }
    }
    return -1;
}

-(int)openAudioWriter
{
    //音频设置
    if(audioMeta)
    {
        int audio_channels = 1;
        AudioChannelLayout acl;
        bzero( &acl, sizeof(acl));
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
        
        int actual_audiochannels = (int)[audioMeta objectForKey:kKSYPLYAudioChannels];
        if(actual_audiochannels == 2)
        {
            audio_channels = 2;
            acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
        }
        
        NSDictionary *audioOutputSettings = [ NSDictionary dictionaryWithObjectsAndKeys:
                                             [ NSNumber numberWithInt: kAudioFormatMPEG4AAC ], AVFormatIDKey,
                                             [ NSNumber numberWithInt:_audioBitrate * 1000], AVEncoderBitRateKey,
                                             [audioMeta objectForKey:kKSYPLYAudioSampleRate], AVSampleRateKey,
                                             [ NSNumber numberWithInt: audio_channels], AVNumberOfChannelsKey,
                                             [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
                                             nil ];
        
        //初始化写入器，并制定媒体格式
        audioWriterInput = [[AVAssetWriterInput alloc]initWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
        if ([AVWriter canAddInput:audioWriterInput])
        {
            //添加input
            [AVWriter addInput:audioWriterInput];
            audioQueue = dispatch_queue_create("com.ksyun.AVAssetWriter.processAudioQueue", DISPATCH_QUEUE_SERIAL);
            return 0;
        }
    }
    
    return -1;
}

//开始记录
-(void)startRecord
{
    [self startRecordDeleteRecordedVideo:YES];
}

-(void)startRecordDeleteRecordedVideo:(BOOL)isDelete {
    int ret  = 0;
    if(status != KSYAVWriter_Status_Init || !filePath)
        return ;
    
    status = KSYAVWriter_Status_Preparing;
    //设置要写成的文件类型及路径
    NSURL *outputUrl = [NSURL fileURLWithPath:[filePath absoluteString]];
    AVWriter = [[AVAssetWriter alloc] initWithURL:outputUrl fileType:AVFileTypeMPEG4 error:nil];
    
    if (isDelete) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[filePath absoluteString]]) {
            NSError *error;
            NSLog(@"");
            if ([[NSFileManager defaultManager] removeItemAtPath:[filePath absoluteString] error:&error] == NO) {
                NSLog(@"removeitematpath %@ error :%@", [filePath absoluteString], error);
            }
        }
    }
    
    if(_bWithVideo)
        ret = [self openVideoWriter];
    
    ret |= [self openAudioWriter];
    if(ret != 0)
        return ;
    
    [AVWriter startWriting];
    startTime = CFAbsoluteTimeGetCurrent();
    
    status = KSYAVWriter_Status_OK;
}

//接收视频sampleBuffer
-(void) processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if(!_bWithVideo || !sampleBuffer || !videoQueue || !videoWriterInput || status != KSYAVWriter_Status_OK)
        return ;
    //丢掉无用帧
    CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    int64_t videopts  = CMTimeGetSeconds(pts) * 1000;
    if(videopts < 0)
        return ;
    
    if(lastVideoPts != videopts)
        lastVideoPts = videopts;
   else
        return ;
    
    if(!bSetStartPts)
    {
        [AVWriter startSessionAtSourceTime:pts];
        NSLog(@"pts ===------- %zd", videopts);
        bSetStartPts = YES;
    }

    CFRetain(sampleBuffer);
    dispatch_async(videoQueue, ^{
        while (KSYAVWriter_Status_OK == status && ![videoWriterInput isReadyForMoreMediaData]) {
            usleep(MIN_DELAY);
            //等待videoWriterInput可以接收数据
        }
        if (KSYAVWriter_Status_OK == status && [videoWriterInput isReadyForMoreMediaData])
            //将sampleBuffer添加进视频输入源
            [videoWriterInput appendSampleBuffer:sampleBuffer];
        CFRelease(sampleBuffer);
    });
}

//接收音频sampleBuffer
-(void) processAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if(!sampleBuffer || !audioQueue || !audioWriterInput || status != KSYAVWriter_Status_OK)
        return ;
    
    if(videoWriterInput && !bSetStartPts)
        return ;
    
    //丢掉无用帧
    CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    Float64 audiopts = CMTimeGetSeconds(pts) * 1000;
    if (audiopts <= 0) {
        return;
    }

    if(lastAudioPts != audiopts)
        lastAudioPts = audiopts;
    else
        return ;

    if(!bSetStartPts)
    {
        [AVWriter startSessionAtSourceTime:pts];
        bSetStartPts = YES;
    }
    
    CFRetain(sampleBuffer);
    dispatch_async(audioQueue, ^{
        while (KSYAVWriter_Status_OK == status && ![audioWriterInput isReadyForMoreMediaData]) {
            usleep(MIN_DELAY);
            //等待videoWriterInput可以接收数据
        }
        if (KSYAVWriter_Status_OK == status && [audioWriterInput isReadyForMoreMediaData])
            //将音频sampleBuffer添加入音频输入源
            [audioWriterInput appendSampleBuffer:sampleBuffer];

        CFRelease(sampleBuffer);
    });
}

//停止写入
-(void)stopRecord
{
    [self stopRecordPause:NO];
}

- (void)stopRecordPause:(BOOL)pause {
    
    if (pause) {
        status = KSYAVWriter_Status_Pause;
        return;
    }
    
    if(status != KSYAVWriter_Status_OK || (!videoWriterInput && !audioWriterInput))
        return ;
    
    status = KSYAVWriter_Status_Stoping;
    
    //停止音视频输入源的写入
    [videoWriterInput markAsFinished];
    [audioWriterInput markAsFinished];
    
    //关闭写入会话
    [AVWriter finishWritingWithCompletionHandler:^{
        if (AVWriter.status == AVAssetWriterStatusCompleted) {
            [AVWriter cancelWriting];
            CFAbsoluteTime stopTime = CFAbsoluteTimeGetCurrent();
            NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[filePath absoluteString]]];
            NSUInteger length = data.length;
            
            NSLog(@"write complete, time spent : %.4f,  file size : %ldKB", stopTime - startTime, length/1024);
        }else{
            NSLog(@"write failed!!! error code : %ld  errstr:%@", AVWriter.error.code, AVWriter.error.domain);
        }
        status = KSYAVWriter_Status_Init;
    }];
    
    videoQueue = nil;
    audioQueue = nil;
}

- (void)saveVideoToPhotosAlbumWithResultBlock:(void(^)(NSError *error))resultBlock {
    
    ALAssetsLibrary *aLibrary = [[ALAssetsLibrary alloc] init];
    [aLibrary writeVideoAtPathToSavedPhotosAlbum:filePath
                                 completionBlock:^(NSURL *assetURL, NSError *error) {
                                     if (error) {
                                         NSLog(@"Save video fail:%@",error);
                                     } else {
                                         NSLog(@"Save video succeed.");
                                     }
                                     if (resultBlock) {
                                         resultBlock(error);
                                     }
                                 }];
}

- (void)cancelRecorde {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[filePath absoluteString]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[filePath absoluteString] error:nil];
    }
}

@end
