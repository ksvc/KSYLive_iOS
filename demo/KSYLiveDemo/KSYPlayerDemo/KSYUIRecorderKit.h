//
//  KSYUIRecorderKit.h
//  playerRecorder
//
//  Created by ksyun on 16/10/26.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <libksygpulive/libksygpulive.h>

#define WeakObj(o) try{}@finally{} __weak typeof(o) o##Weak = o;


@class KSYMoviePlayerController;
@class KSYGPUYUVInput;

@interface KSYUIRecorderKit : NSObject

/* ui图层*/
@property (nonatomic,readwrite) UIView* contentView;

/* 视频输入*/
-(void) processWithTextureId:(GLuint)InputTexture
                 TextureSize:(CGSize)TextureSize
                        Time:(CMTime)time;
/* 音频输入*/
-(void) processAudioSampleBuffer:(CMSampleBufferRef) buf;

/*开始录制*/
-(void)startRecord:(NSURL*) path;

/*停止录制*/
-(void)stopRecord;

/*是否开启录屏*/
@property BOOL bPlayRecord;

/*录制视频文件*/
@property (nonatomic,readwrite) KSYMovieWriter* writer;

@end
