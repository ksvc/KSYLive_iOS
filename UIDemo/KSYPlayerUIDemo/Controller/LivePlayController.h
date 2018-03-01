//
//  LivePlayController.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/11.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "PlayController.h"

@class PlayerViewModel;

@interface LivePlayController : PlayController

@property (nonatomic, strong) PlayerViewModel      *playerViewModel;

@property (nonatomic, assign) BOOL fullScreen;

@property (nonatomic, copy) void(^willDisappearBlocked)(void);

- (void)recoveryHandler;

- (void)suspendHandler;

- (void)stopSuspend;

/**
 *  点击悬浮窗，重新push
 */
- (void)pushFromSuspendHandler;

/**
 *  点击视频列表内的其他item，player需要reload
 */
- (void)reloadPushFromSuspendHandler;

@end
