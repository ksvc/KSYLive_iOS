//
//  CustomLaunchController.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/15.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "CustomLaunchController.h"

@interface CustomLaunchController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLab;

@end

@implementation CustomLaunchController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLab.text = [[[KSYMoviePlayerController alloc] init] getVersion];
}

- (IBAction)openPlayHandler:(id)sender {
    self.openPlayButton.userInteractionEnabled = NO;
    UIView *superView = [UIApplication sharedApplication].keyWindow;
    [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(superView);
        make.leading.mas_equalTo(-CGRectGetWidth(superView.frame));
        make.width.equalTo(superView);
    }];
    [UIView animateWithDuration:0.5 animations:^{
        [superView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        self.hasRemoved = YES;
    }];
}


@end
