//
//  KSYTransitionFilter.h
//  KSYGPUFilter
//
//  Created by pengbin
//  Copyright 2017 ksyun.com. All rights reserved.
//

#import <GPUImage/GPUImage.h>

/** Protocol for setting duration for each transition filter
 */
@protocol KSYTransition <NSObject>

///
- (void)setDuration:(int)dur;

@end

/**
 @abstract 转场类型
 KSYTransitionType 1 ~ 99     代表 片头转场范围
 KSYTransitionType 101 ~ 199  代表 片尾转场范围
 KSYTransitionType 201 ~ 299  代表 片中转场范围
 */
typedef NS_ENUM(NSUInteger, KSYTransitionType) {
    /// 关闭转场
    KSYTransitionTypeNone = 0,
    /// 渐入（片头效果）
    KSYTransitionTypeFadesIn ,
    /// 模糊变清晰（片头效果）
    KSYTransitionTypeBlurIn ,
    /// 淡出（片尾效果）
    KSYTransitionTypeFadesOut = 101,
    /// 清晰变模糊（片尾效果）
    KSYTransitionTypeBlurOut,
    /// 渐入淡出
    KSYTransitionTypeFadesInOut = 201,
    /// 闪黑
    KSYTransitionTypeFlashBlack,
    /// 闪白
    KSYTransitionTypeFlashWhite,
    /// 清晰变模糊
    KSYTransitionTypeBlurInOut,
    /// 上推
    KSYTransitionTypePushUp,
    /// 下推
    KSYTransitionTypePushDown,
    /// 左推
    KSYTransitionTypePushLeft,
    /// 右推
    KSYTransitionTypePushRight,
};

/**
 @abstract 转场部分重叠类型
 */
typedef NS_ENUM(NSUInteger, KSYOverlapType) {
    /// 前后都是运动的视频, 第一段的最后n帧和第二段的前n帧重叠
    KSYOverlapType_BothVideo = 0,
    /// 第一段的最后一帧和第二段的视频的前n帧重叠
    KSYOverlapType_LastFrameVideo = 1,
    /// 第一段的最后n帧 和 第二段的第一帧重叠
    KSYOverlapType_VideoFirstFrame = 2,
    /// 只有前一段的最后n帧
    KSYOverlapType_VideoOnly = 3,
};


/** KSYTransitionFilter 转场效果滤镜
 * 转场: 两段视频串联的时候, 前一段的结尾和后一段的开头叠加
 * 渐入淡出: 前一段的画面慢慢变淡, 后一段的视频慢慢变清晰
 * 闪黑/闪白: 作用在前一段的结尾画面慢慢变黑或变白,全黑/全白后, 切换为下一段视频
 * ...
 */
@interface KSYTransitionFilter : GPUImageFilterGroup

/**
 @abstract   初始化并指定KSYTransitionType类型来创建对应转场特效
 @param      type 效果类型
 @param      overlap 重叠方式
 */
- (instancetype) initWithType:(KSYTransitionType)type andOverlay:(KSYOverlapType) overlap;

/// 当前转场的类型
@property (atomic, readonly) KSYTransitionType transitionType;
/// 当前转场画面重叠的类型
@property (atomic, readonly) KSYOverlapType overlapType;

/// 转场重叠的帧数 (默认:30)
@property (nonatomic, readwrite) int duration;

/// 转场已经处理的帧数
@property (nonatomic, readwrite) int frameIdx;

@end
