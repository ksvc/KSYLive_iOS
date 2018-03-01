//
//  KSYSettingModel.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/14.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYSettingModel.h"

@implementation KSYSettingModel

+(KSYSettingModel*)modelWithDictionary:(NSDictionary *)dic{
    KSYSettingModel* model = [[self alloc]initWithDictionary:dic];
    return model;
}
-(instancetype)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        for (NSString *string in [dic allKeys]) {
            //遍历字典，拿到字典中的属性值
            if ([string isEqualToString:@"resolutionGroup"]) {
            _strResolutionSize = [self pushFlowResolutionString:[dic valueForKey:string]];
            }
            else if ([string isEqualToString:@"liveGroup"]) {
             _liveSence = [self liveSenceString:[dic valueForKey:string]];
            }
            else if ([string isEqualToString:@"performanceGroup"]) {
               _performanceModel = [self performanceModelString:[dic valueForKey:string]];
            }
            else if ([string isEqualToString:@"collectGroup"]) {
               _collectPreset = [self collectPresetString:[dic valueForKey:string]];
            }
            else if ([string isEqualToString:@"videoGroup"]) {
              _videoCodecTpye = [self videoCodecString:[dic valueForKey:string]];
            }
            else if ([string isEqualToString:@"audioGroup"]) {
             _audioCodecType = [self audioCodecString:[dic valueForKey:string]];
            }
        }
    }
    return self;
}
//推流分辨率
-(CGSize)pushFlowResolutionString:(NSString*)title{

    if ([title isEqualToString:@"360P"]) {
        return CGSizeMake(640, 360);
    }
    else if ([title isEqualToString:@"480P"]){
        return CGSizeMake(960, 540);
    }
    else{
        return  CGSizeMake(1280, 720);
    }
}
//直播场景
- (KSYLiveScene)liveSenceString:(NSString*)title{
    if ([title isEqualToString:@"通用"]){
        return KSYLiveScene_Default;
    }
    else if ([title isEqualToString:@"秀场"]){
        return KSYLiveScene_Showself;
    }
    else {
        return KSYLiveScene_Game;
    }
}
-(KSYVideoEncodePerformance)performanceModelString:(NSString*)title{
    if ([title isEqualToString:@"低耗能"]){
        return KSYVideoEncodePer_LowPower;
    }
    else if ([title isEqualToString:@"均衡"]){
        return KSYVideoEncodePer_Balance;
    }
    else {
        return KSYVideoEncodePer_HighPerformance;
    }
}
-(NSString*)collectPresetString:(NSString*)title{
    if ([title isEqualToString:@"480P"]) {
       return  AVCaptureSessionPreset640x480;;
    }
    else if ([title isEqualToString:@"540P"]){
        return AVCaptureSessionPresetiFrame960x540;
    }
    else{
        return  AVCaptureSessionPreset1280x720;
    }
    
}
-(KSYVideoCodec)videoCodecString:(NSString*)title{
    if ([title isEqualToString:@"自动"]) {
        return  KSYVideoCodec_AUTO;
    }
    else if ([title isEqualToString:@"软264"]){
        return KSYVideoCodec_X264;
    }
    else if ([title isEqualToString:@"硬264"]){
        return KSYVideoCodec_VT264;
    }
    else{
        return  KSYVideoCodec_QY265;
    }
}
-(KSYAudioCodec)audioCodecString:(NSString*)title{
    if ([title isEqualToString:@"AAC LC"]) {
        return  KSYAudioCodec_AAC;
    }
    else if ([title isEqualToString:@"AAC HE"]){
        return KSYAudioCodec_AAC_HE;
    }
    else{
        return  KSYAudioCodec_AAC_HE_V2;
    }
}

@end
