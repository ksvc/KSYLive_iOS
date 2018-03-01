//
//  NemoFavourCALayer.m
//  ALFavourTest
//
//  Created by iVermissDich on 16/11/18.
//  Copyright © 2016年 com.ksc. All rights reserved.
//

#import "NemoFavourCALayer.h"

@implementation NemoFavourCALayer

- (instancetype)initWithAnimationGroup:(CAAnimationGroup *)anAnimationGroup {
    self = [super init];
    if (self) {
        anAnimationGroup.delegate = self;
        [self addAnimation:anAnimationGroup forKey:@"com.ksyun.Favour"];
    }
    return self;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self removeFromSuperlayer];
}

@end
