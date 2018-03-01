//
//  KSYMainController.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/3.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYMainController.h"
#import "KSYCustomLabel.h"
#import "KSYTabBarViewController.h"

@interface KSYMainController ()

@end

@implementation KSYMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpChildView];
    // Do any additional setup after loading the view.
}
#pragma mark -
#pragma mark - private methods 私有方法
/**
 界面布局
 */
- (void)setUpChildView{
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"launch"]];
    //初始化控件
    KSYCustomLabel *sdkLabel = [KSYCustomLabel labelWithText:LocalString(@"Live_BroadCast_SDK") textColor:KSYRGB(121, 121, 121) font:KSYUIFont(25) textAlignment:NSTextAlignmentCenter backgroundColor:nil];
    [self.view addSubview:sdkLabel];
    
    KSYCustomLabel *serviceLabel = [KSYCustomLabel labelWithText:LocalString(@"Provides_Services") textColor:KSYRGB(121, 121, 121) font:KSYUIFont(15) textAlignment:NSTextAlignmentCenter backgroundColor:nil];
    [self.view addSubview:serviceLabel];
    
    UIButton* liveButton = [UIButton buttonWithTitle:LocalString(@"Open_A_Live") titleColor:[UIColor whiteColor] font:KSYUIFont(16) imageName:nil backGroundColor:KSYRGB(236, 69, 84) target:self action:@selector(beginLiveToEvent) backImageName:nil];
    liveButton.layer.cornerRadius = 20;
    [self.view addSubview:liveButton];
    
    KSYCustomLabel *versionLabel = [KSYCustomLabel labelWithText:LocalString(@"SDK_Version") textColor:KSYRGB(121, 121, 121) font:KSYUIFont(14) textAlignment:NSTextAlignmentCenter backgroundColor:nil];
    [self.view addSubview:versionLabel];
    
    KSYCustomLabel *companyNameLabel = [KSYCustomLabel labelWithText:LocalString(@"Company_Name") textColor:KSYRGB(121, 121, 121) font:KSYUIFont(15) textAlignment:NSTextAlignmentCenter backgroundColor:nil];
    [self.view addSubview:companyNameLabel];
    //代码布局
    [sdkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(150);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(250,50));
    }];
    
    [serviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(sdkLabel.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(250,40));
        
    }];
    
    [companyNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).offset(-20);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 40));
    }];
    
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(companyNameLabel.mas_top).offset(-50);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 40));
    }];
    
    [liveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(versionLabel.mas_top).offset(-10);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 40));
        
    }];
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
-(void)beginLiveToEvent{
    KSYTabBarViewController *tabBarVC = [[KSYTabBarViewController alloc]init];
    [UIApplication sharedApplication].keyWindow.rootViewController = tabBarVC;
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark -
#pragma mark - life cycle 视图的生命周期
- (void)viewWillAppear:(BOOL)animated{
    //隐藏导航栏
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    //显示导航栏
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
