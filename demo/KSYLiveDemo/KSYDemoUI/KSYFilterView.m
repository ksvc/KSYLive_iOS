//
//  KSYFilterView.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/24.
//  Copyright © 2016年 ksyun. All rights reserved.
//
#import <GPUImage/GPUImage.h>
#import "KSYFilterView.h"
#import "KSYNameSlider.h"
#import "KSYPresetCfgView.h"


@interface KSYFilterView() {
    UILabel * _lblSeg;
    NSInteger _curIdx;
    NSArray * _effectNames;
    NSInteger _curEffectIdx;
}

@property (nonatomic) UILabel * lbPrevewFlip;
@property (nonatomic) UILabel * lbStreamFlip;

@property (nonatomic) UILabel * lbUiRotate;
@property (nonatomic) UILabel * lbStrRotate;
@end

@implementation KSYFilterView

- (id)init{
    self = [super init];
    _effectNames = [NSArray arrayWithObjects: @"1 小清新",  @"2 靓丽",
                    @"3 甜美可人",  @"4 怀旧",  @"5 蓝调",  @"6 老照片" , nil];
    _curEffectIdx = 1;
    // 修改美颜参数
    _filterParam1 = [self addSliderName:@"参数" From:0 To:100 Init:50];
    _filterParam2 = [self addSliderName:@"美白" From:0 To:100 Init:50];
    _filterParam3 = [self addSliderName:@"红润" From:0 To:100 Init:50];
    _filterParam2.hidden = YES;
    _filterParam3.hidden = YES;
    
    _lblSeg = [self addLable:@"滤镜"];
    _filterGroupType = [self addSegCtrlWithItems:
  @[ @"关",
     @"旧美颜",
     @"金山美颜",
     @"红润美颜",
     @"美颜特效",
     ]];
    _filterGroupType.selectedSegmentIndex = 1;
    [self selectFilter:1];
    
    _lbPrevewFlip = [self addLable:@"预览镜像"];
    _lbStreamFlip = [self addLable:@"推流镜像"];
    _swPrevewFlip = [self addSwitch:NO];
    _swStreamFlip = [self addSwitch:NO];
    
    _lbUiRotate   = [self addLable:@"UI旋转"];
    _lbStrRotate  = [self addLable:@"推流旋转"];
    _swUiRotate   = [self addSwitch:NO];
    _swStrRotate  = [self addSwitch:NO];
    _swStrRotate.enabled = NO;
    
    _effectPicker = [[UIPickerView alloc] init];
    [self addSubview: _effectPicker];
    _effectPicker.hidden     = YES;
    _effectPicker.delegate   = self;
    _effectPicker.dataSource = self;
    _effectPicker.showsSelectionIndicator= YES;
    _effectPicker.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    return self;
}
- (void)layoutUI{
    [super layoutUI];
    self.yPos = 0;
    [self putRow: @[_lbPrevewFlip, _swPrevewFlip,
                    _lbStreamFlip, _swStreamFlip ]];
    [self putRow: @[_lbUiRotate, _swUiRotate,
                    _lbStrRotate, _swStrRotate ]];
    [self putLable:_lblSeg andView: _filterGroupType];
    CGFloat paramYPos = self.yPos;
    if ( self.width > self.height){
        self.winWdt /= 2;
    }
    [self putRow1:_filterParam1];
    [self putRow1:_filterParam2];
    [self putRow1:_filterParam3];
    
    if ( self.width > self.height){
        _effectPicker.frame = CGRectMake( self.winWdt, paramYPos, self.winWdt, 162);
    }
    else {
        self.btnH = 162;
        [self putRow1:_effectPicker];
    }
}

- (IBAction)onSwitch:(id)sender {
    if (sender == _swUiRotate){
        // 只有界面跟随设备旋转, 推流才能旋转
        _swStrRotate.enabled = _swUiRotate.on;
        if (!_swUiRotate.on) {
            _swStrRotate.on = NO;
        }
    }
    [super onSwitch:sender];
}

- (IBAction)onSegCtrl:(id)sender {
    if (_filterGroupType == sender){
        [self selectFilter: _filterGroupType.selectedSegmentIndex];
    }
    [super onSegCtrl:sender];
}
- (void) selectFilter:(NSInteger)idx {
    if (idx == _curIdx){
        return;
    }
    _curIdx = idx;
    _filterParam1.hidden = YES;
    _filterParam2.hidden = YES;
    _filterParam3.hidden = YES;
    _effectPicker.hidden = YES;
    // 标识当前被选择的滤镜
    if (idx == 0){
        _curFilter  = nil;
    }
    else if (idx == 1){
        _filterParam1.nameL.text = @"参数";
        _filterParam1.hidden = NO;
        _curFilter = [[KSYGPUBeautifyExtFilter alloc] init];
    }
    else if (idx == 2){ // 美颜
        KSYBeautifyFaceFilter * f = [[KSYBeautifyFaceFilter alloc] init];
        _filterParam1.hidden = NO;
        _filterParam2.hidden = NO;
        _filterParam1.nameL.text = @"磨皮";
        f.grindRatio  = _filterParam1.normalValue;
        f.whitenRatio = _filterParam2.normalValue;
        _curFilter    = f;
    }
    else if (idx == 3){ // 红润 + 美颜
        _filterParam1.nameL.text = @"磨皮";
        _filterParam3.nameL.text = @"红润";
        _filterParam1.hidden = NO;
        _filterParam2.hidden = NO;
        _filterParam3.hidden = NO;
        UIImage * rubbyMat = [[self class] KSYGPUImageNamed:@"3_tianmeikeren.png"];
        KSYBeautifyFaceFilter * bf = [[KSYBeautifyFaceFilter alloc] initWithRubbyMaterial:rubbyMat];
        bf.grindRatio  = _filterParam1.normalValue;
        bf.whitenRatio = _filterParam2.normalValue;
        bf.ruddyRatio  = _filterParam3.normalValue;
        _curFilter = bf;
    }
    else if (idx == 4){ // 美颜 + 特效 滤镜组合
        _filterParam1.nameL.text = @"磨皮";
        _filterParam3.nameL.text = @"特效";
        _filterParam1.hidden = NO;
        _filterParam2.hidden = NO;
        _filterParam3.hidden = NO;
        _effectPicker.hidden = NO;
        // 构造美颜滤镜 和  特效滤镜
        KSYBeautifyFaceFilter    * bf = [[KSYBeautifyFaceFilter alloc] init];
        KSYBuildInSpecialEffects * sf = [[KSYBuildInSpecialEffects alloc] initWithIdx:_curEffectIdx];
        bf.grindRatio  = _filterParam1.normalValue;
        bf.whitenRatio = _filterParam2.normalValue;
        sf.intensity   = _filterParam3.normalValue;
        [bf addTarget:sf];
        
        // 用滤镜组 将 滤镜 串联成整体
        GPUImageFilterGroup * fg = [[GPUImageFilterGroup alloc] init];
        [fg addFilter:bf];
        [fg addFilter:sf];
        
        [fg setInitialFilters:[NSArray arrayWithObject:bf]];
        [fg setTerminalFilter:sf];
        _curFilter = fg;
    }
    else {
        _curFilter = nil;
    }
}

- (IBAction)onSlider:(id)sender {
    if (sender != _filterParam1 &&
        sender != _filterParam2 &&
        sender != _filterParam3 ) {
        return;
    }
    float nalVal = _filterParam1.normalValue;
    if (_curIdx == 1){
        int val = (nalVal*5) + 1; // level 1~5
        [(KSYGPUBeautifyExtFilter *)_curFilter setBeautylevel: val];
    }
    else if (_curIdx == 2 || _curIdx == 3 ){ // 美颜
        KSYBeautifyFaceFilter * f =(KSYBeautifyFaceFilter*)_curFilter;
        if (sender == _filterParam1 ){
            f.grindRatio = _filterParam1.normalValue;
        }
        if (sender == _filterParam2 ) {
            f.whitenRatio = _filterParam2.normalValue;
        }
        if (sender == _filterParam3 ) {  // 红润参数
            f.ruddyRatio = _filterParam3.normalValue;
        }
    }
    else if ( _curIdx == 4 ){
        GPUImageFilterGroup * fg = (GPUImageFilterGroup *)_curFilter;
        KSYBeautifyFaceFilter    * bf = (KSYBeautifyFaceFilter *)[fg filterAtIndex:0];
        KSYBuildInSpecialEffects * sf = (KSYBuildInSpecialEffects *)[fg filterAtIndex:1];
        if (sender == _filterParam1 ){
            bf.grindRatio = _filterParam1.normalValue;
        }
        if (sender == _filterParam2 ) {
            bf.whitenRatio = _filterParam2.normalValue;
        }
        if (sender == _filterParam3 ) {  // 特效参数
            [sf setIntensity:_filterParam3.normalValue];
        }
    }
    [super onSlider:sender];
}

#pragma mark - effect picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1; // 单列
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    return _effectNames.count;//
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component{
    return [_effectNames objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    _curEffectIdx = row+1;
    if ( [_curFilter isKindOfClass:[GPUImageFilterGroup class]]){
        GPUImageFilterGroup * fg = (GPUImageFilterGroup *)_curFilter;
        KSYBuildInSpecialEffects * sf = (KSYBuildInSpecialEffects *)[fg filterAtIndex:1];
        [sf setSpecialEffectsIdx: _curEffectIdx];
    }
}

#pragma mark - load resource from resource bundle
+ (NSBundle*)KSYGPUResourceBundle {
    static dispatch_once_t onceToken;
    static NSBundle *resBundle = nil;
    dispatch_once(&onceToken, ^{
        resBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"KSYGPUResource" withExtension:@"bundle"]];
    });
    return resBundle;
}

+ (UIImage*)KSYGPUImageNamed:(NSString*)name {
    UIImage *imageFromMainBundle = [UIImage imageNamed:name];
    if (imageFromMainBundle) {
        return imageFromMainBundle;
    }
    UIImage *imageFromKSYBundle = [UIImage imageWithContentsOfFile:[[[KSYFilterView KSYGPUResourceBundle] resourcePath] stringByAppendingPathComponent:name]];
    return imageFromKSYBundle;
}

@end
