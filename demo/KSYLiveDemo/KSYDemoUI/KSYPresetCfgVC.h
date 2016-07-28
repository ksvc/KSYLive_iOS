//
//  KSYPresetCfgVC.h
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYUIVC.h"


@interface KSYPresetCfgVC : KSYUIVC
// 初始化
- (instancetype)initWithURL:(NSString *)url;
// 初始传入的 rtmpserver 地址
@property NSString * rtmpURL;

@end

