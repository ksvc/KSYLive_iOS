//
//  KSYSettingPartView.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/9.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYSettingPartView.h"
#import "KSYRadioButton.h"

//#define radioTag 4000

#define TitleLabelHeight 30
#define Radio_margin 5
@interface KSYSettingPartView()

@end

@implementation KSYSettingPartView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setUptitleLabel:(NSString*)title withRadioTitleArray:(NSArray *)titleArray radioGroupId:(NSString*)groudId delegate:(id)delegate {
    
       KSYCustomLabel *pushFlowLabel = [KSYCustomLabel labelWithText:title textColor:KSYRGB(121, 121, 121) font:KSYUIFont(16) textAlignment:NSTextAlignmentLeft backgroundColor:nil];
        pushFlowLabel.frame = KSYScreen_Frame(Radio_margin, Radio_margin, KSYViewFrame_Size_Width(self), TitleLabelHeight);
    
        [self addSubview:pushFlowLabel];
    
    //按钮的宽度等于（屏幕的宽度 - 间距）/按钮的数量
    int buttonWidth = (KSYScreenWidth- Radio_margin*(titleArray.count+1))/titleArray.count;
    
    for (int i = 0; i<titleArray.count; i++) {
            KSYRadioButton* radioButton = [[KSYRadioButton alloc]initWithFrame:KSYScreen_Frame(Radio_margin*(1+i)+buttonWidth*i,CGRectGetMaxY(pushFlowLabel.frame)+ Radio_margin,buttonWidth,40) title:titleArray[i] titleColor:[UIColor blackColor] font:KSYUIFont(16) delegate:delegate groupId:groudId];
        //radioButton.tag = radioTag + i;
//        if (i == 1) {
//            [radioButton setChecked:YES];
//        }
        NSString *title = [[NSUserDefaults standardUserDefaults] objectForKey:groudId];
        if ([titleArray[i] isEqual:title]) {
            [radioButton setChecked:YES];
        }
        [self addSubview:radioButton];
    }
}

@end
