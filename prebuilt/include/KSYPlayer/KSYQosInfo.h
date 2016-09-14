//
//  KSYQosInfo.h
//  IJKMediaPlayer
//
//  Created by 崔崔 on 16/3/14.
//  Copyright © 2016年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Qos信息
 */
@interface KSYQosInfo : NSObject

/**
    audio queue size in bytes
 */
@property (nonatomic, assign)int audioBufferByteLength;
/**
    audio queue time length in ms
 */
@property (nonatomic, assign)int audioBufferTimeLength;
/**
    size of data have arrived at audio queue since playing. unit:byte
 */
@property (nonatomic, assign)int64_t audioTotalDataSize;
/**
    video queue size in bytes
 */
@property (nonatomic, assign)int videoBufferByteLength;
/**
    video queue time length in ms
 */
@property (nonatomic, assign)int videoBufferTimeLength;
/**
    size of data have arrived at video queue since playing. unit:byte
 */
@property (nonatomic, assign)int64_t videoTotalDataSize;
/**
    size of total audio and video data since playing. unit: byte
 */
@property (nonatomic, assign)int64_t totalDataSize;
/**
    video decode frame count per second
 */
@property (nonatomic, assign)float videoDecodeFPS;
/**
    video refresh frame count per second
 */
@property (nonatomic, assign)float videoRefreshFPS;


@end
