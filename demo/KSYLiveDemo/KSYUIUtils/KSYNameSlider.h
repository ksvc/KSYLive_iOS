
#import <UIKit/UIKit.h>


/**
 自定义控件: 带标签的slider
 
 控件格式为: 参数名称 + 滑块 + 当前数值
 通过 onSliderBlock,可以得到滑块值改变的事件
 通过 normalValue, 可以查询到归一化的值(0~1.0)
 */
@interface KSYNameSlider: UIView

@property (atomic, retain) UILabel*  nameL;  // 滑块对应参数名称
@property (atomic, retain) UISlider* slider; // 滑块
@property (atomic, retain) UILabel*  valueL; // 滑块当前的值
// UIControlEventValueChanged 回调
@property(nonatomic, copy) void(^onSliderBlock)(id sender);

// normalize between 0.0~1.0 [ (value-min)/max ]
@property (atomic, assign) float  normalValue;

// slider value
@property (atomic, assign) float  value;


// 值的小数点位数[0,1,2,3]
@property (atomic, assign) int precision;

@end
