//
//  libksystreamerengine.h
//  libksystreamerengine.h
//
//  Copyright (c) 2016 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GPUImage/GPUImage.h>

// sources (player & capture)
#import "KSYGPUPicInput.h"
#import "KSYGPUCamera.h"
#import "AVAudioSession+KSY.h"
#import "KSYAVAudioSession.h"
#import "KSYBgmPlayer.h"
#import "KSYBgmReader.h"
#import "KSYAQPlayer.h"
#import "KSYAUAudioCapture.h"
#import "KSYDummyAudioSource.h"
#import "KSYAVFCapture.h"
// mixer
#import "KSYGPUPicMixer.h"
#import "KSYAudioMixer.h"
// streamer
#import "KSYGPUPicOutput.h"


#define KSYSTREAMERENGINE_VER 2.3.0
#define KSYSTREAMERENGINE_ID 72c540022458bc0e64e402bde54f59f0bffed1bd
