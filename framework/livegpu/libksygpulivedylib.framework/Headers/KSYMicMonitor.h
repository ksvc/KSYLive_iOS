
#import <Foundation/Foundation.h>

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
