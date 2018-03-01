//
//  KSYSliderView.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/20.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYSliderView.h"

@implementation KSYSliderView

- (instancetype)initWithLeftTitle:(NSString*)title rightTitle:(float)number minimumValue:(float)minValue maxValue:(float)maxValue {
    if (self = [super init]) {
    
        UILabel *minLabel = [[UILabel alloc]init];
        minLabel.textAlignment = NSTextAlignmentRight;
        minLabel.text = title;
        minLabel.textColor = [UIColor whiteColor];
        minLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:minLabel];
        
        UISlider *slider = [[UISlider alloc]init];
        //设置slider的值
        slider.value = number;
        //设置最小值和最大值
        slider.minimumValue = minValue;
        slider.maximumValue = number;
        
        slider.tintColor = KSYRGB(236, 69, 84);
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:slider];
        self.sldier = slider;
        
        [minLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(50, 20));
        }];
        
        [slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(minLabel.mas_right).offset(5);
            make.top.equalTo(self);
            make.right.equalTo(self);
            make.height.mas_equalTo(20);
        }];
    }
    return self;
}

// slider变动时改变label值
- (void)sliderValueChanged:(UISlider *)sender {
   
    if (self.sliderBlockEvent) {
        self.sliderBlockEvent(sender);
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
