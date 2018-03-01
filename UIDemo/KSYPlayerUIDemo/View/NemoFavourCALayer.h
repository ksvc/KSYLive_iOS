//
//  NemoFavourCALayer.h
//  ALFavourTest
//
//  Created by iVermissDich on 16/11/18.
//  Copyright © 2016年 com.ksc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface NemoFavourCALayer : CALayer<CAAnimationDelegate>

- (instancetype)initWithAnimationGroup:(CAAnimationGroup *)anAnimationGroup;

@end
