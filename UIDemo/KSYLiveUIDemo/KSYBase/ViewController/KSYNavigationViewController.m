//
//  KSYNavigationViewController.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/3.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYNavigationViewController.h"

@interface KSYNavigationViewController()<UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation KSYNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationBarAppearance];
    [self settingPopDelegate];
}

#pragma mark -
#pragma mark - private methods 私有方法
/**
 设置导航栏属性
 */
- (void)setNavigationBarAppearance{
    UINavigationBar* navItem = [UINavigationBar appearance];
    [navItem setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [navItem setBarTintColor:[UIColor colorWithRed:8/255.0 green:8/255.0 blue:11/255.0 alpha:1/1.0]];
    navItem.translucent = NO;
}
- (void)settingPopDelegate {
    //系统自带手势返回
    self.interactivePopGestureRecognizer.delegate = self;
}

#pragma mark -
#pragma mark - Override 复写方法
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //设置导航条左边按钮
    if (self.viewControllers.count != 0)
    {
        UIBarButtonItem *menuItem = [UIBarButtonItem barButtonItemWithImageName:@"返回" frame:KSYScreen_Frame(0, 0, 30, 30) target:self action:@selector(back)];
        viewController.navigationItem.leftBarButtonItem = menuItem;
    }
    [super pushViewController:viewController animated:animated];
}
//导航控制器跳转完成的时候调用
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self.viewControllers[0]) {//显示根控制器
        navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    else{
        navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
//直接返回子控制器tabBar上的按钮会重新加载要获取TabBarVC重新删除
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //UITabBarController *tabBarVc = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    // 删除系统自带的tabBarButton
    //    for (UIView *tabBarButton in tabBarVc.tabBar.subviews) {
    //        if (![tabBarButton isKindOfClass:[AXHTabBar class]]) {
    //            [tabBarButton removeFromSuperview];
    //        }
    //    }
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (void)back {
    [self popViewControllerAnimated:YES];
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
