//
//  KSYMoviePlayerController.h
//  KSYPlayerCore
//
//  Created by zengfanping on 10/12/15.
//  Copyright © 2015 kingsoft. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "KSYMediaPlayback.h"
#import "KSYQosInfo.h"
#import "KSYMoviePlayerDefines.h"
#import "KSYReachability.h"

/**
 金山云播放内核提供了跨终端平台的播放器SDK，支持Android/iOS/Flash平台的视频播放需求。金山云播放内核集成有业界一流的高性能H.265/HEVC解码器，提供流畅、低功耗的播放体验。同时SDK提供和系统播放器一致的音视频播放、控制接口，极大地降低了开发门槛。
 
 在任何平台上，金山云播放内核都提供底层开发接口，开发者可自由实现个性的进度条、播放按钮、设置等播放界面元素。金山云提供丰富的播放器调用示例，全部以source code开放，并提供详尽的接口说明文档，让视频应用快速搭建、开发和发布。
 
 金山云播放内核iOS版继承自系统播放器MPMoviePlayerController，适配支持iOS 7.0以上机型，提供系统一致的播放控制接口，在系统播放器基础上新增如下功能：
 
 * 集成金山云高效H.265解码器，解码效率高于开源版本OpenHEVC一倍以上；
 * 支持rmvb/flv/avi/mkv/mov等主流封装格式；
 * 支持HLS/rtmp协议；
 * 完美支持rtmp/http live streaming，结合金山云直播流动态调整功能，实现持续低于2秒的低延时直播体验。
 
 ## 环境搭建
 KSYMoviePlayerController依赖如下第三方库：
 
 * VideoToolbox.framework
 * libz.tbd or libz.dylib
 * libbz2.tbd or libbz2.dylib
 * libstdc++.tbd or libstdc++.dylib
 
 ## 使用说明
 
 * 开发IDE建议使用Xcode 7，在旧版本Xcode上可能出现其他异常，请直接联系客服人员。
 * 当前iOS framework版本只支持iOS 7.0及以上版本。
 
 ## 联系我们
 当本文档无法帮助您解决在开发中遇到的具体问题，请通过以下方式联系我们，金山云工程师会在第一时间回复您。
 
 __E-mail__:  zengfanping@kingsoft.com
 
 ## 版本信息
 __Version__: 1.0
 
 __Found__: 2015-05-30
 
 */

/**
 @abstract 视频数据回调
 */
typedef void (^KSYPlyVideoDataBlock)(CMSampleBufferRef pixelBuffer);

/**
 @abstract 音频数据回调
 */
typedef void (^KSYPlyAudioDataBlock)(CMSampleBufferRef sampleBuffer);

/**
 @abstract message数据回调
 */
typedef void (^KSYPlyMessageDataBlock)(NSDictionary *message, int64_t pts, int64_t param);

/**
 @abstract texture回调
 */
typedef void (^KSYPlyTextureBlock)(GLuint texId, int width, int height, double pts);

/**
 * KSYMoviePlayerController
 */
@interface KSYMoviePlayerController : NSObject <KSYMediaPlayback>
#pragma mark MPMoviePlayerController

/**
 @abstract 初始化播放器并设置播放地址
 @param url 视频播放地址，该地址可以是本地地址或者服务器地址.
 @return 返回KSYMoviePlayerController对象，该对象的视频播放地址ContentURL已经初始化。此时播放器状态为MPMoviePlaybackStateStopped.
 
 @discussion 该方法初始化了播放器，并设置了播放地址。但是并没有将播放器对视频文件进行初始化，需要调用 [prepareToPlay]([KSYMediaPlayback prepareToPlay])方法对视频文件进行初始化。
 @discussion 当前支持的协议包括：
 
 * http
 * rtmp
 * file, 本地文件
 * rtsp
 
 @warning 必须调用该方法进行初始化，不能调用init方法。
 @since Available in KSYMoviePlayerController 1.0 and later.
 @return 返回KSYMoviePlayerController 实例
 */
- (instancetype)initWithContentURL:(NSURL *)url;

/**
 @abstract 初始化播放器并设置主播放地址和备用播放地址
 @param url 视频主播放地址，使用HEVC流地址.
 @param backURL 视频备用播放地址，使用H264流地址
 @return 返回KSYMoviePlayerController对象，该对象的视频播放地址ContentURL已经初始化。此时播放器状态为MPMoviePlaybackStateStopped.
 
 @discussion 如果设置了备用播放地址，则会在设备不支持硬解播放HEVC流时切换到备用播放地址进行播放
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 3.0.1 and later.
 */
- (instancetype)initWithContentURL:(NSURL *)url backupURL:(NSURL*)backupURL;

/**
 @abstract 初始化播放器并设置播放地址
 @param url 视频播放地址，该地址可以是本地地址或者服务器地址.
 @param sharegroup opengl的sharegroup, 用于共享视频渲染texture
 @return 返回KSYMoviePlayerController对象，该对象的视频播放地址ContentURL已经初始化。此时播放器状态为MPMoviePlaybackStateStopped.
 
 @discussion 如果要获取视频渲染时的texture时(设置textureBlock属性)，需要使用此初始化函数，将EAGLSharegroup对象作为参数传入，否则texture无法在多个OpenGL的context中共享使用
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.8.7 and later.
*/
- (instancetype)initWithContentURL:(NSURL *)url sharegroup:(EAGLSharegroup*)sharegroup;

/**
 @abstract 初始化播放器并设置播放地址
 @param url 视频播放的绝对地址，可以设置为nil;
 @param list 分片列表，可以设置为nil
 @param sharegroup opengl的sharegroup, 用于共享视频渲染texture, 可以设置为nil
 @return 返回KSYMoviePlayerController对象，该对象的视频播放地址ContentURL已经初始化。此时播放器状态为MPMoviePlaybackStateStopped.
 
 @discussion 该方法更适用于点播
 @discussion url和list的设置逻辑:
 
 * url和fileList不能同时为空
 * url为nil，fileList不为nil时，播放器取list中的地址进行播放
 * url不nil，fileList为nil时，播放器取baseURL进行播放
 * url和fileList都不为nil，播放会认为url是绝对地址，list为相对地址，找到url中的最后一个'/'进行url/list 拼接后播放
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 2.1.0 and later.
 */
- (instancetype)initWithContentURL:(NSURL *)url fileList:(NSArray *)fileList sharegroup:(EAGLSharegroup*)sharegroup NS_DESIGNATED_INITIALIZER;

/**
 @abstract 正在播放的视频文件的URL地址，该地址可以是本地地址或者服务器地址。
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property (nonatomic, readonly) NSURL *contentURL;

/**
 @abstract 正在播放的视频文件的list列表
 @since Available in KSYMoviePlayerController 2.1.0 and later.
 */
@property (nonatomic, readonly) NSArray *fileList;

/**
 @abstract 包含视频播放内容的VIEW（只读）。
 @discussion view的使用逻辑：
 
 * 可以通过frame设置view大大小
 * 使用[scalingMode]([KSYMoviePlayerController scalingMode]) 可以更改视频内容在VIEW中的显示情况
 
 @see scalingMode
 */
// The view in which the media and playback controls are displayed.
@property (nonatomic, readonly) UIView *view;

// The style of the playback controls. Defaults to MPMovieControlStyleDefault.
/**
 @warning 该属性当前不支持
 */
@property (nonatomic) MPMovieControlStyle controlStyle;

/**
 @abstract 当前播放器的播放状态（只读）。
 @discussion 可以通过该属性获取视频播放情况：
 
 <pre><code>
 typedef NS_ENUM(NSInteger, MPMoviePlaybackState) {
 MPMoviePlaybackStateStopped,           // 播放停止
 MPMoviePlaybackStatePlaying,           // 正在播放
 MPMoviePlaybackStatePaused,            // 播放暂停
 MPMoviePlaybackStateInterrupted,       // 播放被打断
 MPMoviePlaybackStateSeekingForward,    // 向前seeking中
 MPMoviePlaybackStateSeekingBackward    // 向后seeking中
 } NS_DEPRECATED_IOS(3_2, 9_0);
 </code></pre>
 @discussion 通知：
 
 * MPMoviePlayerPlaybackDidFinishNotification，当播放完成时提供通知
 * MPMoviePlayerPlaybackStateDidChangeNotification，当播放状态变化时提供通知
 
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
// Returns the current playback state of the movie player.
@property (nonatomic, readonly) MPMoviePlaybackState playbackState;


/**
 @abstract 当前网络加载情况
 @discussion 可以通过该属性获取视频加载情况：
 
 <pre><code>
 typedef NS_OPTIONS(NSUInteger, MPMovieLoadState) {
 MPMovieLoadStateUnknown        = 0,        // 加载情况未知
 MPMovieLoadStatePlayable       = 1 << 0,   // 加载完成，可以播放
 MPMovieLoadStatePlaythroughOK  = 1 << 1,   // 加载完成，如果shouldAutoplay为YES，将自动开始播放
 MPMovieLoadStateStalled        = 1 << 2,   // 如果视频正在加载中
 } NS_DEPRECATED_IOS(3_2, 9_0);
 </code></pre>
 @discussion 通知：
 
 * MPMoviePlayerLoadStateDidChangeNotification，当加载状态变化时提供通知
 
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
// Returns the network load state of the movie player.
@property (nonatomic, readonly) MPMovieLoadState loadState;

/**
 @abstract 播放视频时是否需要自动播放，默认值为YES。
 @discussion
 
 * 如果shouldAutoplay值为YES，则调用[prepareToPlay]([KSYMediaPlayback prepareToPlay])方法后，播放器完成初始化后将自动调用[play]([KSYMediaPlayback play])方法播放视频。
 * 如果shouldAutoplay值为NO，则播放器完成初始化后将等待外部调用[play]([KSYMediaPlayback play])方法。
 * 开发者可以监听播放SDK发送的MPMediaPlaybackIsPreparedToPlayDidChangeNotification通知。在收到该通知后进行其他操作并主动调用[play]([KSYMediaPlayback play])方法开启播放。
 
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
// Indicates if a movie should automatically start playback when it is likely to finish uninterrupted based on e.g. network conditions. Defaults to YES.
@property (nonatomic) BOOL shouldAutoplay;

/**
 @abstract 当前缩放显示模式。
 @discussion 当前支持四种缩放模式：
 
 <pre><code>
 typedef NS_ENUM(NSInteger, MPMovieScalingMode) {
 MPMovieScalingModeNone,       // 无缩放
 MPMovieScalingModeAspectFit,  // 同比适配，某个方向会有黑边
 MPMovieScalingModeAspectFill, // 同比填充，某个方向的显示内容可能被裁剪
 MPMovieScalingModeFill        // 满屏填充，与原始视频比例不一致
 } NS_DEPRECATED_IOS(2_0, 9_0);
 </code></pre>
 
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
// Determines how the content scales to fit the view. Defaults to MPMovieScalingModeAspectFit.
@property (nonatomic) MPMovieScalingMode scalingMode;

/**
 @abstract 当前视频总时长
 @discussion 视频总时长，单位是秒。
 
 * 如果是直播视频源，总时长为0.
 * 如果该信息未知，总时长默认为0.
 
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
// The duration of the movie, or 0.0 if not known.
@property (nonatomic, readonly) NSTimeInterval duration;

/**
 @abstract 当前视频可播放长度
 @discussion 视频可播放时长，单位是秒。
 
 * currentPlaybackTime 标记的是播放器当前已播放的时长。
 * playableDuration 标记的是播放器缓冲的时间，会稍大于currentPlaybackTime，与currentPlaybackTime的差值则是缓冲长度。
 * duration 是视频总时长。
 
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
// The currently playable duration of the movie, for progressively downloaded network content.
@property (nonatomic, readonly) NSTimeInterval playableDuration;

/**
 @abstract 数据统计，默认开启
 @discussion 可开关
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property (nonatomic, assign) BOOL shouldEnableKSYStatModule;

/**
 @abstract 当前视频宽高
 @discussion 获取信息
 
 * 监听MPMovieNaturalSizeAvailableNotification
 * 播放过程中，宽高信息可能会产生更改
 
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property (nonatomic, readonly) CGSize naturalSize;

/**
 @abstract 当前视频自带旋转（逆时针）角度
 @discussion  rotateDegress 是人为旋转角度，naturalRotate是文件meta信息中自带的旋转角度
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 2.2.0 and later.
 */
 @property (nonatomic, readonly) NSInteger naturalRotate;

#pragma mark KSYMoviePlayerController New Feature

/**
 @abstract 获取播放器日志
 @discussion 相关字段说明请联系金山云技术支持
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property (nonatomic, copy)void (^logBlock)(NSString *logJson);

/**
 @abstract bufferTimeMax指定播放时的缓冲时长，单位秒
 @discussion 对于直播流，该属性用于直播延时控制；对于点播流，该属性用于缓冲时长控制
 
 * 直播流该属性默认为2秒，设置为0或负值时为关闭直播追赶
 * 点播流该属性默认为3600秒，且与bufferSizeMax同时生效，两者取小值
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property NSTimeInterval bufferTimeMax;

/**
 @abstract bufferSizeMax指定点播播放时的最大缓冲，单位MB
 @discussion 取值大小为0-100，超过此区间时将使用默认值15。
 
 * 该属性仅对点播视频有效；
 * 默认值为15。
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 2.0 and later.
 */
@property NSUInteger bufferSizeMax;

/**
 @abstract 已经加载的数据大小
 @discussion 已经加载的数据大小，单位是兆。
 
 * 已经加载的全部数据大小，包括音频和视频。
 * 数据包括已经播放的，和当前的cache数据。
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
// The flow size of the movie which has been download, or 0.0 if not known.
@property (nonatomic, readonly) double readSize;

/**
 @abstract buffer为空时，拉取数据所耗的时长
 @discussion 当buffer为空时，开始统计。单位为秒。
 
 * 当MPMoviePlayerLoadStateDidChangeNotification 通知发起；
 * MPMovieLoadState状态为MPMovieLoadStateStalled 开始计时；
 * MPMovieLoadState状态为MPMovieLoadStatePlayable 或者 MPMovieLoadStatePlaythroughOK时，结束计时；
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property (nonatomic, readonly) NSTimeInterval bufferEmptyDuration;

/**
 @abstract 发起cache的次数
 @discussion 当buffer为空时，统计一次，统计的条件为
 
 * 当MPMoviePlayerLoadStateDidChangeNotification 通知发起
 * MPMovieLoadState 状态为MPMovieLoadStateStalled

 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property (nonatomic, readonly) NSInteger bufferEmptyCount;

/**
 @abstract 视频流server ip
 @discussion 当收到prepared后，即可以查询当前连接的视频流server ip
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property (nonatomic, readonly) NSString* serverAddress;

/**
 @abstract 客户端出口IP
 @discussion 当收到prepared后，即可以查询客户端的出口IP
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.5.0.1 and later.
 */
@property (nonatomic, readonly) NSString *clientIP;

/**
 @abstract 客户端LocalDNSIP
 @discussion 当收到prepared后，即可以查询客户端的LocalDNSIP
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.5.0.1 and later.
 */
@property (nonatomic, readonly) NSString *localDNSIP;

/**
 @abstract 视频流qos信息
 @discussion 在播放过程中，即可以查询当前连接的视频流qos信息
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property (nonatomic, strong) KSYQosInfo *qosInfo;

/**
 @abstract 截图
 @warning 该方法由金山云引入，不是原生系统接口
 @return 当前时刻的视频UIImage 图像
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
- (UIImage *)thumbnailImageAtCurrentTime;

/**
 @abstract 是否开启视频后处理
 @discussion 默认是关闭
 
 * 只在[prepareToPlay]([KSYMediaPlayback prepareToPlay]) 调用前设置生效；
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
@property(nonatomic)  BOOL  shouldEnableVideoPostProcessing;

/**
 @abstract 是否开启硬件解码
 @discussion 如果系统版本高于8.0，默认开启硬件解码；否则，默认使用软件解码
 
 * 只在[prepareToPlay]([KSYMediaPlayback prepareToPlay]) 调用前设置生效
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.3.1 and later.
 */
@property (nonatomic, assign) MPMovieVideoDecoderMode videoDecoderMode;

/**
 @abstract 是否静音
 @discussion 
  * 默认不静音
  * [prepareToPlay]([KSYMediaPlayback prepareToPlay])方法前设置即生效，也可以在播放过程中动态切换
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.3.1 and later.
 */
@property(nonatomic) BOOL shouldMute;

/**
 @abstract 是否隐藏视频
 @discussion 
 * 默认不隐藏
 * 隐藏视频时播放器本身不再进行渲染动作
 * 如果设置了videoDataBlock回调，隐藏视频时数据会照常上抛
 * [prepareToPlay]([KSYMediaPlayback prepareToPlay])方法前设置即生效，也可以在播放过程中动态切换
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.6.1 and later.
 */
@property(nonatomic) BOOL shouldHideVideo;

/**
 @abstract 是否循环播放
 @discussion 默认不循环
 
 * 只在[prepareToPlay]([KSYMediaPlayback prepareToPlay]) 调用前设置生效；
 * 只有点播生效,直播场景请勿设置
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.3.1 and later.
 */
@property(nonatomic) BOOL shouldLoop;

/**
 @abstract 视频数据回调
 @discussion 调用[prepareToPlay]([KSYMediaPlayback prepareToPlay])方法之前设置生效，回调数据为同步完成后的数据
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.3.3 and later.
 @see KSYPlyVideoDataBlock
 */
@property (nonatomic, copy)KSYPlyVideoDataBlock videoDataBlock;

/**
 @abstract 音频数据回调
 @discussion 调用[prepareToPlay]([KSYMediaPlayback prepareToPlay])方法之前设置生效，回调数据为同步完成后的数据
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.3.3 and later.
 @see KSYPlyAudioDataBlock
 */
@property (nonatomic, copy)KSYPlyAudioDataBlock audioDataBlock;

/**
 @abstract 消息数据回调
 @discussion 调用[prepareToPlay]([KSYMediaPlayback prepareToPlay])方法之前设置生效，回调数据为同步完成后的数据
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.3.3 and later.
 @see KSYPlyMessageDataBlock
 */
@property (nonatomic, copy)KSYPlyMessageDataBlock messageDataBlock;
 
/**
 @abstract 视频图像texture回调
 @discussion 调用[prepareToPlay]([KSYMediaPlayback prepareToPlay])方法之前设置生效
 @warning 该方法由金山云引入，不是原生系统接口。使用该属性时需要在初始化时使用[initWithContentURL:sharegroup:]([initWithContentURL:sharegroup:])函数初始化播放器，否则该属性无效
 @since Available in KSYMoviePlayerController 1.8.7 and later.
 @see KSYPlyAudioDataBlock
 */
@property (nonatomic, copy)KSYPlyTextureBlock textureBlock;

/**
 @abstract 指定逆时针旋转角度，只能是0/90/180/270, 不符合上述值不进行旋转
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.4.1 and later.
 */
@property (nonatomic) int rotateDegress;

/**
 @abstract 指定视频是否镜像显示
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.8.4 and later.
 */
@property (nonatomic) BOOL mirror;

/**
 @abstract 快速播放
 @discussion 默认不快速播放
 
 * 非固定倍速下的快速播放，而是全速将解码器中的数据显示出来
 * 当播放文件存在音频时该功能生效；
 * 播放前或者播放过程中均可配置；
 * 开启快速播放后，不在输出声音，但是audioDataBlock中依然会上抛pcm数据
 * 开启快速播放后，可能会导致播放器不停的进入/结束缓冲状态；
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.5.2 and later.
 */
@property(nonatomic) BOOL superFastPlay;

/**
 @abstract 是否进行视频反交错处理
 @discussion 默认不进行反交错处理
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.7.2 and later.
 */
@property(nonatomic) MPMovieVideoDeinterlaceMode deinterlaceMode;

/**
 @abstract 是否打断其他后台的音乐播放
 @discussion 也可以理解为是否允许和其他音频同时播放
 @discussion YES:开始播放时，会打断其他的后台播放音频，也会被其他音频播放打断
 @discussion NO: 可以与其他后台播放共存，相互之间不会被打断
 @discussion 默认为YES
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.5.3 and later.
 */
@property(nonatomic) BOOL  bInterruptOtherAudio;

/**
 @abstract 立体声平衡模式，默认立体声输出，取值范围为[-1.0, 1.0]
 @discussion 针对单声道或双声道音频播放配置时有效，多声道音频播放配置无效
 @discussion 需要佩戴耳机以区分左右声道，手机外放无效果
 @discussion prepareToPlay前配置无效，应在播放过程中动态配置
 @discussion 该值为0.0时，左右声道都有声音，< 0时，右声道声音小于左声道；> 0时，左声道声音小于右声道
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 2.0.3 and later
 */
@property(nonatomic) float audioPan;

/**
 @abstract 用于检测网络连通性的地址，默认使用地址为“www.baidu.com”
 @discussion 用户可自定义地址，但不可设置无效地址，如果不清楚规则，建议使用默认值
 @discussion 设置为nil时，则关闭网络连通性的检测, networkStatus属性值为-1
 @discussion 建议在创建对象后设置一次或不设置，不推荐在播放过程中动态配置
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 2.1.1 and later
 */
@property (nonatomic, readwrite) NSString* networkDetectURL;

/**
 @abstract 网络连通状态
 @discussion 使用 www.kingsoft.com 作为检测目标
 @discussion 如果networkStatus不等于KSYNetworkStatus枚举中的任意值，则表明当前尚未监测到网络状态
 @since Available in KSYMoviePlayerController 2.1.1 and later
 */
@property (nonatomic, readonly) KSYNetworkStatus networkStatus;

/**
 @abstract 设置播放速度，取值范围(0.5~2.0)，默认1.0
 @warning 该属性由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 2.4.1 and later.
 */
@property (nonatomic) float playbackSpeed;



/**
 @abstract timeout指定拉流超时时间,单位是秒
 @param prepareTimeout 建立链接超时时间，默认值是10秒
 @param readTimeout 拉流超时时间，默认值是30秒
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.3.1 and later.
 */
- (void)setTimeout:(int)prepareTimeout readTimeout:(int)readTimeout;

/**
 @abstract setVolume指定播放器输出音量
 @param leftVolume  left volume scalar  [0~2.0f]
 @param rightVolume right volume scalar [0~2.0f]
 @discussion 使用说明
 
 * 输入参数超出范围将失效
 * 输出到speaker时需同时设置左右音量为有效值
    如：leftVolume ＝ rightVolume ＝ 0.5f
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.3.3 and later.
 */
-(void)setVolume:(float)leftVolume rigthVolume:(float)rightVolume;

/**
 @abstract 获取sdk版本
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.3.1 and later.
 */
- (NSString *)getVersion;

/**
 @abstract 获取播放Meta信息
 @discussion 收到MPMediaPlaybackIsPreparedToPlayDidChangeNotification通知后才能获取到数据
 @discussion 暂时支持的查询包括
 
 * kKSYPLYHttpFirstDataTime 建链成功后到收到第一个包所消耗的时间
 * kKSYPLYHttpConnectTime 链接服务器所消耗的时间
 * kKSYPLYHttpAnalyzeDns 解析DNS所消耗的时间
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.3.1 and later.
 */
- (NSDictionary *)getMetadata;

/**
 @abstract 获取播放Meta
 @discussion 收到MPMediaPlaybackIsPreparedToPlayDidChangeNotification通知后才能获取到数据
 @discussion 暂时支持的查询包括
 
 * 当metaType为MPMovieMetaType_Media时，所得到的结果与getMetadata方法相同
 * 当metaType为其他类型时，得到的当前播放的视频/音频/字幕流的meta信息
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 2.5.2 and later.
 */
- (NSDictionary *)getMetadata:(MPMovieMetaType)metaType;

/**
 @abstract 当前播放器是否在播放
 @return 获取[playbackState]([KSYMoviePlayerController playbackState])信息，如果当前状态为MPMoviePlaybackStatePlaying，则返回TRUE。其他情况返回FASLE。
 @warning 该方法由金山云引入，不是原生系统接口
 @see playbackState
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
// A description of the error encountered.
- (BOOL)isPlaying;

/**
 @abstract 重新启动拉流
 @param aUrl 视频播放地址，该地址可以是本地地址或者服务器地址.如果为nil，则使用前一次播放地址
 @discussion 调用场景如下：
 
 * 当播放器调用方发现卡顿时，可以主动调用
 * 当估计出更优质的拉流ip时，可以主动调用
 * 当发生WiFi/3G网络切换时，可以主动调用
 * 当播放器回调体现播放完成时，可以主动调用
 * 播放器SDK不会自动调用reload功能
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
- (void)reload:(NSURL *)aUrl;

/**
 @abstract 重新启动拉流
 @param aUrl 视频播放地址，该地址可以是本地地址或者服务器地址.如果为nil，则使用前一次播放地址
 @param flush 是否清除上一个url的缓冲区内容，该值为NO不清除，为YES则清除
 @discussion 说明：
 
 * 如果在直播过程中使用reload，希望达到续播的效果，建议flush值设为NO
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.0 and later.
 */
- (void)reload:(NSURL *)aUrl flush:(BOOL)flush;

/**
 @abstract 重新启动拉流
 @param aUrl 视频播放地址，该地址可以是本地地址或者服务器地址.如果为nil，则使用前一次播放地址
 @param flush 是否清除上一个url的缓冲区内容，该值为NO不清除，为YES则清除
 @param mode 配置reload后的加载模式，该值为MPMovieReloadMode_Fast则启用加速播放；若为MPMovieReloadMode_Accurate则启用精准查找模式播放
 @discussion 说明：
 
 * 如果在直播过程中使用reload，希望达到续播的效果，建议flush值设为NO
 * 设置为MPMovieReloadMode_Fast模式可以加快起播速度，但在码流音视频交织较差的情况下，可能无法检测到所有音视频流
 * 设置为MPMovieReloadMode_Accurate模式起播速度会有所下降，但可以保证检测到所有音视频流
 * 如果是监听到MPMoviePlayerSuggestReloadNotification消息后调用reload接口，则mode模式一定要设置为MPMovieReloadMode_Accurate，其它情况可根据实际使用场景自行配置
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.6.3 and later.
 */
- (void)reload:(NSURL *)aUrl flush:(bool)flush mode:(MPMovieReloadMode)mode;

/**
 @abstract 获取当前播放的pts
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.5.0.0 and later.
 */
- (NSTimeInterval)getCurrentPts;

/**
 @abstract 设置播放url
 @param url 视频播放地址，该地址可以是本地地址或者服务器地址.
 @discussion 使用说明
 
 * 通常用于使用一个对象进行多次播放的场景
 * 调用reset接口停止播放后使用该接口来设置下一次播放地址
 * 需要在[prepareToPlay]([KSYMediaPlayback prepareToPlay])方法之前设置
 * v2.1.0及之后的版本，该url不可设置为nil；之前的版本设置为nil，会播放上一次的播放地址
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.6.2 and later.
 */
- (void)setUrl:(NSURL *)url;

/**
 @abstract 设置播放url
 @param baseURL 视频播放的绝对地址，该地址可以是本地地址或者服务器地址
 @param fileList 分片列表
 @discussion url和fileList不可同时为nil
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 2.1.0 and later.
 */
- (void)setUrl:(NSURL *)url fileList:(NSArray *)fileList;

/**
 @abstract 重置播放器
 @param holdLastPic 是否保留最后一帧
 @discussion 使用说明
 
 * 通常用于使用一个对象进行多次播放的场景
 * 该方法可以停止播放，但是不会销毁播放器
 * 调用该方法后可以通过调用stop方法来销毁播放器
 * 如果使用一个对象进行多次播放，需要在reset后使用setUrl方法设置下次播放地址
 
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.6.2 and later.
 */
- (void)reset:(BOOL)holdLastPic;

/**
 @abstract 跳转到指定位置播放
 @param pos 跳转到的位置，单位秒
 @param isAccurate 是否精确跳转，NO时等同于currentPlaybackTime, YES时为精确跳转
 @discussion 媒体文件总时长较小且关键帧间隔较大时，需要使用精确跳转， 总时长较大或者不需要精确定位时可以使用currentPlaybackTime或者将isAccurate设置为NO进行跳转
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 1.9.1 and later.
 */
- (void)seekTo:(double)pos accurate:(BOOL)isAccurate;

/**
 @abstract 发送http请求时需要header带上的字段
 @param header 自定义http header字段
 @discussion 在调用prepareToPlay方法前调用生效
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 2.0.3 and later.
 */
-(void)setHttpHeaders:(NSDictionary *)headers;

/**
 @abstract 设置开启/关闭指定的媒体轨道
 @param trackIndex - 轨道的stream index
 @param selected - 开启/关闭指定媒体轨道
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 2.5.2 and later.
 */
- (void) setTrackSelected:(NSInteger)trackIndex selected:(BOOL)selected;

/**
 @abstract 设置本地字幕文件的地址
 @param subtitleFilePath 本地字幕文件地址
 @discussion 在播放过程中调用
 @warning 该方法由金山云引入，不是原生系统接口
 @since Available in KSYMoviePlayerController 2.5.2 and later.
 */
- (void)setExtSubtitleFilePath:(NSString *)subtitleFilePath;

@end
