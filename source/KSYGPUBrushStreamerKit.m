//
//  KSYGPUPipStreamerKit.m
//  KSYStreamer
//
//  Created by jaingdong on 28/12/16.
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

// 添加图层到 vMixer 中
- (void) addDrawPic:(GPUImageOutput*)pic ToMixerAt: (NSInteger)idx{
    if (pic == nil){
        return;
    }
    [pic removeAllTargets];
    [self.vStreamMixer  clearPicOfLayer:idx];
    [pic addTarget:self.vStreamMixer atTextureLocation:idx];
}

- (void)dealloc {
    [_drawPic     removeAllTargets];
    _drawPic = nil;
}

- (void)removeDrawLayer{
    [self.vStreamMixer  clearPicOfLayer:_drawLayer];
}

/**
 @abstract   添加画笔图层
 */
- (void) addDrawLayer:(UIImage*)img{
    _drawPic = [[GPUImagePicture alloc] initWithImage:img];
    [self addDrawPic:_drawPic ToMixerAt:_drawLayer];
    [_drawPic processImage];
}

@end
