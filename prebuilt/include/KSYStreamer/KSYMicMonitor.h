
#import <Foundation/Foundation.h>

/** 耳返模块
 
 用AudioUnit实现的将麦克风采集的声音直接播放的模块
 */
@interface KSYMicMonitor : NSObject

/**
 @abstract  启动mic返音功能
 */
- (void)start;
/**
 @abstract  关闭mic返音功能
 */
- (void)stop;
/**
 @abstract  设置mic返音音量
 @param     volume 设置音量
 */
- (void)setVolume:(Float32)volume;

/**
 @abstract  mic的采样率
 */
@property(nonatomic, assign) Float64 sampleRate;

/**
 @abstract  查询当前是否有耳机
 */
+ (BOOL) isHeadsetPluggedIn;
@end
