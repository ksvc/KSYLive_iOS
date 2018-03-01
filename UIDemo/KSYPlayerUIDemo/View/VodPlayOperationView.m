//
//  VodPlayOperationView.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/11.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "VodPlayOperationView.h"
#import "VodPlayControlView.h"
#import "DefinitionMenuView.h"
#import "SpeedChoiceView.h"
#import "VideoModel.h"
#import "UpdateVolumeAndBrightView.h"

@interface VodPlayOperationView ()
@property (nonatomic, strong) VodPlayControlView *playControlView;
@property (nonatomic, strong) UIButton           *backButton;
@property (nonatomic, strong) UIButton           *moreButton;
@property (nonatomic, strong) UIButton           *screenShotButton;
@property (nonatomic, strong) UIButton           *screenRecordButton;
@property (nonatomic, strong) UIView             *aBottomMaskView;
@property (nonatomic, strong) UIView             *aTopMaskView;
@property (nonatomic, strong) UIView             *aFullScreenMaskView;
@property (nonatomic, strong) UILabel            *videoTitleLab;
@property (nonatomic, strong) DefinitionMenuView *definitionMenuView;
@property (nonatomic, strong) SpeedChoiceView    *speedChoiceView;
@property (nonatomic, assign) BOOL hasHideProgress;
@property (nonatomic, assign) VCPlayHandlerState playState;
@property (nonatomic, assign) NSTimeInterval playedTime;
@property (nonatomic, strong) VideoModel *videoModel;
@property (nonatomic, copy)   void(^fullScreenBlock)(BOOL isFullScreen);
@property (nonatomic, strong) UpdateVolumeAndBrightView *volumeBrightControlView;
@end

@implementation VodPlayOperationView

- (instancetype)initWithFullScreenBlock:(void(^)(BOOL))fullScreenBlock
{
    if (self = [super init]) {
        _fullScreenBlock = fullScreenBlock;
        _fullScreen = NO;
        _totalPlayTime = 0;
        _playedTime = 0;
        _playState = VCPlayHandlerStatePause;
        [self setupUI];
    }
    return self;
}

- (void)configeVideoModel:(VideoModel *)videoModel {
    self.videoModel = videoModel;
    self.videoTitleLab.text = videoModel.VideoTitle;
}

#pragma mark --
#pragma mark -- UI metohd

- (void)setupUI {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aTapEv)];
    [self addGestureRecognizer:tap];
    
    [self addSubview:self.volumeBrightControlView];
    [self addSubview:self.aTopMaskView];
    [self addSubview:self.backButton];
    [self addSubview:self.moreButton];
    [self addSubview:self.screenShotButton];
    [self addSubview:self.screenRecordButton];
    [self addSubview:self.videoTitleLab];
    [self addSubview:self.aBottomMaskView];
    [self addSubview:self.playControlView];
    [self configeConstraints];
    self.aTopMaskView.hidden = YES;
    self.playControlView.hidden = YES;
    self.aBottomMaskView.hidden = YES;
    self.moreButton.hidden = YES;
    self.screenShotButton.hidden = YES;
    self.screenRecordButton.hidden = YES;
    self.videoTitleLab.hidden = YES;
}

- (UpdateVolumeAndBrightView *)volumeBrightControlView {
    if (!_volumeBrightControlView) {
        _volumeBrightControlView = [[UpdateVolumeAndBrightView alloc] init];
    }
    return _volumeBrightControlView;
}

- (VodPlayControlView *)playControlView {
    if (!_playControlView) {
        _playControlView = [[NSBundle mainBundle] loadNibNamed:@"VodPlayControlView" owner:self options:nil].firstObject;
        _playControlView.backgroundColor = [UIColor clearColor];
        [_playControlView.fullScreenButton addTarget:self action:@selector(fullScreenAction) forControlEvents:UIControlEventTouchUpInside];
        [_playControlView.pauseButton addTarget:self action:@selector(playStateHandler) forControlEvents:UIControlEventTouchUpInside];
        [_playControlView.playSlider addTarget:self action:@selector(sliderValueChangedHandler) forControlEvents:UIControlEventTouchUpInside];
        
        [_playControlView.nextButton addTarget:self action:@selector(nextButtonHandler) forControlEvents:UIControlEventTouchUpInside];
        [_playControlView.switchDefinitionButton addTarget:self action:@selector(switchDefinitionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playControlView;
}

- (UIView *)aBottomMaskView {
    if (!_aBottomMaskView) {
        _aBottomMaskView = [[UIView alloc] init];
        _aBottomMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    return _aBottomMaskView;
}

- (UIView *)aTopMaskView {
    if (!_aTopMaskView) {
        _aTopMaskView = [[UIView alloc] init];
        _aTopMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    return _aTopMaskView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        _backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    }
    return _backButton;
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (UIButton *)screenShotButton {
    if (!_screenShotButton) {
        _screenShotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_screenShotButton setImage:[UIImage imageNamed:@"screenShot"] forState:UIControlStateNormal];
        [_screenShotButton addTarget:self action:@selector(screenShotHandler) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenShotButton;
}

- (UIButton *)screenRecordButton {
    if (!_screenRecordButton) {
        _screenRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_screenRecordButton setImage:[UIImage imageNamed:@"screenRecord"] forState:UIControlStateNormal];
        [_screenRecordButton addTarget:self action:@selector(screenRecordHandler) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screenRecordButton;
}

- (UILabel *)videoTitleLab {
    if (!_videoTitleLab) {
        _videoTitleLab = [[UILabel alloc] init];
        _videoTitleLab.font = [UIFont systemFontOfSize:14];
        _videoTitleLab.textColor = [UIColor whiteColor];
        _videoTitleLab.textAlignment = NSTextAlignmentLeft;
    }
    return _videoTitleLab;
}

- (UIView *)aFullScreenMaskView {
    if (!_aFullScreenMaskView) {
        _aFullScreenMaskView = [[UIView alloc] init];
        _aFullScreenMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFullScreenMaskViewHandler)];
        [_aFullScreenMaskView addGestureRecognizer:tapGesture];
    }
    return _aFullScreenMaskView;
}

- (DefinitionMenuView *)definitionMenuView {
    if (!_definitionMenuView) {
        _definitionMenuView = [[NSBundle mainBundle] loadNibNamed:@"DefinitionMenuView" owner:self options:nil].firstObject;
        _definitionMenuView.backgroundColor = [UIColor clearColor];
        [_definitionMenuView.hightDefinitionButton addTarget:self action:@selector(hightDefinitionHandler) forControlEvents:UIControlEventTouchUpInside];
        [_definitionMenuView.superHighDefinitionButton addTarget:self action:@selector(superHighDefinitionHandler) forControlEvents:UIControlEventTouchUpInside];
        [_definitionMenuView.standardDefinitionButton addTarget:self action:@selector(standardDefinitionHandler) forControlEvents:UIControlEventTouchUpInside];
    }
    return _definitionMenuView;
}

- (SpeedChoiceView *)speedChoiceView {
    if (!_speedChoiceView) {
        _speedChoiceView = [[NSBundle mainBundle] loadNibNamed:@"SpeedChoiceView" owner:self options:nil].firstObject;
        _speedChoiceView.backgroundColor = [UIColor clearColor];
        [_speedChoiceView.oneSpeedButton addTarget:self action:@selector(oneSpeedHandler) forControlEvents:UIControlEventTouchUpInside];
        [_speedChoiceView.oneQuarterSpeedButton addTarget:self action:@selector(oneQuarterSpeedHandler) forControlEvents:UIControlEventTouchUpInside];
        [_speedChoiceView.oneHalfSpeedButton addTarget:self action:@selector(oneHalfSpeedHandler) forControlEvents:UIControlEventTouchUpInside];
        [_speedChoiceView.twoSpeedButton addTarget:self action:@selector(twoSpeedHandler) forControlEvents:UIControlEventTouchUpInside];
        [_speedChoiceView.unOpenButton addTarget:self action:@selector(unOpenHandler) forControlEvents:UIControlEventTouchUpInside];
        [_speedChoiceView.openButton addTarget:self action:@selector(openHandler) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speedChoiceView;
}

- (void)configeConstraints {
    [_volumeBrightControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.aTopMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self);
        make.height.mas_equalTo(57);
    }];
    [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self);
        make.width.height.mas_equalTo(60);
    }];
    [self.moreButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.equalTo(self);
        make.size.equalTo(self.backButton);
    }];
    [self.screenShotButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_trailing).offset(-6);
        make.bottom.equalTo(self.mas_centerY).offset(-20);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    [self.screenRecordButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_trailing).offset(-6);
        make.top.equalTo(self.mas_centerY).offset(20);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    [self.videoTitleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(31);
        make.centerY.equalTo(self.backButton);
    }];
    [self.aBottomMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    [self.playControlView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.aBottomMaskView);
    }];
}

- (void)updateConstraintsHandler {
    [self.aTopMaskView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_top);
    }];
    [self.backButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_top);
    }];
    [self.videoTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton).offset(-10);
    }];
    [self.aBottomMaskView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom);
    }];
    [self.playControlView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.top.equalTo(self.mas_bottom);
        make.height.mas_equalTo(50);
    }];
}

#pragma mark --
#pragma mark -- private handler method

- (void)playStateHandler {
    if (self.playStateBlock) {
        self.playStateBlock(_playState);
        if (_playState == VCPlayHandlerStatePause) {
            self.playState = VCPlayHandlerStatePlay;
            self.playControlView.pauseButton.selected = YES;
        } else {
            self.playState = VCPlayHandlerStatePause;
            self.playControlView.pauseButton.selected = NO;
        }
    }
}

- (void)fullScreenAction {
    if (self.fullScreenBlock) {
        self.fullScreenBlock(YES);
        self.aTopMaskView.hidden = NO;
    }
}

- (void)aTapEv {
    self.userInteractionEnabled = NO;
    if (self.isFullScreen) {
        if (self.hasHideProgress) {
            [self configeConstraints];
            [UIView animateWithDuration:0.2 animations:^{
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.userInteractionEnabled = YES;
                self.hasHideProgress = NO;
            }];
        } else {
            [self updateConstraintsHandler];
            [UIView animateWithDuration:0.2 animations:^{
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.userInteractionEnabled = YES;
                self.hasHideProgress = YES;
            }];
        }
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.playControlView.hidden = !self.playControlView.hidden;
            self.aBottomMaskView.hidden = !self.aBottomMaskView.hidden;
            self.userInteractionEnabled = YES;
        });
    }
}

- (void)backAction {
    if (self.isFullScreen) {
        if (self.fullScreenBlock) {
            self.fullScreenBlock(NO);
            self.aTopMaskView.hidden = YES;
        }
    } else {
        UIViewController *controller = nil;
        for (UIView *view = self; view; view = view.superview) {
            UIResponder *nextResponder = [view nextResponder];
            if ([nextResponder isKindOfClass:[UIViewController class]]) {
                controller = (UIViewController *)nextResponder;
                if ([controller isKindOfClass:[UINavigationController class]]) {
                    break;
                }
            }
        }
        if ([controller isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)controller popViewControllerAnimated:YES];
        } else {
            [controller.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)moreAction {
    [self addSubview:self.aFullScreenMaskView];
    [self addSubview:self.speedChoiceView];
    [self.aFullScreenMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.speedChoiceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(66 + 52 + 41*4 + 45*3, 100));
        make.center.equalTo(self);
    }];
}

- (void)screenShotHandler {
    if (self.screenShotBlock) {
        self.screenShotBlock();
    }
}

- (void)screenRecordHandler {
    [self enterRecordState];
    if (self.screenRecordeBlock) {
        self.screenRecordeBlock();
    }
}

- (void)enterRecordState {
    
}

- (NSString *)convertToMinutes:(NSTimeInterval)seconds {
    NSString *timeStr = [NSString stringWithFormat:@"%02d:%02d", (int)seconds / 60, (int)seconds % 60];
    return timeStr;
}

- (void)setFullScreen:(BOOL)fullScreen {
    _fullScreen = fullScreen;
    [self.playControlView screenRotateHandler:fullScreen];
    if (!fullScreen) {
        [self tapFullScreenMaskViewHandler];
    }
    self.aTopMaskView.hidden = !fullScreen;
    self.videoTitleLab.hidden = !fullScreen;
    self.moreButton.hidden = !fullScreen;
    self.screenShotButton.hidden = !fullScreen;
    self.screenRecordButton.hidden = !fullScreen;
}

- (void)switchDefinitionButtonClicked {
    [self addSubview:self.aFullScreenMaskView];
    [self addSubview:self.definitionMenuView];
    [self.aFullScreenMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.definitionMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(109, 190));
        make.center.equalTo(self);
    }];
    VideoDefinitionType definition = self.videoModel.definitation.integerValue;
    [self.definitionMenuView definitationButtonColorHandler:definition];
    if (self.videoModel.PlayURL.count < 3) {
        _definitionMenuView.superHighDefinitionButton.enabled = NO;
        _definitionMenuView.superHighDefinitionButton.hidden = YES;
    } else {
        _definitionMenuView.superHighDefinitionButton.hidden = NO;
        _definitionMenuView.superHighDefinitionButton.enabled = YES;
    }
}

- (void)nextButtonHandler {
    if (self.nextButtonBLock) {
        self.nextButtonBLock();
    }
}

- (void)sliderValueChangedHandler {
    if (self.dragSliderBlock) {
        self.dragSliderBlock(self.playControlView.playSlider.value);
    }
}

- (void)tapFullScreenMaskViewHandler {
    [self.aFullScreenMaskView removeFromSuperview];
    [self.definitionMenuView removeFromSuperview];
    [self.speedChoiceView removeFromSuperview];
}

- (void)superHighDefinitionHandler {
    if (self.definitionChoiceBlock) {
        self.definitionChoiceBlock(VideoDefinitionTypeSuper);
    }
    [self tapFullScreenMaskViewHandler];
    [self.playControlView.switchDefinitionButton setTitle:@"超高清" forState:UIControlStateNormal];
}

- (void)hightDefinitionHandler {
    if (self.definitionChoiceBlock) {
        self.definitionChoiceBlock(VideoDefinitionTypeHigh);
    }
    [self tapFullScreenMaskViewHandler];
    [self.playControlView.switchDefinitionButton setTitle:@"高清" forState:UIControlStateNormal];
}

- (void)standardDefinitionHandler {
    if (self.definitionChoiceBlock) {
        self.definitionChoiceBlock(VideoDefinitionTypeStandard);
    }
    [self tapFullScreenMaskViewHandler];
    [self.playControlView.switchDefinitionButton setTitle:@"标清" forState:UIControlStateNormal];
}

- (void)oneSpeedHandler {
    if (self.speedChoiceBlock) {
        self.speedChoiceBlock(1.0);
    }
    [self.speedChoiceView speedButtonColorHandler:1.0];
}

- (void)oneQuarterSpeedHandler {
    if (self.speedChoiceBlock) {
        self.speedChoiceBlock(1.25);
    }
    [self.speedChoiceView speedButtonColorHandler:1.25];
}

- (void)oneHalfSpeedHandler {
    if (self.speedChoiceBlock) {
        self.speedChoiceBlock(1.5);
    }
    [self.speedChoiceView speedButtonColorHandler:1.5];
}

- (void)twoSpeedHandler {
    if (self.speedChoiceBlock) {
        self.speedChoiceBlock(2.0);
    }
    [self.speedChoiceView speedButtonColorHandler:2.0];
}

- (void)unOpenHandler {
    //    [self oneSpeedHandler];
    //    [self.speedChoiceView speedButtonEnableHandler:NO];
}

- (void)openHandler {
    //    [self.speedChoiceView speedButtonEnableHandler:YES];
}

#pragma mark --
#pragma mark -- public method

- (void)updatePlayedTime:(NSTimeInterval)playedTime {
    self.playControlView.playedTimeLab.text = [self convertToMinutes:playedTime];
    float sliderValue = 0;
    if (self.totalPlayTime > 0) {
        sliderValue = playedTime / self.totalPlayTime;
    }
    [self.playControlView.playSlider setValue:sliderValue];
}

- (void)updateTotalPlayTime:(NSTimeInterval)totalPlayTime {
    self.totalPlayTime = totalPlayTime;
    self.playControlView.hidden = NO;
    self.aBottomMaskView.hidden = NO;
    self.playControlView.totalPlayTimeLab.text = [self convertToMinutes:totalPlayTime];
}

- (void)suspendHandler {
    self.backButton.hidden = YES;
    self.playControlView.hidden = YES;
    self.aBottomMaskView.hidden = YES;
    self.userInteractionEnabled = NO;
}

- (void)recoveryHandler {
    self.backButton.hidden = NO;
    self.playControlView.hidden = NO;
    self.aBottomMaskView.hidden = NO;
    self.userInteractionEnabled = YES;
}
@end
