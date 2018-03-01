//
//  KSYSliderVauleChangeView.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/12/14.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KSYSliderView.h"

//返回
typedef void (^sliderReturnBlock)(UIButton *sender);

@interface KSYSliderVauleChangeView : UIView

@property (nonatomic,strong) NSString *nameTitle;
//回调事件
@property (nonatomic,copy) sliderReturnBlock block;
//磨皮
@property (nonatomic,strong) KSYSliderView *exfoliatingSlider;
//美白
@property (nonatomic,strong) KSYSliderView *whiteSlider;
//红润
@property (nonatomic,strong) KSYSliderView *hongrunSlider;
//音量
@property (nonatomic,strong) KSYSliderView *volumnSlider;
//音调
@property (nonatomic,strong) KSYSliderView *voiceSlider;

@end
