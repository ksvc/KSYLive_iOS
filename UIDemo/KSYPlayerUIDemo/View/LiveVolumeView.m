//
//  LiveVolumeView.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/13.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "LiveVolumeView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIColor+Additions.h"

@interface LiveVolumeView ()
@property (nonatomic, strong) UISlider     *volumeSlider;
@property (nonatomic, strong) UISlider     *dragSlider;
@property (nonatomic, strong) MPVolumeView *volumeView;
@end

@implementation LiveVolumeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.volumeView.showsRouteButton = NO;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aTapEv)];
    [self addGestureRecognizer:tap];
    [self addSubview:self.dragSlider];
    [self configeConstraints];
}

- (void)aTapEv {}

- (MPVolumeView *)volumeView {
    if (_volumeView == nil) {
        _volumeView  = [[MPVolumeView alloc] initWithFrame:CGRectZero];
        for (UIView *view in [_volumeView subviews]) {
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
                self.volumeSlider = (UISlider*)view;
                break;
            }
        }
    }
    return _volumeView;
}

- (UISlider *)dragSlider {
    if (!_dragSlider) {
        _dragSlider = [[UISlider alloc] init];
        _dragSlider.minimumValue = self.volumeSlider.minimumValue;
        _dragSlider.maximumValue = self.volumeSlider.maximumValue;
        _dragSlider.value = self.volumeSlider.value;
        _dragSlider.minimumTrackTintColor = [UIColor whiteColor];
        _dragSlider.maximumTrackTintColor = [UIColor colorWithHexString:@"#1D1D1F"];
        [_dragSlider addTarget:self action:@selector(dragSliderValueChangedEvent) forControlEvents:UIControlEventValueChanged];
    }
    return _dragSlider;
}

- (void)dragSliderValueChangedEvent {
    self.volumeSlider.value = self.dragSlider.value;
}

- (void)configeConstraints {
    [self.dragSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.leading.mas_equalTo(15);
    }];
}

@end
