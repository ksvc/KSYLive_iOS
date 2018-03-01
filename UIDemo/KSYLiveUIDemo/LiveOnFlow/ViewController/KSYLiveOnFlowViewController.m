//
//  KSYLiveOnFlowViewController.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/6.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYLiveOnFlowViewController.h"
#import <libksygpulive/KSYGPUStreamerKit.h>
#import "AppDelegate.h"
#import "KSYQRCodeVC.h"
#import "KSYParameterSettingVC.h"
#import "KSYUIStreamerVC.h"
#import "KSYBackgroundPushVC.h"
#import "KSYPictureInPictureVC.h"
#import "KSYBrushLiveVC.h"
#import "KSYLandScapeKitVC.h"
#import "KSYDynamicSwitchVC.h"

@interface KSYLiveOnFlowViewController ()

@end

@implementation KSYLiveOnFlowViewController

#pragma mark -
#pragma mark - life cycle 视图的生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    //代码布局
    [self setUpChildView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
    //设置界面的横竖屏
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 0;
    appDelegate.settingModel.recording = NO;
    
}
- (void)viewWillDisappear:(BOOL)animated {
    //    [super viewWillDisappear:YES];
    //    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark -
#pragma mark - private methods 私有方法
/**
 布局子控件
 */
- (void)setUpChildView {
    self.view.backgroundColor = [UIColor blackColor];
    //设置导航栏的按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"直播页面返回"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    //设置按钮
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setImage:[UIImage imageNamed:@"直播页面设置"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(jumpSetting) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingButton];
    
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.top.equalTo(self.view).offset(SafeAreaStatusBarTopHeight);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(SafeAreaStatusBarTopHeight);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    //利用for循环布局控件
    float buttonWidth =  KSYScreenWidth/2;
    float buttonHeight = (KSYScreenHeight-SafeAreaTopHeight-SafeAreaBottomHeight)/3;
    float navHeight = SafeAreaTopHeight;
    NSArray *leftImageArray = @[@"竖屏直播",@"横竖屏切换",@"背景图直播"];
    for (int i = 0; i<3; i++) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setBackgroundImage:[UIImage imageNamed:leftImageArray[i]] forState:UIControlStateNormal];
        leftButton.frame = CGRectMake(0,navHeight+buttonHeight*i, buttonWidth, buttonHeight);
        leftButton.layer.borderColor = [UIColor whiteColor].CGColor;
        leftButton.layer.borderWidth = 0.5;
        leftButton.tag = 300+i;
        [leftButton addTarget:self action:@selector(beginLiveToEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:leftButton];
    }
    NSArray *rightImageArray = @[@"横屏直播",@"涂鸦直播",@"画中画直播"];
    for (int i = 0; i<3; i++) {
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setBackgroundImage:[UIImage imageNamed:rightImageArray[i]] forState:UIControlStateNormal];
        rightButton.frame = CGRectMake(buttonWidth,navHeight+buttonHeight*i, buttonWidth, buttonHeight);
        rightButton.layer.borderColor = [UIColor whiteColor].CGColor;
        rightButton.layer.borderWidth = 0.5;
        rightButton.tag = 303+i;
        [rightButton addTarget:self action:@selector(beginLiveToEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:rightButton];
    }
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等

-(void)beginLiveToEvent:(UIButton*)button{
    NSString *uuidStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *devCode  = [[uuidStr substringToIndex:3] lowercaseString];
    NSLog(@"%@",devCode);
    //推流地址
    NSString *streamSrv =  @"rtmp://mobile.kscvbu.cn/live";
    NSString *streamUrl = [NSString stringWithFormat:@"%@/%@", streamSrv, devCode];
    NSURL *rtmpUrl = [NSURL URLWithString:streamUrl];
    
    //竖屏普通直播
    if (button.tag == 300) {
        KSYUIStreamerVC *vc =  [[KSYUIStreamerVC alloc] initWithUrl:rtmpUrl];
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
    //横竖屏切换
    else if (button.tag == 301){
        KSYDynamicSwitchVC *vc =  [[KSYDynamicSwitchVC alloc] initWithUrl:rtmpUrl];
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
    //背景图推流
    else if (button.tag == 302){
        KSYBackgroundPushVC *vc =  [[KSYBackgroundPushVC alloc] initWithUrl:rtmpUrl];
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
    //横屏
    else if (button.tag == 303){
        KSYLandScapeKitVC *vc =  [[KSYLandScapeKitVC alloc]initWithUrl:rtmpUrl];
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
    //画笔
    else if (button.tag == 304){
        
        KSYBrushLiveVC *vc =  [[KSYBrushLiveVC alloc]initWithUrl:rtmpUrl];
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
    //画中画
    else{
        
        KSYPictureInPictureVC *vc =  [[KSYPictureInPictureVC alloc] initWithUrl:rtmpUrl];
        [self.navigationController presentViewController:vc animated:YES completion:nil];
        
    }
    
}
// 关闭
- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
 扫描二维码
 
 @param sender 按钮
 */
- (void)scanQRCodeAction:(UIButton*)sender {
    KSYQRCodeVC *qrCodeVC = [[KSYQRCodeVC alloc]init];
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:qrCodeVC];
    [self presentViewController:nav animated:YES completion:nil];
}
/**
 设置界面
 */
- (void)jumpSetting {
    KSYParameterSettingVC *settingVC = [[KSYParameterSettingVC alloc]init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end

