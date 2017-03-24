//
//  KSYSimplestStreamerVC.h
//  KSYLiveDemo
//
//  Created by 孙健 on 2017/2/7.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYUIVC.h"
#import <libksygpulive/KSYGPUStreamerKit.h>

@interface KSYSimplestStreamerVC : KSYUIVC

@property KSYGPUStreamerKit *kit;

// profile picker
@property UIPickerView *profilePicker;

- (id)initWithUrl:(NSString *)rtmpUrl;

// 重写此方法，调整UI布局
- (void)setupUI;
@end
