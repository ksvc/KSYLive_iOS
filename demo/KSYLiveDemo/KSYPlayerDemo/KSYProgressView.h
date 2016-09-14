//
//  KSYProgressView.h
//  KSYPlayerDemo
//
//  Created by isExist on 16/8/30.
//  Copyright © 2016年 kingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DragingSliderCallback)(float progress);

@interface KSYProgressView : UIView

@property (nonatomic) float totalTimeInSeconds;
@property (nonatomic) float cacheProgress;
@property (nonatomic) float playProgress;
@property (nonatomic, copy) DragingSliderCallback dragingSliderCallback;

@end
