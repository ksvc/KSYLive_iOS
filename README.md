# [KSY Live iOS SDK](http://ksvc.github.io/KSYLive_iOS/index.html)
## 一. 功能特性
### 1.1 推流功能
- [x] AAC 音频编码
- [x] H.264 视频编码（软硬编同时支持）
- [x] 多分辨率编码支持
- [x] 摄像头控制（朝向,闪光灯,前后摄像头）
- [x] 摄像头控制（可以调用原生的系统api）
- [x] 用户可自由设定音视频码率
- [x] 根据网络带宽自适应调整视频的码率
- [x] 支持 RTMP 协议直播推流
- [x] 提供两种层次的API：简单易用的的kit类API 和 灵活的组件化API
- [x] 能够与GPUImage无缝集成
- [x] 提供GPU实现的[内置美颜滤镜](https://github.com/ksvc/KSYLive_iOS/wiki/filter)
- [x] 支持[背景音乐播放](https://github.com/ksvc/KSYLive_iOS/wiki/BGM)
- [x] 支持[混音](https://github.com/ksvc/KSYLive_iOS/wiki/mixer)
- [x] 支持[视频动态推流开关/纯音频推流](https://github.com/ksvc/KSYLive_iOS/wiki/pureAudioStream)
- [x] [在线API 文档支持](http://ksvc.github.io/KSYLive_iOS/html/index.html)
- [x] 支持[耳返](https://github.com/ksvc/KSYLive_iOS/wiki/micMonitor)
- [x] 支持[画中画](https://github.com/ksvc/KSYLive_iOS/wiki/pip)推流
- [x] 支持[预览和采集分辨率分别设置](https://github.com/ksvc/KSYLive_iOS/wiki/customOutputSize)
- [x] 支持一对一[连麦](https://github.com/ksvc/KSYLive_iOS/wiki/rtc)

### 1.2 文档
[详情请见wiki](https://github.com/ksvc/KSYLive_iOS/wiki)

### 1.3 播放特点
- [x] 与系统播放器MPMoviePlayerController接口一致，可以无缝快速切换至KSYMediaPlayer；
- [x] 本地全媒体格式支持, 并对主流的媒体格式(mp4, avi, wmv, flv, mkv, mov, rmvb 等 )进行优化；
- [x] 支持广泛的流式视频格式, HLS, RTMP, HTTP Rseudo-Streaming 等；
- [x] 低延时直播体验，配合金山云推流sdk，可以达到全程直播稳定的4秒内延时；
- [x] 实现快速满屏播放，为用户带来更快捷优质的播放体验；
- [x] 版本适配支持iOS 7.0以上版本；
- [x] 业内一流的H.265解码；
- [x] 小于2M大小的超轻量级直播sdk；

## 二. 推流端大事记  
### 2.1 2016年发布大事记  
1. 2016.02.25 上行网络自适应上线；
2. 2016.03.26 [内建美颜](https://github.com/ksvc/KSYLive_iOS/wiki/filter)上线；
3. 2016.04.11 支持四种混响模式的[混音](https://github.com/ksvc/KSYLive_iOS/wiki/mixer)上线；
4. 2016.05.18 [耳返](https://github.com/ksvc/KSYLive_iOS/wiki/micMonitor)上线；
5. 2016.06.12 [画中画](https://github.com/ksvc/KSYLive_iOS/wiki/pip)推流上线；
6. 2016.06.27 支持短视频录制；
7. 2016.08.04 [两人连麦](https://github.com/ksvc/KSYLive_iOS/wiki/rtc)内测；
8. 2016.08.24 支持[纯音频](https://github.com/ksvc/KSYLive_iOS/wiki/pureAudioStream)推流，支持后台音频推流，支持视频动态发送开关；

### 2.2 近期工作  
1. 2016.09.xx kit顶层库代码开源；
2. 2016.09.xx 内建[极致美颜](https://github.com/ksvc/KSYLive_iOS/wiki/filter)上线；
3. 2016.09.xx 高达50% cpu性能节省的场景编码上线；

## 三. SDK集成方法介绍   
### 3.1 系统要求    
* 最低支持iOS版本：iOS 7.0
* 最低支持iPhone型号：iPhone 4
* 支持CPU架构： armv7,armv7s,arm64(和i386,x86_64模拟器)
* 含有i386和x86_64模拟器版本的库文件，推流功能无法在模拟器上工作，播放功能完全支持模拟器。

### 3.2 下载工程
本SDK 提供如下三种获取方式:   
#### 3.2.1 从[github](https://github.com/ksvc/KSYLive_iOS.git) clone

目录结构如下所示:  
- demo        : demo工程为KSYLive ，演示本SDK的主要接口的使用
- doc/docset  : appleDoc风格的接口文档，安装后可在xcode中直接看到方法和属性的文档
- doc/html    : appleDoc风格的网页版接口文档，也可查看[在线版](http://ksvc.github.io/KSYLive_iOS/html/index.html)
- framework/livegpu/libksygpulive.framework : 本SDK的静态库framework，集成时需要将该framework加入到项目中

```
$ git clone https://github.com/ksvc/KSYLive_iOS.git KSYLive_iOS
```

#### 3.2.2 从[oschina](http://git.oschina.net/ksvc/KSYLive_iOS) clone

对于部分地方访问github比较慢的情况，可以从oschina clone，获取的库内容和github一致。
```
$ git clone https://git.oschina.net/ksvc/KSYLive_iOS.git
```

#### 3.2.3 使用Cocoapods 私有库进行安装    
通过Cocoapods 能将本SDK的静态库framework下载到本地，只需要将如下语句加入你的Podfile：   
```
pod 'KSYGPULive_iOS', :git => 'https://github.com/ksvc/KSYLive_iOS.git'
```

执行 pod install 或者 pod update后，将SDK加入工程。

#### 3.2.4 使用Cocoapods 官方库进行安装    
配置工程Podfile文件，添加KSYGPULive_iOS配置信息
```
pod 'KSYGPULive_iOS'
```

### 3.3 添加framework到工程中
* SDK压缩包
将压缩包中framework下的libksygpulive.framework添加到XCode的工程，具体步骤为：
1. 选中应用的Target，进入项目配置页面
2. 切换到 Build Phases标签页
3. 在Link Binary With Libraries 一栏中加入 libksygpulive.framework和第三方依赖库GPUImage.framework

* SDK Cocoapods
在Podfile中本SDK的条目，并执行了 pod install 之后， 本SDK就已经加入工程中，打开工程的workspace即可。

### 3.4 添加头文件到需要使用本SDK的文件中
```
#import <GPUImage/GPUImage.h>
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/libksygpuimage.h>
```
以上三个头文件都是需要引入的：   
* GPUImage.h是因为依赖第三方framework需要引入的
* libksygpulive.h 是本SDK中不依赖 GPUImage部分的头文件
* libksygpuimage.h 是依赖GPUImage部分的头文件
* 当自定义GPUImage时，GPUImage的版本要求是0.1.7

### 3.5 SDK版本号查询
本SDK的版本号 主要通过核心类查询
```
NSLog(@"version: %@", [streamerBase getKSYVersion]);
NSLog(@"version: %@", [kit getKSYVersion]);
```

### 3.6 集成时的注意事项
* 本framework已经包含[播放SDK](https://github.com/ksvc/KSYMediaPlayer_iOS.git)   
且会跟播放SDK产生冲突，在集成前，请先保证将之前集成的KSY播放SDK移除
* 本framework可能与其他使用了FFmpeg的静态库冲突
* 本framework为静态库，虽然库的大小为20M+，但是最后链接后，对app的增量只有4M+

## 四. 参考文档
* [iOS直播推流SDK使用指南](https://github.com/ksvc/KSYLive_iOS/wiki/KSYStreamerSDKUserManual)
* [iOS直播推流SDK常见问题](https://github.com/ksvc/KSYLive_iOS/wiki/FAQ)

## 五. 播放器使用示例
请见github库：https://github.com/ksvc/KSYMediaPlayer_iOS.git

## 六. 反馈与建议
* 主页：[金山云](http://www.ksyun.com/)
* 邮箱：<zengfanping@kingsoft.com>
* QQ讨论群：574179720
* Issues:<https://github.com/ksvc/KSYLive_iOS/issues>
