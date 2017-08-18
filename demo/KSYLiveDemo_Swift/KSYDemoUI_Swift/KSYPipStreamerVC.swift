//
//  KSYPipStreamerVC.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 2017/2/6.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

/**
 KSY 推流SDK的主要演示视图
 
 主要演示了SDK 提供的API的基本使用方法
 */

class KSYPipStreamerVC: KSYStreamerVC {
    /// 画中画配置页面
    var ksyPipView: KSYPipView?
    var pipKit: KSYGPUPipStreamerKit?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(Cfg presetCfgView: KSYPresetCfgView) {
        super.init(Cfg: presetCfgView)
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        if let _ = menuNames {
            menuNames!.append("画中画")
        }
        pipKit = KSYGPUPipStreamerKit.init(defaultCfg: ())
        kit = pipKit
        super.viewDidLoad()
    }
    
    override func addSubViews() {
        super.addSubViews()
        ksyPipView = KSYPipView.init(withParent: ctrlView!)
        // connect UI
        ksyPipView?.onBtnBlock = { [weak self] (sender) in
            self?.onPipBtnPress(btn: sender as! UIButton)
        }
        ksyPipView?.onSliderBlock = { [weak self] (sender) in
            self?.pipVolChange(sender: sender as! UISlider)
        }
    }
    
    override func addObservers() {
        super.addObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(onPipStateChange(notify:)), name: NSNotification.Name.MPMoviePlayerPlaybackStateDidChange, object: nil)
    }
    
    override func rmObservers() {
        super.rmObservers()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackStateDidChange, object: nil)
    }
    
    func enterBg(notify: Notification) {
        kit?.appEnterBackground()
    }
    
    func becameActive(notify: Notification) {
        kit?.appBecomeActive()
    }
    
    func onPipStateChange(notify: Notification) {
        let st = pipKit?.getCurPipStateName()
        ksyPipView?.pipStatus = (st! as NSString).substring(from: 20)
    }
    
    // MARK: Capture & stream setup
    override func setCaptureCfg() {
        super.setCaptureCfg()
    }
    
    /// 推流的参数设置
    override func setStreamerCfg() {
        super.setStreamerCfg()
    }
    
    // MARK: state change
    override func onTimer(timer: Timer) {
        super.onTimer(timer: timer)
        guard let _ = pipKit?.player else {
            return
        }
        
        if pipKit!.player.playbackState == .playing {
            if pipKit!.player.duration > 0 {
                ksyPipView?.progressV?.progress = Float(pipKit!.player.currentPlaybackTime / pipKit!.player.duration)
            }
        }
    }
    
    // MARK: UI respond
    override func onMenuBtnPress(btn: UIButton) {
        var view: KSYUIView? = nil
        if btn == ctrlView!.menuBtns![menuNames!.count-1] {
            view = ksyPipView!   // 画中画播放相关
        }
        
        if let view = view {
            ctrlView?.showSubMenuView(view: view)
            return
        }
        super.onMenuBtnPress(btn: btn)
    }
    
    /// pipView btn Control
    func onPipBtnPress(btn: UIButton) {
        if btn == ksyPipView!.pipPlay {
            onPipPlay()
        }else if  btn == ksyPipView!.pipPause {
            onPipPause()
        }else if  btn == ksyPipView!.pipStop {
            onPipStop()
        }else if  btn == ksyPipView!.pipNext {
            onPipNext()
        }else if  btn == ksyPipView!.bgpNext {
            onBgpNext()
        }
    }
    
    func onPipPlay() {
        guard let _ = ksyPipView?.pipURL ,let _ = ksyPipView?.bgpURL else {
            return
        }
        pipKit?.startPip(withPlayerUrl: ksyPipView?.pipURL,
                         bgPic: ksyPipView?.bgpURL)
    }
    
    func onPipStop() {
        pipKit?.stopPip()
    }
    
    func onPipNext() {
        guard let _ = pipKit?.player else {
            return
        }
        pipKit?.stopPip()
        onPipPlay()
    }
    
    func onPipPause() {
        guard let _ = pipKit?.player else {
            return
        }
        if pipKit!.player.playbackState == .playing {
            pipKit?.player.pause()
        }else if pipKit!.player.playbackState == .paused {
            pipKit?.player.play()
        }
    }
    
    func onBgpNext() {
        guard let _ = pipKit?.player else {
            return
        }
        pipKit?.startPip(withPlayerUrl: nil, bgPic: ksyPipView?.bgpURL)
    }
    
    func pipVolChange(sender: UISlider) {
        if pipKit?.player != nil && sender == ksyPipView?.volumSl{
            let vol = ksyPipView?.volumSl?.normalValue ?? 0
            pipKit?.player.setVolume(vol, rigthVolume: vol)
        }
    }
    
    // MARK: subviews: basic ctrl
    override func onQuit() {
        pipKit?.stopPip()
        super.onQuit()
    }
    
    override var shouldAutorotate: Bool {
        get{
            return super.shouldAutorotate
        }
    }
}
