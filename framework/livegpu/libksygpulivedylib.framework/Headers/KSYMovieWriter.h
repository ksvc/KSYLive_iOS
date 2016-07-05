//
//  KSYMovieWriter.h
//  KSYStreamer
//
//  Created by pengbin on 6/16/16.
//  Copyright © 2016 ksyun. All rights reserved.
//

@class KSYStreamerBase;

@interface KSYMovieWriter : KSYStreamerBase

/**
 @abstract write video stream to local files
 @param    filePath is local file path
 @discussion 开始写文件前需要设定好编码参数
 @discussion 编码参数主要是视频编码器，音视频码率的设置
 */
- (void) startWrite: (NSURL*) filePath;

/**
 @abstract stop wirte file
 */
- (void) stopWrite;

@end
