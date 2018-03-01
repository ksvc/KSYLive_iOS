//
//  KSYPlayUrlAndQRCode.h
//  KSYLiveDemo
//
//  Created by zhengWei on 2017/5/25.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,KSYDeviceOrientation) {
    KSYDeviceOrientationPortrait = 0,
    KSYDeviceOrientationLandscape = 1
};

@interface KSYQRCode : UIViewController
//存放二维码的地址
@property (nonatomic,strong) NSString *url;

@property (nonatomic,assign) KSYDeviceOrientation imageViewOrientation;
@end
