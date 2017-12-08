//
//  KSYGPUStreamerKit+bgp.h
//  KSYStreamer
//
//  bgp = background picture
//  Created by jiangdong on 28/12/16.
//  Copyright © 2016 ksyun. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <libksygpulive/KSYGPUStreamerKit.h>

@interface KSYGPUStreamerKit(bgp)

// 背景图片, 这里背景图片放在原本摄像头图层的下方, 图层index为1
@property (nonatomic, retain) KSYGPUPicture * bgPic;

/**
 更新背景图片

 @param img 新的背景图片
 */
- (void)updateBgpImage:(UIImage*)img;

/**
 开始背景图预览

 @param bgView 预览视图的背景图, 预览视图会填满背景视图
 结束预览仍然使用之前的 stopPreview
 */
- (BOOL)startBgpPreview:(UIView*)bgView;

/**
 开始背景图推流

 @param url 推流地址
 @return 当前状态是否能开始推流
 */
- (BOOL)startBgpStream:(NSURL*)url;

/**
 停止背景图推流
 */
- (void)stopBgpStream;
@end
