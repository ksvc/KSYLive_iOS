//
//  PlayController.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/11.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "BaseViewController.h"
#import <libksygpulive/KSYMoviePlayerController.h>

@class VideoModel;

@interface PlayController : BaseViewController

@property (nonatomic, strong) KSYMoviePlayerController *player;

// 网络状态
@property NSString* networkStatus;
@property(nonatomic, copy) void(^onNetworkChange)(NSString* msg);

- (instancetype)initWithVideoModel:(VideoModel *)videoModel;

- (void)reload:(NSURL *)aUrl;

- (VideoModel *)currentVideoModel;

- (void)configeVideoModel:(VideoModel *)videoModel;

- (void)notifyHandler:(NSNotification*)notify;

@end
