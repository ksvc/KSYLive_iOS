//
//  ALFavourView.m
//  Nemo
//
//  Created by iVermisseDich on 16/11/23.
//  Copyright © 2016年 com.ksyun. All rights reserved.
//


#import "NemoFavourView.h"
#import "NemoFavourCALayer.h"
// 点赞图标宽度
#define kFavourLength 30


@implementation NemoFavourView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)dismiss{
    [self removeFromSuperview];
}

- (void)animationStart{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        [strongSelf addAnimation];
    });
}

- (void)addAnimation {
    
    NSInteger index = arc4random() % self.imageArray.count;
    CGFloat kWidth = CGRectGetWidth(self.frame);
    CGFloat kHeigth = CGRectGetHeight(self.frame);
    CGFloat positionX = kWidth - kFavourLength + 5;
    CGFloat positionY = kHeigth - kFavourLength;
    
    // 1.opacity动画
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    
    // 2.scale动画 从小变大
    CAKeyframeAnimation *animationScale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animationScale.values = @[@(0.0),@(1.0)];
    animationScale.keyTimes = @[@(0.0),@(1.0)];
    animationScale.duration  = 0.7;
    animationScale.calculationMode = kCAAnimationCubic;
    
    // 3.关键帧动画
    CAKeyframeAnimation * moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat smallDwidth = kWidth - kFavourLength ;
    CGFloat otherDwidth = kFavourLength / 2;
    CGPoint p0 = CGPointMake(kWidth - 10 - 18, positionY - kHeigth * 0.0875);
    CGPoint p1 = CGPointMake(positionX - 5, p0.y - kHeigth * 0.0625);
    CGPoint p2 = CGPointMake(arc4random() % (NSInteger)smallDwidth + otherDwidth,p1.y - kHeigth * 0.21875);
    CGPoint p3 = CGPointMake(arc4random() % (NSInteger)smallDwidth + otherDwidth + 1, p2.y - kHeigth * 0.28125);
    CGPoint p4 = CGPointMake(arc4random() % (NSInteger)smallDwidth + otherDwidth + 1, 0);
    NSArray *values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p0],[NSValue valueWithCGPoint:p0],[NSValue valueWithCGPoint:p1],[NSValue valueWithCGPoint:p2],[NSValue valueWithCGPoint:p3],[NSValue valueWithCGPoint:p4], nil];
    [moveAnimation setValues:values];
    moveAnimation.calculationMode = kCAAnimationCubicPaced;
    CGPathRelease(path);
    
    // 4.动画组
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 3;
    group.repeatCount = 0;
    group.removedOnCompletion = YES;
    group.fillMode = kCAFillModeForwards;
    [group setAnimations:[NSArray arrayWithObjects:animationScale,opacityAnimation,moveAnimation,nil]];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        
        NemoFavourCALayer *animationLayer = [[NemoFavourCALayer alloc] initWithAnimationGroup:group];
        animationLayer.bounds = CGRectMake(positionX, positionY, kFavourLength + 4, kFavourLength + 4);
        animationLayer.position = CGPointMake(kWidth - 10 - 12, (kHeigth - kFavourLength - 1.5) + kFavourLength / 2 - 2);
        if (index < (strongSelf.imageArray.count - 1)) {
            animationLayer.contents = (__bridge id)((UIImage *)strongSelf.imageArray[index]).CGImage;
        }else {
            if (strongSelf.imageArray.count > 0){
                animationLayer.contents = (__bridge id)((UIImage *)strongSelf.imageArray[0]).CGImage;
            }else{
                return;
            }
        }
        animationLayer.opacity = 0.f;
        [strongSelf.layer addSublayer:animationLayer];
        
    });
}

@end

