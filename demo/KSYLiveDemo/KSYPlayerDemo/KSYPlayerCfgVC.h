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

@property(nonatomic, assign) MPMovieVideoDecoderMode decodeMode;

@property(nonatomic, assign) MPMovieScalingMode contentMode;

@property(nonatomic, assign) BOOL bAutoPlay;

@property(nonatomic, assign) MPMovieVideoDeinterlaceMode deinterlaceMode;

@property(nonatomic, assign) BOOL bAudioInterrupt;

@property(nonatomic, assign)  BOOL bLoop;

@property(nonatomic, assign) int connectTimeout;

@property(nonatomic, assign) int readTimeout;

@property(nonatomic, assign) double bufferTimeMax;

@property(nonatomic, assign) int bufferSizeMax;

@end
