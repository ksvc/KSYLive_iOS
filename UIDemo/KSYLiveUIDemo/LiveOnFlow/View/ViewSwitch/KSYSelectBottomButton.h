//
//  KSYSelectBottomButton.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/15.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSYSelectBottomButton;
//声明协议
@protocol KSYSelectBottomButtonDelegate <NSObject>

@optional
//协议方法
-(void)didSelectedBottomButton:(KSYSelectBottomButton*)button groupId:(NSString*)groupId;


@end

@interface KSYSelectBottomButton : UIButton

//代理
@property(nonatomic,weak)id<KSYSelectBottomButtonDelegate>delegate;
//按钮标识
@property(nonatomic,copy)NSString* groudId;
//按钮的状态
@property(nonatomic,assign)BOOL checked;

-(id)initWithFrame:(CGRect)frame title:(NSString*)title titleColor:(UIColor*)titleColor selectedColor:(UIColor*)selectedColor font:(UIFont*)font delegate:(id)delegate groupId:(NSString *)groupId;

@end
