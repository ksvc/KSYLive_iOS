//
//  KSYBgpStreamerVC.h
//  KSYLiveDemo
//
//  Created by 江东 on 17/4/21.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYUIVC.h"
#import <libksygpulive/KSYGPUBgpStreamerKit.h>

@interface KSYBgpStreamerVC : KSYUIVC

@property KSYGPUBgpStreamerKit *kit;

- (id)initWithUrl:(NSString *)rtmpUrl;

// 重写此方法，调整UI布局
- (void)setupUI;
@end
