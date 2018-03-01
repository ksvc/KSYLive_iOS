//
//  LivePlayOperationView.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/12.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "BaseView.h"

@class VideoModel;

@interface LivePlayOperationView : BaseView

@property (nonatomic, assign, getter=isFullScreen) BOOL  fullScreen;

@property (nonatomic, copy) void(^playStateBlock)(VCPlayHandlerState);
@property (nonatomic, copy) void(^screenShotBlock)(void);
@property (nonatomic, copy) void(^screenRecordeBlock)(void);
@property (nonatomic, copy) void(^mirrorBlock)(void);
@property (nonatomic, copy) void(^pictureRotateBlock)(void);

- (instancetype)initWithVideoModel:(VideoModel *)videoModel FullScreenBlock:(void(^)(BOOL))fullScreenBlock;

- (void)configeWithVideoModel:(VideoModel *)videoModel;

- (void)recoveryHandler;

- (void)suspendHandler;

@end
