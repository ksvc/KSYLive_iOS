<h1 align="center">KSY Live iOS SDK</h1>

[![Apps Using][badge_at]][cocoapods_url]
[![Downloads][badge_dt]][cocoapods_url]

[![Apps Using][badge_at_ks3]][cocoapods_url_ks3]
[![Downloads][badge_at_ks3]][cocoapods_url_ks3]

[![Build Status](https://travis-ci.org/ksvc/KSYLive_iOS.svg?branch=master)](https://travis-ci.org/ksvc/KSYLive_iOS)
[![Latest release](https://img.shields.io/github/release/ksvc/KSYLive_iOS.svg)][github_release]
[![CocoaPods platform](https://img.shields.io/cocoapods/p/libksygpulive.svg)][cocoapods_url]
[![CocoaPods version](https://img.shields.io/cocoapods/v/libksygpulive.svg?label=pod_github)][cocoapods_url]
[![CocoaPods version](https://img.shields.io/cocoapods/v/libksygpulive_ks3.svg?label=pod_ks3)][cocoapods_url_ks3]

<pre> Source Type: <b> Binary SDK </b>
Charge Type: <b> free of charge </b> </pre>

## Reading object
This document is intended for all developers and testers who use [KSY Live iOS SDK][libksygpulive], and requires readers to have some experience in iOS programming and development, and require readers to read [wiki][wiki] habits.

|![live_1.png](https://raw.githubusercontent.com/wiki/ksvc/KSYLive_iOS/images/live_1.png)|![live_1.png](https://raw.githubusercontent.com/wiki/ksvc/KSYLive_iOS/images/live_2.png)|![live_1.png](https://raw.githubusercontent.com/wiki/ksvc/KSYLive_iOS/images/live_3.png)|

|![live_4.png](https://raw.githubusercontent.com/wiki/ksvc/KSYLive_iOS/images/live_4.png)|![live_5.png](https://raw.githubusercontent.com/wiki/ksvc/KSYLive_iOS/images/live_5.png)|


## 1. Features

[KSY Live iOS SDK][libksygpulive] Jinshan Cloud provides live solution as part of the completion of the iOS audio and video data acquisition, processing, streaming and playback.

[KSY Live iOS SDK][libksygpulive] **does not** limit the user's push, pull flow address. Users can only use [KSY Live iOS SDK][libksygpulive] instead of using Jinshan cloud services.

[KSY Live iOS SDK][libksygpulive] does not charge any license fee, does not contain any lapse of time or shut down the back door remotely. At the same time [KSY Live iOS SDK][libksygpulive] does not require ak / sk authentication, there is no user identification information.

[KSY Live iOS SDK][libksygpulive] provides industry-leading H.265 encoding and decoding capabilities, H.265 capabilities are **free to use**, welcome to integration trial.

[KSY Live iOS SDK][libksygpulive] Currently does not provide open source code, if you need other custom development features, please contact [Kingsoft Business Channel][ksyun].


### 1.1 About Hot Update

Kingsoft Cloud guarantees, [KSY Live SDK][libksygpulive] does not use any hot update technology, such as: RN (ReactNative), weex, JSPatch, etc.

### 1.2 Push flow function
- [x] AAC Audio Encoding (Soft and Hard)
- [x] H.264 video encoding (soft / hardcode supported, baseline / main / high profile supported)
- [x] [H.265 Video Soft Coding](https://github.com/ksvc/KSYLive_iOS/wiki/enableH265)
- [x] H.264 video coding (support for soft editing H.264 / H.265 support for H.264 hard coding (baseline / main / high profile support)
- [x] Multi-resolution encoding support
- [x] Camera Controls (Toward, Flash, Front and Rear Cameras)
- [x] Camera Control (native system api can be called)
- [x] User can freely set audio and video bit rate
- [x] Adjust the video bit rate adaptively according to the network bandwidth. The network adaptation mode can be configured
- [x] Support RTMP streaming live streaming
- [x] Provides two levels of APIs: easy-to-use kit APIs and flexible component-based APIs that provide open source kit class code
- [x] Seamless integration with GPUImage
- [x] [Built-in Beauty Filters for GPU Implementation](https://github.com/ksvc/KSYLive_iOS/wiki/filter)
- [x] Support [Background Music Play](https://github.com/ksvc/KSYLive_iOS/wiki/BGM)
- [x] Support [Remix](https://github.com/ksvc/KSYLive_iOS/wiki/mixer)
- [x] Support [Video Motion Switch / Audio Streaming](https://github.com/ksvc/KSYLive_iOS/wiki/pureAudioStream)
- [x] Support [Backstage](https://github.com/ksvc/KSYLive_iOS/wiki/backgroupStream)
- [x] Support [Ear Back](https://github.com/ksvc/KSYLive_iOS/wiki/micMonitor)
- [x] Support [PIP](https://github.com/ksvc/KSYLive_iOS/wiki/pip) Streaming
- [x] support [preview and capture resolution set separately, support for any resolution](https://github.com/ksvc/KSYLive_iOS/wiki/customOutputSize)
- [x] Support [3rd party with wheat](https://github.com/ksvc/KSYDiversityLive_iOS/tree/master/agoraRtc)
- [x] [Scene Code](https://github.com/ksvc/KSYLive_iOS/wiki/liveScene)
- [x] Support for soft and hard coded [Performance Coding Mode](https://github.com/ksvc/KSYLive_iOS/wiki/liveScene)
- [x] Support [Preview & Stream respectively](https://github.com/ksvc/KSYLive_iOS/wiki/mirrored)
- [x] [Online API Documentation Support](http://ksvc.github.io/KSYLive_iOS/doc/html/index.html)
- [x] Support [Sidebar](https://github.com/ksvc/KSYLive_iOS/wiki/bypassRecord), save the video file during the streaming
- [x] Support [Stereo](https://github.com/ksvc/KSYLive_iOS/wiki/stereo) Streaming (2-channel)
- [x] Support [Doodle Streaming](https://github.com/ksvc/KSYLive_iOS/wiki/BrushStream)
- [x] Support for [Desktop Recording, Live Tour](https://github.com/ksvc/KSYAirStreamer_iOS)

### 1.3 playback features
- [x] Consistent with the system player MPMoviePlayerController interface, seamless and fast switching to KSYMediaPlayer;
- [x] Native full media format support, optimized for mainstream media formats (mp4, avi, wmv, flv, mkv, mov, rmvb, etc)
- [x] Support for a wide range of streaming video formats, HLS, RTMP, HTTP Pseudo-Streaming, etc;
- [x] low latency live experience, with Jinshan cloud streaming sdk, you can achieve full live broadcast 4 seconds delay stability;
- [x] Achieve fast full screen playback, to bring users faster and better quality playback experience;
- [x] version adapter supports iOS 7.0 and above;
- [x] Industry-leading H.265 decoding;
- [x] Ultra-lightweight live sdk less than 2M;

### 1.4 documentation
[See wiki](https://github.com/ksvc/KSYLive_iOS/wiki)

### 1.4 About Hot Update

Kingsoft Cloud SDK guarantees that the provided [KSYLive iOS Live Broadcast SDK](https://github.com/ksvc/KSYLive_iOS) does not use thermal update technologies such as RN (ReactNative), weex, JSPatch, etc., so be sure to use it.

### 1.5 about the cost
Kingsoft Cloud SDK guarantees that the provided [KSYLive iOS Live Broadcast SDK](https://github.com/ksvc/KSYLive_iOS) can be used for commercial applications without charge for any SDK usage. However, other commercial services based on the [KSYLive iOS Live Broadcast SDK](https://github.com/ksvc/KSYLive_iOS) will be charged by a specific vendor for licensing fees, broadly including:

Cloud storage
CDN distribution
1. Dynamic stickers
1. Even wheat
1. Third-party beauty

## 2. Streaming Events
### 2.1 2016 release memorabilia
1. 2016.02.25 uplink network adaptive on-line;
1. 2016.03.26 [Built-in beauty](https://github.com/ksvc/KSYLive_iOS/wiki/filter) On the line;
1. 2016.04.11 [Voice](https://github.com/ksvc/KSYLive_iOS/wiki/reverb) that supports four reverb modes is online;
1. 2016.05.18 [Ear Return](https://github.com/ksvc/KSYLive_iOS/wiki/micMonitor) Go live;
1. 2016.06.12 [PIP](https://github.com/ksvc/KSYLive_iOS/wiki/pip) Streaming on the line;
1. 2016.06.27 support short video recording;
1. 2016.08.24 Support [Pure Audio](https://github.com/ksvc/KSYLive_iOS/wiki/pureAudioStream) Streaming, support [Backstage](https://github.com/ksvc/KSYLive_iOS/wiki / backgroupStream), support video dynamic send switch;
1. 2016.08.31 [Scenario Code](https://github.com/ksvc/KSYLive_iOS/wiki/liveScene) to effectively enhance the live video quality;
1. 2016.09.07 Built-in [new beauty](https://github.com/ksvc/KSYLive_iOS/wiki/filter) on the line;
1. 2016.09.12 [kit class top-level code open source](https://github.com/ksvc/KSYLive_iOS/tree/master/source), podspec integrated framework will be changed to integrated static library
1. 2016.09.21 special effects filter on the line;
1. 2016.09.26 [double with wheat](https://github.com/ksvc/KSYDiversityLive_Android/tree/master/Agora) stable version on the line;
1. 2016.09.28 Video Hardcoding [Performance Encoding Mode](https://github.com/ksvc/KSYLive_iOS/wiki/liveScene) Go live. Audio AAC hard-coded features on the line. Network adaptive scene on the line;
1. 2016.10.19 Support [Live Streaming Dynamics](https://github.com/ksvc/KSYLive_iOS/wiki/dynamicOrientation);
1. 2016.10.20 Support [replaykit 屏 屏 流流](https://github.com/ksvc/KSYDiversityLive_iOS/tree/master/KSYReplayKit);
1. 2016.11.18 Support [Record as mp4 file while streaming](https://github.com/ksvc/KSYLive_iOS/wiki/bypassRecord)
1. 2016.2.22 Support [Dynamic Frame Rate](https://github.com/ksvc/KSYLive_iOS/wiki/dynamicFPS)
1. 2016.3.1 support anchor audio [Acquisition voice](http://ksvc.github.io/KSYLive_iOS/doc/html/Classes/KSYAUAudioCapture.html#//api/name/effectTyped)
1. 2017.3.14 Support [Stereo](https://github.com/ksvc/KSYLive_iOS/wiki/stereo) Streaming
1. 2017.5.16 Support [Graffiti streaming](https://github.com/ksvc/KSYLive_iOS/wiki/BrushStream)
1. 2017.7.7 Support [Desktop Recording, Live Streaming](https://github.com/ksvc/KSYAirStreamer_iOS)
1. 2017.7.7 Support [iOS 11 HEVC Streaming](https://github.com/ksvc/KSYLive_iOS/wiki/enableH265)
1. 2017.8.3 support to collect noise reduction

### 2.2 Recent work

1. 2017.03.xx multi-view live;
1. 2017.03.xx background noise reduction;

## 3. SDK integration methods introduced
### 3.1 System Requirements
* Minimum iOS version supported: iOS 7.0
* Minimum support iPhone model: iPhone 4
* Support CPU architecture: armv7, armv7s, arm64 (and i386, x86_64 emulator)
* Contains i386 and x86_64 emulator version of the library file, streaming function can not work on the simulator, playback fully support simulator.

### 3.2 download project
The SDK provides the following access methods:

#### 3.2.1 from [github](https://github.com/ksvc/KSYLive_iOS.git) clone

The directory structure is as follows:
- demo: The demo project is KSYLive, which demonstrates the use of the SDK's main interface
- doc / docset: appleDoc-style interface document, installed in xcode can see the method and properties of the document
- doc / html: AppleDoc-style web interface documentation, but also view the [online version](http://ksvc.github.io/KSYLive_iOS/doc/html/index.html)
- prebuilt: precompiled library header and library files
- source: Kit kit source code
- releaseFramework: Scripts and projects for packaging a precompiled library into an easy-to-integrate framework

```
$ git clone https://github.com/ksvc/KSYLive_iOS.git KSYLive_iOS --depth 1
```

#### 3.2.2 From [bitbucket](https://bitbucket.org/ksvc/ksylive_ios.git) clone

For some places to visit slower github circumstances, you can get from the bitbucket clone library content and github consistent.
```
$ git clone https://bitbucket.org/ksvc/ksylive_ios.git --depth 1
```

#### 3.2.3 Install using Cocoapods
By using Cocoapods, you can download the static library and code of this SDK locally just by adding a sentence similar to the following sentence to your Podfile:

```ruby
pod 'libksygpulive / KSYGPUResource'
pod 'libksygpulive / libksygpulive'
```

POD install can be implemented.

Among them, the first paragraph libksygpulive SDK name, the second paragraph KSYGPUResource and libksygpulive sub-module name

This SDK provides a number of different sub-modules to meet the needs of different users:
* KSYMediaPlayer: for broadcast live kernel (support for streamlined format)
* KSYMediaPlayer_vod: for on-demand playback kernel (rich format support)
* libksygpulive: SDK for live streaming and playback (Streaming Streaming and Streaming SDK)
* libksygpulive_265: SDK for Streaming and Playback on Streaming (supports Streaming and Streaming SDKs)
* KSYGPUResource: streaming media resources used in the main file, mainly for beauty and special effects filters

<details>
<summary> Pod Dependencies </summary>
<b markdown = 1>
  
* Local development version (sdk clone or download to the local)

```
pod 'libksygpulive / libksygpulive',: path => '../'
```

* Directly specify the SDK's github repository address and version number

```
pod 'libksygpulive / libksygpulive',: git => 'https://github.com/ksvc/KSYLive_iOS.git' ,: tag => 'v1.8.0'
```

Get spec from cocoapod official library trunk, download sdk from github

```
pod 'libksygpulive / libksygpulive'
```

* Get spec from cocoapod official library Trunk, download sdk from Kingsoft cloud storage ks3 (domestic speed is faster)

```
pod 'libksygpulive_ks3 / libksygpulive'
```

* If pod install can not find the prompt of specification, please update repo first

```
pod repo update
```

* **Note 1**: The above statements can not be added to the Podfile, their role is the same, but Podspec read different locations.

</b>
</details>

### 3.2.4 GPUImage Dependencies

Please refer to [GPUImage](https://github.com/BradLarson/GPUImage/releases/tag/0.1.7) provided by the official cocoapods. The current version of our test is [0.1.7](https: // github. com / BradLarson / GPUImage / releases / tag / 0.1.7)

### 3.3 to start the demo project
!!!!! Note: Here are two ways to run the demo, but only one alternative; If you want to change another method, please re-download or decompression, or restore git repository before trying. !!!!!

#### 3.3.1 Use Cocoapod to run demo
There is already a Podfile in the demo directory that specifies the local development version of the pod
In the demo directory, execute the following command, you can start to compile and run the demo
```
$ cd demo
$ pod install
$ open KSYLiveDemo.xcworkspace
```

note:
After updating the pod, you need to open xcwrokspace instead of xcodeproj

#### 3.3.2 manually compile the framework to generate dependencies to run the demo
* SDK package as framework

Unzip the archive (or clone successfully), enter the releaseFramework directory, download the dependencies via release-libKSYLive.sh and package out the framework, generated to KSYLive_iOS / framework / static directory.
```
$ cd releaseFramework
$ ./release-libKSYLive.sh libksygpulive lite
$ ls ../framework/static
Bugly.framework GPUImage.framework libksygpulive.framework
```
Please refer to the help of the script release-libKSYLive.sh (./release-libKSYLive.sh -h) or [Dynamic Library Point 4] for details on the parameters (https://github.com/ksvc/KSYLive_iOS/wiki/dylib ).

> Bugly.framework is to collect the demo's crash letter
#### 3.3.2 manually compile the framework to generate dependencies to run the demo
* SDK package as framework

Unzip the archive (or clone successfully), enter the releaseFramework directory, download the dependencies via release-libKSYLive.sh and package out the framework, generated to KSYLive_iOS / framework / static directory.
```
$ cd releaseFramework
$ ./release-libKSYLive.sh libksygpulive lite
$ ls ../framework/static
Bugly.framework GPUImage.framework libksygpulive.framework
```
Please refer to the help of the script release-libKSYLive.sh (./release-libKSYLive.sh -h) or [Dynamic Library Point 4] for details on the parameters (https://github.com/ksvc/KSYLive_iOS/wiki/dylib ).

> Bugly.framework is used to collect demo crashes (used in demo only) Bugs are not dependent on integrating the SDK into user projects.

* Add library dependencies to demo

Open the demo directory KSYLiveDemo.xcodeproj, modify the configuration file of the KSYLiveDemo project:
Select KSYLiveDemo project -> select Project KSYLiveDemo-> select Info tab -> select Configurations-> Debug or Release-> to KSYLiveDemo respectively select the corresponding KSYLiveDemo-framework.xcconfig file. Note that if using a dynamic library, select KSYLiveDemo-dy-framework.xcconfig.

![xcode_configs](https://github.com/ksvc/KSYLive_iOS/wiki/images/xcode_configs.png)

Or manually add the following parameters in the project configuration: (For details, see KSYLiveDemo-framework.xcconfig in the demo directory)
```
OTHER_LDFLAGS = $ (inherited) -ObjC -all_load -framework libksygpulive -framework GPUImage -framework Bugly -lstdc ++. 6 -lz
FRAMEWORK_SEARCH_PATHS = $ (inherited) ../framework/ ../framework/static
```
The above is the integration method of the static library. For the configuration and usage of the dynamic library, please refer to the content of [Dynamic Library](https://github.com/ksvc/KSYLive_iOS/wiki/dylib) in the Wiki.
### 3.4 Add header files to the files that need to use this SDK
```
#import <GPUImage / GPUImage.h>
#import <libksygpulive / KSYGPUStreamerKit.h>
```
The above two header files need to be introduced:
* GPUImage.h because of reliance on third-party framework needs to be introduced
* KSYGPUStreamerKit.h is open top kit class kit class can be used directly, you can also modify

* When you need to customize GPUImage, the version of GPUImage is 0.1.7

### 3.5 SDK version number query
The SDK version number mainly through the core class query
```
NSLog (@ "version:% @", [streamerBase getKSYVersion]);
NSLog (@ "version:% @", [kit getKSYVersion]);
```

### 3.6 Precautions when integrating
* This framework already includes [Play SDK](https://github.com/ksvc/KSYMediaPlayer_iOS.git)
And will have a conflict with the playback SDK, before integration, please ensure that the previously integrated KSY playback SDK is removed
* This framework may conflict with other static libraries that use FFmpeg (conflict may consider using dynamic libraries)
* This framework is a static library, although the size of the library is 20M +, but after the last link, the increment of the app is only 5M +
* If you use the cocoapod official library Trunk and found that you can not find the latest version of the library, you need to execute the following command to update the spec library
```
pod repo update
```

## 4. reference documents
* [iOS Streaming SDK User Guide](https://github.com/ksvc/KSYLive_iOS/wiki/KSYStreamerSDKUserManual)
* [iOS Live Streaming SDK Frequently Asked Questions](https://github.com/ksvc/KSYLive_iOS/wiki/FAQ)
* [Interface Change History](https://github.com/ksvc/KSYLive_iOS/wiki/apiAdjust)

## 5. player usage examples
See the github library at https://github.com/ksvc/KSYMediaPlayer_iOS.git

## 6. Feedback and suggestions
### 6.1 Feedback Template


| Type | Description |
|: ---: |: ---: |
| SDK Name | KSYLive_iOS |
| SDK Version | v2.5.0 |
| Equipment model | iphone7 |
| OS Version | iOS 10 |
| Problem Description | Description of the problem |
| Description of Operation | Describes what went wrong with this operation |
| Extra Attachments | Textual Forms Console log, crash reports, other ancillary information (screen shots or videos, etc.) |


### 6.2 Contact information
* Homepage: [Jinshan cloud](http://www.ksyun.com/)
* E-mail: <zengfanping@kingsoft.com>
* QQ discussion group:
    * 574179720 [video cloud technology exchange group]
    * 621137661 [video cloud iOS technology exchange]
    * Add more than one QQ group can be
    
* Issues: <https://github.com/ksvc/KSYLive_iOS/issues>

<a href="http://www.ksyun.com/"> <img src = "https://raw.githubusercontent.com/wiki/ksvc/KSYLive_Android/images/logo.png" border = "0" alt = "Jinshan cloud computing" /> </a>

[libksygpulive]: https://github.com/ksvc/KSYLive_iOS
[ksyun]: https://www.ksyun.com/about/aboutcontact
[wiki]: https://github.com/ksvc/KSYLive_iOS/wiki

[cocoapods_url]: http://cocoapods.org/pods/libksygpulive
[cocoapods_url_ks3]: http://cocoapods.org/pods/libksygpulive_ks3
[badge_at]: https://img.shields.io/cocoapods/at/libksygpulive.svg?label=Apps%20Using%20libksygpulive&colorB=28B9FE
[badge_dt]: https://img.shields.io/cocoapods/dt/libksygpulive.svg?label=Total%20Downloads%20libksygpulive&colorB=28B9FE
[badge_at_ks3]: https://img.shields.io/cocoapods/at/libksygpulive_ks3.svg?label=Apps%20Using%20libksygpulive_ks3&colorB=28B9FE
[badge_dt_ks3]: https://img.shields.io/cocoapods/dt/libksygpulive_ks3.svg?label=Total%20Downloads%20libksygpulive_ks3&colorB=28B9FE
[github_release]: https://github.com/ksvc/KSYLive_iOS/releases/latest
