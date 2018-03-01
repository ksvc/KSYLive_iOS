//
//  ChoiceViewController.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/22.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "ChoiceViewController.h"
#import "VideoListShowController.h"
#import "Constant.h"

#import "CustomLaunchController.h"

@interface ChoiceViewController ()
@property (nonatomic, strong) CustomLaunchController *launchController;
@end

@implementation ChoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.launchController = [[CustomLaunchController alloc] init];
    [self showLaunchView];
}

- (void)showLaunchView {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *superView = keyWindow;
    UIView *launchView = self.launchController.view;
    [superView addSubview:launchView];
    [self.launchController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView);
    }];
    [self addChildViewController:self.launchController];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.launchController.hasRemoved) {
            self.launchController = nil;
        } else {
            self.launchController.openPlayButton.userInteractionEnabled = NO;
            [launchView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(superView);
                make.leading.mas_equalTo(-CGRectGetWidth(superView.frame));
                make.width.equalTo(superView);
            }];
            [UIView animateWithDuration:0.5 animations:^{
                [keyWindow layoutIfNeeded];
            } completion:^(BOOL finished) {
                [launchView removeFromSuperview];
                [self.launchController removeFromParentViewController];
                self.launchController.hasRemoved = YES;
                self.launchController = nil;
            }];
        }
    });
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    VideoListShowType showType = VideoListShowTypeUnknown;
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:@"pushToLiveVideoListId"]) {
        showType = VideoListShowTypeLive;
    } else if ([identifier isEqualToString:@"pushToVodVideoListId"]) {
        showType = VideoListShowTypeVod;
    }
    if (showType != VideoListShowTypeUnknown) {
        VideoListShowController *vlsc = (VideoListShowController *)segue.destinationViewController;
        vlsc.showType = showType;
    }
}


@end
