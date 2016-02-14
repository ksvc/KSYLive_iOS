//
//  ViewController.h
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 kingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libksylive/libksylive.h>
@class KSYStreamer;

@interface KSYStreamerVC : UIViewController

@property NSURL * hostURL;
@property UILabel *stat;

- (KSYStreamer *) getStreamer;
- (void) setStreamerCfg;

@end

