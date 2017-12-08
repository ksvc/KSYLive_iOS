//
//  KSYSimplestStreamerVC.m
//  KSYLiveDemo
//
//  Created by 孙健 on 2017/2/7.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYHorScreenStreamerVC.h"
#import <libksygpulive/KSYGPUStreamerKit.h>

@interface KSYHorScreenStreamerVC ()
@property UILabel           *text;
@property UIView      *preView;
@end

@implementation KSYHorScreenStreamerVC

- (void)setupUI{
    [super setupUI];
    _text = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 30)];
    [self.view addSubview:_text];
    _text.textAlignment = NSTextAlignmentCenter;
    _text.backgroundColor = [UIColor lightGrayColor];
    _text.text = @"Comments";
    _text.hidden = YES;
    self.bgView.backgroundColor = [UIColor whiteColor];
    CGFloat wdt = self.view.frame.size.width;
    CGFloat offset = CGRectGetMaxY(self.quitBtn.frame) + 4;
    offset += self.bgView.frame.origin.y;
    _preView = [[UIView alloc] initWithFrame:CGRectMake(0, offset, wdt, wdt * 9.0 / 16)];
    [self.view addSubview:_preView];
    _preView.hidden = YES;
    self.profilePicker.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self onCapture];
}

- (void)onCapture{
    _text.hidden = NO;
    _preView.hidden = NO;
    if (!self.kit.vCapDev.isRunning){
        // 半屏推流(预览视图不是全屏的, 预览视图的size如下)
        CGSize preSz = _preView.frame.size;
        // 1. preView的宽高比大于1的情况下，需要避免根据方向进行调整previewDimension
        self.kit.videoOrientation = preSz.width > preSz.height ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
        
        // 2. 设置采集画面输出方向(手机竖屏, 采集的画面也是竖屏)
        self.kit.vCapDev.outputImageOrientation = UIDeviceOrientationPortrait;
        
        // 3. 根据_preView的[宽高比]进行设置预览和推流分辨率，即可做到任意size的半屏推流
        CGFloat ratio = preSz.height / preSz.width;
        self.kit.previewDimension = CGSizeMake(1080, 1080 * ratio);
        self.kit.streamDimension = CGSizeMake(720, 720 *ratio);
        
        // 4. 开启预览
        [self.kit startPreview:self.preView];
        
    }
    else {
        [self.kit stopPreview];
    }
}

- (BOOL)shouldAutorotate{
    return NO;
}

@end
