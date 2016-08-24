//
//  controlView.h
//  KSYDemo
//
//  Created by 孙健 on 16/4/6.
//  Copyright © 2016年 孙健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYUIView.h"
@class KSYMenuView;

@interface KSYCtrlView : KSYUIView

#pragma mark - buttons
@property UIButton * btnFlash;
@property UIButton * btnCameraToggle;
@property UIButton * btnQuit;
@property UIButton * btnStream;
@property UIButton * btnCapture;
@property UILabel  * lblStat;
@property UILabel  * lblNetwork;
@end
