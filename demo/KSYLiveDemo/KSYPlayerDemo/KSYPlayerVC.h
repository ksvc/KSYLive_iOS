//
//  FirstViewController.h
//  QYLive
//
//  Created by yiqian on 11/3/15.
//  Copyright (c) 2015 qyvideo. All rights reserved.
//

#import <libksygpulive/libksygpulive.h>

@interface KSYPlayerVC : UIViewController
- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url fileList:(NSArray *)list;
@property (strong, nonatomic) KSYMoviePlayerController *player;
@end

