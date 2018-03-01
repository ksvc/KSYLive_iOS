//
//  KSYSecondVCBottomView.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/15.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYSecondVCBottomView.h"
#import "KSYSelectBottomButton.h"

#define TitleLabelHeight 30
#define Radio_margin 5

@implementation KSYSecondVCBottomView

-(void)setUpRadioTitleArray:(NSArray *)titleArray radioGroupId:(NSString*)groudId delegate:(id)delegate direction:(ScreenDirectionTest)direction{
    //按钮的宽度等于（屏幕的宽度 - 间距）/按钮的数量
    int buttonWidth;
    self.screenDirection = direction;
    if (direction == ScreenDirectionLandScapeTest) {
        buttonWidth = (KSYScreenHeight- Radio_margin*(titleArray.count+1))/titleArray.count;
    }
    else{
        buttonWidth = (KSYScreenWidth- Radio_margin*(titleArray.count+1))/titleArray.count;
    }
    for (int i = 0; i<titleArray.count; i++) {
        KSYSelectBottomButton* radioButton = [[KSYSelectBottomButton alloc]initWithFrame:KSYScreen_Frame(Radio_margin*(1+i)+buttonWidth*i,Radio_margin,buttonWidth,40) title:titleArray[i] titleColor:[UIColor whiteColor] selectedColor:[UIColor redColor] font:KSYUIFont(16) delegate:delegate groupId:groudId];
        if (titleArray.count>1&&i<titleArray.count-1) {
            UIView* lineView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(radioButton.frame),2, 2, 36)];
            lineView.backgroundColor = [UIColor redColor];
            [self addSubview:lineView];
        }
        
        if (i==0) {
            [radioButton setChecked:YES];
        }
        [self addSubview:radioButton];
        
    }
    
}

- (void)layoutSubviews {
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

