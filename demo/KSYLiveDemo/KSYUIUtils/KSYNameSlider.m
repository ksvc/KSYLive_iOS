
#import "KSYNameSlider.h"

@implementation KSYNameSlider

- (id) init {
    self = [super init];
    self.nameL  = [[UILabel alloc] init];
    self.valueL = [[UILabel alloc] init];
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

//UIControlEventValueChanged
- (IBAction)onSlider:(id)sender {
    if (_slider.maximumValue > 1){
        int val = (int)_slider.value;
        _valueL.text = [NSString stringWithFormat:@"%d", val];
    }
    if (_slider.maximumValue <= 1.0){
        float val = _slider.value;
        _valueL.text = [NSString stringWithFormat:@"%0.2f", val];
    }
    [self layoutSlider];
    if (_onSliderBlock) {
        _onSliderBlock(self);
    }
    _normalValue = (_slider.value - _slider.minimumValue) / _slider.maximumValue;
}
@end