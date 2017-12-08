//
//  KSYGPUBgmStreamerKit.m
//  KSYStreamer
//
//  Created by jiangdong on 28/12/16.
//  Copyright © 2016 ksyun. All rights reserved.
//
#import <objc/runtime.h>
#import "KSYGPUStreamerKit+bgp.h"

#define weakObj(o) __weak typeof(o) o##Weak = o;

// 这里背景图片放在原本摄像头图层的下方, 图层index为1
static const NSInteger kBgpIdx = 1;

@implementation KSYGPUStreamerKit(bgp)


- (KSYGPUPicture*)bgPic {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBgPic:(KSYGPUPicture *)bgPic {
    objc_setAssociatedObject(self, @selector(bgPic), bgPic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)updateDimensions {
    UIInterfaceOrientation ori = [[UIApplication sharedApplication] statusBarOrientation];
    CGSize preSz, strSz;
    if (UIInterfaceOrientationIsPortrait(ori)) {
        preSz.width  = MIN(self.previewDimension.width, self.previewDimension.height);
        preSz.height = MAX(self.previewDimension.width, self.previewDimension.height);
        strSz.width  = MIN(self.streamDimension.width, self.streamDimension.height);
        strSz.height = MAX(self.streamDimension.width, self.streamDimension.height);
    }
    else {
        preSz.width  = MAX(self.previewDimension.width, self.previewDimension.height);
        preSz.height = MIN(self.previewDimension.width, self.previewDimension.height);
        strSz.width  = MAX(self.streamDimension.width, self.streamDimension.height);
        strSz.height = MIN(self.streamDimension.width, self.streamDimension.height);
    }
    [self.vPreviewMixer forceProcessingAtSize:preSz];
    [self.vStreamMixer forceProcessingAtSize:strSz];
    self.gpuToStr.outputSize = strSz;
}

- (void)updateBgpImage:(UIImage*)img {
    self.gpuToStr.targetFps = self.videoFPS;
    self.vPreviewMixer.masterLayer = kBgpIdx;
    self.vStreamMixer.masterLayer  = kBgpIdx;
    [self.vPreviewMixer  clearPicOfLayer:kBgpIdx];
    [self.vStreamMixer  clearPicOfLayer:kBgpIdx];
    
    self.bgPic = [[KSYGPUPicture alloc] initWithImage:img andOutputSize:img.size];
    [self.bgPic addTarget:self.vPreviewMixer atTextureLocation:kBgpIdx];
    [self.bgPic addTarget:self.vStreamMixer atTextureLocation:kBgpIdx];
    [self setRect:CGRectMake(-2.0, -2.0, 0.0, 0.0) ofLayer:kBgpIdx]; // 居中放置背景图片
    [self setOrientaion:img.imageOrientation ofLayer:kBgpIdx];
    
    self.gpuToStr.bAutoRepeat = NO; // 为了图片内容刷新, 先停止输出上一帧画面
    weakObj(self);
    [self.bgPic processImageWithCompletionHandler:^{
        if (selfWeak.streamerBase.isStreaming) {
            selfWeak.gpuToStr.bAutoRepeat = YES; // 图片内容更新完毕, 开始输出画面
        }
    }];
}

- (void)startBgpPreview:(UIView*)bgView {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [bgView addSubview:self.preview];
        self.preview.frame = bgView.bounds;
        [self.preview layoutSubviews];
        [self updateDimensions];
        [self.vPreviewMixer addTarget:self.preview];
        [self.vStreamMixer addTarget:self.gpuToStr];
        self.gpuToStr.bAutoRepeat = NO; // 为了图片内容刷新, 先停止输出上一帧画面
        weakObj(self);
        [self.bgPic processImageWithCompletionHandler:^{
            if (selfWeak.streamerBase.isStreaming) {
                selfWeak.gpuToStr.bAutoRepeat = YES; // 图片内容更新完毕, 开始输出画面
            }
        }];
    });
    [self startAudioCap];
}

- (BOOL)startBgpStream:(NSURL*)url {
    if (self.streamerBase.streamState == KSYStreamStateIdle ||
        self.streamerBase.streamState == KSYStreamStateError) {
        self.gpuToStr.bAutoRepeat = YES;
        [self.streamerBase startStream:url]; //启动推流
        return YES;
    }
    return NO;
}

- (void)stopBgpStream {
    self.gpuToStr.bAutoRepeat = NO;
    [self.streamerBase stopStream];
}

@end
