//
//  VideoListViewModel.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/22.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "VideoListViewModel.h"
#import "VideoModel.h"

@implementation VideoListViewModel

/*
 https://ks3-cn-beijing.ksyun.com/ksvsdemo/xulei_0815/Aerial%20China%206-copy.mp4,
 https://ks3-cn-beijing.ksyun.com/ksvsdemo/xulei_0815/Aerial%2520China%25206-libx264-1280x720-1100000.mp4,
 https://ks3-cn-beijing.ksyun.com/ksvsdemo/xulei_0815/Aerial%2520China%25206-libx264-640x480-800000.mp4
 */

- (instancetype)initWithJsonResponseData:(NSData *)data {
    if (self = [super init]) {
        NSError *error;
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
        VideoModelData *modelData = [[VideoModelData alloc] initWithString:jsonString error:&error];
        if (!error) {
            if ([modelData.Data.RetMsg isEqualToString:@"success"]) {
                self.listViewDataSource = [[NSMutableArray alloc] initWithArray:modelData.Data.Detail];
                for (VideoModel *aVideoModel in self.listViewDataSource) {
                    aVideoModel.definitation = @(0);
                    // 将三种清晰度的url排序（标清，高清，超高清）
                    NSMutableArray *array = [aVideoModel.PlayURL mutableCopy];
                    
                    for (NSInteger i = 0, j = aVideoModel.PlayURL.count - 1; i < j ; ++i, --j) {
                        id objI = [aVideoModel.PlayURL[i] copy];
                        id objJ = [aVideoModel.PlayURL[j] copy];
                        [array replaceObjectAtIndex:i withObject:objJ];
                        [array replaceObjectAtIndex:j withObject:objI];
                    }
                    aVideoModel.PlayURL = [[NSArray alloc] initWithArray:array copyItems:YES];
                }
            }
        }
    }
    return self;
}

@end
