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
//美颜
@property UIButton *filterBtn;
//其他功能: 比如截屏
@property UIButton *miscBtn;
//混音
@property UIButton *mixBtn;
//混响
@property UIButton *reverbBtn;
//返回
@property UIButton *backBtn;

- (void) showSubMenuView: (UIView*) view;

@end
