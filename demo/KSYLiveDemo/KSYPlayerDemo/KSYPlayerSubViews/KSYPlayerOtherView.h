//
//  KSYPlayerOtherView.h
//  KSYGPUStreamerDemo
//
//  Created by 施雪梅 on 17/7/12.
//  Copyright © 2016年 ksyun. All rights reserved.
//

/**
 其他相关控制
 */
#import "KSYUIView.h"

@interface KSYPlayerOtherView: KSYUIView

@property (nonatomic)UIButton *btnReload;                         //reload

@property (nonatomic)UIButton *btnFloat;                            //悬浮窗

@property (nonatomic)UISwitch *switchRec;                        //录制

@property (nonatomic)UILabel   *labelMeta;                         //信息显示页面

@property (nonatomic)UIButton *btnPrintMeta;                    //显示当前的媒体信息

@end
