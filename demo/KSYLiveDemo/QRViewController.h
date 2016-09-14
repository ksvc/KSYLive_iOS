//
//  QRViewController.h
//  KSYLiveDemo
//
//  Created by 孙健 on 16/4/13.
//  Copyright © 2016年 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRViewController : UIViewController
@property (nonatomic, copy) void (^getQrCode)(NSString *stringQR);
@end
