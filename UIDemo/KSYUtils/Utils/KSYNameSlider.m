
#import "KSYNameSlider.h"

@implementation KSYNameSlider

- (id) init {
    self = [super init];
    UIColor* bgColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    self.nameL  = [[UILabel alloc] init];
    self.valueL = [[UILabel alloc] init];
    self.nameL.backgroundColor  = bgColor;
    self.valueL.backgroundColor = bgColor;
    self.slider = [[UISlider alloc] init];
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 100;
    [self addSubview:_nameL];
    [self addSubview:_valueL];
    [self addSubview:_slider];
    [_slider addTarget:self
                action:@selector(onSlider:)
      forControlEvents:UIControlEventValueChanged];
    self.valueL.textAlignment = NSTextAlignmentCenter;
    self.onSliderBlock = nil;
    _normalValue = (_slider.value - _slider.minimumValue) / _slider.maximumValue;
    _precision = 0;
    return self;
}
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self layoutSlider];
}
- (void)layoutSlider{
    CGFloat wdt = self.frame.size.width;
    CGFloat hgt = self.frame.size.height;
    [_nameL sizeToFit];
    [_valueL sizeToFit];
    
    CGFloat wdtN = _nameL.frame.size.width + 10;
    CGFloat wdtV = _valueL.frame.size.width + 10;
    CGFloat wdtS = wdt - wdtN - wdtV;
    _nameL.frame  = CGRectMake(0, 0, wdtN, hgt);
    _slider.frame = CGRectMake(wdtN, 0, wdtS, hgt);
    _valueL.frame = CGRectMake(wdtN+wdtS, 0,wdtV, hgt);
}
- (void) updateValue {
    float val = _slider.value;
    if (_precision == 0){
        _valueL.text = [NSString stringWithFormat:@"%d", (int)val];
    }
    else {
        NSString *fmt =[NSString stringWithFormat:@"%%0.%df", _precision];
        _valueL.text = [NSString stringWithFormat:fmt, val];
    }
    [self layoutSlider];
    _normalValue = (_slider.value - _slider.minimumValue) / _slider.maximumValue;
}

//UIControlEventValueChanged
- (IBAction)onSlider:(id)sender {
    [self updateValue];
    if (_onSliderBlock) {
        _onSliderBlock(self);
    }
}

@synthesize normalValue = _normalValue;
- (float)normalValue{
    return _normalValue;
}
- (void)setNormalValue:(float )val{
    _slider.value = val * _slider.maximumValue + _slider.minimumValue;
    [self updateValue];
}
- (float)value{
    return _slider.value;
}
- (void)setValue:(float )val{
    _slider.value = val;
    [self updateValue];
    if (_onSliderBlock) {
        _onSliderBlock(self);
    }
}
@end
