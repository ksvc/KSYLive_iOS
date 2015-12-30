# KSY Live iOS SDK使用手册

## 阅读对象
本文档面向所有使用该SDK的开发人员, 测试人员等, 要求读者具有一定的iOS编程开发经验.

## KSY Live iOS SDK 概述
KSY Live iOS SDK是金山云推出的 iOS 平台上使用的软件开发工具包(SDK), 其中Stremer负责采集和推流。MediaPlayer负责视频播放。

## 主要功能点

### Stremer推流特点
* 音频编码：AAC
* 视频编码：H.264 
* 推流协议：RTMP
* 视频分辨率：1280x720, 960x540,640x480,640x360,352x288
* 屏幕朝向： 横屏, 竖屏
* iOS摄像头：前, 后置摄像头（可动态切换）
* 音视频目标码率：可设
* 根据网络带宽自适应调整视频的码率
* 闪光灯：开/关
* Apple Doc 文档支持
* 可使用系统原生接口对当前采集设备进行操作

### MediaPlayer播放特点
* 与系统播放器MPMoviePlayerController接口一致，可以无缝快速切换至KSYMediaPlayer；
* 本地全媒体格式支持, 并对主流的媒体格式(mp4, avi, wmv, flv, mkv, mov, rmvb 等 )进行优化；
* 支持广泛的流式视频格式, HLS, RTMP, HTTP Rseudo-Streaming 等；
* 低延时直播体验，配合金山云推流sdk，可以达到全程直播稳定的4秒内延时；
* 实现快速满屏播放，为用户带来更快捷优质的播放体验；
* 版本适配支持iOS 7.0以上版本；
* 业内一流的H.265解码；
* 小于2M大小的超轻量级直播sdk；

## SDK 下载   
本SDK 提供如下三种获取方式:

* 使用金山云账户邮件向 taochuntang@kingsoft.com索取;
* 从github下载：https://github.com/ksvc/KSYLive_iOS.git
* 使用Cocoapods进行安装，将如下语句加入你的Podfile：

```
pod 'KSYLive', :git => 'https://github.com/ksvc/KSYLive_iOS.git'
```

执行 pod install 或者  pod update后，将SDK加入工程。
## SDK 内容说明

1. SDK压缩包
如果获取到的为zip格式的压缩包，解压后的目录结构如下所示:

* demo    : demo工程为KSYLive ，演示本SDK的主要接口的使用
* doc     : appleDoc风格的接口文档，主要描述接口函数，参数和类型定义
* framework : 本SDK的静态库framework，集成时需要将该framework加入到项目中

1. SDK Cocoapods
通过Cocoapods 能将本SDK的静态库framework下载到本地

1. Streamer SDK与KSYMediaPlayer SDK打包融合未KSYLive SDK进行发布，避免使用 -all_load参数时的符号冲突问题。

# 运行环境和兼容性

* 最低支持iOS版本：iOS 7.0
* 最低支持iPhone型号：iPhone 4
* 支持CPU架构： armv7, arm64
* 含有i386和x86_64模拟器版本的库文件，推流功能无法在模拟器上工作，播放功能完全支持模拟器。

#开始集成
* SDK压缩包
将压缩包中framework下的libksylive.framework添加到XCode的工程，具体步骤为：
1. 选中应用的Target，进入项目配置页面
2. 切换到 Build Phases标签页
3. 在Link Binary With Libraries的列表中添加上 libksylive.framework   
(点击列表底部的加号，在弹出的向导中选择libksylive.framework)

* SDK Cocoapods
在Podfile中本SDK的条目，并执行了 pod install 之后， 本SDK就已经加入工程中，打开工程的workspace即可

## Streamer使用示例
* 在需要进行推流预览的VC类的实现文件中引入头文件
```
#import <libksylive/libksylive.h>
```
* SDK 鉴权设置
使用SDK前, 需要联系金山云获取合法的ak/sk 在开始推流前，需要使用KSYAuthInfo类的setAuthInfo将ak和加密后的sk传入SDK内部, 具体代码见demo中的initKSYAuth方法
* SDK的核心类为KSYStreamer, 可以在VC中增加 KSYStreamer 的属性, 后续与推流相关的操作大部分都要通过KSYStreamer 来进行
```
@property KSYStreamer * streamer;
```
* 创建KSYStreamer 的实例,并初始化, 注意本SDK不支持多实例, 同一时间只能有一个推流类的实例，否则会出现不可预期的问题
```
_streamer = [[KSYStreamer alloc] initWithDefaultCfg];
```
* 设置采集和推流参数，主要是对分辨率，帧率等参数进行设置，具体可设置的内容参见KSYStreamer的属性。例如：
```
_streamer.videoDimension = KSYVideoDimension_16_9__640x360;

```

* 设置消息通知的接收函数

| 通知名称 | 通知说明 |  相关属性 |
| --------| ------|  --- |
| KSYCaptureStateDidChangeNotification | 采集设备状态变化通知  | captureState |
| KSYStreamStateDidChangeNotification  | 推流状态变化通知| streamState, streamErrorCode |
| KSYNetStateEventNotification         | 网络事件发生通知| netStateCode |

比如 当采集设备的状态发生变化时，对应的接收回调函数会被调用，通过_streamer.captureState属性,可查询到新的状态
其中如果推流状态变为 KSYStreamStateError,需要通过streamErrorCode 具体查询其错误原因

* 开始/停止预览
通过如下接口启动和停止预览，当启动预览时，需要将显示预览的view传入到SDK中
```
[_streamer startPreview: self.view];
//....
[_streamer stopPreview];
```
在调用这一组接口后，对应操作开始和结束时会有KSYCaptureStateDidChangeNotification的状态通知
当采集设备的权限被用户禁用时，会进入KSYCaptureStateDevAuthDenied状态

* 开始/停止推流, 开始推流时, 需要将推流的完整URL作为参数传入, 比如rtmp://xxx.xxx.xxx/appname/streamkey 
```
[_streamer startStream:_hostURL];
//....
[_streamer stopStream];
```
在调用这一组接口后，对应操作开始和结束时会有 KSYStreamStateDidChangeNotification 的状态通知，
进入KSYStreamStateConnected 状态，表明推流成功；

### 其他操作
```
[_streamer switchCamera]; // 在前后摄像头之间切换
[_streamer toggleTorch ]; // 开关闪关灯状态
```

### 状态监控
如果需要对推流状态进行监控，可以设置一个每秒刷新一次的timer，计算出网络发送速度（每秒发送的字节数）和视频编码速度（每秒编码的帧数）

## MediaPlayer 使用示例
请见github库：https://github.com/ksvc/KSYMediaPlayer_iOS.git
