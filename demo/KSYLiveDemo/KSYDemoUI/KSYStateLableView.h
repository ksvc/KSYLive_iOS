//
//  KSYStateLableView.h
//  KSYDemo
//
//  Created by pengbin on 16/9/5.
//  Copyright © 2016年 ksyun. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef struct _StreamState {
    double    timeSecond;   // 更新时间
    int       uploadKByte;  // 上传的字节数(KB)
    int       encodedFrames;// 编码的视频帧数
    int       droppedVFrames; // 丢弃的视频帧数
} StreamState;
@class KSYStreamerBase;

/**
 KSY 推流SDK的状态监控控件
 
 streamerVC 每秒钟刷新一次监控的数据
 视图中文字为底部对齐
 */
@interface KSYStateLableView : UILabel {
    // 上一次更新时的数据, 假定每秒更新一次
    StreamState _lastStD;
}

// 开始推流的时间
@property double      startTime;
// 网络拥塞事件发生次数
@property int         notGoodCnt;
// 码率上调事件发生次数
@property int         bwRaiseCnt;
// 码率下调事件发生次数
@property int         bwDropCnt;

// 将推流状态信息清0
- (void) initStreamStat;

// 更新数据(需要每秒被调用一次)
- (void) updateState:(KSYStreamerBase*)str;
@end
