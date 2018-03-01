//
//  KSYRadioButton.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/8.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSYRadioButton;

@protocol KSYRadioButtonDelegate <NSObject>

@optional

-(void)didSelectedRadioButton:(KSYRadioButton*)radioButton groupId:(NSString*)groupId;

@end

@interface KSYRadioButton : UIButton

//代理
@property(nonatomic,weak)id<KSYRadioButtonDelegate>delegate;
//按钮标识
@property(nonatomic,copy)NSString *groudId;
//按钮的状态
@property(nonatomic,assign)BOOL checked;

- (id)initWithFrame:(CGRect)frame title:(NSString*)title titleColor:(UIColor*)titleColor font:(UIFont*)font delegate:(id)delegate groupId:(NSString *)groupId ;

@end
