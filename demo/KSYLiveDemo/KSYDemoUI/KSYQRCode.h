//
//  KSYPlayUrlAndQRCode.h
//  KSYLiveDemo
//
//  Created by zhengWei on 2017/5/25.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSYQRCode : UIViewController
//存放要生成为二维码的地址
@property(nonatomic,strong)NSString *url;
@end
