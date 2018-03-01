//
//  KSYLandScapeControlView.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/12/18.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^liveControlBlock)(UIButton *sender);

@interface KSYLandScapeControlView : UIView

//相机按钮
@property (nonatomic,strong) UIButton *cameraButton;
//闪光灯按钮
@property (nonatomic,strong) UIButton *flashButton;
//美颜按钮
@property (nonatomic,strong) UIButton *skinCareButton;
//镜像按钮
@property (nonatomic,strong) UIButton *mirrorButton;
//音量
@property (nonatomic,strong) UIButton *muteButton;
//拉流地址
@property (nonatomic,strong) UIButton *flowButton;
//回调的block
@property (nonatomic,copy) liveControlBlock buttonBlock;

@end
