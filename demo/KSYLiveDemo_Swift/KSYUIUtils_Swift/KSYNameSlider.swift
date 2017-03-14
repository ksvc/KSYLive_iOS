//
//  KSYNameSlider.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/9.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit
/**
 自定义控件: 带标签的slider
 
 控件格式为: 参数名称 + 滑块 + 当前数值
 通过 onSliderBlock,可以得到滑块值改变的事件
 通过 normalValue, 可以查询到归一化的值(0~1.0)
 */

class KSYNameSlider: UIView {

    var nameL: UILabel     // 滑块对应参数名称
    var slider: UISlider   // 滑块
    var valueL: UILabel    // 滑块当前的值
    
    // UIControlEventValueChanged 回调
    var onSliderBlock: ((AnyObject) -> Void)?
    // normalize between 0.0~1.0 [ (value-min)/max ]
    var _normalValue: Float = 0
    var normalValue: Float {
        get{
            return _normalValue
        }
        set{
            _normalValue = newValue
            slider.value = newValue * slider.maximumValue + slider.minimumValue
            self.updateValue()
        }
    }
    
    // 值的小数点位数[0,1,2,3]
    var precision: Int = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        let bgColor: UIColor = UIColor.init(white: 0.8, alpha: 0.3)
        
        nameL = UILabel.init()
        valueL = UILabel.init()
        slider = UISlider.init()
        
        super.init(frame: CGRect.zero)
        
        nameL.backgroundColor = bgColor
        valueL.backgroundColor = bgColor
        valueL.textAlignment = .center
        
        slider.minimumValue = 0
        slider.maximumValue = 100
        
        addSubview(nameL)
        addSubview(valueL)
        addSubview(slider)
        
        slider.addTarget(self, action: #selector(onSlider), for: .valueChanged)
        onSliderBlock = nil
        normalValue = (slider.value - slider.minimumValue) / slider.maximumValue;
        precision = 0
    }
    
    override var frame: CGRect {
        get{
            return super.frame
        }
        set{
            super.frame = newValue
            layoutSlider()
        }
    }
    
    func layoutSlider() {
        let wdt = self.frame.width
        let hgt = self.frame.height
        
        nameL.sizeToFit()
        valueL.sizeToFit()

        let wdtN: CGFloat = nameL.frame.width + 10;
        let wdtV: CGFloat = valueL.frame.width + 10;
        let wdtS: CGFloat = wdt - wdtN - wdtV;
        nameL.frame  = CGRect.init(x: 0, y: 0, width: wdtN, height: hgt)
        slider.frame = CGRect.init(x: wdtN, y: 0, width: wdtS, height: hgt)
        valueL.frame = CGRect.init(x: wdtN+wdtS, y: 0, width: wdtV, height: hgt)
    }
    
    func updateValue() {
        let val = slider.value
        if precision == 0 {
            valueL.text = "\(Int(val))"
        }else{
            valueL.text = String.init(format: "%0.\(precision)f", val)
        }
        self.layoutSlider()
        _normalValue = (slider.value - slider.minimumValue) / slider.maximumValue
    }
    
    func onSlider() {
        self.updateValue()
        if (onSliderBlock != nil) {
            onSliderBlock!(self)
        }
    }
}
