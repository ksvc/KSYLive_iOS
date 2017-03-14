//
//  KSYFilterView.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

class KSYFilterView: KSYUIView {

    // 参数调节
    var filterParam1: KSYNameSlider?
    var filterParam2: KSYNameSlider?
    var filterParam3: KSYNameSlider?
    
    var curFilter: GPUImageOutput?              // 选择滤镜
    var filterGroupType: UISegmentedControl?    // 滤镜组合
    var effectPicker: UIPickerView?             // 特效滤镜
    
    // 镜像翻转按钮
    var swPrevewFlip: UISwitch?
    var swStreamFlip: UISwitch?
    
    // 界面旋转 和推流画面动态旋转
    var swUiRotate: UISwitch?           // 只在iphone上能锁定
    var swStrRotate: UISwitch?
    
    private
    var _lblSeg: UILabel?
    var _curIdx: Int = 0
    var _effectNames: [String]?
    var _curEffectIdx: Int = 1
    
    var lbPreviewFlip: UILabel?
    var lbStreamFlip: UILabel?
    
    var lbUiRotate: UILabel?
    var lbStrRotate: UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(withParent pView: KSYUIView) {
        super.init(withParent: pView)
        _effectNames = ["1 小清新", "2 靓丽", "3 甜美可人", "4 怀旧", "5 蓝调", "6 老照片"]
        _curEffectIdx = 1
        
        // 修改美颜参数
        filterParam1 = addSlider(name: "参数", from: 0, to: 100, initV: 50)
        filterParam2 = addSlider(name: "美白", from: 0, to: 100, initV: 50)
        filterParam3 = addSlider(name: "红润", from: 0, to: 100, initV: 50)
        filterParam2?.isHidden = true
        filterParam3?.isHidden = true
        
        _lblSeg = addLabel(title: "滤镜")
        filterGroupType = addSegCtrlWithItems(items: ["关", "旧美颜", "美颜pro", "红润美颜", "美颜特效"])
        filterGroupType?.selectedSegmentIndex = 1
        selectFilter(idx: 1)
        
        lbPreviewFlip = addLabel(title: "预览镜像")
        lbStreamFlip = addLabel(title: "推流镜像")
        swPrevewFlip = addSwitch(on: false)
        swStreamFlip = addSwitch(on: false)
        
        lbUiRotate = addLabel(title: "UI旋转")
        lbStrRotate = addLabel(title: "推流旋转")
        swUiRotate = addSwitch(on: false)
        swStrRotate = addSwitch(on: false)
        swStrRotate?.isEnabled = false
        
        effectPicker = UIPickerView()
        addSubview(effectPicker!)
        effectPicker?.isHidden = true
        effectPicker?.delegate = self
        effectPicker?.dataSource = self
        effectPicker?.showsSelectionIndicator = true
        effectPicker?.backgroundColor = UIColor.init(white: 0.8, alpha: 0.3)
    }
    
    override func layoutUI() {
        super.layoutUI()
        yPos = 0
        putRow(subV: [lbPreviewFlip!, swPrevewFlip!, lbStreamFlip!, swStreamFlip!])
        putRow(subV: [lbUiRotate!, swUiRotate!, lbStrRotate!, swStrRotate!])
        putLabel(lbl: _lblSeg!, andView: filterGroupType!)
        let paramYPos = yPos
        if width > height {
            winWdt /= 2
        }
        
        putRow1(subV: filterParam1!)
        putRow1(subV: filterParam2!)
        putRow1(subV: filterParam3!)
        
        if width > height {
            effectPicker?.frame = CGRect.init(x: winWdt, y: paramYPos, width: winWdt, height: 162)
        }else{
            btnH = 162
            putRow1(subV: effectPicker!)
        }
    }
    
    override func onSwitch(sender: AnyObject) {
        if sender as? NSObject == swUiRotate {
            // 只有界面跟随设备旋转, 推流才能旋转
            swStrRotate!.isEnabled = swUiRotate!.isOn
            if !swUiRotate!.isOn {
                swUiRotate?.isOn = false
            }
        }
        super.onSwitch(sender: sender)
    }
    
    override func onSegCtrl(sender: AnyObject) {
        if sender as? NSObject == filterGroupType {
            selectFilter(idx: filterGroupType!.selectedSegmentIndex)
        }
        super.onSegCtrl(sender: sender)
    }
    
    override func onSlider(sender: UIView) {
        if sender != filterParam1 &&
            sender != filterParam2 &&
            sender != filterParam3 {
            return
        }
        
        let nalVal = filterParam1!.normalValue
        
        switch _curIdx {
        case 1:
            let val = nalVal * 5 + 1 // level 1~5
            (curFilter as! KSYGPUBeautifyExtFilter).setBeautylevel(Int32(val))
            break
        case 2:
            let f: KSYBeautifyProFilter = curFilter as! KSYBeautifyProFilter
            if sender == filterParam1 {
                f.grindRatio = CGFloat(filterParam1!.normalValue)
            }else if sender == filterParam2 {
                f.whitenRatio = CGFloat(filterParam2!.normalValue)
            }else if sender == filterParam3 {
                f.ruddyRatio = CGFloat(filterParam3!.normalValue)
            }
            break
        case 3:
            let f: KSYBeautifyFaceFilter = curFilter as! KSYBeautifyFaceFilter
            if sender == filterParam1 {
                f.grindRatio = CGFloat(filterParam1!.normalValue)
            }else if sender == filterParam2 {
                f.whitenRatio = CGFloat(filterParam2!.normalValue)
            }else if sender == filterParam3 {
                f.ruddyRatio = CGFloat(filterParam3!.normalValue)
            }
            break
        case 4:
            let fg: GPUImageFilterGroup = curFilter as! GPUImageFilterGroup
            let bf: KSYBeautifyFaceFilter = fg.filter(at: 0) as! KSYBeautifyFaceFilter
            let sf: KSYBuildInSpecialEffects = fg.filter(at: 1) as! KSYBuildInSpecialEffects
            if sender == filterParam1 {
                bf.grindRatio = CGFloat(filterParam1!.normalValue)
            }else if sender == filterParam2 {
                bf.whitenRatio = CGFloat(filterParam2!.normalValue)
            }else if sender == filterParam3 {
                sf.intensity = CGFloat(filterParam3!.normalValue)
            }
            break
        default:
            ()
        }
        super.onSlider(sender: sender)
    }
    
    func selectFilter(idx: Int) {
        if idx == _curIdx {
            return
        }
        
        _curIdx = idx
        filterParam1?.isHidden = true
        filterParam2?.isHidden = true
        filterParam3?.isHidden = true
        effectPicker?.isHidden = true
        
        // 标识当前被选择的滤镜
        switch idx {
        case 0:
            curFilter = nil
            break
        case 1:
            filterParam1?.nameL.text = "参数"
            filterParam1?.isHidden = false
            curFilter = KSYGPUBeautifyExtFilter()
            break
        case 2:
            let f: KSYBeautifyProFilter = KSYBeautifyProFilter()
            filterParam1?.isHidden = false
            filterParam2?.isHidden = false
            filterParam3?.isHidden = false
            filterParam1?.nameL.text = "磨皮"
            
            f.grindRatio = CGFloat(filterParam1!.normalValue)
            f.whitenRatio = CGFloat(filterParam2!.normalValue)
            f.ruddyRatio = CGFloat(filterParam3!.normalValue)
            curFilter = f
            break
        case 3:
            filterParam1?.nameL.text = "磨皮"
            filterParam3?.nameL.text = "红润"
            filterParam1?.isHidden = false
            filterParam2?.isHidden = false
            filterParam3?.isHidden = false

            let rubbyMat = KSYGPUImageNamed(name: "3_tianmeikeren.png")
            let bf = KSYBeautifyFaceFilter.init(rubbyMaterial: rubbyMat)
            
            bf?.grindRatio = CGFloat(filterParam1!.normalValue)
            bf?.whitenRatio = CGFloat(filterParam2!.normalValue)
            bf?.ruddyRatio = CGFloat(filterParam3!.normalValue)
            
            curFilter = bf
            break
        case 4:
            filterParam1?.nameL.text = "磨皮"
            filterParam3?.nameL.text = "特效"
            filterParam1?.isHidden = false
            filterParam2?.isHidden = false
            filterParam3?.isHidden = false
            effectPicker?.isHidden = false
            // 构造美颜滤镜 和  特效滤镜
            let bf = KSYBeautifyFaceFilter()
            let sf = KSYBuildInSpecialEffects.init(idx: _curEffectIdx)
            bf?.grindRatio = CGFloat(filterParam1!.normalValue)
            bf?.whitenRatio = CGFloat(filterParam2!.normalValue)
            sf?.intensity = CGFloat(filterParam3!.normalValue)
            bf?.addTarget(sf)
            
            // 用滤镜组 将 滤镜 串联成整体
            let fg = GPUImageFilterGroup()
            fg.addFilter(bf)
            fg.addFilter(sf)
            
            fg.initialFilters = [bf!]
            fg.terminalFilter = sf
            
            curFilter = fg
            break
        default:
            ()
        }
        
    }
    
}

extension KSYFilterView: UIPickerViewDataSource, UIPickerViewDelegate{

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    // 单列
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return _effectNames?.count ?? 0
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (_effectNames! as NSArray).object(at: row) as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        _curEffectIdx = row + 1
        if curFilter!.isMember(of: GPUImageFilterGroup.self) {
            let fg: GPUImageFilterGroup = curFilter as! GPUImageFilterGroup
            let sf: KSYBuildInSpecialEffects = fg.filter(at: 1) as! KSYBuildInSpecialEffects
            sf.setSpecialEffectsIdx(_curEffectIdx)
        }
    }
    
    // MARK: - load resource from resource bundle
    func KSYGPUResourceBundle() -> Bundle? {
        let resBundle: Bundle = Bundle.init(url: (Bundle.main.url(forResource: "KSYGPUResource", withExtension: "bundle")!))!
        return resBundle
    }
    
    func KSYGPUImageNamed(name: String) -> UIImage? {
        let imageFromMainBundle = UIImage.init(named: name)
        if let _ = imageFromMainBundle {
            return imageFromMainBundle!
        }
        if let bundle = KSYGPUResourceBundle() {
            let imageFromKSYBundle = UIImage.init(contentsOfFile: ((bundle.resourcePath! as NSString).appendingPathComponent(name) as String))
            return imageFromKSYBundle
        }
        return nil
    }
}
