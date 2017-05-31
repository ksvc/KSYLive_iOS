//
//  KSYPlayerCfgVC.h
//  KSYPlayerDemo
//
//  Created by zhengWei on 2017/4/17.
//  Copyright © 2017年 kingsoft. All rights reserved.
//
#import "KSYUIVC.h"
#import <libksygpulive/KSYMoviePlayerController.h>

@interface KSYPlayerCfgVC : KSYUIVC

- (instancetype)initWithURL:(NSURL *)url fileList:(NSArray *)fileList;

@property (nonatomic, strong) NSURL *url;
@property(nonatomic, strong) NSArray *fileList;
//解码模式
@property(nonatomic, assign) MPMovieVideoDecoderMode decodeMode;
//填充模式
@property(nonatomic, assign) MPMovieScalingMode contentMode;
//自动播放
@property(nonatomic, assign) BOOL bAutoPlay;
//反交错模式
@property(nonatomic, assign) MPMovieVideoDeinterlaceMode deinterlaceMode;
//音频打断模式
@property(nonatomic, assign) BOOL bAudioInterrupt;
//循环播放
@property(nonatomic, assign)  BOOL bLoop;
//连接超时
@property(nonatomic, assign) int connectTimeout;
//读超时
@property(nonatomic, assign) int readTimeout;
//
@property(nonatomic, assign) double bufferTimeMax;
//
@property(nonatomic, assign) int bufferSizeMax;

@end
