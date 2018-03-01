//
//  AppDelegate.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/3.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingModel.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign) BOOL allowRotation;

@property (nonatomic, strong) SettingModel *settingModel;

@end

