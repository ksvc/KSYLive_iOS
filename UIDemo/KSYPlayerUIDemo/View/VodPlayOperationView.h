//
//  VodPlayOperationView.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/11.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "BaseView.h"

@class VideoModel;

@interface VodPlayOperationView : BaseView

@property (nonatomic, assign, getter=isFullScreen) BOOL  fullScreen;

@property (nonatomic, assign) NSTimeInterval totalPlayTime;

@property (nonatomic, copy) void(^playStateBlock)(VCPlayHandlerState);
@property (nonatomic, copy) void(^dragSliderBlock)(float progress);
@property (nonatomic, copy) void(^nextButtonBLock)(void);
@property (nonatomic, copy) void(^definitionChoiceBlock)(VideoDefinitionType definition);
@property (nonatomic, copy) void(^speedChoiceBlock)(float speed);
@property (nonatomic, copy) void(^screenShotBlock)(void);
@property (nonatomic, copy) void(^screenRecordeBlock)(void);

- (instancetype)initWithFullScreenBlock:(void(^)(BOOL))fullScreenBlock;

- (void)configeVideoModel:(VideoModel *)videoModel;

- (void)updatePlayedTime:(NSTimeInterval)playedTime;

- (void)updateTotalPlayTime:(NSTimeInterval)totalPlayTime;

- (void)suspendHandler;

- (void)recoveryHandler;

@end
