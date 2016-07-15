//
//  ViewController.h
//  KSYGPUStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSYGPUStreamer;

@interface KSYGPUStreamerVC : UIViewController

// 切到当前VC后， 界面自动开启推流
@property BOOL  bAutoStart;

// 推流地址 完整的URL
@property NSURL * hostURL;

- (KSYGPUStreamer *) getStreamer;

// 采集和推流的参数设置
- (void) setStreamerCfg;

// 根据UI的朝向设置推流视频的朝向
- (void) setVideoOrientation;

// 在UI上显示的调试信息
@property UILabel *stat;
// 定时更新调试信息stat
- (void)updateStat:(NSTimer *)theTimer ;

// 注册通知
- (void) addObservers;
// 注销通知
- (void) rmObservers;
@end

