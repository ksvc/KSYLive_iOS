//
//  SettingModel.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/22.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libksygpulive/KSYMoviePlayerController.h>

@interface SettingModel : NSObject

@property (nonatomic, assign) MPMovieVideoDecoderMode videoDecoderMode;

@property (nonatomic, assign) NSInteger bufferTimeMax;

@property (nonatomic, assign) NSInteger bufferSizeMax;

@property (nonatomic, assign) NSInteger preparetimeOut;

@property (nonatomic, assign) NSInteger readtimeOut;

@property (nonatomic, assign) BOOL  shouldLoop;

@property (nonatomic, assign) BOOL  recording;

@property (nonatomic, assign) BOOL  showDebugLog;

+ (instancetype)defaultSetting;

@end
