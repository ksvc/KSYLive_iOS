//
//  KSYMiscView.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

class KSYMiscView: KSYUIView {

    var btn0: UIButton?
    var btn1: UIButton?
    var btn2: UIButton?
    var btn3: UIButton?
    var btn4: UIButton?

    var swBypassRec: UISwitch?
    var lblRecDur: UILabel?
    
    var layerSeg: UISegmentedControl?
    var alphaSl: KSYNameSlider?
    
    var liveSceneSeg: UISegmentedControl?
    var vEncPerfSeg: UISegmentedControl?
    
    var liveScene: KSYLiveScene? {
        get{
            if self.liveSceneSeg?.selectedSegmentIndex == 1 {
                return .showself
            }else{
                return .default
            }
        }
    }
    var vEncPerf: KSYVideoEncodePerformance? {
        get{
            switch self.vEncPerfSeg!.selectedSegmentIndex {
            case 0:
                return .per_LowPower
            case 1:
                return .per_Balance
            case 2:
                return .per_HighPerformance
            default:
                return .per_Balance
            }
        }
    }
    
    var autoReconnect: KSYNameSlider?
    
    private
    var _curBtn: UIButton?
    var _lblScene: UILabel?
    var _lblPerf: UILabel?
    var _lblRec: UILabel?
    
    override init(withParent pView: KSYUIView) {
        super.init(withParent: pView)
        btn0 = addButton(title: "str截图为文件")
        btn1 = addButton(title: "str截图为UIImage")
        btn2 = addButton(title: "filter截图")
        
        btn3 = addButton(title: "选择Logo")
        btn4 = addButton(title: "拍摄Logo")
        
        _lblRec = addLabel(title: "旁路录制")
        swBypassRec = addSwitch(on: false)
        lblRecDur = addLabel(title: "0s")
        
        layerSeg = addSegCtrlWithItems(items: ["logo", "文字"])
        alphaSl = addSlider(name: "alpha", from: 0.0, to: 1.0, initV: 1.0)
        
        _lblScene = addLabel(title: "直播场景")
        liveSceneSeg = addSegCtrlWithItems(items: ["默认", "秀场"])
        _lblPerf = addLabel(title: "编码性能")
        vEncPerfSeg = addSegCtrlWithItems(items: ["低功耗", "均衡", "高性能"])
        autoReconnect = addSlider(name: "自动重连次数", from: 0.0, to: 10, initV: 3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutUI() {
        super.layoutUI()
        btnH = 30
        putRow3(subV0: btn0, and: btn1, and: btn2)
        putLabel(lbl: _lblScene!, andView: liveSceneSeg!)
        putLabel(lbl: _lblPerf!, andView: vEncPerfSeg!)
        putRow(subV: [btn4!, btn3!])
        putNarrow(firstV: layerSeg!, andWide: alphaSl!)
        putRow(subV: [_lblRec!, swBypassRec!, lblRecDur!])
        putRow1(subV: autoReconnect)
    }
}
