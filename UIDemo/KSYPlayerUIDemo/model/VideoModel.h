//
//  VideoModel.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/22.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface VideoModel : JSONModel
@property (nonatomic, copy) NSString *VideoID;
@property (nonatomic, copy) NSString *VideoTitle;
@property (nonatomic, copy) NSArray<NSString*> *PlayURL;
@property (nonatomic, copy) NSArray<NSString*> *CoverURL;
@property (nonatomic, copy) NSNumber<Optional> *definitation;  // 清晰度
@end

@protocol VideoModel;
@interface VideoModelResponseObj : JSONModel
@property (nonatomic, assign) NSInteger  RetCode;
@property (nonatomic, copy)   NSString  *RetMsg;
@property (nonatomic, strong) NSArray<VideoModel> *Detail;
@end


@interface VideoModelData : JSONModel
@property (nonatomic, strong) VideoModelResponseObj *Data;
@end
