//
//  KSYTabBarViewController.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/3.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYTabBarViewController.h"
#import "KSYLiveOnFlowViewController.h"
#import "KSYDemandListViewController.h"
#import "KSYNavigationViewController.h"
#import "VideoListShowController.h"

#import "UIImage+KSYImage.h"
#import "WXCustomTabBar.h"
#import "UIView+Extension.h"


@interface KSYTabBarViewController () {
    WXCustomTabBar *tabBar;
}
//@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation KSYTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpTabBarItemAttr];
    [self setUpChildViewController];
    [self setUpTabBar];
}

#pragma mark -
#pragma mark - private methods 私有方法

/**
 设置TabBar的属性
 */
- (void)setUpTabBarItemAttr
{  //设置tabbar的颜色
    //    [[UITabBar appearance]setBackgroundColor:[UIColor blackColor]];
    //    [UITabBar appearance].translucent = NO;
    UITabBarItem *item = [UITabBarItem appearance];
    // UIControlStateNormal状态下的属性
    NSMutableDictionary *normalAttr = [NSMutableDictionary dictionary];
    // 设置字体颜色
    normalAttr[NSForegroundColorAttributeName] = [UIColor grayColor];
    // 设置字体大小
    normalAttr[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    // UIControlStateSelected状态下的属性
    NSMutableDictionary *selectAttr = [NSMutableDictionary dictionary];
    selectAttr[NSForegroundColorAttributeName] = [UIColor colorWithRed:240/255.0 green:156/255.0 blue:30/255.0 alpha:1];
    [item setTitleTextAttributes:normalAttr forState:UIControlStateNormal];
    [item setTitleTextAttributes:selectAttr forState:UIControlStateSelected];
}

//设置自控制器
-(void)setUpChildViewController{
    
    VideoListShowController *listVC = [[VideoListShowController alloc]init];
    listVC.showType = VideoListShowTypeLive;
    [self setUpOneChildViewController:listVC image:[UIImage imageNamed:@"tabBar_icon_schedule_default"] selectedImage:[UIImage imageWithOriginalName:@"tabBar_icon_schedule"] title:@"直播"];
    
    KSYDemandListViewController *demandVC = [[KSYDemandListViewController alloc]init];
    demandVC.ksyShowType = VideoListShowTypeVod;
    [self setUpOneChildViewController:demandVC image:[UIImage imageNamed:@"tabBar_icon_contrast_default"] selectedImage:[UIImage imageWithOriginalName:@"tabBar_icon_contrast"] title:@"点播"];
}

/**
 替换系统的tabbar
 */
- (void)setUpTabBar
{
    [self setValue:[[WXCustomTabBar alloc] init] forKeyPath:@"tabBar"];
}
/**
 
 设置子控制器
 @param VC 子控制器
 @param image 普通背景图
 @param selectedImage 选中背景图片
 @param title 标题
 */
-(void)setUpOneChildViewController:(UIViewController *)VC image:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title {
    
    VC.title = title;
    VC.tabBarItem.image = image;
    VC.tabBarItem.selectedImage = selectedImage;
    // 保存tabBarItem模型到数组
    //[self.items addObject:VC.tabBarItem];
    KSYNavigationViewController *nav = [[KSYNavigationViewController alloc] initWithRootViewController:VC];
    [self addChildViewController:nav];
}
#pragma mark -
#pragma mark - Override 复写方法

- (BOOL)shouldAutorotate {
    return YES;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
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
