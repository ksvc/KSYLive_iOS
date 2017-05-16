//
//  KSYStreamerVC+Rotation.m
//  KSYLiveDemo
//
//  Created by iVermisseDich on 2017/4/28.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYStreamerVC+Rotation.h"

@interface KSYStreamerVC ()
@end

@implementation KSYStreamerVC (Rotation)

#pragma mark - ui rotate
- (void) onViewRotate { // 重写父类的方法, 参考父类 KSYUIView.m 中对UI旋转的响应
    [self layoutUI];
    if (self.kit == nil || !self.ksyFilterView.swUiRotate.on) {
        return;
    }
    if (self.ksyFilterView.swStrRotate.on) {
        // 1. 旋转推流方向
        UIInterfaceOrientation orie = [[UIApplication sharedApplication] statusBarOrientation];
        [self.kit rotateStreamTo:orie];
        
        // 注意 : traitCollection不变时不需要更改logo和水印的尺寸大小
        if (self.curCollection.verticalSizeClass == self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
            return;
        }
        self.curCollection = self.traitCollection;
        
        // 2. 旋转水印方向，并调整大小和位置（保持水印大小和位置不变）
        // 设置 logoRect
        [self.kit setLogoRect:CGRectMake(self.kit.logoRect.origin.x, self.kit.logoRect.origin.y, self.kit.logoRect.size.height, self.kit.logoRect.size.width)];
        
        // 根据text相对于logo的布局来计算text的Y值(text出于logo正下方)
        CGFloat textY = (self.kit.textRect.origin.y - self.kit.logoRect.origin.y) / (self.kit.streamDimension.height / self.kit.streamDimension.width) + self.kit.logoRect.origin.y;
        // width 根据推流分辨率计算
        CGFloat textheight = self.kit.textRect.size.height / self.kit.streamDimension.height * self.kit.streamDimension.width;
        // 设置 textRect
        [self.kit setTextRect:CGRectMake(self.kit.textRect.origin.x,
                                         textY,
                                         self.kit.textRect.size.width,
                                         textheight)];
    }
}
#pragma mark - 旋转预览 iOS > 8.0
// 旋转处理，通过旋转bgView来做到画面相对手机静止不动
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // size
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat minLength = MIN(screenSize.width, screenSize.height);
    CGFloat maxLength = MAX(screenSize.width, screenSize.height);
    CGRect newFrame;
    
    // frame
    CGAffineTransform newTransform;
    // need stay frame after animation
    CGAffineTransform newTransformOfStay;
    // whether need to stay
    __block BOOL needStay = NO;
    
    UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    UIDeviceOrientation toDeviceOrientation = [UIDevice currentDevice].orientation;
    
    if (toDeviceOrientation == UIDeviceOrientationPortrait) {
        newTransform = CGAffineTransformIdentity;
        newFrame = CGRectMake(0, 0, minLength, maxLength);
    } else {
        if (currentInterfaceOrientation == UIInterfaceOrientationPortrait) {
            newTransform = CGAffineTransformMakeRotation(M_PI_2*(toDeviceOrientation == UIDeviceOrientationLandscapeRight ? 1 : -1));
        } else {
            needStay = YES;
            if (currentInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                newTransform = CGAffineTransformRotate(self.bgView.transform, M_PI * 1.00001);
                newTransformOfStay = CGAffineTransformRotate(self.bgView.transform, M_PI);
            }else{
                newTransform = CGAffineTransformRotate(self.bgView.transform, SYSTEM_VERSION_GE_TO(@"8.0") ? 1.00001 * M_PI : M_PI * 0.99999);
                newTransformOfStay = CGAffineTransformRotate(self.bgView.transform, M_PI);
            }
        }
        newFrame = CGRectMake(0, 0, maxLength, minLength);
    }
    
    __weak typeof(self) weakSelf = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        strongSelf.bgView.transform = newTransform;
        strongSelf.bgView.frame =  newFrame;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        if (needStay) {
            strongSelf.bgView.transform = newTransformOfStay;
            strongSelf.bgView.frame = newFrame;
            needStay = NO;
        }
    }];
}

#pragma mark - 适配8.0之前旋转
// 旋转处理，通过旋转bgView来做到画面相对手机静止不动
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // size
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat minLength = MIN(screenSize.width, screenSize.height);
    CGFloat maxLength = MAX(screenSize.width, screenSize.height);
    CGRect newFrame;
    
    // frame
    CGAffineTransform newTransform;
    // need stay frame after animation
    CGAffineTransform newTransformOfStay;
    // whether need to stay
    __block BOOL needStay = NO;
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        newTransform = CGAffineTransformIdentity;
        newFrame = CGRectMake(0, 0, minLength, maxLength);
    } else {
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
            newTransform = CGAffineTransformMakeRotation(M_PI_2*(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ? 1 : -1));
        } else {
            needStay = YES;
            if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                newTransform = CGAffineTransformRotate(self.bgView.transform,M_PI * 1.00001);
                newTransformOfStay = CGAffineTransformRotate(self.bgView.transform, M_PI);
            }else{
                newTransform = CGAffineTransformRotate(self.bgView.transform,SYSTEM_VERSION_GE_TO(@"8.0") ? 1.00001 * M_PI : M_PI * 0.99999);
                newTransformOfStay = CGAffineTransformRotate(self.bgView.transform, M_PI);
                
            }
        }
        newFrame = CGRectMake(0, 0, maxLength, minLength);
    }
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        // sometimes strongSelf can be nil in iOS version 7.0
        if (!strongSelf) {
            return ;
        }
        strongSelf.bgView.transform = newTransform;
        strongSelf.bgView.frame = newFrame;
    }completion:^(BOOL finished) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        if (needStay) {
            strongSelf.bgView.transform = newTransformOfStay;
            strongSelf.bgView.frame = newFrame;
            needStay = NO;
        }
    }];
}

- (BOOL)shouldAutorotate {
    if (self.ksyFilterView){
        return self.ksyFilterView.swUiRotate.on;
    }
    return NO;
}

@end
