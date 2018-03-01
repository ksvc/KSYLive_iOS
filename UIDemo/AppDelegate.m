//
//  AppDelegate.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/3.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "AppDelegate.h"

#import "KSYMainController.h"
#import <Bugly/Bugly.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self judgeFirstBegin];
   //bugly
    BuglyConfig *cfg = [[BuglyConfig alloc] init];
    cfg.channel = @"public";
    [Bugly startWithAppId:@"900034350" config:cfg];
    NSLog(@"Bugly Version:%@",[Bugly sdkVersion]);
    
    //创建主视图
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    KSYMainController *mainVC = [[KSYMainController alloc]init];
    UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:mainVC];
    self.window.rootViewController = navVC;
    self.window.backgroundColor = [UIColor clearColor];
      //可视化
    [self.window makeKeyAndVisible];
    // Override point for customization after application launch.
    return YES;
}

/**
 第一次启动，直播界面的配置
 */
-(void)judgeFirstBegin{
    //判断程序是不是第一次启动
    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"firstLaunch"]){
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstLaunch"];
        //推流分辨率
        [[NSUserDefaults standardUserDefaults]setValue:@"360P" forKey:@"resolutionGroup"];
        //直播场景
        [[NSUserDefaults standardUserDefaults]setValue:@"秀场" forKey:@"liveGroup"];
        //性能模式
        [[NSUserDefaults standardUserDefaults]setValue:@"均衡" forKey:@"performanceGroup"];
        //采集分辨率
        [[NSUserDefaults standardUserDefaults]setValue:@"480P" forKey:@"collectGroup"];
        //视频编码器
        [[NSUserDefaults standardUserDefaults]setValue:@"自动" forKey:@"videoGroup"];
        //音频编码器
        [[NSUserDefaults standardUserDefaults]setValue:@"AAC LC" forKey:@"audioGroup"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        //第一次启动
    }else{
        //不是第一次启动了
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark - Override 复写方法
- (UIInterfaceOrientationMask )application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.allowRotation) {
        return UIInterfaceOrientationMaskAll;
    }
    if (self.settingModel.recording) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark - getters and setters 设置器和访问器
- (SettingModel *)settingModel {
    if (!_settingModel) {
        _settingModel = [SettingModel defaultSetting];
    }
    return _settingModel;
}




@end
