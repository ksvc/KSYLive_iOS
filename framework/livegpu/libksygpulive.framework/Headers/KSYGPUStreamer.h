#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "KSYStreamerBase.h"

@protocol GPUImageInput;
@class KSYStreamerBase;

@interface KSYGPUStreamer : NSObject <GPUImageInput>

@property(nonatomic) BOOL enabled;
/**
 @abstract 数据接口
 @discussion 数据接口
 */
@property (nonatomic, copy) void (^sendBlock)(NSString *str);

/**
 @abstract 初始化方法
 @discussion 初始化，创建带有默认参数的 KSYGPUStreamer
 
 @warning KSYGPUStreamer只支持单实例推流，构造多个实例会出现异常
 */
- (instancetype) initWithDefaultCfg;


/**
 @abstract   获取底层推流实例
 @discussion
 */
- (KSYStreamerBase* ) getStreamer;
@end
