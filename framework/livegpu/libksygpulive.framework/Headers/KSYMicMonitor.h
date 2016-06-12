#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

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

@property(nonatomic, assign) Float64 sampleRate;


@end
