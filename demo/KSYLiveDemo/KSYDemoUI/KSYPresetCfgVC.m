//
//  KSYPresetCfgVC.m
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 ksyun. All rights reserved.
//


#import "KSYPresetCfgVC.h"
#import "KSYUIView.h"
#import "KSYStreamerVC.h"
#import "KSYPipStreamerVC.h"
#import "KSYBgmStreamerVC.h"
#import "KSYFloatStreamerVC.h"

#ifdef KSYSTREAMER_DEMO
#import "TestVCs.h"
#endif

@interface KSYPresetCfgVC () {
}
@end

@implementation KSYPresetCfgVC

- (instancetype)initWithURL:(NSURL *)url{
    self = [super init];
    _rtmpURL = url;
    _cfgView = [[KSYPresetCfgView alloc] init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_cfgView == nil){
        _cfgView = [[KSYPresetCfgView alloc] init];
    }
    weakObj(self);
    _cfgView.onBtnBlock = ^(id sender){
        [selfWeak  btnFunc:sender];
    };
    _cfgView.frame = self.view.frame;
    self.view = _cfgView;
    
    //  TODO: !!!! 设置是否自动启动推流
    UIButton * btn = nil;
    //btn = _cfgView.btn2;
    if (btn) {
        [self pressBtn:btn after:0.5];
    }
    if (_rtmpURL ){
        _cfgView.hostUrlUI.text = _rtmpURL.absoluteString;
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self layoutUI];
}

- (void) pressBtn:( UIButton* ) btn after : (double) delay {
    dispatch_time_t dt = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(dt, dispatch_get_main_queue(), ^{
        [self btnFunc:btn];
    });
}

-(void)layoutUI{
    [_cfgView layoutUI];
}

- (BOOL)shouldAutorotate {
    [self layoutUI];
    return YES;
}
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self layoutUI];
}

- (IBAction)btnFunc:(id)sender {
    UIViewController *vc = nil;
    if ( sender == _cfgView.btn0) { // kit demo
        NSString * btnName = _cfgView.btn0.currentTitle;
        KSYStreamerVC * strVC = [[KSYStreamerVC alloc] initWithCfg:_cfgView];
        [strVC.ctrlView.btnStream setTitle:btnName forState:UIControlStateNormal];
        vc = strVC;
    }
    else if ( sender == _cfgView.btn1) { // pip demo
        NSString * btnName = _cfgView.btn1.currentTitle;
        KSYPipStreamerVC * strVC = [[KSYPipStreamerVC alloc] initWithCfg:_cfgView];
        [strVC.ctrlView.btnStream setTitle:btnName forState:UIControlStateNormal];
        vc = strVC;

    }
    else if ( sender == _cfgView.btn3) { // bgm demo
        NSString * btnName = _cfgView.btn3.currentTitle;
        KSYBgmStreamerVC * strVC = [[KSYBgmStreamerVC alloc] initWithCfg:_cfgView];
        [strVC.ctrlView.btnStream setTitle:btnName forState:UIControlStateNormal];
        vc = strVC;
    }
    else if (sender ==  _cfgView.btn5) { // floating demo
        NSString * btnName = _cfgView.btn5.currentTitle;
        KSYFloatStreamerVC *strVC = [[KSYFloatStreamerVC alloc] initWithCfg:_cfgView];
        [strVC.ctrlView.btnStream setTitle:btnName forState:UIControlStateNormal];
        vc = strVC;
    }
    else if ( sender == _cfgView.btn2) { // tests
#ifdef KSYSTREAMER_DEMO
        vc = [[TEST_VC alloc] init];
#endif
    }
    else if (sender == _cfgView.btn4) {
        [self dismissViewControllerAnimated:FALSE
                                 completion:nil];
        return;
    }

    if (vc){
        [self presentViewController:vc animated:true completion:nil];
    }
}
@end
