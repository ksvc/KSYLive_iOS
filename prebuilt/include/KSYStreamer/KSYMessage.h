//
//  KSYMessage.h
//  KSYStreamer
//
//  Created by 施雪梅 on 16/8/25.
//  Copyright © 2016年 yiqian. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface KSYMessage : NSObject

/**
 @abstract    处理消息数据
 @param      消息数据
 */
- (BOOL) processMessageData:(NSMutableDictionary *)messageData;

/**
 @abstract   消息处理回调接口
 @param      消息数据
 @discussion 请注意本函数的执行时间，如果太长可能导致不可预知的问题
 */
@property(nonatomic, copy) void(^messageProcessingCallback)(NSDictionary *messageData);


@end
