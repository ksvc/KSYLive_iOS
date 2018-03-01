//
//  VodPlayControlView.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/24.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VodPlayControlView : UIView
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;
@property (weak, nonatomic) IBOutlet UILabel  *playedTimeLab;
@property (weak, nonatomic) IBOutlet UILabel  *totalPlayTimeLab;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *switchDefinitionButton;
- (void)screenRotateHandler:(BOOL)fullScreen;
@end
