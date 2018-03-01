//
//  KSYSettingModel.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/14.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <libksygpulive/KSYGPUStreamerKit.h>
//#import <libksygpulive/KSYTypeDef.h>

@interface KSYSettingModel : NSObject

//推流分辨率
@property(nonatomic,assign)CGSize strResolutionSize;
//直播场景
@property(nonatomic,assign)KSYLiveScene liveSence;
//性能模式
@property(nonatomic,assign)KSYVideoEncodePerformance performanceModel;
//采集分辨率
@property (nonatomic, assign)NSString *collectPreset;
//音频编码器类型
@property(nonatomic,assign)KSYAudioCodec audioCodecType;
//视频编码器类型
@property(nonatomic,assign)KSYVideoCodec videoCodecTpye;

+ (KSYSettingModel*)modelWithDictionary:(NSDictionary *)dic;

- (instancetype)initWithDictionary:(NSDictionary*)dic;

@end
