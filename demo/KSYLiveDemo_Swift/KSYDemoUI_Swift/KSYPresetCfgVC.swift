//
//  KSYPresetCfgVC.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit
/**
 KSY 预设参数配置视图控制器
 
 demo的入口
 */
class KSYPresetCfgVC: KSYUIVC {

    var rtmpURL: String            // rtmpserver 地址
    var cfgView: KSYPresetCfgView
    
    init(url: String) {
        rtmpURL = url
        cfgView = KSYPresetCfgView.init()
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cfgView.onBtnBlock = { [weak self] (sender) -> Void in
            self?.btnFunc(sender: sender)
        }
        
        cfgView.frame = view.frame
        self.view = cfgView
        //  TODO: !!!! 设置是否自动启动推流
//        let btn: UIButton
//        btn = cfgView.btn2
//        if btn != nil {
//            self.pressBtn(btn: btn, after: 0.5)
//        }
        
        if !rtmpURL.isEmpty {
            cfgView.hostUrlUI?.text = rtmpURL
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layoutUI()
    }
    
    func pressBtn(btn: UIButton, after delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) { [weak self] in
            self?.btnFunc(sender: btn)
        }
    }
    
    override func layoutUI() {
        cfgView.layoutUI()
    }
    
    override var shouldAutorotate: Bool {
        get{
            layoutUI()
            return true
        }
    }
    
    func btnFunc(sender: AnyObject) {
        var vc: UIViewController? = nil
        if sender as? UIButton == cfgView.btn0 {
            let btnName = cfgView.btn0?.currentTitle
            let strVC = KSYStreamerVC.init(Cfg: cfgView)
            strVC.ctrlView?.btnStream?.setTitle(btnName, for: .normal)
            vc = strVC
        }else if sender as? UIButton == cfgView.btn1 {
            let btnName = cfgView.btn1!.currentTitle
            let strVC = KSYPipStreamerVC.init(Cfg: cfgView)
            strVC.ctrlView?.btnStream?.setTitle(btnName, for: .normal)
            vc = strVC
        }else if sender as? UIButton == cfgView.btn2 {
            dismiss(animated: false, completion: nil)
            
            return
        }else{
            vc = nil
        }
        
        if vc != nil {
            present(vc!, animated: true, completion: nil)
        }
        
    }

}
