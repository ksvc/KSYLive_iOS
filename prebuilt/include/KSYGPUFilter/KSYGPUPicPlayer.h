#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <GPUImage/GPUImage.h>

/*!
 * @abstract  图片播放器状态
 */
typedef NS_ENUM(NSUInteger, KSYGPUPicPlayerState) {
    /// 空闲状态
    KSYGPUPicPlayerState_Idle = 0,
    /// 播放状态
    KSYGPUPicPlayerState_Play,
    /// 暂停状态
    KSYGPUPicPlayerState_Pause,
    /// 结束状态
    KSYGPUPicPlayerState_Finished,
    /// 错误状态
    KSYGPUPicPlayerState_Error,
};


/** 图片播放器
 
 提供图片播放的功能，支持自定义总时长、输出图像大小
 */
@interface KSYGPUPicPlayer : GPUImageOutput

/**
 @abstract 初始化KSYGPUPicPlayer
 @param imageSource 图像
 @param parameters 播放参数
 
 @discussion

 - 播放参数说明

 @{
 @"fps":@(25),   // 每秒帧率，默认值为25
 @"duration":@(4),    // 播放总时长，默认为4s
 @"outputSize":@(540*960),   //输出图像的分辨率(CGSize)，默认为540p
 */
- (id)initWithImage:(UIImage *)imageSource parameters:(NSDictionary *)parameters;

/**
 @abstract   设置裁剪区域的起始和结束位置
 @discussion 要求输入相对位置, 即CGRect中所有值均在[0.0, 1.0]之间
 @discussion 如果出现非法值，则设置无效
 @discussion 默认的结束裁剪区域是按outputSize比例对全图片进行的裁剪
 @discussion 默认的起始裁剪区域大小是结束区域大小的一半
 */
- (void)setCropRegion:(CGRect)fromRegion toRect:(CGRect)toRegion;

/**
 @abstract  开始播放图片
 @discussion 在Idle或者Pause状态下调用，进入play状态
 */
- (void)play;

/**
 @abstract  暂停播放图片
 @discussion 在Play状态下调用，进入pause状态
 */
- (void)pause;

/**
 @abstract  seek到指定时间
 @param     time 时间
 @discussion 如果在pause状态下调用，则seek完成后依然为pause状态，需调用play方法恢复播放状态
 @discussion 如果在play状态下调用，则seek完成后依然play状态
 @discussion 在Idle或finished状态下调用，则从time处开始播放
 */
- (BOOL)seekTo:(float)time;

/**
 @abstract  停止播放图片
 @discussion 非Idle状态下调用，进入Idle状态
 */
- (void)stop;

/**
 @abstract  驱动下一帧的输出
 @param completion 当前图片帧处理完成的回调
 @discussion bEnd 如果completion中的回调参数为YES，表示已经处理到frame最后一帧
 */
- (BOOL)processImageWithCompletionHandler:(void (^)(BOOL bEnd))completion;

/**
 @abstract  当前图片播放的总时长，单位是秒
 @discussion  与initWithImage方法中设置的duration相同，默认值为4秒
 */
@property (nonatomic, readonly) float duration;

/**
 @abstract  图片播放的帧率
 @discussion  与initWithImage方法中设置的fps相同，默认值为25
 */
@property (nonatomic, readonly) float fps;

/**
 @abstract 输出图像的大小
 @discussion  与initWithImage方法中设置的outputSize相同，默认值为(540, 960)
 */
@property (nonatomic, readonly) CGSize outputSize;

/**
 @abstract  当前播放时间，单位是秒
 */
@property (nonatomic, readonly) float position;

/**
 @abstract  当前处理进度
 */
@property (nonatomic, readonly) float progress;
/**
 @abstract  播放器当前状态
 */
@property (nonatomic, readonly) KSYGPUPicPlayerState state;

/**
 @abstract   播放状态发生变化时的回调
 @discussion preState 变化前的状态
 @discussion newState 变化后的状态
 */
@property (nonatomic, copy)void (^stateChangeBlock)(KSYGPUPicPlayerState preState, KSYGPUPicPlayerState newState);

@end
