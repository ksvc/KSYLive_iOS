//
//  libksylive.h
//  libksylive
//
//  Created by yiqian on 11/3/15.
//  Copyright (c) 2015 kingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for libksylive.
FOUNDATION_EXPORT double libqyliveVersionNumber;

//! Project version string for libksylive.
FOUNDATION_EXPORT const unsigned char libqyliveVersionString[];

@class GPUImageOutput;

// streamer
#import "KSYTypeDef.h"
#import "KSYStreamerBase.h"
#import "KSYGPUStreamer.h"
#import "KSYAudioMixer.h"
#import "KSYAUAudioCapture.h"
#import "KSYBgmPlayer.h"

#import "KSYGPUStreamerKit.h"
// player
#import "KSYMediaPlayer.h"
#import "KSYMicMonitor.h"
#import "KSYAudioReverb.h"
#import "KSYMovieWriter.h"
#import "KSYAVMuxer.h"

//prober
#import "KSYMediaInfoProber.h"
