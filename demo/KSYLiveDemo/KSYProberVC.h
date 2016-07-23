//
//  KSYProberVC.h
//  KSYPlayerDemo
//
//  Created by 施雪梅 on 16/7/10.
//  Copyright © 2016年 kingsoft. All rights reserved.
//

#ifndef KSYProberVC_h
#define KSYProberVC_h

#import <UIKit/UIKit.h>
#if USING_DYNAMIC_FRAMEWORK
#import <libksygpulivedylib/libksygpulivedylib.h>
#else
#import <libksygpulive/libksygpulive.h>
#endif

@interface KSYProberVC : UIViewController
- (instancetype)initWithURL:(NSURL *)url;
@end

#endif /* KSYProberVC_h */
