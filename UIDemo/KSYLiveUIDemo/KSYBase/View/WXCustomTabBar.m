//
//  WXCustomTabBar.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/4/21.
//  Copyright © 2017年 kys-5. All rights reserved.
//

#import "WXCustomTabBar.h"
#import "KSYNavigationViewController.h"
#import "KSYLiveOnFlowViewController.h"

@interface WXCustomTabBar()
@property (nonatomic, strong) UIButton *centerBtn;
@end

@implementation WXCustomTabBar

#pragma mark -
#pragma mark - Override 复写方法
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBarTintColor:[UIColor blackColor]];
        self.translucent = NO;
        // 设置tabBarItem选中状态时的颜色
        self.tintColor = [UIColor redColor];
        // 添加中间按钮到tabBar上
        [self addSubview:self.centerBtn];
    }
    return self;
}
// 重新布局tabBarItem（这里需要具体情况具体分析，本例是中间有个按钮，两边平均分配按钮）
- (void)layoutSubviews {
    [super layoutSubviews];
    // 把tabBarButton取出来（把tabBar的SubViews打印出来就明白了）
    NSMutableArray *tabBarButtonArray = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabBarButtonArray addObject:view];
        }
    }
    
    CGFloat barWidth = self.bounds.size.width;
    CGFloat barHeight = self.bounds.size.height;
    CGFloat centerBtnWidth = CGRectGetWidth(self.centerBtn.frame);
    CGFloat centerBtnHeight = CGRectGetHeight(self.centerBtn.frame);
    // 设置中间按钮的位置，居中，凸起一丢丢
    //适配iphoneX
    if ([[KSYGetDeviceName getDeviceName] isEqual:@"iPhoneX"]) {
        self.centerBtn.center = CGPointMake(barWidth / 2, barHeight - centerBtnHeight/2 - 5 - SafeAreaBottomHeight);
    }
    else {
        self.centerBtn.center = CGPointMake(barWidth / 2, barHeight - centerBtnHeight/2 - 5);
    }
    
    // 重新布局其他tabBarItem
    // 平均分配其他tabBarItem的宽度
    CGFloat barItemWidth = (barWidth - centerBtnWidth) / tabBarButtonArray.count;
    // 逐个布局tabBarItem，修改UITabBarButton的frame
    [tabBarButtonArray enumerateObjectsUsingBlock:^(UIView *  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGRect frame = view.frame;
        if (idx >= tabBarButtonArray.count / 2) {
            // 重新设置x坐标，如果排在中间按钮的右边需要加上中间按钮的宽度
            frame.origin.x = idx * barItemWidth + centerBtnWidth;
        } else {
            frame.origin.x = idx * barItemWidth;
        }
        // 重新设置宽度
        frame.size.width = barItemWidth;
        view.frame = frame;
    }];
    // 把中间按钮带到视图最前面
    [self bringSubviewToFront:self.centerBtn];
}

// 重写hitTest方法，让超出tabBar部分也能响应事件
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.clipsToBounds || self.hidden || (self.alpha == 0.f)) {
        return nil;
    }
    UIView *result = [super hitTest:point withEvent:event];
    // 如果事件发生在tabbar里面直接返回
    if (result) {
        return result;
    }
    // 这里遍历那些超出的部分就可以了，不过这么写比较通用。
    for (UIView *subview in self.subviews) {
        // 把这个坐标从tabbar的坐标系转为subview的坐标系
        CGPoint subPoint = [subview convertPoint:point fromView:self];
        result = [subview hitTest:subPoint withEvent:event];
        // 如果事件发生在subView里就返回
        if (result) {
            return result;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark - getters and setters 设置器和访问器
- (UIButton *)centerBtn {
    if (_centerBtn == nil) {
        _centerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_centerBtn setImage:[UIImage imageNamed:@"直播"] forState:UIControlStateNormal];
        [_centerBtn addTarget:self action:@selector(clickCenterBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _centerBtn;
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (void)clickCenterBtn:(UIButton *)sender {
    KSYLiveOnFlowViewController* liveOnFlowVC = [[KSYLiveOnFlowViewController alloc]init];
    KSYNavigationViewController *nav = [[KSYNavigationViewController alloc] initWithRootViewController:liveOnFlowVC];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
