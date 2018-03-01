//
//  SpeedChoiceView.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/30.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpeedChoiceView : UIView
@property (weak, nonatomic) IBOutlet UIButton *oneSpeedButton;
@property (weak, nonatomic) IBOutlet UIButton *oneQuarterSpeedButton;
@property (weak, nonatomic) IBOutlet UIButton *oneHalfSpeedButton;
@property (weak, nonatomic) IBOutlet UIButton *twoSpeedButton;
@property (weak, nonatomic) IBOutlet UIButton *unOpenButton;
@property (weak, nonatomic) IBOutlet UIButton *openButton;
- (void)speedButtonColorHandler:(float)speed;
- (void)speedButtonEnableHandler:(BOOL)enable;
@end
