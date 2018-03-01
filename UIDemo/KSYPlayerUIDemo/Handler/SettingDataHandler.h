//
//  SettingDataHandler.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/23.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SettingModel;

@interface SettingDataHandler : NSObject

+ (SettingModel *)getSettingModel;

+ (void)setSettingModel:(SettingModel *)model;

@end
