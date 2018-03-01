//
//  SpeedChoiceView.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/30.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "SpeedChoiceView.h"

@implementation SpeedChoiceView

- (void)speedButtonColorHandler:(float)speed {
    NSInteger spd = (NSInteger)roundf(speed * 100);
    switch (spd) {
        case 100:
        {
            self.oneSpeedButton.selected = YES;
            self.oneQuarterSpeedButton.selected = NO;
            self.oneHalfSpeedButton.selected = NO;
            self.twoSpeedButton.selected = NO;
        }
            break;
            
        case 125:
        {
            self.oneSpeedButton.selected = NO;
            self.oneQuarterSpeedButton.selected = YES;
            self.oneHalfSpeedButton.selected = NO;
            self.twoSpeedButton.selected = NO;
        }
            break;
            
        case 150:
        {
            self.oneSpeedButton.selected = NO;
            self.oneQuarterSpeedButton.selected = NO;
            self.oneHalfSpeedButton.selected = YES;
            self.twoSpeedButton.selected = NO;
        }
            break;
            
        case 200:
        {
            self.oneSpeedButton.selected = NO;
            self.oneQuarterSpeedButton.selected = NO;
            self.oneHalfSpeedButton.selected = NO;
            self.twoSpeedButton.selected = YES;
        }
            break;
            
        default:
            break;
    }
}

- (void)speedButtonEnableHandler:(BOOL)enable {
    self.oneSpeedButton.enabled = enable;
    self.oneQuarterSpeedButton.enabled = enable;
    self.oneHalfSpeedButton.enabled = enable;
    self.twoSpeedButton.enabled = enable;
    
    self.openButton.selected = enable;
    self.unOpenButton.selected = !enable;
}

@end
