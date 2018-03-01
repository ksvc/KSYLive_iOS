//
//  KSYSliderView.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/20.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^sliderBlock)(UISlider *slider);

@interface KSYSliderView : UIView

@property (nonatomic,copy) sliderBlock sliderBlockEvent;
@property (nonatomic,strong) UISlider *sldier;

-(instancetype)initWithLeftTitle:(NSString*)title rightTitle:(float)number minimumValue:(float)minValue maxValue:(float)maxValue;

@end
