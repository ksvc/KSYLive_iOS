//
//  KSYNetTracker.h
//  KSYCommon
//
//  Created by 施雪梅 on 2017/1/4.
//  Copyright © 2017年 施雪梅. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * _Nonnull const KSYNetTrackerOnceDoneNotification;
FOUNDATION_EXPORT NSString * _Nonnull const KSYNetTrackerFinishedNotification;
FOUNDATION_EXPORT NSString * _Nonnull const KSYNetTrackerErrorNotification;

/**
 * 探测方式
 */
typedef NS_ENUM(NSInteger, KSY_NETTRACKER_ACTION){
    ///mtr方式，探测链路上每个节点
    KSY_NETTRACKER_ACTION_MTR,
    ///ping方式，直接探测终点
    KSY_NETTRACKER_ACTION_PING,
};

/**
 * 网络链路上的路由节点信息类
 */
@interface KSYNetRouterInfo : NSObject

/**
 @abstract 链路上每个节点的ip地址
 @discussion 如果每个探测报文对应的路径不同，则每一跳上会存在多个不同ip
 */
@property (nonatomic, readonly) NSMutableArray * _Nullable ips;

/**
 @abstract 所有探测报文的rtt最大值
 */
@property (nonatomic, readonly) float tmax;

/**
 @abstract 所有探测报文的rtt最小值
 */
@property (nonatomic, readonly) float tmin;

/**
 @abstract 所有探测报文的rtt平均值
 */
@property (nonatomic, readonly) float tavg;

/**
 @abstract 所有探测报文的rtt均方差
 */
@property (nonatomic, readonly) float tdev;

/**
 @abstract 所有探测报文的丢包率
 */
@property (nonatomic, readonly) float loss;

/**
 @abstract 统计所使用的探测报文个数
 */
@property (nonatomic, readonly) int number;

@end


/**
 * 网络链路探测器类
 */
@interface KSYNetTracker : NSObject

/**
 @abstract 开始探测
 @param domain 探测地址
 @return 成功开始返回0, 否则返回非0
 */
- (int) start:(NSString * __nonnull)domain;

/**
 @abstract 停止探测
 */
- (void) stop;

/**
 @abstract 探测方式
 @discussion 说明：
 
 * start开始前配置有效，探测过程中配置下一次探测生效

 */
@property (nonatomic, assign) KSY_NETTRACKER_ACTION action;

/**
 @abstract 探测超时时间，单位是ms，默认值是1000ms
 @discussion 说明：
 
 * start开始前配置有效，探测过程中配置下一次探测生效
 * 有效范围是100-2000ms，不在有效范围内的配置不生效
 */
@property (nonatomic, assign) int timeout;

/**
 @abstract 探测使用的最大ttl值，默认值是64
 @discussion 说明：
 
 * start开始前配置有效，探测过程中配置下一次探测生效
 * 有效范围是1-int最大值，不在有效范围内的配置不生效
 */
@property (nonatomic, assign) int maxttl;

/**
 @abstract 探测次数，默认值是10
 @discussion 说明：
 
 * start开始前配置有效，探测过程中配置下一次探测生效
 * 有效范围是1-20，不在有效范围内的配置不生效
 */
@property (nonatomic, assign) int number;

/**
 @abstract 链路状况
 */
@property (nonatomic, readonly) NSMutableArray * _Nullable routerInfo;

@end
