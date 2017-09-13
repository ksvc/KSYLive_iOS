//
//  KSYGPUBrushStreamerKit.m
//  KSYStreamer
//
//  Created by jiangdong on 28/12/16.
//  Copyright © 2016 ksyun. All rights reserved.
//
#import "KSYGPUBrushStreamerKit.h"

@interface KSYGPUBrushStreamerKit ()
@end

@implementation KSYGPUBrushStreamerKit
- (instancetype) initWithDefaultCfg {
    self = [super initWithDefaultCfg];
    _drawLayer = 5;
    _drawPic = nil;
    return self;
}

@synthesize drawPicRect = _drawPicRect;
- (CGRect) drawPicRect {
    return [self.vStreamMixer getPicRectOfLayer:_drawLayer];
}

- (void) setDrawPicRect:(CGRect)drawPicRect{
    [self.vStreamMixer setPicRect:drawPicRect
                          ofLayer:_drawLayer];
}

@synthesize drawPic = _drawPic;
-(void) setDrawPic:(KSYGPUViewCapture *)drawPic{
    if (drawPic == nil && _drawPic){
        [_drawPic removeAllTargets];
        [self.vStreamMixer  clearPicOfLayer:_drawLayer];
        [_drawPic stop];
        _drawPic = nil;
        return;
    }
    _drawPic = drawPic;
    [_drawPic removeAllTargets];
    [_drawPic addTarget:self.vStreamMixer atTextureLocation:_drawLayer];
}

- (void)dealloc {
    self.drawPic = nil;
}

@end
