//
//  KSYRecordScreenView.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/12/17.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSYRecordScreenView : UIView

//录屏按钮
@property (nonatomic,strong) UIButton *recordScreenBtn;
//保存按钮
@property (nonatomic,strong) UIButton *saveButton;
//取消
@property (nonatomic,strong) UIButton *cancelButton;

@property (nonatomic, copy) void(^cancelOrSaveBlock)(UIButton *button);
@property (nonatomic,strong) UIImageView *flashImageView;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) NSTimer *countTimer;
//开始录制
- (void)beginRecord;
//结束录制
- (void)endRecord;
//清除内容
- (void)clearViewContent;

@end
