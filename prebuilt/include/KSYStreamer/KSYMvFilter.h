//
//  KSYMvFilter.h
//  GPUImage
//
//  Created by gene on 16/8/29.
//  Copyright © 2016年 ksyun. All rights reserved.
//
#import <GPUImage/GPUImage.h>

/** KSYMvFilter MV效果类
 
 * 在原视频上添加mp4素材，用户可以根据自身需求导入mp4素材，展示mv效果
 * 例如：video -->mvFilter
 
 */
@interface KSYMvFilter : GPUImageFilterGroup
/**
 单个mp4 filter
 
 @param mp4URL 指定mp4路径
 @param shouldRepeat mp4是否循环播放
 @return  mp4 filter
 */
- (id)initWithPath:(NSURL *)mp4URL shouldRepeat:(BOOL)bRepeat;

/**
 mv 播放暂停
 */
-(void)MvPause;

/**
 mv 播放暂停恢复
 */
-(void)MvResume;

/**
 关闭mv filter
 */
- (void)closeMvFilter;

///**
// @abstract   mv播放结束回调函数
// */
//@property(nonatomic, copy) void(^mvPlayEndCallback)();

@end
