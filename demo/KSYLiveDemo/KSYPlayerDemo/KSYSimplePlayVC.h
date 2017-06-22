//
//  KSYSamplestPlayVC.h
//  KSYLiveDemo
//
//  Created by zhengwei on 2017/6/14.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYUIVC.h"
#import "KSYPlayerCfgVC.h"

@interface KSYSimplePlayVC : KSYUIVC

- (instancetype)initWithURLAndConfigure:(NSURL *)url fileList:(NSArray *)fileList config:(KSYPlayerCfgVC *)config;
@property (strong, nonatomic) KSYMoviePlayerController *player;
@end
