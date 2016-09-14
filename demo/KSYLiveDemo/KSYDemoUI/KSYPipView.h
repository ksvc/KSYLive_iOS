//
//  KSYPipView.h
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYUIView.h"
@class KSYNameSlider;

@interface KSYPipView : KSYUIView

@property UIButton * pipPlay;
@property UIButton * pipPause;
@property UIButton * pipStop;
@property UIProgressView * progressV;
@property KSYNameSlider  * volumSl;
@property UIButton * pipNext;
@property UIButton * bgpNext;

// 当前画中画的视频和背景图片的路径
@property NSURL *pipURL;
@property NSURL *bgpURL;
// 当前画中画的播放状态
@property NSString* pipStatus;

// match pattern
@property NSArray* pipPattern;
@property NSArray* bgpPattern;
@end
