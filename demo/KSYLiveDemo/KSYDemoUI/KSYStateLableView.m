//
//  KSYStateLableView.m
//  KSYDemo
//
//  Created by pengbin on 16/9/5.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYUIVC.h"
#import "KSYStateLableView.h"
#import "KSYPresetCfgView.h"


@interface KSYStateLableView ()

@end

@implementation KSYStateLableView

- (id) init {
    self = [super init];
    self.backgroundColor = [UIColor clearColor];
    self.textColor = [UIColor redColor];
    self.numberOfLines = 7;
    self.textAlignment = NSTextAlignmentLeft;
    [self initStreamStat];
    return self;
}

// 将推流状态信息清0
- (void) initStreamStat{
    memset(&_lastStD, 0, sizeof(_lastStD));
    _startTime  = [[NSDate date]timeIntervalSince1970];
    _notGoodCnt = 0;
    _bwRaiseCnt = 0;
    _bwDropCnt  = 0;
}

- (void) updateState:(KSYStreamerBase*)str {
    StreamState curState = {0};
    curState.timeSecond     = [[NSDate date]timeIntervalSince1970];
    curState.uploadKByte    = [str uploadedKByte];
    curState.encodedFrames  = [str encodedFrames];
    curState.droppedVFrames = [str droppedVideoFrames];
    StreamState deltaS  = {0};
    deltaS.timeSecond    = curState.timeSecond    -_lastStD.timeSecond    ;
    deltaS.uploadKByte   = curState.uploadKByte   -_lastStD.uploadKByte   ;
    deltaS.encodedFrames = curState.encodedFrames -_lastStD.encodedFrames ;
    deltaS.droppedVFrames= curState.droppedVFrames-_lastStD.droppedVFrames;
    _lastStD = curState;
    
    double realTKbps   = deltaS.uploadKByte*8 / deltaS.timeSecond;
    double encFps      = deltaS.encodedFrames / deltaS.timeSecond;
    double dropPercent = deltaS.droppedVFrames * 100.0 /MAX(curState.encodedFrames, 1);
    
    NSString* liveTime =[KSYUIVC timeFormatted: (int)(curState.timeSecond-_startTime) ] ;
    NSString *uploadDateSize = [KSYUIVC sizeFormatted:curState.uploadKByte];
    NSString* stateurl  = [NSString stringWithFormat:@"%@\n", [str.hostURL absoluteString]];
    NSString* statekbps = [NSString stringWithFormat:@"实时码率(kbps)%4.1f\tA%4.1f\tV%4.1f\n", realTKbps, [str encodeAKbps], [str encodeVKbps] ];
    NSString* statefps  = [NSString stringWithFormat:@"实时帧率(fps)%2.1f\t总上传:%@\n", encFps, uploadDateSize ];
    NSString* statedrop = [NSString stringWithFormat:@"视频丢帧 %4d\t %2.1f%% \n", curState.droppedVFrames, dropPercent ];
    NSString* netEvent = [NSString stringWithFormat:@"网络事件计数 %d bad\t bw %d Raise\t %d drop\n", _notGoodCnt, _bwRaiseCnt, _bwDropCnt];
    NSString *cpu_use = [NSString stringWithFormat:@"cpu: %3.2f \t%@",[KSYUIVC cpu_usage], liveTime];
    
    self.text = [ stateurl   stringByAppendingString:statekbps ];
    self.text = [ self.text  stringByAppendingString:statefps  ];
    self.text = [ self.text  stringByAppendingString:statedrop ];
    self.text = [ self.text  stringByAppendingString:netEvent  ];
    self.text = [ self.text  stringByAppendingString:cpu_use  ];
    
}

- (void)drawTextInRect:(CGRect) rect {
    if (self.text == nil){
        return;
    }
    CGFloat oldH = rect.size.height;
    NSAttributedString *attributedText;
    attributedText = [[NSAttributedString alloc] initWithString:self.text
                                                     attributes:@{NSFontAttributeName:self.font}];
    rect.size.height = [attributedText boundingRectWithSize:rect.size
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                    context:nil].size.height;
    if (self.numberOfLines != 0) {
        rect.size.height = MIN(rect.size.height, self.numberOfLines * self.font.lineHeight);
    }
    rect.origin.y = oldH - rect.size.height;  // 底部对齐 将一段文字移动到最底部
    [super drawTextInRect:rect];
}
@end
