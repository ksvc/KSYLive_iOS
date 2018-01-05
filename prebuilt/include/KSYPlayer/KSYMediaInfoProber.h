//
//  KSYMediaInfoProber.h
//  IJKMediaPlayer
//
//  Created by 施雪梅 on 16/7/8.
//  Copyright © 2016年 bilibili. All rights reserved.
//

#ifndef KSYMediaInfoProber_h
#define KSYMediaInfoProber_h

#import <AVFoundation/AVFoundation.h>
#import "KSYMediaInfo.h"

/**
 * KSYMediaInfoProber
 */
@interface KSYMediaInfoProber : NSObject

/**
 @abstract 初始化文件格式探测器并设置播放地址
 @param url 待探测格式的文件地址，该地址可以是本地地址或者服务器地址.
 @return 返回KSYMediaInfoProber对象
 @warning 必须调用该方法进行初始化，不能调用init方法。
 */
- (instancetype)initWithContentURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

/**
 @abstract 文件格式探测时间，单位是秒，默认值是3秒
 @discussion 超过该时间未探测到文件格式时，直接返回
 */
@property (nonatomic) NSTimeInterval timeout;

/**
 @abstract 是否要加速探测速度
 @discussion 加速后，探测格式可能不完整，默认不加速
 */
@property (nonatomic) BOOL bAccelerate;

/**
 @abstract 发送http请求时需要header带上的字段
 @since Available in KSYMoviePlayerController 2.1.0 and later.
 */
-(void)setHttpHeaders:(NSDictionary *)headers;

/**
 @abstract 待探测的文件格式地址
 @discussion 可不释放KSYMediaInfoProber实例，通过设置contentURL来完成下一次探测
 */
@property (nonatomic, copy) NSURL *url;

/**
 @abstract 编码类型是否是h264
 @discussion 获取此属性前至少要调用一次[ksyMediaInfo]，方可得到正确的结果
 */
@property (nonatomic, readonly) BOOL bH264Codec;

/**
 @abstract 编码类型是否是hevc
 @discussion 获取此属性前至少要调用一次[ksyMediaInfo]，方可得到正确的结果
 */
@property (nonatomic, readonly) BOOL bHEVCCodec;

/**
 @abstract 编码类型是否是aac
 @discussion 获取此属性前至少要调用一次[ksyMediaInfo]，方可得到正确的结果
 */
@property (nonatomic, readonly) BOOL bAACCodec;

/**
 @abstract 编码类型是否是mp3
 @discussion 获取此属性前至少要调用一次[ksyMediaInfo]，方可得到正确的结果
 */
@property (nonatomic, readonly) BOOL bMP3Codec;

/**
 @abstract 媒体信息, 具体对象类型为KSYMediaInfo
 @discussion 未探测到文件格式时为nil
 @since Available in KSYMoviePlayerController 1.5.3 and later.
 */
@property (nonatomic, strong) KSYMediaInfo *ksyMediaInfo;

/**
 @abstract 获取视频缩略图
 @param seekTime 指定的时间位置，单位为s, 小于0时无法截图
 @param width 缩略图的宽度
 @param height 缩略图的高度
 @return 返回UIImage对象，即为缩略图
 @discussion 缩略图宽度和高度说明
 
 * 指定缩略图宽度和高度都为0时，输出的缩略图与原视频中的宽高相同
 * 指定缩略图宽度不为0，高度为0时，高度会根据原视频的宽高比例做出缩放
 * 指定缩略图高度不为0，宽度为0时，宽度会根据原视频的宽高比例作出缩放

 @since Available in KSYMoviePlayerController 1.8.2 and later.
 */
- (UIImage *)getVideoThumbnailImageAtTime:(NSTimeInterval)seekTime width:(int)width height:(int)height;

/**
 @abstract 精准获取视频缩略图
 @param seekTime 指定的时间位置，单位为s, 小于0时无法截图
 @param width 缩略图的宽度
 @param height 缩略图的高度
 @param accurate 指定是否使用精准获取缩略图
 @return 返回UIImage对象，即为缩略图
 @discussion 缩略图宽度和高度说明
 
 * 指定缩略图宽度和高度都为0时，输出的缩略图与原视频中的宽高相同
 * 指定缩略图宽度不为0，高度为0时，高度会根据原视频的宽高比例做出缩放
 * 指定缩略图高度不为0，宽度为0时，宽度会根据原视频的宽高比例作出缩放
 * 如果accurate为NO，只能获取关键帧的缩略图；如果为YES，则按照seekTime精准获取缩略图
 
 @since Available in KSYMoviePlayerController 2.9.6 and later.
 */
- (UIImage *)getVideoThumbnailImageAtTime:(NSTimeInterval)seekTime width:(int)width height:(int)height accurate:(BOOL)accurate;

@end

#endif /* KSYMediaInfoProber_h */
