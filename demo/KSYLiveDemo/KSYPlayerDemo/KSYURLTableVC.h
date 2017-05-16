//
//  KSYURLTableVC.h
//  KSYPlayerDemo
//
//  Created by isExist on 16/8/22.
//  Copyright © 2016年 kingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSYURLTableVC : UITableViewController

@property (nonatomic, copy) void (^getURLs)(NSArray<NSURL *> *scannedURLs);

- (instancetype)initWithURLs:(NSArray<NSURL *> *)urls;

@end
