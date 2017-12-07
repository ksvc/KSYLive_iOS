# [KSY Live iOS SDK](http://ksvc.github.io/KSYLive_iOS/doc/html/index.html)

[![Apps Using](https://img.shields.io/cocoapods/at/libksygpulive.svg?label=Apps%20Using%20libksygpulive&colorB=28B9FE)](http://cocoapods.org/pods/libksygpulive)[![Downloads](https://img.shields.io/cocoapods/dt/libksygpulive.svg?label=Total%20Downloads%20libksygpulive&colorB=28B9FE)](http://cocoapods.org/pods/libksygpulive)


[![Apps Using](https://img.shields.io/cocoapods/at/libksygpulive_ks3.svg?label=Apps%20Using%20libksygpulive_ks3&colorB=28B9FE)](http://cocoapods.org/pods/libksygpulive_ks3)
[![Downloads](https://img.shields.io/cocoapods/dt/libksygpulive_ks3.svg?label=Total%20Downloads%20libksygpulive_ks3&colorB=28B9FE)](http://cocoapods.org/pods/libksygpulive_ks3)


[![Build Status](https://travis-ci.org/ksvc/KSYLive_iOS.svg?branch=master)](https://travis-ci.org/ksvc/KSYLive_iOS)
[![Latest release](https://img.shields.io/github/release/ksvc/KSYLive_iOS.svg)](https://github.com/ksvc/KSYLive_iOS/releases/latest)
[![CocoaPods platform](https://img.shields.io/cocoapods/p/libksygpulive.svg)](https://cocoapods.org/pods/libksygpulive)
[![CocoaPods version](https://img.shields.io/cocoapods/v/libksygpulive.svg?label=pod_github)](https://cocoapods.org/pods/libksygpulive)
[![CocoaPods version](https://img.shields.io/cocoapods/v/libksygpulive_ks3.svg?label=pod_ks3)](https://cocoapods.org/pods/libksygpulive_ks3)

<pre>Source Type:<b> Binary SDK</b>
Charge Type:<b> free of charge</b></pre>

## 阅读对象
本文档面向所有使用[金山云直播SDK][libksygpulive]的开发、测试人员等, 要求读者具有一定的iOS编程开发经验，并且要求读者具备阅读[wiki][wiki]的习惯。

|![live_1.png](https://raw.githubusercontent.com/wiki/ksvc/KSYLive_iOS/images/live_1.png)|![live_1.png](https://raw.githubusercontent.com/wiki/ksvc/KSYLive_iOS/images/live_2.png)|![live_1.png](https://raw.githubusercontent.com/wiki/ksvc/KSYLive_iOS/images/live_3.png)|

|![live_4.png](https://raw.githubusercontent.com/wiki/ksvc/KSYLive_iOS/images/live_4.png)|![live_5.png](https://raw.githubusercontent.com/wiki/ksvc/KSYLive_iOS/images/live_5.png)|


## 一. 功能特性

[金山云直播SDK][libksygpulive]是金山云提供的直播解决方案的一部分，完成了iOS端音视频数据采集、处理、推流和播放的工作。

[金山云直播SDK][libksygpulive]**不限制**用户的推流、拉流地址。用户可以只使用[金山云直播SDK][libksygpulive]而不使用金山云的云服务。

[金山云直播SDK][libksygpulive]不收取任何授权使用费用，不含任何失效时间或者远程下发关闭的后门。同时[金山云直播SDK][libksygpulive]也不要求ak/sk等鉴权，没有任何用户标识信息。

[金山云直播SDK][libksygpulive]提供了业内一流的H.265编码、解码能力，H.265能力也是**免费使用**，欢迎集成试用。

[金山云直播SDK][libksygpulive]当前未提供开源代码，如果需要其他定制化开发功能，请通过[金山云商务渠道][ksyun]联系。


### 1.1 关于热更新

金山云SDK保证，提供的[金山云直播SDK][libksygpulive]未使用任何热更新技术，例如：RN(ReactNative)、weex、JSPatch等，请放心使用。

### 1.2 推流功能
- [x] AAC 音频编码（支持软、硬编）
- [x] H.264 视频编码（支持软编/硬编,支持baseline/main/high profile）
- [x] [H.265 视频软编码](https://github.com/ksvc/KSYLive_iOS/wiki/enableH265)
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
- [x] 支持[预览和采集分辨率分别设置,支持任意分辨率](https://github.com/ksvc/KSYLive_iOS/wiki/customOutputSize)
- [x] 支持[第三方连麦](https://github.com/ksvc/KSYDiversityLive_iOS/tree/master/agoraRtc)
- [x] [场景编码](https://github.com/ksvc/KSYLive_iOS/wiki/liveScene)
- [x] 支持软编、硬编的[性能编码模式](https://github.com/ksvc/KSYLive_iOS/wiki/liveScene)
- [x] 支持[预览和推流分别镜像](https://github.com/ksvc/KSYLive_iOS/wiki/mirrored)
- [x] [在线API 文档支持](http://ksvc.github.io/KSYLive_iOS/doc/html/index.html)
- [x] 支持[边推边录](https://github.com/ksvc/KSYLive_iOS/wiki/bypassRecord)，在直播推流过程中同时保存录像文件
- [x] 支持[立体声](https://github.com/ksvc/KSYLive_iOS/wiki/stereo)推流（双声道）
- [x] 支持[涂鸦推流](https://github.com/ksvc/KSYLive_iOS/wiki/BrushStream)
- [x] 支持[桌面录制、手游直播](https://github.com/ksvc/KSYAirStreamer_iOS)

### 1.3 播放特点
- [x] 与系统播放器MPMoviePlayerController接口一致，可以无缝快速切换至KSYMediaPlayer；
- [x] 本地全媒体格式支持, 并对主流的媒体格式(mp4, avi, wmv, flv, mkv, mov, rmvb 等 )进行优化；
- [x] 支持广泛的流式视频格式, HLS, RTMP, HTTP Pseudo-Streaming 等；
- [x] 低延时直播体验，配合金山云推流sdk，可以达到全程直播稳定的4秒内延时；
- [x] 实现快速满屏播放，为用户带来更快捷优质的播放体验；
- [x] 版本适配支持iOS 7.0以上版本；
- [x] 业内一流的H.265解码；
- [x] 小于2M大小的超轻量级直播sdk；

### 1.4 文档
[详情请见wiki](https://github.com/ksvc/KSYLive_iOS/wiki)

### 1.4 关于热更新

金山云SDK保证，提供的[KSYLive iOS直播SDK](https://github.com/ksvc/KSYLive_iOS)未使用热更新技术，例如：RN(ReactNative)、weex、JSPatch等，请放心使用。

### 1.5 关于费用
金山云SDK保证，提供的[KSYLive iOS直播SDK](https://github.com/ksvc/KSYLive_iOS)可以用于商业应用，不会收取任何SDK使用费用。但是基于[KSYLive iOS直播SDK](https://github.com/ksvc/KSYLive_iOS)的其他商业服务，会由特定供应商收取授权费用，大致包括：

1. 云存储
1. CDN分发
1. 动态贴纸
1. 连麦
1. 第三方美颜

## 二. 推流端大事记 
### 2.1 2016年发布大事记  
1. 2016.02.25 上行网络自适应上线；
1. 2016.03.26 [内建美颜](https://github.com/ksvc/KSYLive_iOS/wiki/filter)上线；
1. 2016.04.11 支持四种混响模式的[美声](https://github.com/ksvc/KSYLive_iOS/wiki/reverb)上线；
1. 2016.05.18 [耳返](https://github.com/ksvc/KSYLive_iOS/wiki/micMonitor)上线；
1. 2016.06.12 [画中画](https://github.com/ksvc/KSYLive_iOS/wiki/pip)推流上线；
1. 2016.06.27 支持短视频录制；
1. 2016.08.24 支持[纯音频](https://github.com/ksvc/KSYLive_iOS/wiki/pureAudioStream)推流，支持[后台推流](https://github.com/ksvc/KSYLive_iOS/wiki/backgroupStream)，支持视频动态发送开关；
1. 2016.08.31 [场景编码](https://github.com/ksvc/KSYLive_iOS/wiki/liveScene)，有效提升直播画质；
1. 2016.09.07 内建[新美颜](https://github.com/ksvc/KSYLive_iOS/wiki/filter)上线； 
1. 2016.09.12 [kit类顶层代码开源](https://github.com/ksvc/KSYLive_iOS/tree/master/source), podspec 中将集成framework改为集成静态库
1. 2016.09.21 特效滤镜上线;
1. 2016.09.26 [双人连麦](https://github.com/ksvc/KSYDiversityLive_Android/tree/master/Agora)稳定版本上线;
1. 2016.09.28 视频硬编[性能编码模式](https://github.com/ksvc/KSYLive_iOS/wiki/liveScene)上线。音频AAC硬编功能上线。网络自适应场景上线；
1. 2016.10.19 支持[推流横竖屏动态变化](https://github.com/ksvc/KSYLive_iOS/wiki/dynamicOrientation)；
1. 2016.10.20 支持[replaykit录屏推流](https://github.com/ksvc/KSYDiversityLive_iOS/tree/master/KSYReplayKit)；
1. 2016.11.18 支持[边推流边录制为mp4文件](https://github.com/ksvc/KSYLive_iOS/wiki/bypassRecord)
1. 2016.2.22 支持[动态帧率](https://github.com/ksvc/KSYLive_iOS/wiki/dynamicFPS)
1. 2016.3.1 支持主播音频[采集变声](http://ksvc.github.io/KSYLive_iOS/doc/html/Classes/KSYAUAudioCapture.html#//api/name/effectTyped)
1. 2017.3.14 支持[立体声](https://github.com/ksvc/KSYLive_iOS/wiki/stereo)推流
1. 2017.5.16 支持[涂鸦推流](https://github.com/ksvc/KSYLive_iOS/wiki/BrushStream)
1. 2017.7.7 支持[桌面录制、手游直播](https://github.com/ksvc/KSYAirStreamer_iOS)
1. 2017.7.7 支持[iOS 11 HEVC 硬编推流](https://github.com/ksvc/KSYLive_iOS/wiki/enableH265)
1. 2017.8.3 支持采集降噪

### 2.2 近期工作   

1. 2017.03.xx 多视角直播;
1. 2017.03.xx 背景音降噪;

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

#### 3.2.2 从[bitbucket](https://bitbucket.org/ksvc/ksylive_ios.git) clone

对于部分地方访问github比较慢的情况，可以从bitbucket clone，获取的库内容和github一致。
```
$ git clone https://bitbucket.org/ksvc/ksylive_ios.git  --depth 1
```

#### 3.2.3 使用Cocoapods 进行安装    
通过Cocoapods 能将本SDK的静态库和代码下载到本地，只需要将类似如下语句中的一句加入你的Podfile：   
```ruby
pod 'libksygpulive/KSYGPUResource'
pod 'libksygpulive/libksygpulive'
```
执行 pod install即可.  

其中, 第一段libksygpulive为SDK名,第二段KSYGPUResource和libksygpulive为子模块名

本SDK提供了多个不同的子模块以满足不同用户的需求:
* KSYMediaPlayer     : 用于直播的播放内核(支持格式精简)
* KSYMediaPlayer_vod : 用于点播的播放内核(支持格式丰富)
* libksygpulive      : 用于直播推流和播放的SDK（直播推流功能和精简版本的播放SDK）
* libksygpulive_265  : 用于直播推流和播放的SDK (支持265推流和精简版本的播放SDK)
* KSYGPUResource     : 直播推流用到的资源文件, 主要用于美颜和特效滤镜

<details>
<summary>Pod依赖进阶</summary>
<b markdown=1>
  
* 本地开发版 (sdk clone或下载到本地后)
``` 
pod 'libksygpulive/libksygpulive', :path => '../'  
```

* 直接指定SDK的github仓库地址和版本号
```
pod 'libksygpulive/libksygpulive', :git => 'https://github.com/ksvc/KSYLive_iOS.git', :tag => 'v1.8.0'
```

* 从cocoapod官方库Trunk获取spec, 从github下载sdk
```
pod 'libksygpulive/libksygpulive'
```

* 从cocoapod官方库Trunk获取spec, 从金山云存储 ks3 下载sdk (国内速度较快)
```
pod 'libksygpulive_ks3/libksygpulive'
```         

* 如果pod install 时出现无法找到specification的提示, 请先更新repo
```
pod repo update
```

*  **注意1**: 不能将以上语句都加入Podfile, 他们作用是一样的, 只是Podspec读取位置不同.

</b>
</details>

### 3.2.4 GPUImage依赖

请参考官方cocoapods提供的[GPUImage](https://github.com/BradLarson/GPUImage/releases/tag/0.1.7)，当前我们测试通过的版本是[0.1.7](https://github.com/BradLarson/GPUImage/releases/tag/0.1.7)

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

将压缩包解压(或者clone成功)后, 进入 releaseFramework 目录, 通过 release-libKSYLive.sh 下载依赖项并打包出framework，生成到KSYLive_iOS/framework/static目录下。      
```
$ cd releaseFramework
$ ./release-libKSYLive.sh libksygpulive lite
$ ls ../framework/static
Bugly.framework  GPUImage.framework  libksygpulive.framework
```
参数的详细说明请参考脚本release-libKSYLive.sh的帮助(./release-libKSYLive.sh -h)或[动态库第4点说明](https://github.com/ksvc/KSYLive_iOS/wiki/dylib).

> Bugly.framework 是为了收集demo的崩溃信息用的(仅仅demo里用到). 集成SDK到用户项目中时,不依赖Bugly.

* 给demo添加库依赖选项

打开demo目录下的KSYLiveDemo.xcodeproj, 修改KSYLiveDemo项目的配置文件:  
选中KSYLiveDemo工程->选中Project KSYLiveDemo->选中 Info 标签->选择Configurations->Debug或Release->给KSYLiveDemo分别选择对应的KSYLiveDemo-framework.xcconfig文件。注意，如果使用动态库则选择KSYLiveDemo-dy-framework.xcconfig。

![xcode_configs](https://github.com/ksvc/KSYLive_iOS/wiki/images/xcode_configs.png)

或者手动在项目配置中添加如下参数: (具体请参见 demo目录下的 KSYLiveDemo-framework.xcconfig)
```
OTHER_LDFLAGS = $(inherited) -ObjC -all_load -framework libksygpulive -framework GPUImage -framework Bugly -lstdc++.6 -lz
FRAMEWORK_SEARCH_PATHS = $(inherited) ../framework/ ../framework/static
```
以上为静态库的集成方法，动态库的配置使用方法请参考Wiki中[动态库](https://github.com/ksvc/KSYLive_iOS/wiki/dylib)相关内容。
### 3.4 添加头文件到需要使用本SDK的文件中
```
#import <GPUImage/GPUImage.h>
#import <libksygpulive/KSYGPUStreamerKit.h>
```
以上两个头文件都是需要引入的：  
* GPUImage.h是因为依赖第三方framework需要引入的
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
* 本framework为静态库，虽然库的大小为20M+，但是最后链接后，对app的增量只有5M+
* 如果使用cocoapod官方库Trunk时,发现找不到最新版本的库, 需要先执行如下命令, 更新spec库
```
pod repo update
```

## 四. 参考文档
* [iOS直播推流SDK使用指南](https://github.com/ksvc/KSYLive_iOS/wiki/KSYStreamerSDKUserManual)
* [iOS直播推流SDK常见问题](https://github.com/ksvc/KSYLive_iOS/wiki/FAQ)
* [接口变更历史](https://github.com/ksvc/KSYLive_iOS/wiki/apiAdjust)

## 五. 播放器使用示例
请见github库：https://github.com/ksvc/KSYMediaPlayer_iOS.git

## 六. 反馈与建议
### 6.1 反馈模板  

| 类型    | 描述|
| :---: | :---:| 
|SDK名称|KSYLive_iOS|
|SDK版本| v2.5.0|
|设备型号| iphone7  |
|OS版本| iOS 10 |
|问题描述| 描述问题出现的现象  |
|操作描述| 描述经过如何操作出现上述问题                     |
|额外附件| 文本形式控制台log、crash报告、其他辅助信息（界面截屏或录像等） |

### 6.2 联系方式
* 主页：[金山云](http://www.ksyun.com/)
* 邮箱：<zengfanping@kingsoft.com>
* QQ讨论群：
    * 574179720 [视频云技术交流群]
    * 621137661 [视频云iOS技术交流]
    * 以上两个加一个QQ群即可
    
* Issues:<https://github.com/ksvc/KSYLive_iOS/issues>

<a href="http://www.ksyun.com/"><img src="https://raw.githubusercontent.com/wiki/ksvc/KSYLive_Android/images/logo.png" border="0" alt="金山云计算" /></a>

[libksygpulive]:https://github.com/ksvc/KSYLive_iOS
[ksyun]:https://www.ksyun.com/about/aboutcontact
[wiki]:https://github.com/ksvc/KSYLive_iOS/wiki
