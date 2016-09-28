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
@property (nonatomic) int timeout;

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
 */
@property (nonatomic, strong) KSYMediaInfo *ksyMediaInfo;

/**
 @abstract 获取视频缩略图
 @param seekTime 指定的时间位置，单位为s
 @param width 缩略图的宽度
 @param height 缩略图的高度
 @return 返回UIImage对象，即为缩略图
 */
- (UIImage *)getVideoThumbnailImageAtTime:(NSTimeInterval)seekTime width:(int)width height:(int)height;

@end

#endif /* KSYMediaInfoProber_h */
