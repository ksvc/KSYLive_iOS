//
//  VodListPlayController.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/11.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "BaseViewController.h"

@class PlayerViewModel, VodPlayController;

@interface VodListPlayController : BaseViewController

@property (nonatomic, strong) VodPlayController        *playVC;

@property (nonatomic, copy) void(^willDisappearBlocked)(void);

- (instancetype)initWithPlayerViewModel:(PlayerViewModel *)playerViewModel
                            suspendView:(UIView *)suspendView;

- (void)pushFromSuspendHandler;

- (void)reloadPushFromSuspendHandler;

- (void)recoveryHandler;

@end
