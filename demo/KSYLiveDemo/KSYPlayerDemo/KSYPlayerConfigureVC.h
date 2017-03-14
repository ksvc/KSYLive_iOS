//
//  KSYPlayerConfigureVC.h
//  KSYPlayerDemo
//
//  Created by mayudong on 2017/3/3.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libksygpulive/KSYMoviePlayerController.h>

typedef struct PlayerConfigure
{
    MPMovieVideoDecoderMode decodeMode;
    MPMovieVideoDeinterlaceMode deinterlaceMode;
    BOOL bAudioInterrupt;
    BOOL bLoop;
    int connectTimeout;
    int readTimeout;
    double bufferTimeMax;
    int bufferSizeMax;
}PlayerConfigure;

typedef void(^ConfirmBlock)(PlayerConfigure newConfig);
typedef void(^CancelBlock)();

@interface KSYPlayerConfigureVC : UIViewController

-(instancetype) initWithConfig:(PlayerConfigure)config confirm:(ConfirmBlock)confirm;

@end
