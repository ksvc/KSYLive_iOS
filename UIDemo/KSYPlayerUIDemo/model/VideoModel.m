//
//  VideoModel.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/22.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "VideoModel.h"

@implementation VideoModel

- (NSString *)VideoTitle {
    return [_VideoTitle stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end

@implementation VideoModelResponseObj
@end

@implementation VideoModelData
@end
