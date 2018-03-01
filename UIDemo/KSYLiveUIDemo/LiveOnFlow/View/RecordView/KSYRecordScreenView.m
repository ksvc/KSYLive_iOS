//
//  KSYRecordScreenView.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/12/17.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYRecordScreenView.h"
#import "UIColor+Additions.h"

@interface KSYRecordScreenView(){
     int second; //推流的时间
}

@property (nonatomic,strong) CALayer* recordProgressLayer;
@property (nonatomic,strong) UIView* headView;

@end

@implementation KSYRecordScreenView

- (UILabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor whiteColor];
//        _timeLabel.backgroundColor = KSYRGB(138, 138, 138);
        _timeLabel.font = [UIFont systemFontOfSize:17];
        //_timeLabel.alpha = 0.f;
        [self.timeLabel setText:@"00:00"];
    }
    return _timeLabel;
}


- (instancetype)init {
    if (self = [super init]) {
        [self setUpControlView];
        [self setUpLayer];
    }
    return self;
}

-(void)setUpControlView{
    UIView *headView = [[UIView alloc]init];
    headView.frame = CGRectMake(0, 0, KSYScreenWidth, 64);
    headView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2];
    [self addSubview:headView];
    self .headView = headView;
    
    KSYWeakSelf;
    UIButton *cancelBtn = [[UIButton alloc]initButtonWithTitle:@"取消" titleColor:[UIColor whiteColor] font:KSYUIFont(14) backGroundColor:KSYRGB(112,87,78)  callBack:^(UIButton *sender) {
        //结束录制
        [weakSelf endRecord];
        //清空内容
        [weakSelf clearViewContent];

        weakSelf.cancelOrSaveBlock(sender);
    }];
    cancelBtn.tag = 400;
    [headView addSubview:cancelBtn];
    self.cancelButton = cancelBtn;
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView).offset(-10);
        make.top.mas_equalTo(@20);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    
    UIButton* saveBtn = [[UIButton alloc]initButtonWithTitle:@"保存" titleColor:[UIColor whiteColor] font:KSYUIFont(14) backGroundColor:KSYRGB(112,87,78)  callBack:^(UIButton *sender) {
        weakSelf.cancelOrSaveBlock(sender);
    }];
    saveBtn.tag = 401;
    [headView addSubview:saveBtn];
    self.saveButton = saveBtn;
    self.saveButton.hidden = YES;
    
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headView).offset(-10);
        make.top.mas_equalTo(@20);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    
    UIButton* recordScreenBtn = [[UIButton alloc]initButtonWithTitle:@"" titleColor:[UIColor whiteColor] font:KSYUIFont(14) backGroundColor:KSYRGB(112,87,78)  callBack:^(UIButton *sender) {
        
         sender.selected = !sender.selected;
        if (sender.selected) {
            [weakSelf beginRecord];
        }
        else{
            [weakSelf endRecord];
        }
        // 省略了部分非关键代码
         weakSelf.cancelOrSaveBlock(sender);
       
    }];
    recordScreenBtn.tag = 402;
    [recordScreenBtn setImage:[UIImage imageNamed:@"录制"] forState:UIControlStateNormal];
    [recordScreenBtn setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateSelected];
    [self addSubview:recordScreenBtn];
    self.recordScreenBtn = recordScreenBtn;
   
    
    [recordScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-40);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [headView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       // make.left.equalTo(self.flashImageView).offset(10);
        make.centerX.equalTo(self);
        make.top.mas_equalTo(@20);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];
    
}

-(void)setUpLayer{
    
    self.recordProgressLayer = [CALayer layer];
    self.recordProgressLayer.backgroundColor = [UIColor colorWithHexString:@"FC3252"].CGColor;
    self.recordProgressLayer.frame = CGRectMake(0, 0, 0, 6);
    [self.headView.layer addSublayer:self.recordProgressLayer];
}

-(void)beginRecord{
    
    //开启定时器
    second = 0;
    self.countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countUpTime) userInfo:nil repeats:YES];
//    //呼吸动画
//    CABasicAnimation *animation =[CABasicAnimation animationWithKeyPath:@"opacity"];
//    animation.fromValue = [NSNumber numberWithFloat:1.0f];
//    animation.toValue = [NSNumber numberWithFloat:0.0f];
//    animation.autoreverses = YES;    //回退动画（动画可逆，即循环）
//    animation.duration = 1.0f;
//    animation.repeatCount = MAXFLOAT;
//    animation.removedOnCompletion = NO;
//    animation.speed = 2;
//    animation.fillMode = kCAFillModeForwards;//removedOnCompletion,fillMode配合使用保持动画完成效果
//    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    [self.flashImageView.layer addAnimation:animation forKey:@"aAlpha"];
}
- (void)endRecord {
    //移除动画
    //[self.flashImageView.layer removeAnimationForKey:@"aAlpha"];
    //定时器失效
    [self.countTimer invalidate];
}

- (void)clearViewContent {
    
    self.saveButton.hidden = YES;
    self.recordScreenBtn.hidden = NO;
    [self.recordScreenBtn setSelected:NO];
    
    //清空进度条
    self.recordProgressLayer.frame = CGRectMake(0, 0, 0, 6);
    second = 0;
    [self.timeLabel setText:[NSString stringWithFormat:@"00:%02d",second]];
}

/**
 计时器自增
 */
- (void)countUpTime {
    second ++ ;
    if (second>0&&second<=29) {
        // dispatch_async(dispatch_get_main_queue(), ^{
        [self.timeLabel setText:[NSString stringWithFormat:@"00:%02d",second]];
     
        CGRect viewFrame = self.headView.frame;
        CGRect viewProgressFrame = self.recordProgressLayer.frame;
        if (viewFrame.size.width > viewProgressFrame.size.width) {
            CGRect frame = viewProgressFrame;
            frame.size.width += KSYScreenWidth/30;
            self.recordProgressLayer.frame = frame;
        } else {
            
        }
        
     }
    else{
        [self endRecord];
        // 省略了部分非关键代码
        [self.recordScreenBtn setSelected:NO];
        self.cancelOrSaveBlock(self.recordScreenBtn);
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
