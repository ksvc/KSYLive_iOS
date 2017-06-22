//
//  ViewController.h
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 ksy自定义视图控制器
 
 主要增加一些工具函数
 */
#define SYSTEM_VERSION_GE_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@class  KSYUIView;
@interface KSYUIVC : UIViewController

// 定时更新调试信息 // 每秒重复调用
- (void)onTimer:(NSTimer *)theTimer ;

// 在addObservers 中会注册此timer, 没秒重复调用onTimer
@property NSTimer *timer;

// 在viewDidLoad 时会调用, 继承后重载该函数, 可以增加其他消息注册
- (void) addObservers;

// 如果没有主动调用, 会在 dealloc时调用
- (void) rmObservers;

// 重写本函数进行UI重新布局
- (void) layoutUI;

// 重写该方法来响应屏幕旋转
- (void) onViewRotate;

// 默认的控制视图
@property KSYUIView *layoutView;

// ksy util functions
+ (NSString*) sizeFormatted : (int )KB;
+ (NSString *)timeFormatted:(int)totalSeconds;
+ (void) toast:(NSString*)message
          time:(double)duration;
//cpu use rate
+ (float) cpu_usage;
+ (float) memory_usage;
+ (int)getCurrentBatteryLevel;

// 网络状态
@property NSString* networkStatus;
@property(nonatomic, copy) void(^onNetworkChange)(NSString* msg);

// 将UIImage 保存到path对应的文件
+ (void)saveImage: (UIImage *)image
               to: (NSString*)path;
+ (void)saveImageToPhotosAlbum:(UIImage *)image;
@end
