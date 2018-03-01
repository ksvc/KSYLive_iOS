//
//  KSYTransViewAfterView.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/12.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    KSYTranslateTypeTurn,   //在同一个界面翻转、替换
    KSYTranslateTypeSlide, //滑动，替换
}KSYTranslateType;

@interface KSYTransViewAfterView : UIView

@property(nonatomic,assign)CGFloat animateTime; //动画时间
@property(nonatomic,assign)KSYTranslateType translateType; //切换视图的类型

/**
 切换视图

 @param isLeft 从哪个方向
 @param currentView 当前的视图
 @param lastView 将要展现的视图
 */
-(void)transformDirection:(BOOL)isLeft withCurrentView:(UIView*)currentView withLastView:(UIView*)lastView;

/**
  使当前视图消失

 @param currentView 当前视图   
 */
-(void)dismissWithCurrentView:(UIView*)currentView;

@end
