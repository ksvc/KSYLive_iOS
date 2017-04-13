//
//  KSYMediaInfo.h
//  IJKMediaPlayer
//
//  Created by 施雪梅 on 16/7/3.
//  Copyright © 2016年 kingsoft. All rights reserved.
//

#ifndef KSYMediaInfo_h
#define KSYMediaInfo_h

#import <Foundation/Foundation.h>

/**
 * 封装格式
 */
typedef NS_ENUM(NSInteger, MEDIAINFO_MUX_TYPE) {
    ///未知的文件封装格式
    MEDIAINFO_MUXTYPE_UNKNOWN,
    ///封装格式为TS
    MEDIAINFO_MUXTYPE_MP2T,
    ///封装格式为MOV
    MEDIAINFO_MUXTYPE_MOV,
    ///封装格式为AVI
    MEDIAINFO_MUXTYPE_AVI,
    ///封装格式为FLV
    MEDIAINFO_MUXTYPE_FLV,
    ///封装格式为MKV
    MEDIAINFO_MUXTYPE_MKV,
    ///封装格式为ASF
    MEDIAINFO_MUXTYPE_ASF,
    ///封装格式为RM
    MEDIAINFO_MUXTYPE_RM,
    ///封装格式为WAV
    MEDIAINFO_MUXTYPE_WAV,
    ///封装格式为OGG
    MEDIAINFO_MUXTYPE_OGG,
    ///封装格式为APE
    MEDIAINFO_MUXTYPE_APE,
    ///封装格式为RAWVIDEO
    MEDIAINFO_MUXTYPE_RAWVIDEO,
    ///封装格式为HLS
    MEDIAINFO_MUXTYPE_HLS,
};

/**
 * 音视频格式
 */
typedef NS_ENUM(NSInteger, MEDIAINFO_CODEC_ID) {
    ///未知的音视频编码格式
    MEDIAINFO_CODEC_ID_UNKNOWN,
    
    ///视频编码格式MPEG2
    MEDIAINFO_CODEC_MPEG2VIDEO,
    ///视频编码格式MPEG4
    MEDIAINFO_CODEC_MPEG4,
    ///视频编码格式MJPEG
    MEDIAINFO_CODEC_MJPEG,
    ///视频编码格式JPEG2000
    MEDIAINFO_CODEC_JPEG2000,
    ///视频编码格式H264
    MEDIAINFO_CODEC_H264,
    ///视频编码格式HEVC
    MEDIAINFO_CODEC_HEVC,
    ///视频编码格式VC1
    MEDIAINFO_CODEC_VC1,
    
    ///首个音频编码格式定义(不对应具体的编码格式)
    MEDIAINFO_CODEC_ID_FIRST_AUDIO  = 0x10000,
    ///音频编码格式AAC
    MEDIAINFO_CODEC_AAC,
    ///音频编码格式AC3
    MEDIAINFO_CODEC_AC3,
    ///音频编码格式MP3
    MEDIAINFO_CODEC_MP3,
    ///音频编码格式PCM
    MEDIAINFO_CODEC_PCM,
    ///音频编码格式DTS
    MEDIAINFO_CODEC_DTS,
    ///音频编码格式NELLYMOSER
    MEDIAINFO_CODEC_NELLYMOSER,
};

/**
 * 音频采样格式
 */
typedef NS_ENUM(NSInteger, MEDIAINFO_SAMPLE_FMT){
    ///未知的音频采样格式
    MEDIAINFO_SAMPLE_FMT_UNKNOWN,
    ///音频采样格式为unsigned 8 bits
    MEDIAINFO_SAMPLE_FMT_U8,
    ///音频采样格式为signed 16 bits
    MEDIAINFO_SAMPLE_FMT_S16,
    ///音频采样格式为signed 32 bits
    MEDIAINFO_SAMPLE_FMT_S32,
    ///音频采样格式为float
    MEDIAINFO_SAMPLE_FMT_FLT,
    ///音频采样格式为double
    MEDIAINFO_SAMPLE_FMT_DBL,
    
    ///音频采样格式为unsigned 8 bits, planar
    MEDIAINFO_SAMPLE_FMT_U8P,
    ///音频采样格式为signed 16 bits, planar
    MEDIAINFO_SAMPLE_FMT_S16P,
    ///音频采样格式为signed 32 bits, planar
    MEDIAINFO_SAMPLE_FMT_S32P,
    ///音频采样格式为float, planar
    MEDIAINFO_SAMPLE_FMT_FLTP,
    ///音频采样格式为double, planar
    MEDIAINFO_SAMPLE_FMT_DBLP,
    
    ///音频采样格式为Number of sample formats
    MEDIAINFO_SAMPLE_FMT_NB,
};

/**
 * 视频信息
 */
@interface KSYVideoInfo : NSObject

/**
 视频编码格式, 具体类型为MEDIAINFO_CODEC_ID
 */
@property (nonatomic) MEDIAINFO_CODEC_ID vcodec;
/**
 视频帧宽度
 */
@property (nonatomic, assign) int32_t frame_width;
/**
 视频帧高度
 */
@property (nonatomic, assign) int32_t frame_height;

@end

/**
 * 音频信息
 */
@interface KSYAudioInfo : NSObject

/**
 音频编码格式,  具体类型为MEDIAINFO_CODEC_ID
 */
@property (nonatomic) MEDIAINFO_CODEC_ID acodec;
/**
 音频语言, 如chinese, english...
 */
@property (nonatomic) NSString *language;
/**
 音频码率
 */
@property (nonatomic, assign) int64_t bitrate;
/**
 声道数
 */
@property (nonatomic, assign) int32_t channels;
/**
 音频采样率
 */
@property (nonatomic, assign) int32_t samplerate;
/**
 音频采样格式, 具体类型为MEDIAINFO_SAMPLE_FMT
 */
@property (nonatomic, assign) MEDIAINFO_SAMPLE_FMT sample_format;
/**
 音频帧大小
 */
@property (nonatomic, assign) int32_t framesize;

@end

/**
 * 媒体信息
 */
@interface KSYMediaInfo : NSObject

/**
 封装格式，具体类型为MEDIAINFO_MUX_TYPE
 */
@property (nonatomic) MEDIAINFO_MUX_TYPE type;

/**
 码率
 */
@property (nonatomic, assign) int64_t bitrate;

/**
 视频总时长，单位是秒
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 所有视频流信息，具体对象类型为KSYVideoInfo
 */
@property (nonatomic) NSMutableArray *videos;

/**
 所有音频流信息，具体对象类型为KSYAudioInfo
 */
@property (nonatomic) NSMutableArray *audios;

@end

#endif /* KSYMediaInfo_h */
