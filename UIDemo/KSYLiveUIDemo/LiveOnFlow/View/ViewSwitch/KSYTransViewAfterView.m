//
//  KSYTransViewAfterView.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/12.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYTransViewAfterView.h"

#define ANIMATE_TIME .2f

@implementation KSYTransViewAfterView

-(instancetype)init{
    if (self = [super init]) {
        self = [self initWithFrame:CGRectZero];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.animateTime = ANIMATE_TIME;
        
    }
    return self;
}

-(void)transformDirection:(BOOL)isLeft withCurrentView:(UIView *)currentView withLastView:(UIView *)lastView{
    switch (self.translateType) {
        case KSYTranslateTypeTurn:
             [self turnWithCurrentView:currentView withLastView:lastView];
            break;
        case KSYTranslateTypeSlide:
            [self slideDirection:isLeft withCurrentView:currentView withLastView:lastView];
            break;
        default:
            break;
    }
}
//翻转切换视图
- (void)turnWithCurrentView:(UIView *)currentView withLastView:(UIView *)lastView {
    CGFloat offset = currentView.frame.size.height * 0.5;
    lastView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1, 0), CGAffineTransformTranslate(currentView.transform, 0, -offset));
    lastView.alpha = 0;
    lastView.hidden = NO;
    
    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0f, 0.01f), CGAffineTransformMakeTranslation(0, offset));
    [UIView animateWithDuration:self.animateTime animations:^{
        lastView.transform = CGAffineTransformIdentity;
        currentView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.21, 0.1), CGAffineTransformTranslate(currentView.transform, 0, -offset));
        lastView.alpha = 1;
        currentView.transform = transform;
        currentView.alpha = 0;
    }];
}

//滑动切换视图
- (void)slideDirection:(BOOL)isLeft withCurrentView:(UIView *)currentView withLastView:(UIView *)lastView {
    CGFloat offset = self.frame.size.width;
    
    CGAffineTransform leftTransform = CGAffineTransformMakeTranslation(-offset, 0);
    
    CGAffineTransform rightTransform = CGAffineTransformMakeTranslation(offset, 0);
    
    CGAffineTransform currentTransform,lastTransform;
    if (isLeft) {
        currentTransform = leftTransform;
        lastTransform = rightTransform;
    }
    else{
        lastTransform = leftTransform;
        currentTransform = rightTransform;
    }
    lastView.transform = lastTransform;
    lastView.hidden = NO;
    
    [UIView animateWithDuration:self.animateTime animations:^{
        currentView.transform = currentTransform;
        lastView.transform = CGAffineTransformIdentity;
    }];
    
}


/**
 *  使当前视图消失
 *
 *  @param currentView 当前视图
 */
- (void)dismissWithCurrentView:(UIView *)currentView {
    
    [UIView animateWithDuration:0.3f animations:^{
        currentView.transform = CGAffineTransformMakeScale(1.21, 1.21);
        currentView.alpha = 0;
    } completion:^(BOOL finished) {
        
        
        [self removeFromSuperview];
    }];
   
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
