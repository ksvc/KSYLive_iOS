//
//  KSYLiveControlView.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/12/15.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^liveControlBlock)(UIButton *sender);

@interface KSYLiveControlView : UIView

@property (nonatomic,strong) NSString *title;
//美颜按钮
@property (nonatomic,strong) UIButton *skinCareButton;
//截屏按钮
@property (nonatomic,strong) UIButton *screenShotButton;
//录屏按钮
@property (nonatomic,strong) UIButton *recordButton;
//悬浮窗按钮
@property (nonatomic,strong) UIButton *floatWindowButton;
//相机按钮
@property (nonatomic,strong) UIButton *cameraButton;
//闪光灯按钮
@property (nonatomic,strong) UIButton *flashButton;
//功能按钮
@property (nonatomic,strong) UIButton *functionButton;
//贴纸按钮
@property (nonatomic,strong) UIButton *stickerButton;
//回调的block
@property(nonatomic,copy)liveControlBlock buttonBlock;

- (void)setUpButtonView:(NSString*)title;

@end
