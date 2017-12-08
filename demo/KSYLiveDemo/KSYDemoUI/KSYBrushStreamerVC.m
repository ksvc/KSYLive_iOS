//
//  KSYBrushStreamerVC.m
//  KSYLiveDemo
//
//  Created by 江东 on 17/6/20.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYBrushStreamerVC.h"
#import "KSYDrawingView.h"
#import <libksygpulive/KSYGPUBrushStreamerKit.h>


@interface KSYBrushStreamerVC (){
    UIButton *_drawBtn;//启动/停止 画图按钮
}
@property KSYGPUBrushStreamerKit *brushKit;
@property KSYDrawingView *drawView;
@end

@implementation KSYBrushStreamerVC

- (void)viewDidLoad {
    _brushKit = [[KSYGPUBrushStreamerKit alloc] initWithDefaultCfg];
    self.kit = _brushKit;
    _brushKit.drawPicRect = CGRectMake(0.0, 0.15, 1.0, 0.75);
    [super viewDidLoad];
}
- (void)setupUI{
    [super setupUI];
    _drawBtn = [self.ctrlView addButton:@"启动画板"];
    [_drawBtn setTitle:@"清除画板" forState: UIControlStateSelected ];
    _drawView = [[KSYDrawingView alloc] init];
    [_drawView.layer setBorderColor:[[UIColor blueColor] CGColor]];
    [_drawView.layer setBorderWidth:2.0f];
    [self.view addSubview:_drawView];
    _drawView.hidden = YES;
    self.profilePicker.hidden = YES;
}

- (void)layoutUI{
    [super layoutUI];
    if (self.ctrlView == nil || _drawBtn == nil) {
        return;
    }
    self.ctrlView.yPos = CGRectGetMaxY(self.quitBtn.frame) + 4;
    [self.ctrlView putRow:@[_drawBtn, [UIView new]]];
    int hgt = self.ctrlView.frame.size.height;
    int wdt = self.ctrlView.frame.size.width;
    int offset = self.bgView.frame.origin.y;
    _drawView.frame = CGRectMake(0, 0.15*hgt+offset, wdt, 0.75*hgt);
    
    weakObj(self); // update layer on view update
    _drawView.viewUpdateCallback = ^{
        [selfWeak.brushKit.drawPic update];
    };
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_brushKit) { // init with default filter
        _brushKit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [_brushKit setupFilter:self.curFilter];
        //启动预览
        [_brushKit startPreview:self.bgView];
    }
}

- (void)onBtn:(UIButton *)btn{
    [super onBtn:btn];
    if (btn == _drawBtn){
        _drawBtn.selected = !_drawBtn.selected;
        if (_drawBtn.selected) { // 启动画板
            _brushKit.drawPic = [[KSYGPUViewCapture alloc] initWithView:_drawView];
            _drawView.hidden = NO;
        }
        else { //停止画板
            _brushKit.drawPic = nil;
            _drawView.hidden = YES;
            [_drawView clearAllPath];
        }
    }
}

- (void)onQuit{
    [super onQuit];
    _brushKit = nil;
}

- (BOOL)shouldAutorotate{
    return NO;
}

@end

