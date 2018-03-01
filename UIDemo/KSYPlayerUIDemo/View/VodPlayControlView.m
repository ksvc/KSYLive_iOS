//
//  VodPlayControlView.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/24.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "VodPlayControlView.h"
#import "Masonry.h"
#import "UIColor+Additions.h"

@implementation VodPlayControlView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.playSlider.minimumTrackTintColor = [UIColor colorWithHexString:@"FC3252"];
    self.playSlider.thumbTintColor = [UIColor colorWithHexString:@"FC3252"];
}

- (void)screenRotateHandler:(BOOL)fullScreen {
    if (fullScreen) {
        [self fullScreenHandler];
    } else {
        [self portraitScreenHandler];
    }
}

- (void)fullScreenHandler {
    self.nextButton.hidden = NO;
    self.switchDefinitionButton.hidden = NO;
    self.fullScreenButton.hidden = YES;
    [self.nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pauseButton.mas_right).offset(6);
        make.centerY.equalTo(self.pauseButton);
        make.size.mas_equalTo(CGSizeMake(40, 30));
    }];
    [self.playedTimeLab mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.nextButton.mas_right).offset(6);
        make.left.equalTo(self.pauseButton.mas_right).offset(52);
        make.centerY.equalTo(self.nextButton);
    }];
    [self.switchDefinitionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.fullScreenButton);
    }];
}

- (void)portraitScreenHandler {
    self.nextButton.hidden = YES;
    self.switchDefinitionButton.hidden = YES;
    self.fullScreenButton.hidden = NO;
    [self.playedTimeLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pauseButton.mas_right).offset(6);
        make.centerY.equalTo(self.pauseButton);
    }];
}

@end
