# [KSY Live iOS SDK](http://ksvc.github.io/KSYLive_iOS/index.html)使用手册


##SDK 概述
金山云推出的iOS平台上使用的软件开发工具包,可高度定制化和二次开发.


##功能特性

###推流功能
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

###播放特点
- [x] 与系统播放器MPMoviePlayerController接口一致，可以无缝快速切换至KSYMediaPlayer；
- [x] 本地全媒体格式支持, 并对主流的媒体格式(mp4, avi, wmv, flv, mkv, mov, rmvb 等 )进行优化；
- [x] 支持广泛的流式视频格式, HLS, RTMP, HTTP Rseudo-Streaming 等；
- [x] 低延时直播体验，配合金山云推流sdk，可以达到全程直播稳定的4秒内延时；
- [x] 实现快速满屏播放，为用户带来更快捷优质的播放体验；
- [x] 版本适配支持iOS 7.0以上版本；
- [x] 业内一流的H.265解码；
- [x] 小于2M大小的超轻量级直播sdk；

##内容摘要
- [工程环境](#工程环境)
    - [运行环境](#运行环境)
    - [下载工程](#下载工程)
    - [工程目录](#工程目录)
    - [添加工程](#添加工程)
- [SDK使用示例](#SDK使用示例)
    - [入口类](#入口类)
    - [采集参数设置](#采集参数设置)
    - [推流编码参数设置](#推流编码参数设置)
    - [服务器地址](#服务器地址)
    - [采集推流状态](#采集推流状态)
    - [启停预览](#启停预览)
    - [启停推流](#启停推流)
    - [美颜滤镜](#美颜滤镜)
- [播放器使用示例](#播放器使用示例)

##工程环境
###运行环境

* 最低支持iOS版本：iOS 7.0
* 最低支持iPhone型号：iPhone 4
* 支持CPU架构： armv7, armv7s,arm64
* 含有i386和x86_64模拟器版本的库文件，推流功能无法在模拟器上工作，播放功能完全支持模拟器。

###下载工程
本SDK 提供如下两种获取方式:
1. 从github下载：https://github.com/ksvc/KSYLive_iOS.git
2. 使用Cocoapods进行安装，方法见下段。

###工程目录

1. SDK压缩包
如果获取到的为zip格式的压缩包，解压后的目录结构如下所示:
  - demo        : demo工程为KSYLive ，演示本SDK的主要接口的使用
  - doc/docset  : appleDoc风格的接口文档
  - doc/html    : appleDoc风格的[接口文档](http://ksvc.github.io/KSYLive_iOS/html/index.html)
  - framework   : 本SDK的静态库framework，集成时需要将该framework加入到项目中
    - framework/live264/libksylive.framework    
    不依赖GPUImage的推流SDK
    - framework/livegpu/libksygpulive.framework     
    依赖GPUImage，支持美颜功能，并包含了libksylive全部功能的推流SDK

2. SDK Cocoapods
通过Cocoapods 能将本SDK的静态库framework下载到本地，只需要 将如下语句加入你的Podfile：   
（libksylive）   
```
pod 'KSYLive_iOS', :git => 'https://github.com/ksvc/KSYLive_iOS.git'
```
（libksygpulive）    
```
pod 'KSYGPULive_iOS', :git => 'https://github.com/ksvc/KSYLive_iOS.git'
```

执行 pod install 或者 pod update后，将SDK加入工程。

###添加工程
* SDK压缩包
将压缩包中framework下的libksylive.framework添加到XCode的工程，具体步骤为：
1. 选中应用的Target，进入项目配置页面
2. 切换到 Build Phases标签页
3. 在Link Binary With Libraries的列表中添加上 libksylive.framework   
(点击列表底部的加号，在弹出的向导中选择libksylive.framework)
4. 如果需要使用GPU美颜滤镜，则用同样的方法加上libksygpulive.framework，并且需要添加第三方库GPUImage.framework

* SDK Cocoapods
在Podfile中本SDK的条目，并执行了 pod install 之后， 本SDK就已经加入工程中，打开工程的workspace即可。

##SDK使用示例

具体可参见KSYLiveDemo工程中的KSYStreamerVC/KSYGPUStreamerVC/KSYStreamerKitVC.
- KSYStreamerVC    
  KSYStreamer的使用示例（使用libksylive时不依赖GPUImage）
- KSYStreamerKitVC     
  KSYGPUStreamerKit的使用示例，与KSYStreamer用法一致，仅仅添加了设置美颜接口
- KSYGPUStreamerVC 
  KSYGPUStreamer使用示例，可以自由组合采集，滤镜和推流，实现高度定制化的需求

* 在使用libksylive，引入头文件
```
#import <libksylive/libksylive.h>
```
或者使用支持滤镜的 libksygpulive
```
#import <GPUImage/GPUImage.h>
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/libksygpuimage.h>
```

###入口类
本SDK提供的入口类如下
![sdk classes](http://ksvc.github.io/KSYLive_iOS/html/img/sdkClass.png)

* libksylive 的入口类为[KSYStreamer](http://ksvc.github.io/KSYLive_iOS/html/Classes/KSYStreamer.html), 包含了采集和推流的功能，后续与推流相关的操作大部分都要通过KSYStreamer 来进行，比如设置采集和推流的属性，启停预览，启停推流等

* libksygpulive 的入口类如下
  * KSYStreamerBase   基础推流类，接受CMSampleBufferRef的音视频数据进行编码推流
  * KSYGPUCamera      对GPUImageVideoCamera的封装，负责采集部分的功能
  * KSYGPUStreamer    对KSYStreamerBase的封装，对接GPUImage的滤镜输出
  * KSYGPUStreamerKit 对KSYGPUCamera和KSYGPUStreamer的封装，对采集，滤镜和推流组装
 
* 两种使用方式： 
  - 简单接口 KSYGPUStreamerKit 与 KSYStreamer类似，打包了采集和推流部分
  - 进阶接口 KSYGPUCamera+KSYGPUStreamer，自由度比较大，采集和推流模块分离可以自由组合

以下总结使用libksygpulive和使用libksylive中基本推流的几点修改：
* 依赖的头文件不同，本SDK的头文件分为两个，并且需要在引入GPUImage 之后引入：
```
#import <GPUImage/GPUImage.h>
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/libksygpuimage.h>
```

###采集参数设置
* 设置分辨率

    ```
     _kit.videoDimension = KSYVideoDimension_16_9__960x540;
    ```
    如果使用KSYGPUStreamerKit/KSYStreamer，可以支持自定义分辨率.
    ```
    /// 16 : 9 宽高比，1280 x 720 分辨率
    KSYVideoDimension_16_9__1280x720 = 0,
    /// 16 : 9 宽高比，960 x 540 分辨率
    KSYVideoDimension_16_9__960x540,
            
    /// 缩放自定义分辨率 从设备支持的最近分辨率缩放获得, 若设备没有对应宽高比的分辨率，则裁剪后进行缩放
    KSYVideoDimension_UserDefine_Scale,
    /// 裁剪自定义分辨率 从设备支持的最近分辨率裁剪获得
    KSYVideoDimension_UserDefine_Crop,
    /// 注意： 选择缩放自定义分辨率时可能会有额外CPU代价
    ```
    其中KSYVideoDimension_UserDefine_Scale/Crop为可以自定义的分辨率，自定义范围为
    
        - 宽度有效范围[160, 1280]
        - 高度有效范围[ 90,  720], 超出范围会提示参数错误
        
    如果使用KSYGPUSteamer,只支持iOS系统定义的AVCaptureSessionPreset*,需要自定义分辨率的话，可以通过添加裁剪和缩放的滤镜         来实现分辨率的改变.
* 设置视频采集帧率

    ```
    _kit.videoFPS = 15;
    ```
    如果使用KSYGPUStreamerKit/KSYStreamer,可以通过设置 videoFPS 就设定了采集和推流的帧率.
    如果使用KSYGPUSteamer,只设置摄像头的帧率,需要将同一个值在推流参数中再设置一次.
* 设置视频朝向

    ```
        UIInterfaceOrientation orien = [[UIApplication sharedApplication] statusBarOrientation];
        [_kit outputImageOrientation:orien];
    ```
    推流和采集的朝向必须保持一致，建议直接将设备UI的朝向设置为视频的朝向

###推流编码参数设置
* 选择视频编码器，（264软编码，264硬编码，265软编码等）
    
    ```
     _kit.streamerBase.videoCodec = KSYVideoCodec_VT264;
    ```
* 设置视频自适应码率范围

    ```
        _kit.streamerBase.enAutoApplyEstimateBW = _btnAutoBw.on;
        _kit.streamerBase.videoInitBitrate = 1000; // k bit ps
        _kit.streamerBase.videoMaxBitrate  = 1000; // k bit ps
        _kit.streamerBase.videoMinBitrate  = 100; // k bit ps
    ```
    
    - videoMaxBitrate为平均码率上调的上限，即当网络足够好时的目标码率，对应画质最好的情况
    - videoMinBitrate为平均码率下调的下限，即当网络太差时，如果再往下调整，画面质量会无法接受
    - videoInitBitrate为开始推流时的码率，开始推流后才能根据实际网络情况自动上调或下调
* 设置音频码率

    
        ```
            _kit.streamerBase.audiokBPS        = 48; // k bit ps
        ```

* 设置采集帧率(使用KSYGPUSteamer才需要)
    
        通过设置 videoFPS 就设定了推流的帧率，一般设置成和采集的一样。
        ```
        _gpuStreamer.streamerBase.videoFPS   = _capDev.frameRate;
        ```
        
###服务器地址
* 服务器url(需要向相关人员申请，测试地址并不稳定！)：
```
@property NSURL * hostURL;
NSString *url = @"rtmp://test.uplive.ksyun.com/live/{streamName}"
_hostURL      = [[NSURL alloc] initWithString:url];
```

###采集推流状态
由于对摄像头的操作和启停推流都与设备交互，可能会出现比较耗时的情况，相关API设计为异步接口，比如调用启动推流接口API后，并不是API返回后就能知道是否连接成功，而是需要通过状态变化回调，来查询执行的结果。本SDK提供如下表列出的通知，通过NSNotificationCenter注册接收相应的通知：    

| 通知名称 | 通知说明 |  相关属性 | 相关类  |
| --------| ------|  --- |  --- |
| KSYCaptureStateDidChangeNotification | 采集设备状态变化通知  | captureState | KSYStreamer, KSYGPUStreamerKit |
| KSYStreamStateDidChangeNotification  | 推流状态变化通知| streamState, streamErrorCode | KSYStreamer, KSYStreamerBase |
| KSYNetStateEventNotification         | 网络事件发生通知| netStateCode | KSYStreamer, KSYStreamerBase |

当采集设备的状态发生变化时，对应的接收回调函数会被调用，通过_kit.captureState属性,可查询到新的状态。
当推流状态发生变化，则在收到通知回调后，查询streamState查询新状态。其中如果streamState变为 [KSYStreamStateError](http://ksvc.github.io/KSYLive_iOS/html/Constants/KSYStreamState.html),需要通过[streamErrorCode](http://ksvc.github.io/KSYLive_iOS/html/Constants/KSYStreamErrorCode.html) 具体查询其错误原因
使用KSYGPUCamera时，为了保持与GPUImage一致，没有采用异步接口，不提供captureState状态。

如果需要对推流状态进行监控，可以设置一个每秒刷新一次的timer，计算出网络发送速度（每秒发送的字节数）和视频编码速度（每秒编码的帧数）

###启停预览
* 通过如下接口启动和停止预览，当启动预览时，需要将显示预览的view传入到SDK中

```
[_kit startPreview: self.view];
//....
[_kit stopPreview];
```
注意：当采集设备的权限被用户禁用时，会进入KSYCaptureStateDevAuthDenied状态

###启停推流
* 开始/停止推流, 在这之前必须要先启动预览，开始推流时, 需要将推流的完整URL作为参数传入, 比如rtmp://xxx.xxx.xxx/appname/streamkey 

```
[_kit startStream:_hostURL];
//....
[_kit stopStream];
```
进入KSYStreamStateConnected 状态，表明推流成功；

注意：所有的对应操作开始和结束时会有KSYCaptureStateDidChangeNotification的状态通知

###美颜滤镜
本SDK中的美颜滤镜依赖第三方开源库GPUImage，可以方便简单的进行对接，也可以很方便的增加自定义的美颜滤镜。

* KSYGPUStreamerKit增加了setupFilter的方法，创建出美颜滤镜后，通过该方法传入SDK，预览和推流的图像就是应用了该滤镜后的图像
```
    @property GPUImageFilter     * filter;
    _filter = [[KSYGPUBeautifyPlusFilter alloc] init];
    [_kit setupFilter:_filter];
```

* 使用KSYGPUStreamer，需要开发者自行将 采集，滤镜，推流，预览等部分组装起来，自由度比较大
  - 通过采集类KSYGPUCamera设置摄像头参数
   - 通过GPUImageFilter来实现GPU滤镜图像处理
   - 通过KSYGPUStreamer实现编码推流
   - 通过GPUImageView实现画面预览
   - 以上都是符合GPUImage框架的部件，通过各自的 addTarget/removeTarget,来实现连接组装和拆解

```
    [_capDev addTarget:_cropfilter];
    [_cropfilter addTarget:_filter];
    [_filter  addTarget:_preview];
    [_filter  addTarget:_gpuStreamer];
```

以上例子中有滤镜级联，其中_cropfilter只有在需要对图像进行裁剪时才添加，比如摄像头设置为16:9的分辨率，如果需要在ipad上显示4:3的分辨率，就可以用GPUImageCropFilter来进行裁剪。

```
 [[GPUImageCropFilter alloc] initWithCropRegion:rect];
```

###混音、混响功能

本SDK支持声音的处理，用户可以很方便的使用接口对声音进行处理。
* 开始混响

```
[_kit.streamerBase enableReverb:level];
```
level: 取值范围为[0，1，2，3，4]，分别为不同效果，level取值为0表示关闭。

* 开启／关闭混音功能
```
[_kit.streamerBase enableMicMixMusic:YES/NO];
```

* 开始混音
```
[_kit.streamerBase startMixMusic:testMp3 isLoop:NO];
```

* 暂停／恢复
```
[_kit.streamerBase pauseMixMusic];
//...
[_kit.streamerBase resumeMixMusic];
```

* 停止混音
```
[_kit.streamerBase stopMixMusic];
```

###音视频处理回调接口

* 音频处理回调接口
```
_kit.audioProcessingCallback = ^(CMSampleBufferRef sampleBuffer){
//        processAudio(sampleBuffer);
};
```
sampleBuffer 前处理，原始采集到的音频数据；


* 视频处理回调接口
```
_kit.videoProcessingCallback = ^(CMSampleBufferRef sampleBuffer){
//        processVideo(sampleBuffer);
};
```
sampleBuffer 前处理，原始采集到的视频数据，即美颜之前的数据。

* 请注意以上两个函数的执行时间，如果太长可能导致不可预知的问题。


##播放器使用示例
请见github库：https://github.com/ksvc/KSYMediaPlayer_iOS.git
