//
//  KSYSecondVCBottomView.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/15.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ScreenDirectionTest) {
    ScreenDirectionLandScapeTest = 0,
    ScreenDirectionPortraitTest = 1
};

@interface KSYSecondVCBottomView : UIView

@property (nonatomic,assign)ScreenDirectionTest screenDirection;

-(void)setUpRadioTitleArray:(NSArray *)titleArray radioGroupId:(NSString*)groudId delegate:(id)delegate direction:(ScreenDirectionTest)direction;

- (void)layoutSubviews;

@end

