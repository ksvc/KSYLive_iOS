//
//  RecordeViewController.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/1.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "BaseViewController.h"
#import <libksygpulive/KSYMoviePlayerController.h>

@class KSYMoviePlayerController;

@interface RecordeViewController : BaseViewController

- (instancetype)initWithPlayer:(KSYMoviePlayerController *)player
    screenRecordeFinishedBlock:(void(^)(void))screenRecordeFinishedBlock;

- (void)startRecorde;

@end
