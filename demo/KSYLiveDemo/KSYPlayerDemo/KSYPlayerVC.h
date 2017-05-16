//
//  FirstViewController.h
//  QYLive
//
//  Created by yiqian on 11/3/15.
//  Copyright (c) 2015 qyvideo. All rights reserved.
//
#import "KSYUIVC.h"
#import "KSYPlayerCfgVC.h"

@interface KSYPlayerVC : KSYUIVC
- (instancetype)initWithURLAndConfigure:(NSURL *)url fileList:(NSArray *)fileList config:(KSYPlayerCfgVC *)config;
@property (strong, nonatomic) KSYMoviePlayerController *player;
@end

