//
//  KSYFloatingWindowVC.m
//  KSYLiveDemo
//
//  Created by iVermisseDich on 2017/3/13.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYFloatingWindowVC.h"

@interface FloatingView : KSYUIView

@property UIButton * quitBtn;
@property GPUImageView * preView;
@property UILabel * text;
@property CGPoint loc_in;

@end

@implementation FloatingView
- (id) init {
    self = [super init];
    self.backgroundColor = [UIColor whiteColor];
    _text  = [self addLable:@"金山视频云依托业界领先的编解码技术与强大的分发服务，立足于金山云顶级的IaaS基础设施，提供一站式云直、点播服务。\n金山视频云提供内容生产及观看的工具，即推流播放SDK，凭借其完善的功能、卓越的兼容性及性能，满足客户不断涌现的业务需求，再通过金山魔方系统与第三方平台共同实现视频生态链的繁荣。\n\n金山云推流SDK支持H.264/H.265编码、软硬编，支持多种美颜滤镜特效、连麦，音频模块也在不断强化：美声、升降调、变声、混音等，弱网优化模块也颇有建树：码率自适应、网络主动探测、动态帧率等。\n金山云播放SDK通过首屏秒开、直播追赶等直播优化策略给直播提供一流的直播体验。"];
    _text.textAlignment = NSTextAlignmentCenter;
    _text.numberOfLines = 0;

    _preView = [[GPUImageView alloc] init];
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_preView addGestureRecognizer:panGes];
    
    [self addSubview:_preView];
    
    _quitBtn = [self addButton:@"X"];
    [_preView addSubview:_quitBtn];
    
    return self;
}

- (void)updateConstraints{
    [super updateConstraints];
    _quitBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:_quitBtn
                                 attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_preView
                                 attribute:NSLayoutAttributeRight
                                multiplier:1.0
                                  constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:_quitBtn
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:_preView
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:_quitBtn
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:30].active = YES;
    [NSLayoutConstraint constraintWithItem:_quitBtn
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:30].active = YES;
}

- (void)pan:(UIPanGestureRecognizer *)ges{
    CGPoint loc = [ges locationInView:self];
    if (ges.state == UIGestureRecognizerStateBegan) {
        _loc_in = [ges locationInView:_preView];
    }
    
    // 坐标矫正，避免画面超出屏幕
    CGFloat x;
    CGFloat y;
    if (_preView.frame.size.width - _loc_in.x + loc.x >= self.width){
        x = self.width - _preView.frame.size.width * 0.5;
    }else if (loc.x - _loc_in.x <= 0) {
        x = _preView.frame.size.width * 0.5;
    }else {
        x = _preView.frame.size.width * 0.5 - _loc_in.x + loc.x;
    }
    
    if (_preView.frame.size.height - _loc_in.y + loc.y >= self.height) {
        y = self.height - _preView.frame.size.height * 0.5;
    }else if (loc.y - _loc_in.y <= 0){
        y = _preView.frame.size.height * 0.5;
    }else {
        y = _preView.frame.size.height * 0.5 - _loc_in.y + loc.y;
    }
    
    [UIView animateWithDuration:0 animations:^{
        _preView.center = CGPointMake(x, y);
    }];
}

- (void)rotateUI{
    [super layoutUI];
    _text.frame =  CGRectMake(0, 60, self.width, 100);
    [_text sizeToFit];
}

- (void) layoutUI {
    [super layoutUI];
    CGFloat x = self.width/2;
    CGFloat wdt = self.width/3;
    CGFloat hgt = self.height/3;
    _text.frame =  CGRectMake(0, 60, self.width, 100);
    [_text sizeToFit];

    _preView.frame = CGRectMake(x, self.yPos, wdt, hgt);
}

@end


@interface KSYFloatingWindowVC ()
{
    FloatingView * _floatingView;
}
@end

@implementation KSYFloatingWindowVC


- (void)loadView{
    _floatingView = [[FloatingView alloc] init];
    self.view = _floatingView;
    @WeakObj(self);
    _floatingView.onBtnBlock = ^(id sender){
        [selfWeak  onBtn:sender];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    // 需要在父类方法之前调用
    self.view.frame = [UIApplication sharedApplication].keyWindow.bounds;

    if (_streamerVC) {
        [_streamerVC.kit.vPreviewMixer addTarget: _floatingView.preView];
        _floatingView.preView.transform = _streamerVC.kit.preview.transform;
    }

    [super viewWillAppear:animated];
}

-(void)layoutUI{
    _floatingView.frame = self.view.bounds;
    [_floatingView layoutUI];
}

- (void)onViewRotate{
    [_floatingView rotateUI];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)onBtn:(id)sender {
    if (sender == _floatingView.quitBtn) {
        [_streamerVC.kit.vPreviewMixer removeTarget:_floatingView.preView];
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
        return;
    }
}

@end
