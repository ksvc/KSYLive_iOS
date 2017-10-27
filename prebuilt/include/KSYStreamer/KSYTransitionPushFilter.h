//
//  KSYTransitionPushFilter
//  KSYGPUFilter
//
//  Created by pengbin
//  Copyright © 2017年 ksyun.com. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "KSYGPUTwoInputFiter.h"
#import "KSYTransitionFilter.h"


/**
 @abstract 推出转场的方向
 */
typedef NS_ENUM(NSUInteger, KSYTPushDirection) {
    /// 前后都是运动的视频, 第一段的最后n帧和第二段的前n帧重叠
    KSYTPushDirection_Up = 0,
    /// 第一段的最后一帧和第二段的视频的前n帧重叠
    KSYTPushDirection_Down = 1,
    /// 第一段的最后n帧 和 第二段的第一帧重叠
    KSYTPushDirection_Left = 2,
    /// 只有前一段的最后n帧
    KSYTPushDirection_Right = 3,
};



/** KSYTransitionPushFilter 推出的转场效果
 
 * 转场: 两段视频串联的时候, 前一段的结尾和后一段的开头叠加
 * 推出: 前一段的画面慢慢向屏幕的一边推,面积变小; 后一段的视频慢慢跟随占据屏幕
 
 */
@interface KSYTransitionPushFilter : KSYGPUTwoInputFiter<KSYTransition>

/// 视频所在的图层
@property (nonatomic, readwrite) NSInteger masterLayer;

/// 转场重叠的帧数
@property (nonatomic, readwrite) int duration;

/// 转场已经处理的帧数
@property (nonatomic, readwrite) int frameIdx;

/// 推动方向 默认向上
@property (nonatomic, readwrite) KSYTPushDirection direction;

@end
