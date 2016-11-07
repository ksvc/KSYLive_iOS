#[KSY Live iOS SDK](http://ksvc.github.io/KSYLive_iOS/doc/html/index.html)
## 一. 功能特性
### 1.1 推流功能
- [x] AAC 音频编码（支持软、硬编）
- [x] H.264 视频编码（支持软编H.264/H.265 支持H.264硬编(支持baseline/main/high profile)）
- [x] 多分辨率编码支持
- [x] 摄像头控制（朝向,闪光灯,前后摄像头）
- [x] 摄像头控制（可以调用原生的系统api）
- [x] 用户可自由设定音视频码率
- [x] 根据网络带宽自适应调整视频的码率，网络自适应模式可配置
- [x] 支持 RTMP 协议直播推流
- [x] 提供两种层次的API：简单易用的的kit类API 和 灵活的组件化API，提供开源的kit类代码
- [x] 能够与GPUImage无缝集成
- [x] 提供GPU实现的[内置美颜滤镜](https://github.com/ksvc/KSYLive_iOS/wiki/filter)
- [x] 支持[背景音乐播放](https://github.com/ksvc/KSYLive_iOS/wiki/BGM)
- [x] 支持[混音](https://github.com/ksvc/KSYLive_iOS/wiki/mixer)
- [x] 支持[视频动态推流开关/纯音频推流](https://github.com/ksvc/KSYLive_iOS/wiki/pureAudioStream)
- [x] 支持[后台推流](https://github.com/ksvc/KSYLive_iOS/wiki/backgroupStream)
- [x] 支持[耳返](https://github.com/ksvc/KSYLive_iOS/wiki/micMonitor)
- [x] 支持[画中画](https://github.com/ksvc/KSYLive_iOS/wiki/pip)推流
- [x] 支持[预览和采集分辨率分别设置](https://github.com/ksvc/KSYLive_iOS/wiki/customOutputSize)
- [x] 支持一对一[连麦](https://github.com/ksvc/KSYLive_iOS/wiki/rtc)
- [x] [场景编码](https://github.com/ksvc/KSYLive_iOS/wiki/liveScene)
- [x] 支持软编、硬编的[性能编码模式](https://github.com/ksvc/KSYLive_iOS/wiki/liveScene)
- [x] [在线API 文档支持](http://ksvc.github.io/KSYLive_iOS/doc/html/index.html)


### 1.2 文档
[详情请见wiki](https://github.com/ksvc/KSYLive_iOS/wiki)

### 1.3 播放特点
- [x] 与系统播放器MPMoviePlayerController接口一致，可以无缝快速切换至KSYMediaPlayer；
- [x] 本地全媒体格式支持, 并对主流的媒体格式(mp4, avi, wmv, flv, mkv, mov, rmvb 等 )进行优化；
- [x] 支持广泛的流式视频格式, HLS, RTMP, HTTP Pseudo-Streaming 等；
- [x] 低延时直播体验，配合金山云推流sdk，可以达到全程直播稳定的4秒内延时；
- [x] 实现快速满屏播放，为用户带来更快捷优质的播放体验；
- [x] 版本适配支持iOS 7.0以上版本；
- [x] 业内一流的H.265解码；
- [x] 小于2M大小的超轻量级直播sdk；

## 二. 推流端大事记  
### 2.1 2016年发布大事记  
1. 2016.02.25 上行网络自适应上线；
1. 2016.03.26 [内建美颜](https://github.com/ksvc/KSYLive_iOS/wiki/filter)上线；
1. 2016.04.11 支持四种混响模式的[美声](https://github.com/ksvc/KSYLive_iOS/wiki/reverb)上线；
1. 2016.05.18 [耳返](https://github.com/ksvc/KSYLive_iOS/wiki/micMonitor)上线；
1. 2016.06.12 [画中画](https://github.com/ksvc/KSYLive_iOS/wiki/pip)推流上线；
1. 2016.06.27 支持短视频录制；
1. 2016.08.04 [两人连麦](https://github.com/ksvc/KSYLive_iOS/wiki/rtc)内测；
1. 2016.08.24 支持[纯音频](https://github.com/ksvc/KSYLive_iOS/wiki/pureAudioStream)推流，支持[后台推流](https://github.com/ksvc/KSYLive_iOS/wiki/backgroupStream)，支持视频动态发送开关；
1. 2016.08.31 [场景编码](https://github.com/ksvc/KSYLive_iOS/wiki/liveScene)，有效提升直播画质；
1. 2016.09.07 内建[新美颜](https://github.com/ksvc/KSYLive_iOS/wiki/filter)上线； 
1. 2016.09.12 [kit类顶层代码开源](https://github.com/ksvc/KSYLive_iOS/tree/master/source), podspec 中将集成framework改为集成静态库
1. 2016.09.21 特效滤镜上线;
1. 2016.09.26 [双人连麦](https://github.com/ksvc/KSYRTCLive_iOS/releases/tag/v1.8.5)稳定版本上线;
1. 2016.09.28 视频硬编[性能编码模式](https://github.com/ksvc/KSYLive_iOS/wiki/liveScene)上线。音频AAC硬编功能上线。网络自适应场景上线；
1. 2016.10.19 支持[推流横竖屏动态变化](https://github.com/ksvc/KSYLive_iOS/wiki/dynamicOrientation)；
1. 2016.10.20 支持[replaykit录屏推流](https://github.com/ksvc/KSYDiversityLive_iOS/tree/master/KSYReplayKit)；

### 2.2 近期工作  
1. 2016.10.xx 人脸贴纸功能上线;
1. 2016.10.xx AR直播上线;
1. 2016.10.xx 应用内录屏推流；
1. 2016.10.xx 支持录屏、美颜、动态贴纸的短视频(mp4格式)录制上线；
1. 2016.10.xx 无人机直播上线；

## 三. SDK集成方法介绍   
### 3.1 系统要求    
* 最低支持iOS版本：iOS 7.0
* 最低支持iPhone型号：iPhone 4
* 支持CPU架构： armv7,armv7s,arm64(和i386,x86_64模拟器)
* 含有i386和x86_64模拟器版本的库文件，推流功能无法在模拟器上工作，播放功能完全支持模拟器。

### 3.2 下载工程
本SDK 提供如下列出获取方式:     
#### 3.2.1 从[github](https://github.com/ksvc/KSYLive_iOS.git) clone

目录结构如下所示:  
- demo        : demo工程为KSYLive ，演示本SDK的主要接口的使用
- doc/docset  : appleDoc风格的接口文档，安装后可在xcode中直接看到方法和属性的文档
- doc/html    : appleDoc风格的网页版接口文档，也可查看[在线版](http://ksvc.github.io/KSYLive_iOS/doc/html/index.html)
- prebuilt    : 预编译库的头文件和库文件
- source      : 顶层kit类的源代码
- releaseFramework: 用于将预编译库打包为方便集成的framework的脚本和工程

```
$ git clone https://github.com/ksvc/KSYLive_iOS.git KSYLive_iOS --depth 1
```

#### 3.2.2 从[csdn](https://code.csdn.net/ksvc/ksylive_ios) clone

对于部分地方访问github比较慢的情况，可以从csdn clone，获取的库内容和github一致。
```
$ git clone git@code.csdn.net:ksvc/ksylive_ios.git  --depth 1
```

#### 3.2.3 使用Cocoapods 进行安装    
通过Cocoapods 能将本SDK的静态库和代码下载到本地，只需要将类似如下语句中的一句加入你的Podfile：   

```
// 本地开发版 (sdk clone或下载到本地后)
pod 'libksygpulive/libksygpulive', :path => '../'

// 私有库 (直接指定SDK的github仓库地址)
pod 'libksygpulive/libksygpulive', :git => 'https://github.com/ksvc/KSYLive_iOS.git'

// 私有库 (直接指定SDK的github仓库地址和版本号)
pod 'libksygpulive/libksygpulive', :git => 'https://github.com/ksvc/KSYLive_iOS.git', :tag => 'v1.8.0'

// cocoapod官方库
pod 'libksygpulive/libksygpulive'
```

执行 pod install即可.    
注意: 不能将以上四条语句都加入Podfile, 他们作用是一样的, 只是Podspec读取位置不同.

其中, libksygpulive为libksygpulive的子模块, 为了满足不同用户的需求, libksygpulive中提供了4个不同的子模块:    
* KSYMediaPlayer     : 用于直播的播放内核(支持格式精简)
* KSYMediaPlayer_vod : 用于点播的播放内核(支持格式丰富)
* libksygpulive      : 用于直播推流和播放的SDK（直播推流功能和精简版本的播放SDK）
* libksygpulive_265  : 用于直播推流和播放的SDK (支持265推流和精简版本的播放SDK)

### 3.3 开始运行demo工程
!!!!!注意: 这里提供以下两种方法运行demo, 但是只能二选一; 如果要换另一种方法请重新下载解压, 或恢复git仓库的原状后再尝试.!!!!!

#### 3.3.1 使用Cocoapod的的方式来运行demo 
demo 目录中已经有一个Podfile, 指定了本地开发版的pod    
在demo目录下执行如下命令, 即可开始编译运行demo  
```
$ cd demo
$ pod install
$ open KSYLiveDemo.xcworkspace
```

注意:
1. 更新pod之后, 需要打开 xcwrokspace, 而不是xcodeproj

#### 3.3.2 手动编译framework生成依赖项运行示例demo
* 将SDK 打包为framework

将压缩包解压(或者clone成功)后, 进入 releaseFramework 目录, 通过 release-libKSYLive.sh 下载依赖项并打包出framework，生成到KSYLive_iOS/framework目录下。      
```
$ cd releaseFramework
$ ./release-libKSYLive.sh libksygpulive lite
$ ls ../framework
Bugly.framework  GPUImage.framework  libksygpulive.framework
```
参数的详细说明请参考脚本release-libKSYLive.sh的[帮助](https://github.com/ksvc/KSYLive_iOS/wiki/dylib).

* 给demo添加库依赖选项

打开demo目录下的KSYLiveDemo.xcodeproj, 修改KSYLiveDemo项目的配置文件:  
选中KSYLiveDemo工程->选中Project KSYLiveDemo->选中 Info 标签->选择Configurations->Debug或Release->给KSYLiveDemo分别选择对应的KSYLiveDemo-framework.xcconfig文件。注意，如果使用动态库则选择KSYLiveDemo-dy-framework.xcconfig。

![xcode_configs](https://github.com/ksvc/KSYLive_iOS/wiki/images/xcode_configs.png)

或者手动在项目配置中添加如下参数: (具体请参见 demo目录下的 KSYLiveDemo-framework.xcconfig)
```
OTHER_LDFLAGS = $(inherited) -ObjC -all_load -framework libksygpulive -framework GPUImage -framework Bugly -lstdc++.6 -lz
```
以上为静态库的集成方法，动态库的配置使用方法请参考Wiki中[动态库](https://github.com/ksvc/KSYLive_iOS/wiki/dylib)相关内容。
### 3.4 添加头文件到需要使用本SDK的文件中
```
#import <GPUImage/GPUImage.h>
#import <libksygpulive/libksygpuimage.h>
#import "KSYGPUStreamerKit.h"
```
以上三个头文件都是需要引入的：   
* GPUImage.h是因为依赖第三方framework需要引入的
* libksygpuimage.h 是SDK对外的的头文件
* KSYGPUStreamerKit.h 为开放的顶层kit类, kit类可以直接使用, 也可以自行修改

* 当需要自定义修改GPUImage时，GPUImage的版本要求是0.1.7

### 3.5 SDK版本号查询
本SDK的版本号 主要通过核心类查询
```
NSLog(@"version: %@", [streamerBase getKSYVersion]);
NSLog(@"version: %@", [kit getKSYVersion]);
```

### 3.6 集成时的注意事项
* 本framework已经包含[播放SDK](https://github.com/ksvc/KSYMediaPlayer_iOS.git)   
且会跟播放SDK产生冲突，在集成前，请先保证将之前集成的KSY播放SDK移除
* 本framework可能与其他使用了FFmpeg的静态库冲突 (冲突时可以考虑使用动态库)
* 本framework为静态库，虽然库的大小为20M+，但是最后链接后，对app的增量只有4M+

## 四. 参考文档
* [iOS直播推流SDK使用指南](https://github.com/ksvc/KSYLive_iOS/wiki/KSYStreamerSDKUserManual)
* [iOS直播推流SDK常见问题](https://github.com/ksvc/KSYLive_iOS/wiki/FAQ)
* [接口变更历史](https://github.com/ksvc/KSYLive_iOS/wiki/apiAdjust)

## 五. 播放器使用示例
请见github库：https://github.com/ksvc/KSYMediaPlayer_iOS.git

## 六. 反馈与建议
* 主页：[金山云](http://www.ksyun.com/)
* 邮箱：<zengfanping@kingsoft.com>
* QQ讨论群：574179720 [视频云技术交流群] 
* Issues:<https://github.com/ksvc/KSYLive_iOS/issues>
