//
//  VideoListViewModel.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/22.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoModel;

@interface VideoListViewModel : NSObject

@property (nonatomic, strong) NSMutableArray<VideoModel*> *listViewDataSource;

- (instancetype)initWithJsonResponseData:(NSData *)data;

@end
