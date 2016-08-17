//
//  KSYPresetCfgVC.m
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 ksyun. All rights reserved.
//

#import "KSYPresetCfgVC.h"
#import "KSYUIView.h"
#import "KSYPresetCfgView.h"
#import "KSYBlockDemoVC.h"
#import "KSYKitDemoVC.h"


#ifdef KSYSTREAMER_DEMO
@interface KSYSimpleStreamerVC : UIViewController
@end
@interface KSYGPUStreamerKitVC : UIViewController
@end
@interface rawVC : UIViewController
@end
@interface imageVC : UIViewController
@end
@interface movieWriterVC : UIViewController
@end
@interface KSYSimKitVC : UIViewController
@end
#endif

@interface KSYPresetCfgVC () {
    KSYPresetCfgView * _cfgView;
}

// 方便调试 可以在app启动后自动开启预览和推流
@property BOOL  bAutoStart;

@end

@implementation KSYPresetCfgVC

- (instancetype)initWithURL:(NSString *)url{
    self = [super init];
    _rtmpURL = url;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _cfgView = [[KSYPresetCfgView alloc] init];
    __weak KSYPresetCfgVC * weakSelf = self;
    _cfgView.onBtnBlock = ^(id sender){
        [weakSelf  btnFunc:sender];
    };
    _cfgView.frame = self.view.frame;
    self.view = _cfgView;

    //  TODO: !!!! 设置是否自动启动推流
    _bAutoStart = NO;
    if (_bAutoStart) {
        [self pressBtnAfter:0.5];
    }
    if (_rtmpURL && [_rtmpURL length] ){
        _cfgView.hostUrlUI.text = _rtmpURL;
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [self layoutUI];
}

- (void) pressBtnAfter : (double) delay {
    dispatch_time_t dt = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(dt, dispatch_get_main_queue(), ^{
        [self btnFunc:_cfgView.btn0];
    });
}

-(void)layoutUI{
    [_cfgView layoutUI];
}

- (BOOL)shouldAutorotate {
    [self layoutUI];
    return YES;
}

- (IBAction)btnFunc:(id)sender {
    UIViewController *vc = nil;
    if ( sender == _cfgView.btn0) { // kit demo
        vc = [[KSYKitDemoVC alloc] initWithCfg:_cfgView];
    }
    else if (sender == _cfgView.btn1) { // block demo
        vc = [[KSYBlockDemoVC alloc] initWithCfg:_cfgView];
    }
    else if ( sender == _cfgView.btn2) { // tests
#ifdef KSYSTREAMER_DEMO
        vc = [[KSYSimpleStreamerVC alloc] init];
        vc = [[imageVC alloc] init];
        //vc = [[movieWriterVC alloc] init];
#else
        [self dismissViewControllerAnimated:FALSE
                                 completion:nil];
        return;
#endif
    }
    if (vc){
        [self presentViewController:vc animated:true completion:nil];
    }
}

@end
