//
//  KSYPlayerAuth.h
//  KSYPlayerCore
//
//  Created by zengfanping on 10/15/15.
//  Copyright © 2015 kingsoft. All rights reserved.
//

#ifndef KSYPlayerAuth_h
#define KSYPlayerAuth_h
/**
 金山云播放内核需要提供鉴权信息，鉴权信息未完成，将导致如下效果：

 * 播放画面出现金山云logo
 * 播放一定时间后停止播放
 * 以及其他异常现象发生
 
 ## 联系我们
 当本文档无法帮助您解决在开发中遇到的具体问题，请通过以下方式联系我们，金山云工程师会在第一时间回复您。
 
 __E-mail__:  zengfanping@kingsoft.com
  
 */
#ifdef __cplusplus
#define KSY_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define KSY_EXTERN     extern __attribute__((visibility ("default")))
#endif


@interface KSYPlayerAuth: NSObject

/**
 @abstract 开发者设置的开发者标识
 @discussion 该信息由haomingfei@kingsoft.com提供。
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property (nonatomic, readonly) NSString *appId;
/**
 @abstract 开发者设置的应用接入信息
 @discussion 该信息由haomingfei@kingsoft.com提供。
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property (nonatomic, readonly) NSString *accessKey;

/**
 @abstract 开发者设置的密钥
 @discussion 加密算法请见setAuthInfo

 可以使用以下方法获取secretKey，其中"iamskey"为用户密钥，需要从金山云服务器获取。sksign则为secretKey：
 <pre><code>
 //需要import CommonCrypto/CommonDigest.h

 - (NSString *)MD5:(NSString*)raw {
    const char * pointer = [raw UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
 
    CC_MD5(pointer, (CC_LONG)strlen(pointer), md5Buffer);
 
    NSMutableString *string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [string appendFormat:@"%02x",md5Buffer[i]];
 
    return string;
 }
 
 - (void)initKSYAuth
 {
    NSString* timeSeconds = [NSString stringWithFormat:@"%d",(int)[[NSDate date]timeIntervalSince1970]];
    NSString* sk = [NSString stringWithFormat:@"iamskey%@", time];
    NSString* sksign = [self MD5:sk];
 </pre></code>
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property (nonatomic, readonly) NSString *secretKey;
/**
 @abstract 开发者设置的1970年至今经过的秒数。
 @discussion 参与加密计算，设置由setAuthInfo传入。
 
 可以使用以下方法获取timeSeconds：
 <pre><code>
 NSString* timeSeconds = [NSString stringWithFormat:@"%d",(int)[[NSDate date]timeIntervalSince1970]];
</pre></code>
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property (nonatomic, readonly) NSString *timeSeconds;

/**
 @abstract 设备id
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property (nonatomic, readonly) NSString *mCode;
/**
 @abstract 设备版本信息
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property (nonatomic, readonly) NSString *sam;

/**
 @abstract 获取认证单例
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
+ (KSYPlayerAuth *)sharedInstance;

/**
 @abstract 设置认证信息
 @param appId 开发者标识，由haomingfei@kingsoft.com分配
 @param ak 应用接入信息，与SecretKey对应，由开放平台针对appid分配
 @param skSign 设置加密后的SecretKey，加密方式为SecretKeySign=md5( SecretKey + TimeSec )，其中“+”号表示字符串连接
 @param seconds 1970年至今经过的秒数。
 
 @discussion timeSeconds获取方法：
 <pre><code>
 NSString* timeSeconds = [NSString stringWithFormat:@"%d",(int)[[NSDate date]timeIntervalSince1970]];
 </pre></code>
 */
- (void)setAuthInfo:(NSString *)appId accessKey:(NSString*) ak secretKeySign:(NSString*) skSign timeSeconds:(NSString*) seconds;

KSY_EXTERN NSString * const KSYAuthAppid;
KSY_EXTERN NSString * const KSYAuthAccessKey;
KSY_EXTERN NSString * const KSYAuthSecretKeySign;
KSY_EXTERN NSString * const KSYAuthTimeSeconds;
KSY_EXTERN NSString * const KSYAuthMCode;
KSY_EXTERN NSString * const KSYAuthSam;

@end
#endif /* KSYAuth_h */
