//
//  KSYMenuView.h
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYUIView.h"

@interface KSYMenuView : KSYUIView
//背景音乐
@property UIButton *bgmBtn;
//美颜
@property UIButton *filterBtn;

//画中画
@property UIButton *pipBtn;
//其他功能: 比如截屏
@property UIButton *miscBtn;
//混音
@property UIButton *mixBtn;
//混响
@property UIButton *reverbBtn;
//返回
@property UIButton *backBtn;

- (void)hideAllBtn: (BOOL) bHide;

@end
