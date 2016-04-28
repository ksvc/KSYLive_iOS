//
//  KSYCamera.h
//  KSYCam
//
//  Created by yiqian on 1/24/16.
//  Copyright © 2016 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KSYStreamerBase.h"


@interface KSYCamera : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

// capture settings
/**
 @abstract   视频分辨率
 @discussion width x height （ 此处width始终大于高度，是否竖屏取决于videoOrientation的值 )

 @see KSYVideoDimension, videoOrientation
 */
//@property (nonatomic, assign) KSYVideoDimension        videoDimension;

/**
 @abstract   用户定义的视频分辨率
 @discussion 当videoDimension 设置为 KSYVideoDimension_UserDefine_* 时有效
 @discussion 内部始终将较大的值作为宽度 (若需要竖屏，请设置 videoOrientation）
 @discussion 宽高都会向上取整为4的整数倍
 @discussion 宽度有效范围[160, 1280]
 @discussion 高度有效范围[ 90,  720], 超出范围会提示参数错误
 @see KSYVideoDimension, videoOrientation
 */
@property (nonatomic, assign) CGSize        videoDimensionUserDefine;

/**
 @abstract   摄像头位置
 @discussion 前后摄像头
 */
@property (nonatomic, assign) AVCaptureDevicePosition   cameraPosition;

/**
 @abstract   摄像头朝向
 @discussion (1~4):down up right left (home button)
 @discussion down,up: width < height
 @discussion right,left: width > height
 @discussion 需要与UI方向一致
 */
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

/**
 @abstract   视频帧率
 @discussion video frame per seconds 有效范围[1~30], 超出会提示参数错误
 */
@property (nonatomic, assign) int                       videoFPS;

/**
 @abstract 当前采集设备状况
 @discussion 可以通过该属性获取采集设备的工作状况
 
 @discussion 通知：
 * KSYCaptureStateDidChangeNotification 当采集设备工作状态发生变化时提供通知
 * 收到通知后，通过本属性查询新的状态，并作出相应的动作
 */
@property (nonatomic, readonly) KSYCaptureState captureState;


@property (strong, nonatomic, readonly) KSYStreamerBase * streamer;

// Posted when capture state changes
FOUNDATION_EXPORT NSString *const KSYCaptureStateDidChangeNotification NS_AVAILABLE_IOS(7_0);

/**
 @abstract 启动预览 （step2）
 @param view 预览画面作为subview，插入到 view 的最底层
 @discussion 设置完成采集参数之后，按照设置值启动预览，启动后对采集参数修改不会生效
 @discussion 需要访问摄像头和麦克风的权限，若授权失败，其他API都会拒绝服务
 
 @warning: 开始推流前必须先启动预览
 @see videoDimension, cameraPosition, videoOrientation, videoFPS
 */
- (void) startPreview: (UIView*) view
             streamer: (KSYStreamerBase*)streamer;

/**
 @abstract   停止预览，停止采集设备，并清理会话（step5）
 @discussion 若推流未结束，则先停止推流
 
 @see stopStream
 */
- (void) stopPreview;
@end

