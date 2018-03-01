//
//  SettingDataHandler.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/23.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "SettingDataHandler.h"
#import "SettingModel.h"
#import "AppDelegate.h"

static NSString * const kSettingModel = @"kSettingModel";

@implementation SettingDataHandler

+ (SettingModel *)getSettingModel {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.settingModel;
}

+ (void)setSettingModel:(SettingModel *)model {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.settingModel = model;
}

@end
