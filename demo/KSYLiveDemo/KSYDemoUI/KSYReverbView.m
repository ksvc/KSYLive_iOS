//
//  KSYReverbView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/28.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYReverbView.h"
@interface KSYReverbView () {
    UILabel * _title;
}
@end
@implementation KSYReverbView
- (id)init{
    self = [super init];
    _title = [self addLable:@"选择混响类型"];
    _reverbType = [self addSegCtrlWithItems:@[@"关闭", @"录影棚",@"演唱会",@"KTV",@"小舞台"]];
    return self;
}
- (void)layoutUI{
    [super layoutUI];
    [self putRow1:_title];
    [self putRow1:_reverbType];
}
@end
