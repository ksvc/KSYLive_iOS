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
    UIButton *drawBtn;//画图按钮
    UIButton *drawDelBtn;//删图按钮
}
@property KSYGPUBrushStreamerKit *brushKit;
@property KSYDrawingView *drawView;
@property NSTimer        *nsTimer;
@property BOOL drawRefresh; //是否刷新画图图层
@property CGRect drawViewRect;
@end

@implementation KSYBrushStreamerVC
- (void)setupUI{
    [super setupUI];
    _nsTimer =  [NSTimer scheduledTimerWithTimeInterval:0.1
                                                 target:self
                                               selector:@selector(onTimer:)
                                               userInfo:nil
                                                repeats:YES];
    _drawRefresh = NO;
    _drawViewRect = CGRectMake(0, 0.15*self.view.frame.size.height, self.view.frame.size.width, 0.75*self.view.frame.size.height);
    _brushKit.drawPicRect = CGRectMake(0.0, 0.15, 1.0, 0.75);
    
    //draw view
    drawBtn = [self.ctrlView addButton:@"画图"];
    drawDelBtn = [self.ctrlView addButton:@"删图"];
    self.ctrlView.yPos = 50;
    [self.ctrlView putRow:@[drawBtn, drawDelBtn, [UIView new]]];

    self.profilePicker.hidden = YES;
}

- (void)viewDidLoad {
    _brushKit = [[KSYGPUBrushStreamerKit alloc] initWithDefaultCfg];
    self.kit = _brushKit;
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_brushKit) { // init with default filter
        _brushKit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [_brushKit setupFilter:self.curFilter];
        //启动预览
        [_brushKit startPreview:self.view];
    }
}

- (void)onBtn:(UIButton *)btn{
    [super onBtn:btn];
    if (btn == drawBtn){
        //画图
        [self onDraw];
    }else if (btn == drawDelBtn){
        //删图
        [self onDrawDel];
    }
}

- (void)onDraw{
    if (!_drawRefresh){
        _drawRefresh = YES;
        _drawView = [[KSYDrawingView alloc] initDraw:_drawViewRect];
        _drawView.frame = _drawViewRect;
        [_drawView.layer setBorderColor:[[UIColor blueColor] CGColor]];
        [_drawView.layer setBorderWidth:2.0f];
        [self.view addSubview:_drawView];
    }
}

- (void)onDrawDel{
    if (_drawRefresh){
        _drawRefresh = NO;
        [_brushKit removeDrawLayer];
        [_drawView removeFromSuperview];
    }
}

- (void)onQuit{
    [super onQuit];
    [self onDrawDel];
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (void)onTimer:(NSTimer *)theTimer{
    [self updateDrawView];
}

#pragma mark - utils
-(UIImage *)imageFromUIView:(UIView *)v {
    CGSize s = v.frame.size;
    UIGraphicsBeginImageContextWithOptions(s, NO, 0.0);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (void) updateDrawView{
    if(_drawRefresh){
        UIImage * img = [self imageFromUIView:_drawView];
        [_brushKit addDrawLayer:img];
    }
}

@end

