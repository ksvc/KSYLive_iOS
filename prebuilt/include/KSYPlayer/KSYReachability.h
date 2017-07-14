//
//  KSYReachability.h
//  KSYCommon
//
//  Created by ksyun on 2017/1/4.
//  Copyright © 2017年 ksyun. All rights reserved.
//
#ifndef _KSYReachability_H_
#define _KSYReachability_H_
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

/** 
 * Create NS_ENUM macro if it does not exist on the targeted version of iOS or OS X.
 *
 * @see http://nshipster.com/ns_enum-ns_options/
 **/
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

extern NSString *const kKSYReachabilityChangedNotification;

typedef NS_ENUM(NSInteger, KSYNetworkStatus) {
    // same as Apple NetworkStatus
    KSYNotReachable = 0,
    KSYReachableViaWiFi = 2,
    KSYReachableViaWWAN = 1
};

@class KSYReachability;

typedef void (^KSYNetworkReachable)(KSYReachability * reachability);
typedef void (^KSYNetworkUnreachable)(KSYReachability * reachability);
typedef void (^KSYNetworkReachability)(KSYReachability * reachability, SCNetworkConnectionFlags flags);


@interface KSYReachability : NSObject

@property (nonatomic, copy) KSYNetworkReachable    reachableBlock;
@property (nonatomic, copy) KSYNetworkUnreachable  unreachableBlock;
@property (nonatomic, copy) KSYNetworkReachability reachabilityBlock;

@property (nonatomic, assign) BOOL reachableOnWWAN;


+(instancetype)reachabilityWithHostname:(NSString*)hostname;
// This is identical to the function above, but is here to maintain
//compatibility with Apples original code. (see .m)
+(instancetype)reachabilityWithHostName:(NSString*)hostname;
+(instancetype)reachabilityForInternetConnection;
+(instancetype)reachabilityWithAddress:(void *)hostAddress;
+(instancetype)reachabilityForLocalWiFi;

-(instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

-(BOOL)startNotifier;
-(void)stopNotifier;

-(BOOL)isReachable;
-(BOOL)isReachableViaWWAN;
-(BOOL)isReachableViaWiFi;

// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
-(BOOL)isConnectionRequired; // Identical DDG variant.
-(BOOL)connectionRequired; // Apple's routine.
// Dynamic, on demand connection?
-(BOOL)isConnectionOnDemand;
// Is user intervention required?
-(BOOL)isInterventionRequired;

-(KSYNetworkStatus)currentReachabilityStatus;
-(SCNetworkReachabilityFlags)reachabilityFlags;
-(NSString*)currentReachabilityString;
-(NSString*)currentReachabilityFlags;

@end

#endif  // _KSYReachability_H_
