//
//  Constant.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/23.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VideoDefinitionType) {
    VideoDefinitionTypeStandard = 0,
    VideoDefinitionTypeHigh,
    VideoDefinitionTypeSuper,
};

typedef NS_ENUM(NSInteger, VCPlayHandlerState) {
    VCPlayHandlerStatePause,
    VCPlayHandlerStatePlay
};

typedef NS_ENUM(NSInteger, VideoListShowType) {
    VideoListShowTypeUnknown,
    VideoListShowTypeLive,          // 直播视频列表
    VideoListShowTypeVod,           // 点播视频列表
};

static NSString * const kVideoCollectionViewCellId = @"kVideoCollectionViewCellId";
static NSString * const kPlayerTableViewCellId     = @"kPlayerTableViewCellId";
static CGFloat    const kVideoCollectionViewCellHeight = 116;
