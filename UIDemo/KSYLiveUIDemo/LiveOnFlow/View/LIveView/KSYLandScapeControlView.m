//
//  KSYLandScapeControlView.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/12/18.
//  Copyright © 2017年 王旭. All rights reserved.
//


#import "KSYLandScapeControlView.h"

@implementation KSYLandScapeControlView

- (instancetype)init {
    if (self = [super init]) {
        [self setUpButtonView];
    }
    return self;
}

- (void)setUpButtonView {

    //相机
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setBackgroundImage:[UIImage imageNamed:@"相机翻转"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(TransferButtonTagToController:) forControlEvents:UIControlEventTouchUpInside];
    cameraButton.tag = 600;
    [self addSubview:cameraButton];
    self.cameraButton = cameraButton;
    
    //闪光灯
    UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashButton setBackgroundImage:[UIImage imageNamed:@"闪光灯关"] forState:UIControlStateNormal];
    [flashButton setBackgroundImage:[UIImage imageNamed:@"闪光灯"] forState:UIControlStateSelected];
    [flashButton addTarget:self action:@selector(TransferButtonTagToController:) forControlEvents:UIControlEventTouchUpInside];
    flashButton.tag = 601;
    [self addSubview:flashButton];
    self.flashButton = flashButton;
    
    //美颜按钮
    UIButton *skinCareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [skinCareButton setBackgroundImage:[UIImage imageNamed:@"美颜"] forState:UIControlStateNormal];
    [skinCareButton addTarget:self action:@selector(TransferButtonTagToController:) forControlEvents:UIControlEventTouchUpInside];
    skinCareButton.tag = 602;
    [self addSubview:skinCareButton];
    self.skinCareButton = skinCareButton;
    //镜像
    UIButton *mirrorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mirrorButton setBackgroundImage:[UIImage imageNamed:@"镜像"] forState:UIControlStateNormal];
    [mirrorButton addTarget:self action:@selector(TransferButtonTagToController:) forControlEvents:UIControlEventTouchUpInside];
    mirrorButton.tag = 603;
    [self addSubview:mirrorButton];
    self.mirrorButton = mirrorButton;
    //静音
    UIButton *muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [muteButton setBackgroundImage:[UIImage imageNamed:@"静音未开"] forState:UIControlStateNormal];
    [muteButton setBackgroundImage:[UIImage imageNamed:@"静音开"] forState:UIControlStateSelected];

    [muteButton addTarget:self action:@selector(TransferButtonTagToController:) forControlEvents:UIControlEventTouchUpInside];
    muteButton.tag = 604;
    [self addSubview:muteButton];
    self.muteButton = muteButton;
    
    //拉流地址按钮
    UIButton *flowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flowButton setBackgroundImage:[UIImage imageNamed:@"拉流地址"] forState:UIControlStateNormal];
    [flowButton addTarget:self action:@selector(TransferButtonTagToController:) forControlEvents:UIControlEventTouchUpInside];
    flowButton.tag = 605;
    [self addSubview:flowButton];
    self.flowButton = flowButton;
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
    
    //音量
    [self.muteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(rightMargin);
        make.bottom.equalTo(self).offset(bottomMargin);
        make.size.mas_equalTo(CGSizeMake(buttonWH, buttonWH));
    }];
    
    [self.mirrorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.muteButton.mas_left).offset(rightMargin);
        make.bottom.equalTo(self).offset(bottomMargin);
        make.size.mas_equalTo(CGSizeMake(buttonWH, buttonWH));
    }];
    
    [self.skinCareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mirrorButton.mas_left).offset(rightMargin);
        make.bottom.equalTo(self).offset(bottomMargin);
        make.size.mas_equalTo(CGSizeMake(buttonWH, buttonWH));
    }];
    
    [self.flowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(rightMargin);
        make.bottom.equalTo(self.muteButton.mas_top).offset(bottomMargin);
        make.size.mas_equalTo(CGSizeMake(buttonWH, buttonWH));
    }];
    
}

/**
 按钮的响应事件
 
 @param sender 按钮对象
 */
- (void)TransferButtonTagToController:(UIButton*)sender {

    //相机翻转时，闪光灯关闭
    if (sender.tag == 600) {
        sender.selected = !sender.selected;
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

