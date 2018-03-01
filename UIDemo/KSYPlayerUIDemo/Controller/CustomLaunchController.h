//
//  CustomLaunchController.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/15.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "BaseViewController.h"
#import <libksygpulive/KSYMoviePlayerController.h>

@interface CustomLaunchController : BaseViewController

@property (nonatomic, assign) BOOL hasRemoved;

@property (weak, nonatomic) IBOutlet UIButton *openPlayButton;

@end
