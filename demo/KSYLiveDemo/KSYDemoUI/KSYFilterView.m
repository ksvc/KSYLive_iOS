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
#import "ZipArchive.h"


@interface KSYFilterView() {
    UILabel * _lblSeg;
    NSInteger _curIdx;
    NSArray * _effectNames;
    NSInteger _curEffectIdx;
    //GPUResource资源的存储路径
    NSString *_gpuResourceDir;
}

@property (nonatomic) UILabel * lbPrevewFlip;
@property (nonatomic) UILabel * lbStreamFlip;

@property (nonatomic) UILabel * lbUiRotate;
@property (nonatomic) UILabel * lbStrRotate;

@property KSYNameSlider *proFilterLevel;
@property UIStepper *proFilterLevelStep;

@end

@implementation KSYFilterView

- (id)init{
    self = [super init];
    _effectNames = [NSArray arrayWithObjects:
                    @"0 原图关闭特效",
                    @"1 小清新",
                    @"2 靓丽",
                    @"3 甜美可人",
                    @"4 怀旧",
                    @"5 蓝调",
                    @"6 老照片",
                    @"7 樱花",
                    @"8 樱花（适用于光线较暗的环境）",
                    @"9 红润（适用于光线较暗的环境）",
                    @"10 阳光（适用于光线较暗的环境）",
                    @"11 红润",
                    @"12 阳光",
                    @"13 自然",
                    @"14 恋人",
                    @"15 高雅",
                    @"16 红粉佳人 ",
                    @"17 优格 ",
                    @"18 流年 ",
                    @"19 柔光 ",
                    @"20 经典 ",
                    @"21 初夏 ",
                    @"22 黑白 ",
                    @"23 纽约 ",
                    @"24 上野 ",
                    @"25 碧波 ",
                    @"26 日系 ",
                    @"27 清凉 ",
                    @"28 移轴 ",
                    @"29 梦幻 ",
                    @"30 恬淡 ",
                    @"31 候鸟 ",
                    @"32 淡雅 ", nil];
    [self downloadGPUResource];
    _curEffectIdx = 1;
    // 修改美颜参数
    _filterParam1 = [self addSliderName:@"参数" From:0 To:100 Init:50];
    _filterParam2 = [self addSliderName:@"美白" From:0 To:100 Init:50];
    _filterParam3 = [self addSliderName:@"红润" From:0 To:100 Init:50];
    _filterParam2.hidden = YES;
    _filterParam3.hidden = YES;
    
    _proFilterLevel    = [self addSliderName:@"类型" From:1 To:4 Init:1];
    _proFilterLevel.precision = 0;
    _proFilterLevel.slider.enabled = NO;
    _proFilterLevelStep  = [[UIStepper alloc] init];
    _proFilterLevelStep.continuous = NO;
    _proFilterLevelStep.maximumValue = 4;
    _proFilterLevelStep.minimumValue = 1;
    [self addSubview:_proFilterLevelStep];
    [_proFilterLevelStep addTarget:self
                   action:@selector(onStep:)
         forControlEvents:UIControlEventValueChanged];
    _proFilterLevel.hidden = YES;
    _proFilterLevelStep.hidden = YES;
    
    _lblSeg = [self addLable:@"滤镜"];
    _filterGroupType = [self addSegCtrlWithItems:
  @[ @"关",
     @"旧美颜",
     @"美颜pro",
     @"natural",
     @"红润",
     @"特效",
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
    [_effectPicker selectRow:1 inComponent:0 animated:YES];
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
    [self putWide:_proFilterLevel andNarrow:_proFilterLevelStep];
    
    if ( self.width > self.height){
        _effectPicker.frame = CGRectMake( self.winWdt, paramYPos, self.winWdt, 162);
    }
    else {
        self.btnH = 162;
        [self putRow1:_effectPicker];
    }
}

- (IBAction)onStep:(id)sender {
    if (sender == _proFilterLevelStep) {
        _proFilterLevel.value = _proFilterLevelStep.value;
        [self selectFilter: _filterGroupType.selectedSegmentIndex];
    }
    [super onSegCtrl:sender];
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
    _curIdx = idx;
    _filterParam1.hidden = YES;
    _filterParam2.hidden = YES;
    _filterParam3.hidden = YES;
    _proFilterLevel.hidden = YES;
    _proFilterLevelStep.hidden = YES;
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
    else if (idx == 2){ // 美颜pro
        _filterParam1.hidden = NO;
        _filterParam2.hidden = NO;
        _filterParam3.hidden = NO;
        _proFilterLevel.hidden = NO;
        _proFilterLevelStep.hidden = NO;
        KSYBeautifyProFilter * f = [[KSYBeautifyProFilter alloc] initWithIdx:_proFilterLevel.value];
        _filterParam1.nameL.text = @"磨皮";
        f.grindRatio  = _filterParam1.normalValue;
        f.whitenRatio = _filterParam2.normalValue;
        f.ruddyRatio  = _filterParam3.normalValue;
        _curFilter    = f;
    }
    else if (idx == 3){ // natural
        _filterParam1.hidden = NO;
        _filterParam2.hidden = NO;
        _filterParam3.hidden = NO;
        KSYBeautifyProFilter * nf = [[KSYBeautifyProFilter alloc] initWithIdx:3];
        _filterParam1.nameL.text = @"磨皮";
        nf.grindRatio  = _filterParam1.normalValue;
        nf.whitenRatio = _filterParam2.normalValue;
        nf.ruddyRatio  = _filterParam3.normalValue;
        _curFilter    = nf;
    }
    else if (idx == 4){ // 红润 + 美颜
        _filterParam1.nameL.text = @"磨皮";
        _filterParam3.nameL.text = @"红润";
        _filterParam1.hidden = NO;
        _filterParam2.hidden = NO;
        _filterParam3.hidden = NO;
        NSString *imgPath=[_gpuResourceDir stringByAppendingString:@"3_tianmeikeren.png"];
        UIImage *rubbyMat=[[UIImage alloc]initWithContentsOfFile:imgPath];
        if (rubbyMat == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"特效资源正在下载，请稍后重试"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确定", nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
        }
        KSYBeautifyFaceFilter *bf = [[KSYBeautifyFaceFilter alloc] initWithRubbyMaterial:rubbyMat];
        bf.grindRatio  = _filterParam1.normalValue;
        bf.whitenRatio = _filterParam2.normalValue;
        bf.ruddyRatio  = _filterParam3.normalValue;
        _curFilter = bf;
    }
    else if (idx == 5){ // 美颜 + 特效 滤镜组合
        _filterParam1.nameL.text = @"磨皮";
        _filterParam3.nameL.text = @"特效";
        _filterParam1.hidden = NO;
        _filterParam2.hidden = NO;
        _filterParam3.hidden = NO;
        _effectPicker.hidden = NO;
        _proFilterLevel.hidden = NO;
        _proFilterLevelStep.hidden = NO;
        // 构造美颜滤镜 和  特效滤镜
        KSYBeautifyProFilter    * bf = [[KSYBeautifyProFilter alloc] initWithIdx:_proFilterLevel.value];
        bf.grindRatio  = _filterParam1.normalValue;
        bf.whitenRatio = _filterParam2.normalValue;
        bf.ruddyRatio  = 0.5;
        
        KSYBuildInSpecialEffects * sf = [[KSYBuildInSpecialEffects alloc] initWithIdx:_curEffectIdx];
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
    else if (_curIdx == 2 || _curIdx == 3) {
        KSYBeautifyProFilter * f =(KSYBeautifyProFilter*)_curFilter;
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
    else if (_curIdx == 4 ){ // 美颜
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
    else if ( _curIdx == 5 ){
        GPUImageFilterGroup * fg = (GPUImageFilterGroup *)_curFilter;
        KSYBeautifyProFilter    * bf = (KSYBeautifyProFilter *)[fg filterAtIndex:0];
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
    _curEffectIdx = row;
    if (! [_curFilter isMemberOfClass:[GPUImageFilterGroup class]]){
        return;
    }
    GPUImageFilterGroup * fg = (GPUImageFilterGroup *)_curFilter;
    if (![fg.terminalFilter isMemberOfClass:[KSYBuildInSpecialEffects class]]) {
        return;
    }
    KSYBuildInSpecialEffects * sf = (KSYBuildInSpecialEffects *)fg.terminalFilter;
    [sf setSpecialEffectsIdx:_curEffectIdx];
}

-(void)downloadGPUResource{ // 下载资源文件
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    _gpuResourceDir=[NSHomeDirectory() stringByAppendingString:@"/Documents/GPUResource/"];
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:_gpuResourceDir]) {
        [fileManager createDirectoryAtPath:_gpuResourceDir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    NSString *zipPath = [_gpuResourceDir stringByAppendingString:@"KSYGPUResource.zip"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath]) {
        return; // already downloaded
    }
    NSString *zipUrl = @"https://ks3-cn-beijing.ksyun.com/ksy.vcloud.sdk/Ios/KSYLive_iOS_Resource/KSYGPUResource.zip";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url =[NSURL URLWithString:zipUrl];
        NSData *data =[NSData dataWithContentsOfURL:url];
        [data writeToFile:zipPath atomically:YES];
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        [zipArchive UnzipOpenFile:zipPath ];
        [zipArchive UnzipFileTo:_gpuResourceDir overWrite:YES];
        [zipArchive UnzipCloseFile];
    });
}

@end
