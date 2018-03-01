//
//  KSYLiveControlView.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/12/15.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYLiveControlView.h"

@implementation KSYLiveControlView

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setUpButtonView:(NSString*)title {

    self.title = title;
    //美颜按钮
    UIButton *skinCareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [skinCareButton setBackgroundImage:[UIImage imageNamed:@"美颜"] forState:UIControlStateNormal];
    [skinCareButton addTarget:self action:@selector(TransferButtonTagToController:) forControlEvents:UIControlEventTouchUpInside];
    skinCareButton.tag = 200;
    [self addSubview:skinCareButton];
    self.skinCareButton = skinCareButton;
    
    //截图按钮
    UIButton *screenShotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [screenShotButton setBackgroundImage:[UIImage imageNamed:@"截屏"] forState:UIControlStateNormal];
    [screenShotButton addTarget:self action:@selector(TransferButtonTagToController:) forControlEvents:UIControlEventTouchUpInside];
    screenShotButton.tag = 201;
    [self addSubview:screenShotButton];
    self.screenShotButton = screenShotButton;
    
    if ([title isEqualToString:@"横竖屏切换"]) {

    }
    else{
        //录屏
        UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [recordButton setBackgroundImage:[UIImage imageNamed:@"录屏"] forState:UIControlStateNormal];
        [recordButton addTarget:self action:@selector(TransferButtonTagToController:) forControlEvents:UIControlEventTouchUpInside];
        recordButton.tag = 202;
        [self addSubview:recordButton];
        self.recordButton = recordButton;

        //悬浮窗
        UIButton *floatWindowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [floatWindowButton setBackgroundImage:[UIImage imageNamed:@"悬浮窗"] forState:UIControlStateNormal];
        [floatWindowButton addTarget:self action:@selector(TransferButtonTagToController:) forControlEvents:UIControlEventTouchUpInside];
        floatWindowButton.tag = 203;
        [self addSubview:floatWindowButton];
        self.floatWindowButton = floatWindowButton;
        
        //贴纸
        UIButton *stickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [stickerButton setBackgroundImage:[UIImage imageNamed:@"贴纸"] forState:UIControlStateNormal];
        [stickerButton addTarget:self action:@selector(TransferButtonTagToController:) forControlEvents:UIControlEventTouchUpInside];
        stickerButton.tag = 207;
        [self addSubview:stickerButton];
        self.stickerButton = stickerButton;
    }
    
    //相机
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setBackgroundImage:[UIImage imageNamed:@"相机翻转"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(TransferButtonTagToController:) forControlEvents:UIControlEventTouchUpInside];
    cameraButton.tag = 204;
    [self addSubview:cameraButton];
    self.cameraButton = cameraButton;
    
    //闪光灯
    UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashButton setBackgroundImage:[UIImage imageNamed:@"闪光灯关"] forState:UIControlStateNormal];
    [flashButton setBackgroundImage:[UIImage imageNamed:@"闪光灯"] forState:UIControlStateSelected];
    [flashButton addTarget:self action:@selector(TransferButtonTagToController:) forControlEvents:UIControlEventTouchUpInside];
    flashButton.tag = 205;
    [self addSubview:flashButton];
    self.flashButton = flashButton;
    
    //功能
    UIButton *functionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [functionButton setBackgroundImage:[UIImage imageNamed:@"功能"] forState:UIControlStateNormal];
   [functionButton addTarget:self action:@selector(TransferButtonTagToController:) forControlEvents:UIControlEventTouchUpInside];
    functionButton.tag = 206;
    [self addSubview:functionButton];
    self.functionButton = functionButton;
    
}

- (void)layoutSubviews {
    
    int buttonWH = 45;
    int rightMargin = -10;
    int bottomMargin = -20;
    
    [self.cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.bottom.equalTo(self).offset(bottomMargin);
        make.size.mas_equalTo(CGSizeMake(buttonWH, buttonWH));
    }];
    
    [self.flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cameraButton.mas_right).offset(20);
        make.bottom.equalTo(self).offset(bottomMargin);
        make.size.mas_equalTo(CGSizeMake(buttonWH, buttonWH));
    }];
    
    [self.functionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(rightMargin);
        make.bottom.equalTo(self).offset(bottomMargin);
        make.size.mas_equalTo(CGSizeMake(buttonWH, buttonWH));
    }];
    
    if ([self.title isEqualToString:@"横竖屏切换"]) {
        [self.screenShotButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(rightMargin);
            make.bottom.equalTo(self.functionButton.mas_top).offset(bottomMargin);
            make.size.mas_equalTo(CGSizeMake(buttonWH, buttonWH));
        }];
        
        [self.skinCareButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(rightMargin);
            make.bottom.equalTo(self.screenShotButton.mas_top).offset(bottomMargin);
            make.size.mas_equalTo(CGSizeMake(buttonWH, buttonWH));
        }];
        
        
    }
    else{
        [self.floatWindowButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(rightMargin);
            make.bottom.equalTo(self.functionButton.mas_top).offset(bottomMargin);
            make.size.mas_equalTo(CGSizeMake(buttonWH, buttonWH));
        }];
        
        [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(rightMargin);
            make.bottom.equalTo(self.floatWindowButton.mas_top).offset(bottomMargin);
            make.size.mas_equalTo(CGSizeMake(buttonWH, buttonWH));
        }];
        
        [self.screenShotButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(rightMargin);
            make.bottom.equalTo(self.recordButton.mas_top).offset(bottomMargin);
            make.size.mas_equalTo(CGSizeMake(buttonWH, buttonWH));
        }];
        
        [self.skinCareButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(rightMargin);
            make.bottom.equalTo(self.screenShotButton.mas_top).offset(bottomMargin);
            make.size.mas_equalTo(CGSizeMake(buttonWH, buttonWH));
        }];
        
        [self.stickerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(rightMargin);
            make.bottom.equalTo(self.skinCareButton.mas_top).offset(bottomMargin);
            make.size.mas_equalTo(CGSizeMake(buttonWH, buttonWH));
        }];
        
    }
}

/**
 按钮的响应事件

 @param sender 按钮对象
 */
- (void)TransferButtonTagToController:(UIButton*)sender {
    
    //相机翻转时，闪光灯关闭
    if (sender.tag == 204) {
        sender.selected = !sender.selected;
        if (sender.selected) {
            [self.flashButton setSelected:NO];
            self.flashButton.userInteractionEnabled = NO;
            
        }
        else{
            self.flashButton.userInteractionEnabled = YES;
            [self.flashButton setSelected:NO];
        }
    }
    //回传
    if (self.buttonBlock) {
        self.buttonBlock(sender);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
