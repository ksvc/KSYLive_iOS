//
//  SettingModel.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/22.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "SettingModel.h"

@implementation SettingModel

+ (instancetype)defaultSetting {
    SettingModel *settingModel = [[self alloc] init];
    settingModel.videoDecoderMode = MPMovieVideoDecoderMode_Hardware;
    settingModel.bufferTimeMax = 2;
    settingModel.bufferSizeMax = 15;
    settingModel.preparetimeOut = 10;
    settingModel.readtimeOut = 30;
    settingModel.shouldLoop = YES;
    settingModel.recording = NO;
    settingModel.showDebugLog = NO;
    return settingModel;
}

@end
