//
//  KSYFloatStreamerVC.m
//  KSYLiveDemo
//
//  Created by iVermisseDich on 2017/3/15.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYFloatStreamerVC.h"
#import "KSYFloatingWindowVC.h"
@interface KSYFloatStreamerVC ()

@end

@implementation KSYFloatStreamerVC

- (void)viewDidLoad {
    self.menuNames = [self.menuNames arrayByAddingObject:@"悬浮窗"];
    [super viewDidLoad];
}

- (void)onMenuBtnPress:(UIButton *)btn{
    [super onMenuBtnPress:btn];
    if (btn == self.ctrlView.menuBtns[self.menuNames.count - 1] ){
        // 悬浮窗播放
        KSYFloatingWindowVC *floatintVC = [[KSYFloatingWindowVC alloc] init];
        floatintVC.streamerVC = self;
        [self presentViewController:floatintVC animated:YES completion:nil];
    }
}

// 旋转式layoutUI
- (void)rotateUI{
    if (self.ctrlView) {
        CGFloat minWidth = MIN(self.view.frame.size.width, self.view.frame.size.height);
        CGFloat maxWidth = MAX(self.view.frame.size.width, self.view.frame.size.height);
        self.ctrlView.frame = self.ksyFilterView.swUiRotate.on ?  self.view.bounds : CGRectMake(0, 0, minWidth , maxWidth);
        [self.ctrlView layoutUI];
    }
}

// 重写父类layoutUI方法
- (void)layoutUI {
    if(self.ctrlView){
        CGFloat minWidth = MIN(self.view.frame.size.width, self.view.frame.size.height);
        CGFloat maxWidth = MAX(self.view.frame.size.width, self.view.frame.size.height);
        self.ctrlView.frame = (!UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) ?  CGRectMake(0, 0, maxWidth , minWidth) : CGRectMake(0, 0, minWidth , maxWidth);
        [self.ctrlView layoutUI];
    }
}

@end
