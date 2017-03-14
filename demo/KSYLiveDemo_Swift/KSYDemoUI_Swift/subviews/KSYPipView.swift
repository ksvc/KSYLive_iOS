//
//  KSYPipView.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

class KSYPipView: KSYUIView {

    var pipPlay: UIButton?
    var pipPause: UIButton?
    var pipStop: UIButton?
    var progressV: UIProgressView?
    var volumSl: KSYNameSlider?
    var pipNext: UIButton?
    var bgpNext: UIButton?
    
    // 当前画中画的视频和背景图片的路径
    var pipURL: URL?
    var bgpURL: URL?
    // 当前画中画的播放状态
    var pipStatus: String?
    
    // match pattern
    var pipPattern: [String]?
    var bgpPattern: [String]?
    
    private
    var _pipTitle: UILabel?
    var _pipSel: KSYFileSelector?
    var _bgpSel: KSYFileSelector?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(withParent pView: KSYUIView) {
        super.init(withParent: pView)
        pipStatus = "idle"
        _pipTitle = addLabel(title: "")
        _pipTitle?.numberOfLines = 2
        _pipTitle?.textAlignment = .left
        
        progressV = UIProgressView()
        addSubview(progressV!)
        pipPlay = addButton(title: "播放")
        pipPause = addButton(title: "暂停")
        pipStop = addButton(title: "停止")
        pipNext = addButton(title: "下一个视频文件")
        bgpNext = addButton(title: "下一个背景图片")
        volumSl = addSlider(name: "音量", from: 0, to: 100, initV: 50)
        
        pipPattern = [".mp4", ".flv"]
        bgpPattern = [".jpg", ".jpeg", ".png"]
        
        _pipSel = KSYFileSelector.init(dir: "/Documents/movies/", suf: pipPattern!)
        _bgpSel = KSYFileSelector.init(dir: "/Documents/images/", suf: bgpPattern!)
        
        if let filePath = _pipSel?.filePath , filePath.characters.count > 0{
            pipURL = URL.init(fileURLWithPath: _pipSel!.filePath)
        }
        if let filePath = _bgpSel?.filePath , filePath.characters.count > 0 {
            bgpURL = URL.init(fileURLWithPath: _bgpSel!.filePath)
        }
    }
    
    override func layoutUI() {
        super.layoutUI()
        btnH = 10
        putRow1(subV: progressV!)
        btnH = 60
        putRow1(subV: _pipTitle)
        btnH = 30
        putRow(subV: [pipPlay!, pipPause!, pipStop!])
        putRow1(subV: volumSl)
        putRow2(subV0: pipNext, and: bgpNext)
    }
    
    override func onBtn(sender: AnyObject) {
        if sender as? NSObject == pipNext {
            guard let _ = _pipSel else {
                return
            }
            if _pipSel!.selectFileWithType(type: .NEXT) {
                pipURL = URL.init(fileURLWithPath: _pipSel!.filePath)
            }
        }else if sender as? NSObject == bgpNext {
            guard let _ = _bgpSel else {
                return
            }
            if _bgpSel!.selectFileWithType(type: .NEXT) {
                bgpURL = URL.init(fileURLWithPath: _bgpSel!.filePath)
            }
        }
        
        _pipTitle?.text = "\(pipStatus ?? "idle"): \(_pipSel!.fileInfo)\n\(_bgpSel!.fileInfo)"
        super.onBtn(sender: sender)
    }

}
