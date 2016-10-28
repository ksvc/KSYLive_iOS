//
//  controlView.h
//  KSYDemo
//
//  Created by 孙健 on 16/4/6.
//  Copyright © 2016年 孙健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYUIView.h"
@class KSYMenuView;
@class KSYStateLableView;

@interface KSYCtrlView : KSYUIView

#pragma mark - basic ctrl buttons
@property UIButton * btnFlash;
@property UIButton * btnCameraToggle;
@property UIButton * btnQuit;
@property UIButton * btnStream;
@property UIButton * btnCapture;
@property KSYStateLableView  * lblStat;
@property UILabel  * lblNetwork;


#pragma mark - menu buttons
//背景音乐
@property UIButton *bgmBtn;
//图像和美颜相关
@property UIButton *filterBtn;
//声音相关: 混音 / 混响 / 耳返等
@property UIButton *mixBtn;
//其他功能: 比如截屏
@property UIButton *miscBtn;
//返回菜单页面
@property UIButton *backBtn;


- (void) showSubMenuView: (KSYUIView*) view;

@end
