//
//  KSYPlayerSubtitleView.h
//  KSYGPUStreamerDemo
//
//  Created by 施雪梅 on 17/7/12.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYUIView.h"

@interface KSYPlayerSubtitleView: KSYUIView

@property KSYNameSlider *sliderFontSize;                            ///字体大小

@property UISegmentedControl *segSubtitle;

@property (nonatomic, copy) void(^fontColorBlock)(UIColor *fontColor);

@property (nonatomic, copy) void(^fontBlock)(NSString *font);

@property (nonatomic, copy) void(^subtitleFileSelectedBlock)(NSString *subtitleFilePath);

@property (nonatomic, copy) void(^closeSubtitleBlock)();

@property (nonatomic, copy) void(^subtitleNumBlock)();

@property (nonatomic, readwrite) NSInteger subtitleNum;

@property (nonatomic, readwrite) NSInteger selectedSubtitleIndex;

@end
