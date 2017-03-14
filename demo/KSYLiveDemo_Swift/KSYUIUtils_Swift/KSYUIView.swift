//
//  KSYUIView.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/9.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

/**
 KSY自定义视图
 
 主要增加的功能如下:
 1. 增加更方便的视图尺寸查询属性
 2. 增加新建本SDK中常用控件的方法(按钮 滑块 开关等)
 3. 绑定事件响应的回调
 4. 增加简单的布局函数, 逐行添加任意数量的控件, 等大小,等距离放置
 
 演示SDK接口的各种视图都继承自此类
 */

class KSYUIView: UIView {

    var x: CGFloat {
        get{
            return super.frame.origin.x
        }
        set{
//            self.x = newValue
            super.frame.origin.x = newValue
        }
    }
    var y: CGFloat {
        get{
            return super.frame.origin.y
        }
        set{
//            self.y = newValue
            super.frame.origin.y = newValue
        }
    }
    var width: CGFloat {
        get{
            return super.frame.size.width
        }
        set{
//            super.width = newValue
            super.frame.size.width = newValue
        }
    }
    var height: CGFloat {
        get{
            return super.frame.size.height
        }
        set{
//            self.height = newValue
            super.frame.size.height = newValue
        }
    }
    
    var origin: CGPoint {
        get{
            return super.frame.origin
        }
        set{
            super.frame.origin = newValue
        }
    }
    
    var size: CGSize {
        get{
            return super.frame.size
        }
        set{
            super.frame.size = newValue
        }
    }
    
    var gap: CGFloat = 0        // gap between btns (default 4)
    var btnH: CGFloat = 0       // button's height (default 40)
    var winWdt: CGFloat = 0     // default self.width - gap*2
    var yPos: CGFloat = 0       // default gap*5
    // 在布局函数中, 每次使用putXXX接口增加一行控件, yPos 往下增加btnH+gap
    
    var onBtnBlock: ((AnyObject) -> Void)?
    var onSwitchBlock: ((AnyObject) -> Void)?
    var onSliderBlock: ((AnyObject) -> Void)?
    var onSegCtrlBlock: ((AnyObject) -> Void)?
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
        gap = 4
        btnH = 35
        winWdt = width
    }
    
    init(withParent pView: KSYUIView) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
        gap = 4
        btnH = 35
        winWdt = width
        
        self.isHidden = true
        pView.addSubview(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI elements layout
    func layoutUI() {
        btnH = 30
        winWdt = width
        yPos = UIApplication.shared.statusBarFrame.height
    }
    
    func getXStart() -> CGFloat {
        var xPos = gap
        if yPos > height {
            xPos += winWdt
        }
        return xPos
    }
    
    // Array cannot contain NSNull
    func putRow(subV: [UIView]) {
        let cnt = subV.count
        if cnt < 1 {
            return
        }
        
        let btnW = winWdt / CGFloat(cnt) - gap * 2
        var xPos = self.getXStart()
        let step = gap * 2 + btnW
        let yPos = self.yPos > height ? self.yPos - height : self.yPos
        for item in subV {
            if item.isKind(of: UIView.self) {
                item.frame = CGRect.init(x: xPos, y: yPos, width: btnW, height: btnH)
            }
            xPos += step
        }
        self.yPos += btnH + gap
    }

    func putRow(subV2: NSArray) {
        let cnt = subV2.count
        if cnt < 1 {
            return
        }
        
        let btnW = winWdt / CGFloat(cnt) - gap * 2
        var xPos = self.getXStart()
        let step = gap * 2 + btnW
        let yPos = self.yPos > height ? self.yPos - height : self.yPos
        for item in subV2 {
            if (item as AnyObject).isKind(of: UIView.self) {
                (item as! UIView).frame = CGRect.init(x: xPos, y: yPos, width: btnW, height: btnH)
            }
            xPos += step
        }
        self.yPos += btnH + gap
    }
    
    func putRow1(subV: UIView!) {
        let yPos = self.yPos > height ? self.yPos - height : self.yPos
        subV.frame = CGRect.init(x: getXStart(), y: yPos, width: winWdt - gap * 2, height: btnH)
        self.yPos += btnH + gap
    }
    
    func putRow2(subV0: UIView!, and subV1: UIView!) {
        let btnW = winWdt / 2 - gap * 2
        let y = yPos > self.height ? yPos - height : yPos
        let x = getXStart() + gap
        subV0.frame = CGRect.init(x: x, y: y, width: btnW, height: btnH)
        subV1.frame = CGRect.init(x: x + gap * 2 + btnW, y: y, width: btnW, height: btnH)
        yPos += btnH + gap
    }
    
    func putRow3(subV0: UIView!, and subV1: UIView!, and subV2: UIView!) {
        let btnW = winWdt / 3 - gap * 2
        let x = getXStart() + gap
        let y = yPos > self.height ? yPos - height : yPos
        let xPos: [CGFloat] = [x, x + gap * 2 + btnW, x + gap * 4 + btnW * 2]
        subV0.frame = CGRect.init(x: xPos[0], y: y, width: btnW, height: btnH)
        subV1.frame = CGRect.init(x: xPos[1], y: y, width: btnW, height: btnH)
        subV2.frame = CGRect.init(x: xPos[2], y: y, width: btnW, height: btnH)
        yPos += btnH + gap
    }
    
    //(firstV 使用内容宽度, 剩余宽度全部分配给secondV)
    func putNarrow(firstV: UIView, andWide secondV: UIView) {
        let x = getXStart() + gap
        let y = yPos > self.height ? yPos - height : yPos
        firstV.sizeToFit()
        firstV.frame = CGRect.init(x: x, y: y, width: firstV.frame.width, height: btnH)
        
        let btnW = winWdt - gap * 3 - firstV.frame.width
        let xPos = firstV.frame.origin.x + firstV.frame.width + gap
        secondV.frame = CGRect.init(x: xPos, y: y, width: btnW, height: btnH)
        yPos += btnH + gap
    }
    
    //(secondV 使用内容宽度, 剩余宽度全部分配给firstV)
    func putWide(firstV: UIView, andNarrow secondV: UIView) {
        let x = getXStart() + gap
        let y = yPos > height ? yPos - height : yPos
        secondV.sizeToFit()
        
        let slW = winWdt - gap * 3 - secondV.frame.width
        
        secondV.frame = CGRect.init(x: slW + x, y: y, width: secondV.frame.width, height: btnH)
        firstV.frame = CGRect.init(x: x, y: y, width: slW, height: btnH)
        
        yPos += btnH + gap
    }
    
    func putLabel(lbl: UIView, andView subV: UIView) {
        putNarrow(firstV: lbl, andWide: subV)
    }
    
    func putSlider(sl: UIView, andSwitch sw: UIView) {
        putWide(firstV: sl, andNarrow: sw)
    }
    
    // MARK: - new and add UI elements
    func addTextField(text: String) -> UITextField {
        let textF = UITextField.init()
        textF.text = text
        textF.borderStyle = UITextBorderStyle.roundedRect
        addSubview(textF)
        
        return textF
    }
    
    func newButton(title: String) -> UIButton {
        let button = UIButton.init(type: .roundedRect)
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.alpha = 0.9
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        addSubview(button)
        
        return button
    }
    
    func addButton(title: String) -> UIButton {
        let button = newButton(title: title)
        button.addTarget(self, action: #selector(onBtn(sender:)), for: .touchUpInside)
        
        return button
    }
    
    // button with custom action
    func addButton(title: String, action: Selector) -> UIButton {
        let button = newButton(title: title)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        return button
    }
    
    func addSegCtrlWithItems(items: Array<Any>) -> UISegmentedControl {
        let segC = UISegmentedControl.init(items: items)
        segC.selectedSegmentIndex = 0
        segC.layer.cornerRadius = 5
        segC.backgroundColor = UIColor.lightGray
        segC .addTarget(self, action: #selector(onSegCtrl(sender:)), for: .valueChanged)
        
        addSubview(segC)
        
        return segC
    }
    
    func addLabel(title: String) -> UILabel {
        let lbl = UILabel.init()
        lbl.text = title
        lbl.backgroundColor = UIColor.init(white: 0.8, alpha: 0.3)
        
        addSubview(lbl)
        
        return lbl
    }
    
    func newSwitch(on: Bool) -> UISwitch {
        let sw = UISwitch.init()
        sw.isOn = on
        
        addSubview(sw)
        
        return sw
    }
    
    func addSwitch(on: Bool) -> UISwitch {
        let sw = newSwitch(on: on)
        sw .addTarget(self, action: #selector(onSwitch(sender:)), for: .valueChanged)
        
        return sw
    }
 
    func newSlider(from minV: Float,to maxV: Float, initV: Float) -> UISlider {
        let sl = UISlider.init()
        sl.minimumValue = minV
        sl.maximumValue = maxV
        sl.value = initV
        sl.isContinuous = false

        addSubview(sl)
        
        return sl
    }
    
    func addSlider(from minV: Float,to maxV: Float, initV: Float) -> UISlider {
        let sl = newSlider(from: minV, to: maxV, initV: initV)
        sl.addTarget(self, action: #selector(onSlider(sender:)), for: .valueChanged)
        
        return sl
    }
    
    func addSlider(from minV: Float,to maxV: Float,initV: Float,action:Selector) -> UISlider {
        let sl = newSlider(from: minV, to: maxV, initV: initV)
        sl.addTarget(self, action: action, for: .valueChanged)
        
        return sl
    }

    func addSlider(name nm: String, from minV: Float, to maxV: Float, initV: Float) -> KSYNameSlider {
        
        let sl = KSYNameSlider.init()
        sl.slider.minimumValue = minV
        sl.slider.maximumValue = maxV
        sl.slider.value = initV
        sl.nameL.text = nm
        sl.normalValue = (initV - minV)/maxV
        sl.valueL.text = "\(initV )"
        addSubview(sl)
        
        if initV < 2 {
            sl.precision = 2
        }
        sl.slider.addTarget(self, action: #selector(onSlider(sender:)), for: .valueChanged)
        
        sl.onSliderBlock = { [weak self] (sender) -> Void in
            self!.onSlider(sender: sender as! UIView)
        }
        
        return sl
    }
    
    // MARK: UI respond
    func onBtn(sender: AnyObject) {
        if onBtnBlock != nil {
            onBtnBlock!(sender)
        }
        if superview!.isKind(of: KSYUIView.self) {
            (superview as! KSYUIView).onBtn(sender: sender)
        }
    }
    
    func onSwitch(sender: AnyObject) {
        if onSwitchBlock != nil {
            onSwitchBlock!(sender)
        }
        if superview!.isKind(of: KSYUIView.self) {
            (superview as! KSYUIView).onSwitch(sender: sender)
        }
    }
    
    func onSlider(sender: UIView) {
        if onSliderBlock != nil {
            onSliderBlock!(sender)
        }
        if superview!.isKind(of: KSYUIView.self) {
            (superview as! KSYUIView).onSlider(sender: sender)
        }
    }
    
    func onSegCtrl(sender: AnyObject) {
        if onSegCtrlBlock != nil {
            onSegCtrlBlock!(sender)
        }
        if superview!.isKind(of: KSYUIView.self) {
            (superview as! KSYUIView).onSegCtrl(sender: sender)
        }
    }
    
    // 获取设备的UUID
    func getUuid() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString.lowercased()
    }
}
