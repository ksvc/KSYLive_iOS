# [KSY Live iOS SDK](http://ksvc.github.io/KSYLive_iOS/index.html)使用手册


## SDK 概述
金山云推出的iOS平台上使用的软件开发工具包,可高度定制化和二次开发.


## 功能特性

### 推流功能
- [x] AAC 音频编码
- [x] H.264 视频编码
- [x] 多分辨率编码支持
- [x] 摄像头控制（朝向,闪光灯,前后摄像头）
- [x] 摄像头控制（可以调用原生的系统api）
- [x] 动态设定音视频码率
- [x] 根据网络带宽自适应调整视频的码率
- [x] 支持 RTMP 协议直播推流
- [x] [在线API 文档支持](http://ksvc.github.io/KSYLive_iOS/html/index.html)
- [x] Apple Doc 文档支持

### 播放特点
- [x] 与系统播放器MPMoviePlayerController接口一致，可以无缝快速切换至KSYMediaPlayer；
- [x] 本地全媒体格式支持, 并对主流的媒体格式(mp4, avi, wmv, flv, mkv, mov, rmvb 等 )进行优化；
- [x] 支持广泛的流式视频格式, HLS, RTMP, HTTP Rseudo-Streaming 等；
- [x] 低延时直播体验，配合金山云推流sdk，可以达到全程直播稳定的4秒内延时；
- [x] 实现快速满屏播放，为用户带来更快捷优质的播放体验；
- [x] 版本适配支持iOS 7.0以上版本；
- [x] 业内一流的H.265解码；
- [x] 小于2M大小的超轻量级直播sdk；

## 内容摘要
- [工程环境](##工程环境)
    - [运行环境](###运行环境)
    - [下载工程](###下载工程)
    - [工程目录](###工程目录)
    - [添加工程](###添加工程)   
- [推流使用示例](##推流使用示例)
    - [核心类](###核心类)
    - [SDK鉴权](###SDK鉴权)
    - [编码参数](###编码参数)
    - [服务器地址](###服务器地址)
    - [推流状态](###推流状态)
    - [启停推流](###启停推流)
    - [美颜滤镜](###美颜滤镜)
- [播放器使用示例](##播放器使用示例)   
## 工程环境
### 运行环境

* 最低支持iOS版本：iOS 7.0
* 最低支持iPhone型号：iPhone 4
* 支持CPU架构： armv7, armv7s,arm64
* 含有i386和x86_64模拟器版本的库文件，推流功能无法在模拟器上工作，播放功能完全支持模拟器。

### 下载工程
本SDK 提供如下两种获取方式:

1:从github下载：https://github.com/ksvc/KSYLive_iOS.git

2:使用Cocoapods进行安装，将如下语句加入你的Podfile：

（不带滤镜版本）

```
pod 'KSYLive_iOS', :git => 'https://github.com/ksvc/KSYLive_iOS.git'
```
（带滤镜版本）

```
pod 'KSYGPULive_iOS', :git => 'https://github.com/ksvc/KSYLive_iOS.git'
```

执行 pod install 或者 pod update后，将SDK加入工程。

### 工程目录

1:SDK压缩包
如果获取到的为zip格式的压缩包，解压后的目录结构如下所示:

- demo        : demo工程为KSYLive ，演示本SDK的主要接口的使用
- doc/docset  : appleDoc风格的接口文档
- doc/html    : appleDoc风格的[接口文档](http://ksvc.github.io/KSYLive_iOS/html/index.html)
- framework   : 本SDK的静态库framework，集成时需要将该framework加入到项目中
- framework/live264/libksylive.framework    不依赖GPUImage的推流SDK
- framework/livegpu/libksygpulive.framework 依赖GPUImage，带美颜功能的推流SDK

2:SDK Cocoapods
通过Cocoapods 能将本SDK的静态库framework下载到本地

### 添加工程
* SDK压缩包
将压缩包中framework下的libksylive.framework添加到XCode的工程，具体步骤为：
1. 选中应用的Target，进入项目配置页面
2. 切换到 Build Phases标签页
3. 在Link Binary With Libraries的列表中添加上 libksylive.framework   
(点击列表底部的加号，在弹出的向导中选择libksylive.framework)
4. 如果需要使用GPU美颜滤镜，则用同样的方法加上libksygpulive.framework

* SDK Cocoapods
在Podfile中本SDK的条目，并执行了 pod install 之后， 本SDK就已经加入工程中，打开工程的workspace即可。

## SDK使用示例

具体可参见KSYLiveDemo工程的KSYStreamerVC/KSYGPUStreamerVC/KSYStreamerKitVC.
- KSYStreamerVC    KSYStreamer的使用示例，不依赖GPUImage
- KSYStreamerKitVC KSYGPUStreamerKit的使用示例，与KSYStreamer用法一致，仅仅添加了设置美颜接口
- KSYGPUStreamerVC KSYGPUStreamer使用示例，可以自由组合采集，滤镜和推流，实现高度定制化的需求

* 在需要进行推流预览的ViewController类的实现文件中引入头文件
```
#import <libksylive/libksylive.h>
```
或者
```
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/libksygpuimage.h>
```

### 入口类
本SDK提供的入口类如下
[](http://ksvc.github.io/KSYLive_iOS/html/img/sdkClass.png)

* libksylive的入口类为[KSYStreamer](http://ksvc.github.io/KSYLive_iOS/html/Classes/KSYStreamer.html), 包含了采集和推流的功能，可以在VC中增加 KSYStreamer 的属性, 后续与推流相关的操作大部分都要通过KSYStreamer 来进行

```
@property KSYStreamer * streamer;
```
** 创建KSYStreamer 的实例,并初始化, 注意本SDK不支持多实例, 同一时间只能有一个推流类的实例，否则会出现不可预期的问题

```
_streamer = [[KSYStreamer alloc] initWithDefaultCfg];
```

* libksygpulive的入口类有4个
** KSYStreamerBase   基础推流类，接受CMSampleBufferRef的音视频数据进行编码推流
** KSYGPUCamera      对GPUImageVideoCamera的封装，负责采集部分的功能
** KSYGPUStreamer    对KSYStreamerBase的封装，对接GPUImage的滤镜输出
** KSYGPUStreamerKit 对KSYGPUCamera和KSYGPUStreamer的封装，对采集，滤镜和推流组装

###SDK鉴权
使用SDK前, 需要联系金山云获取合法的ak/sk 在开始推流前，需要使用KSYAuthInfo类的setAuthInfo将ak和加密后的sk传入SDK内部, 具体代码见demo中的initKSYAuth方法

###采集参数设置
* 设置分辨率

```
/// 16 : 9 宽高比，1280 x 720 分辨率
    KSYVideoDimension_16_9__1280x720 = 0,
    /// 16 : 9 宽高比，960 x 540 分辨率
    KSYVideoDimension_16_9__960x540,
    /// 4 : 3 宽高比，640 x 480 分辨率
    KSYVideoDimension_4_3__640x480,
    /// 16 : 9 宽高比，640 x 360 分辨率
    KSYVideoDimension_16_9__640x360,
    /// 4 : 3 宽高比，320 x 240 分辨率
    KSYVideoDimension_5_4__352x288,
    
    /// 缩放自定义分辨率 从设备支持的最近分辨率缩放获得, 若设备没有对应宽高比的分辨率，则裁剪后进行缩放
    KSYVideoDimension_UserDefine_Scale,
    /// 裁剪自定义分辨率 从设备支持的最近分辨率裁剪获得
    KSYVideoDimension_UserDefine_Crop,
    /// 注意： 选择缩放自定义分辨率时可能会有额外CPU代价
    
    /// 默认分辨率，默认为 4 : 3 宽高比，640 x 480 分辨率
    KSYVideoDimension_Default = KSYVideoDimension_4_3__640x480,

```
* 设置视频采集帧率：

```
_streamer.videoFPS = 15;
```
* 设置视频朝向：
###推流编码参数设置
```
_streamer.videoFPS = 15;
_streamer.audiokBPS = 48; // k bit ps
```
* 设置编码格式：

```
_streamer.videoCodec = KSYVideoCodec_X264;
```
* 设置视频自适应码率范围：

```
_streamer.videoInitBitrate = 1000; // k bit ps
_streamer.videoMaxBitrate  = 1000; // k bit ps
_streamer.videoMinBitrate  = 100; // k bit ps
```
###服务器地址
* 服务器url(需要向相关人员申请，测试地址并不稳定！)：

```
@property NSURL * hostURL;
NSString *rtmpSrv  = @"rtmp://test.uplive.ksyun.com/live";
NSString *url      = [  NSString stringWithFormat:@"%@/%@", rtmpSrv, streamName];
_hostURL = [[NSURL alloc] initWithString:url];
```
###推流状态
* 设置消息通知的接收函数

| 通知名称 | 通知说明 |  相关属性 |
| --------| ------|  --- |
| KSYCaptureStateDidChangeNotification | 采集设备状态变化通知  | captureState |
| KSYStreamStateDidChangeNotification  | 推流状态变化通知| streamState, streamErrorCode |
| KSYNetStateEventNotification         | 网络事件发生通知| netStateCode |

比如 当采集设备的状态发生变化时，对应的接收回调函数会被调用，通过_streamer.captureState属性,可查询到新的状态
其中如果推流状态变为 [KSYStreamStateError](http://ksvc.github.io/KSYLive_iOS/html/Constants/KSYStreamState.html),需要通过[streamErrorCode](http://ksvc.github.io/KSYLive_iOS/html/Constants/KSYStreamErrorCode.html) 具体查询其错误原因

如果需要对推流状态进行监控，可以设置一个每秒刷新一次的timer，计算出网络发送速度（每秒发送的字节数）和视频编码速度（每秒编码的帧数）

###启停推流
* 通过如下接口启动和停止预览，当启动预览时，需要将显示预览的view传入到SDK中

```
[_streamer startPreview: self.view];
//....
[_streamer stopPreview];
```
注意：当采集设备的权限被用户禁用时，会进入KSYCaptureStateDevAuthDenied状态

* 开始/停止推流, 在这之前必须要先启动预览，开始推流时, 需要将推流的完整URL作为参数传入, 比如rtmp://xxx.xxx.xxx/appname/streamkey 

```
[_streamer startStream:_hostURL];
//....
[_streamer stopStream];
```
进入KSYStreamStateConnected 状态，表明推流成功；

注意：所有的对应操作开始和结束时会有KSYCaptureStateDidChangeNotification的状态通知

###美颜滤镜
参看KSYGPULiveDemo工程，利用开源库GPUImage实现，和基本推流有以下几点修改：

* 新增加头文件：

```
#import <GPUImage/GPUImage.h>
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/libksygpuimage.h>
```

* 核心类修改为KSYGPUStreamer，可以通过getStreamer得到_streamer.

```
@property KSYGPUStreamer * gpuStreamer;
 _streamer = [_gpuStreamer getStreamer];
```
* 增加摄像头采集类KSYGPUCamera,需要设置摄像头参数，然后把target设置为filter。

```
@property KSYGPUCamera * capDev;
[_capDev addTarget:_filter];
```

需要注意这里的分辨率是16:9的比率，如果需要在ipad显示4:3的分辨率，可以用GPUImageCropFilter来进行裁剪。

```
 [[GPUImageCropFilter alloc] initWithCropRegion:rect];
```
* 增加滤镜类filter，如果需要替换filter，只需要在这里把类替换掉，target设置为_preview和_gpuStreamer。

```
@property GPUImageFilter     * filter;
_filter = [[KSYGPUBeautifyFilter alloc] init];
[_filter addTarget:_preview];
[_filter addTarget:_gpuStreamer]; 
```

* preview函数改为：

```
 [_capDev startCameraCapture];
 [_capDev stopCameraCapture];
 ```


## 播放器使用示例
请见github库：https://github.com/ksvc/KSYMediaPlayer_iOS.git