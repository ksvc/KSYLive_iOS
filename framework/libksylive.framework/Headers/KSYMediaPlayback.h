//
//  KSYMediaPlayback.h
//  KSYMediaPlayback
//
//  Created by zengfanping on 10/12/15.
//  Copyright © 2015 kingsoft. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
/*!
 KSYMediaPlayback为播放内核[KSYMoviePlayerController](KSYMoviePlayerController)提供播放控制功能。
 
 ## 联系我们
 当本文档无法帮助您解决在开发中遇到的具体问题，请通过以下方式联系我们，金山云工程师会在第一时间回复您。
 
 __E-mail__:  zengfanping@kingsoft.com
 
 */

@protocol KSYMediaPlayback

/**
 @abstract 准备视频播放
 @discussion prepareToPlay处理逻辑

 * 如果isPreparedToPlay为FALSE，直接调用[play]([KSYMediaPlayback play])，则在play内部自动调用[prepareToPlay]([KSYMediaPlayback prepareToPlay])接口。
 * prepareToPlay调用后，由MPMediaPlaybackIsPreparedToPlayDidChangeNotification通知完成准备工作。查询[isPreparedToPlay]([KSYMediaPlayback isPreparedToPlay])可以获得具体属性值。
 @discussion 通知类型
 
 * MPMediaPlaybackIsPreparedToPlayDidChangeNotification， 播放器完成对视频文件的初始化时发送通知
 
 @see isPreparedToPlay
 */
// Prepares the current queue for playback, interrupting any active (non-mixible) audio sessions.
// Automatically invoked when -play is called if the player is not already prepared.
- (void)prepareToPlay;

/**
 @abstract 查询视频准备是否完成
 @discussion isPreparedToPlay处理逻辑
 
 * 如果isPreparedToPlay为TRUE，则可以调用[play]([KSYMediaPlayback play])接口开始播放;
 * 如果isPreparedToPlay为FALSE，则需要调用[prepareToPlay]([KSYMediaPlayback prepareToPlay])接口开始准备工作；
 * 如果isPreparedToPlay为FALSE，直接调用[play]([KSYMediaPlayback play])，则在play内部自动调用[prepareToPlay]([KSYMediaPlayback prepareToPlay])接口。
 @see prepareToPlay
 */
// Returns YES if prepared for playback.
@property(nonatomic, readonly) BOOL isPreparedToPlay;

/**
 @abstract 播放当前视频。
 @discussion play的使用逻辑:
 
 * 如果调用play方法前已经调用[prepareToPlay]([KSYMediaPlayback prepareToPlay])完成播放器对视频文件的初始化，且[shouldAutoplay]([KSYMoviePlayerController shouldAutoplay])属性为NO，则调用play方法将开始播放当前视频。此时播放器状态为CBPMoviePlaybackStatePlaying。
 * 如果调用play方法前已经调用[prepareToPlay]([KSYMediaPlayback prepareToPlay])完成播放器对视频文件的初始化，且[shouldAutoplay]([KSYMoviePlayerController shouldAutoplay])属性为YES，则调用play方法将暂停播放当前视频，实现效果和pause一致。
 * 如果调用play方法前未调用[prepareToPlay]([KSYMediaPlayback prepareToPlay])完成播放器对视频文件的初始化，则播放器自动调用[prepareToPlay]([KSYMediaPlayback prepareToPlay])进行视频文件的初始化工作。
 * 如果调用play方法前已经调用pause暂停了正在播放的视频，则重新开始启动播放视频。
 @since Available in KSYMediaPlayback 1.0 and later.
 @see prepareToPlay
 */
// Plays items from the current queue, resuming paused playback if possible.
- (void)play;

/**
 @abstract 暂停播放当前视频。
 @discussion pause调用逻辑：
 
 * 如果当前视频播放已经暂停，调用该方法将不产生任何效果。
 * 重新回到播放状态，需要调用[play]([KSYMediaPlayback play])方法。
 * 如果调用pause方法后视频暂停播放，此时播放器状态处于CBPMoviePlaybackStatePaused。
 * 播放器内部监听了UIApplicationWillEnterForegroundNotification通知，该通知发生时如果视频仍然在播放，将自动调用pause暂停当前视频播放。
 
 
 
 @discussion 后台播放逻辑：
 
 * 需要APP有后台执行权限，在工程Info.plist中添加后台运行模式，设置为audio。具体是添加UIBackgroundModes项，值为audio。
 * 当用户点击home按钮后，播放器进入后台继续读取数据并播放音频。
 * 当APP回到前台后，音频继续播放。图像渲染内容保持和音频同步。
 * 如果在开启后台运行模式后，需要切换后台暂停，需要监听相关事件并主动调用pause操作。
 
 @since Available in KSYMediaPlayback 1.0 and later.
 */
// Pauses playback if playing.
- (void)pause;

/**
 @abstract 结束当前视频的播放。
 @discussion stop调用逻辑：
 
 * 调用stop结束当前播放，如果需要重新播放该视频，需要调用[prepareToPlay]([KSYMediaPlayback prepareToPlay])方法。
 * 调用stop方法后，播放器开始进入关闭当前播放的操作，操作完成将发送MPMoviePlayerPlaybackDidFinishNotification通知。
 
 @discussion 通知：
 
 * MPMoviePlayerPlaybackDidFinishNotification， 当播放完成将发送该通知。
 
 @since Available in KSYMediaPlayback 1.0 and later.
 @see prepareToPlay
 */
// Ends playback. Calling -play again will start from the beginnning of the queue.
- (void)stop;

/**
 @abstract 播放视频的当前时刻，单位为秒。
 @discussion currentPlaybackTime属性更改时机：
 
 * 视频正常播放时，如果改变currentPlaybackTime的值，将导致播放行为跳转到新的currentPlaybackTime位置播放。
 * 如果在视频未播放前设置currentPlaybackTime的值，将导致播放时刻从currentPlaybackTime位置播放。
 @since Available in KSYMediaPlayback 1.0 and later.
 */
// The current playback time of the now playing item in seconds.
@property(nonatomic) NSTimeInterval currentPlaybackTime;

// Posted when the prepared state changes of an object conforming to the MPMediaPlayback protocol changes.
// This supersedes MPMoviePlayerContentPreloadDidFinishNotification.
MP_EXTERN NSString *const MPMediaPlaybackIsPreparedToPlayDidChangeNotification NS_DEPRECATED_IOS(3_2, 9_0);

@end
