//
//  KSYProgressView.m
//  KSYPlayerDemo
//
//  Created by isExist on 16/8/30.
//  Copyright © 2016年 kingsoft. All rights reserved.
//

#import "KSYProgressView.h"

static const CGFloat        kBoundsMargin = 2.f;
static const CGFloat        kTimeLabelWidth = 30.f;
static const CGFloat        kTimeLabelHight = 10.f;
static NSString *           kNullTimeLabelText = @"--:--";
static NSString *           kFontName = @"Helvetica";

@interface KSYProgressView ()

@property (nonatomic, strong) UISlider *        slider;
@property (nonatomic, strong) UIProgressView *  progressView;
@property (nonatomic, strong) UILabel *         playedTimeLabel;
@property (nonatomic, strong) UILabel *         unplayedTimeLabel;

@end

@implementation KSYProgressView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.trackTintColor = [UIColor lightGrayColor];
        _progressView.progressTintColor = [UIColor darkGrayColor];
        [self addSubview:_progressView];
        
        _slider = [[UISlider alloc] init];
        _slider.maximumTrackTintColor = [UIColor clearColor];
        _slider.minimumValue = 0.f;
        _slider.maximumValue = 1.f;
        [self addSubview:_slider];
        
        _playedTimeLabel = [self addTimeLabel];
        
        _unplayedTimeLabel = [self addTimeLabel];
        
        [self addObserver:self forKeyPath:@"cacheProgress" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"playProgress" options:NSKeyValueObservingOptionNew context:nil];
        
        [_slider addTarget:self action:@selector(dragSliderDidEnd) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"cacheProgress"];
    [self removeObserver:self forKeyPath:@"playProgress"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"cacheProgress"]) {
        [_progressView setProgress:self.cacheProgress animated:YES];
    }
    if ([keyPath isEqualToString:@"playProgress"]) {
        [_slider setValue:self.playProgress animated:YES];
        _playedTimeLabel.text = [self convertToMinutes:_totalTimeInSeconds * _playProgress];
        _unplayedTimeLabel.text = [self convertToMinutes:_totalTimeInSeconds * (1- _playProgress)];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor colorWithRed:.5f green:.5f blue:.5f alpha:1.f];
    
    _playedTimeLabel.frame = CGRectMake(0,
                                        (self.bounds.size.height - kTimeLabelHight) / 2,
                                        kTimeLabelWidth,
                                        kTimeLabelHight);
    
    _unplayedTimeLabel.frame = CGRectMake(self.bounds.size.width - kTimeLabelWidth,
                                          (self.bounds.size.height - kTimeLabelHight) / 2,
                                          kTimeLabelWidth,
                                          kTimeLabelHight);
    
    CGRect progressAreaFrame = CGRectMake(kTimeLabelWidth, 0, self.bounds.size.width - 2 * kTimeLabelWidth, self.bounds.size.height);
    
    _progressView.frame = CGRectMake(progressAreaFrame.origin.x + kBoundsMargin,
                                     progressAreaFrame.size.height / 2 - kBoundsMargin / 2,
                                     progressAreaFrame.size.width - 2 * kBoundsMargin,
                                     progressAreaFrame.size.height);
    
    _slider.frame = progressAreaFrame;
}

- (void)dragSliderDidEnd {
    self.dragingSliderCallback(_slider.value);
}

- (NSString *)convertToMinutes:(float)seconds {
    NSString *timeStr = [NSString stringWithFormat:@"%02d:%02d", (int)seconds / 60, (int)seconds % 60];
    return timeStr;
}

- (UILabel *)addTimeLabel {
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = [UIFont fontWithName:kFontName size:10];
    timeLabel.text = kNullTimeLabelText;
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:timeLabel];
    
    return timeLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
