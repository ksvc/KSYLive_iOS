//
//  KSYSliderVauleChangeView.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/12/14.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYSliderVauleChangeView.h"

@interface KSYSliderVauleChangeView()

@end

@implementation KSYSliderVauleChangeView

- (instancetype)init {
    if (self = [super init]) {
        [self setUpChildView];
    }
    return self;
}

- (void)setUpChildView {
    
    //美白
    self.whiteSlider = [[KSYSliderView alloc]initWithLeftTitle:@"美白" rightTitle:1 minimumValue:0 maxValue:1];
    [self addSubview: self.whiteSlider];

    //红润
    self.hongrunSlider = [[KSYSliderView alloc]initWithLeftTitle:@"红润" rightTitle:1 minimumValue:0 maxValue:1];
    [self addSubview: self.hongrunSlider];
    
    //磨皮
    self.exfoliatingSlider = [[KSYSliderView alloc]initWithLeftTitle:@"磨皮" rightTitle:1 minimumValue:0 maxValue:1];
    [self addSubview: self.exfoliatingSlider];

    //音量
    self.volumnSlider = [[KSYSliderView alloc]initWithLeftTitle:@"音量" rightTitle:1 minimumValue:0 maxValue:1];
    [self addSubview: self.volumnSlider];

    //音调
    self.voiceSlider = [[KSYSliderView alloc]initWithLeftTitle:@"音调" rightTitle:1 minimumValue:0 maxValue:1];
    [self addSubview:self.voiceSlider];
  
    UIView *backgroundView = [[UIView alloc]init];
    backgroundView.backgroundColor = KSYRGB(151, 141, 123);
    [self addSubview:backgroundView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"调节关闭"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(returnBack:) forControlEvents:UIControlEventTouchUpInside];
    backButton.tag = 500;
    [backgroundView addSubview:backButton];
    
    UIButton* determineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [determineButton setImage:[UIImage imageNamed:@"调节完成"] forState:UIControlStateNormal];
    determineButton.tag = 501;
    [determineButton addTarget:self action:@selector(returnBack:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:determineButton];
    
    [self.whiteSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self).offset(10);
        make.height.mas_equalTo(30);
    }];
    [self.hongrunSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self.whiteSlider.mas_bottom).offset(10);
        make.height.mas_equalTo(30);
    }];
    [self.exfoliatingSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self.hongrunSlider.mas_bottom).offset(10);
        make.height.mas_equalTo(30);
    }];
    [self.volumnSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self).offset(20);
        make.height.mas_equalTo(35);
    }];
    [self.voiceSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self.volumnSlider.mas_bottom).offset(20);
        make.height.mas_equalTo(35);
    }];
    
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-50);
        make.left.equalTo(self);
        make.width.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backgroundView.mas_left).offset(5);
        make.top.equalTo(backgroundView.mas_top);
        make.size.mas_equalTo(CGSizeMake(50,50));
    }];
    [determineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(backgroundView.mas_right).offset(-5);
        make.top.equalTo(backgroundView.mas_top);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
}

//回调事件
-(void)returnBack:(UIButton*)sender{
    
    if ([self.nameTitle isEqualToString:@"美颜"]) {
        if (sender.tag == 500) {
            
        }
        else{
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",self.whiteSlider.sldier.value],@"美白",[NSString stringWithFormat:@"%f",self.hongrunSlider.sldier.value],@"红润",[NSString stringWithFormat:@"%f",self.exfoliatingSlider.sldier.value],@"磨皮",nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:KSYSkinCareChangeNotice object:nil userInfo:dic];
        }
        
    }
    //背景音乐
    else{
        if (sender.tag == 500) {
            
        }
        else{
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",self.volumnSlider.sldier.value],@"音量",[NSString stringWithFormat:@"%f",self.voiceSlider.sldier.value],@"音调",nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:KSYStreamVoiceOrVolumnNotice object:nil userInfo:dic];
        }
        
    }
    
    if (self.block) {
        self.block(sender);
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

