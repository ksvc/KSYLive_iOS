//
//  QRViewController.h
//  KSYLiveDemo
//
//  Created by 孙健 on 16/4/13.
//  Copyright © 2016年 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRViewController : UIViewController
//得到二维码后回调，传出stringQR
@property (nonatomic, copy) void (^getQrCode)(NSString *stringQR);
@end
