//
//  KSYPlayerPicView.m
//
//  Created by 施雪梅 on 17/7/12.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYPlayerPicView.h"

@interface KSYPlayerPicView(){
    UILabel *_labelContenMode;
    UILabel *_labelRotate;
    UILabel *_labelMirror;
    UIButton *_btnShotScreen;
}
@end

@implementation KSYPlayerPicView

- (id)init{
    self = [super init];
    
    [self setupUI];
    return self;
}

- (void) setupUI {
    _labelContenMode = [self addLable:@"填充模式"];
    _segContentMode = [self addSegCtrlWithItems:@[@"无", @"同比", @"裁剪", @"满屏"]];
    
    _labelRotate = [self addLable:@"旋转"];
    _segRotate = [self addSegCtrlWithItems:@[@"0", @"90", @"180", @"270"]];
    
    _labelMirror = [self addLable:@"镜像"];
    _segMirror = [self addSegCtrlWithItems:@[@"正向", @"反向"]];
    
    _btnShotScreen = [self addButton:@"截图"];
    [self layoutUI];
}

- (void)layoutUI{
    [super layoutUI];
    self.yPos = 0;
    
    [self putLable:_labelContenMode andView:_segContentMode];
    [self putLable:_labelRotate andView:_segRotate];
    [self putLable:_labelMirror andView:_segMirror];
    [self putRow1:_btnShotScreen];
}

@synthesize contentMode = _contentMode;
- (MPMovieScalingMode) contentMode{
    MPMovieScalingMode mode = MPMovieScalingModeNone;
    switch(_segContentMode.selectedSegmentIndex) {
        case 0:
            mode = MPMovieScalingModeNone;
            break;
        case 1:
            mode = MPMovieScalingModeAspectFit;
            break;
        case 2:
            mode = MPMovieScalingModeAspectFill;
            break;
        case 3:
            mode = MPMovieScalingModeFill;
            break;
        default:
            return  MPMovieScalingModeNone;
            break;
    }
    return mode;
}

- (void) setContentMode:(MPMovieScalingMode)contentMode{
    _contentMode = contentMode;
    _segContentMode.selectedSegmentIndex = (contentMode - MPMovieScalingModeNone);
}


@synthesize rotateDegress = _rotateDegress;
- (int) rotateDegress{
    return (int)_segRotate.selectedSegmentIndex * 90;
}

@synthesize bMirror = _bMirror;
- (BOOL)bMirror{
    return (BOOL)_segMirror.selectedSegmentIndex;
}

@end
