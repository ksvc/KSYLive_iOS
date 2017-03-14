//
//  MonkeyTestViewController.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

class MonkeyTestViewController: UIViewController {
    
    func dispatch_main_sync_safe(_ block: @escaping () -> ()) {
        if Thread.current == Thread.main {
            block()
        }else{
            DispatchQueue.main.sync {
                block()
            }
        }
    }
    
    let RandomBooleanValue = {
        return arc4random() % 2 == 1 ? true : false
    }
    let RandomScalingMode = {
        return arc4random() % 3
    }
    let RandomMovieVideoDecoderMode = {
        return arc4random() % 3
    }
    let RandomPrepareTimeout = {
        return arc4random() % 20
    }
    let RandomReadTimeout = {
        return arc4random() % 60
    }
    let UseResetToStop = 1
    
    let kViewSpacing: CGFloat = 10
    let kButtonHeight: CGFloat = 30
    
    var player: KSYMoviePlayerController?
    var URLs: [URL]?
    var repeatTimer: Timer?
    var isRunning: Bool = false
    
    private
    var _videoView: UIView?
    var _logView: UITextView?
    var _controlButton: UIButton?
    var _quitButton: UIButton?
    var _scanButton: UIButton?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        URLs = [URL.init(string: "http://maichang.kssws.ks-cdn.com/upload20150716161913.mp4")!]
        view.frame = UIScreen.main.bounds
        view.backgroundColor = .white
        
        initUI()
        layoutUI()
        
        addObserver(self, forKeyPath: "isRunning", options: .new, context: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePlayerNofity(notify:)),
                                               name: .MPMediaPlaybackIsPreparedToPlayDidChange,
                                               object: player)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "isRunning" {
            if isRunning {
                _controlButton?.setTitle("停止", for: .normal)
            }else{
                _controlButton?.setTitle("运行", for: .normal)
            }
        }
    }
    
    // MARK: - Private methods
    private func initUI() {
        _videoView = UIView()
        _videoView?.layer.borderColor = UIColor.black.cgColor
        _videoView?.layer.borderWidth = 1
        view.addSubview(_videoView!)
        
        _controlButton = UIButton.init(type: .roundedRect)
        _controlButton?.setTitle("运行", for: .normal)
        _controlButton?.layer.borderColor = UIColor.black.cgColor
        _controlButton?.layer.borderWidth = 1
        view.addSubview(_controlButton!)
        _controlButton?.addTarget(self, action: #selector(onControlButton(sender:)), for: .touchUpInside)
        
        _quitButton = UIButton.init(type: .roundedRect)
        _quitButton?.setTitle("退出", for: .normal)
        _quitButton?.layer.borderColor = UIColor.black.cgColor
        _quitButton?.layer.borderWidth = 1
        view.addSubview(_quitButton!)
        _quitButton?.addTarget(self, action: #selector(onQuitButton(sender:)), for: .touchUpInside)

        _scanButton = UIButton.init(type: .roundedRect)
        _scanButton?.setTitle("扫码", for: .normal)
        _scanButton?.layer.borderColor = UIColor.black.cgColor
        _scanButton?.layer.borderWidth = 1
        view.addSubview(_scanButton!)
        _scanButton?.addTarget(self, action: #selector(onScanButton(sender:)), for: .touchUpInside)
        
        _logView = UITextView()
        _logView?.layer.borderColor = UIColor.black.cgColor
        _logView?.layer.borderWidth = 1
        view.addSubview(_logView!)
        _logView?.delegate = self
    }
    
    private func layoutUI() {
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        let totalWidth: CGFloat = view.frame.width
        let totalHeight: CGFloat = view.frame.height
        
        _videoView?.frame = CGRect.init(x: kViewSpacing,
                                        y: statusBarHeight + kViewSpacing,
                                        width: totalWidth - 2 * kViewSpacing,
                                        height: totalHeight / 3)
        
        _controlButton?.frame = CGRect.init(x: kViewSpacing,
                                            y: totalHeight - kViewSpacing - kButtonHeight,
                                            width: (totalWidth - 4 * kViewSpacing) / 3,
                                            height: kButtonHeight)
        
        _scanButton?.frame = CGRect.init(x: _controlButton!.frame.origin.x + _controlButton!.frame.width + kButtonHeight,
                                         y: totalHeight - kViewSpacing - kButtonHeight,
                                         width: _controlButton!.frame.width,
                                         height: kButtonHeight)
        
        _quitButton?.frame = CGRect.init(x: _scanButton!.frame.origin.x + _scanButton!.frame.width + kButtonHeight,
                                         y: totalHeight - kViewSpacing - kButtonHeight,
                                         width: _controlButton!.frame.width,
                                         height: kButtonHeight)
        
        let logViewOriginY: CGFloat = _videoView!.frame.origin.y + _videoView!.frame.height + kViewSpacing
        let logViewHeight: CGFloat = _controlButton!.frame.origin.y - kViewSpacing - logViewOriginY
        _logView?.frame = CGRect.init(x: kViewSpacing,
                                      y: logViewOriginY,
                                      width: totalWidth - 2 * kViewSpacing,
                                      height: logViewHeight)
    }
    
    private func appendDebugInfoWithString(infoString: String) {
        let newString = _logView?.text.appending(infoString)
        _logView?.text = newString
        _logView?.scrollRectToVisible(CGRect.init(x: 0, y: _logView!.contentSize.height - 15, width: _logView!.contentSize.width, height: 10),
                                      animated: true)
    }
    
    func handlePlayerNofity(notify: Notification) {
        guard let _ = player else {
            return
        }
        
        if notify.name == .MPMediaPlaybackIsPreparedToPlayDidChange {
            if player!.isPreparedToPlay {
                player!.play()
            }
        }
    }
    
    // MARK: - Player configuration
    
    func configurePlayerRandomly() {
        let randomIndex = Int(arc4random()) % URLs!.count
        let randomURL = (URLs! as NSArray).object(at: randomIndex) as? URL
        
        if player == nil {
            player = KSYMoviePlayerController.init(contentURL: randomURL)
        }else{
            player?.setUrl(randomURL)
        }
        
        player?.view.frame = _videoView!.bounds
        _videoView?.addSubview(player!.view)
        _videoView?.autoresizesSubviews = true
        
        player?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player?.controlStyle = .none
        player?.shouldEnableVideoPostProcessing = true
        
        // Random parameters
        player?.shouldAutoplay = RandomBooleanValue()
        player?.shouldEnableKSYStatModule = RandomBooleanValue()
        player?.shouldLoop = RandomBooleanValue()
        player?.scalingMode = MPMovieScalingMode(rawValue: Int(RandomScalingMode()))!
        player?.videoDecoderMode = MPMovieVideoDecoderMode(rawValue: UInt(RandomMovieVideoDecoderMode()))!
        player?.shouldMute = RandomBooleanValue()
        player?.setTimeout(Int32(RandomPrepareTimeout()), readTimeout: Int32(RandomReadTimeout()))
        
        appendDebugInfoWithString(infoString: String.init(format:
            "******************\n" +
            "URL: %@\n" +
            "shouldAutoplay = %@\n" +
            "shouldEnableKSYStatModule = %@\n" +
            "shouldLoop = %@\n" +
            "shouldMute = %@\n",
            randomURL!.absoluteString,
            player!.shouldAutoplay ? "YES" : "NO",
            player!.shouldEnableKSYStatModule ? "YES" : "NO",
            player!.shouldLoop ? "YES" : "NO",
            player!.shouldMute ? "YES" : "NO"))
        
        player?.prepareToPlay()
        
        if player!.shouldAutoplay {
            player?.play()
        }
    }

    // MARK: - Playback control
    func stopPlaying() {
        #if UseResetToStop
            player?.reset(true)
        #else
            player?.stop()
            player = nil
        #endif
        if isRunning {
            appendDebugInfoWithString(infoString: "stop\n")
            appendDebugInfoWithString(infoString: "******************\n\n")
        }
    }
    
    func rotate() {
        guard let _ = player else {
            return
        }
        
        let degree: Int = Int(arc4random()) % 4 * 90
        player?.rotateDegress = Int32(degree)
        appendDebugInfoWithString(infoString: "rotate \(degree) degrees\n")
    }
    
    func pause() {
        guard let _ = player else {
            return
        }
        
        player!.pause()
        appendDebugInfoWithString(infoString: "pause\n")
    }
    
    func resume() {
        guard let _ = player else {
            return
        }
        guard !player!.isPlaying() else {
            return
        }
        player?.play()
        appendDebugInfoWithString(infoString: "resume\n")
    }
    
    func stopAndReconfigurePlayer() {
        stopPlaying()
        configurePlayerRandomly()
    }
    
    func changeVolumeTo(volumeValue: CGFloat) {
        guard let _ = player else {
            return
        }
        player?.setVolume(Float(volumeValue), rigthVolume: Float(volumeValue))
        appendDebugInfoWithString(infoString: "volume = \(volumeValue)\n")
    }
    
    func muteSetting() {
        guard let _ = player else {
            return
        }
        player?.shouldMute = player!.shouldMute ? false : true
        appendDebugInfoWithString(infoString: "\(player!.shouldMute ? "mute" : "unmute")\n")
    }
    
    func reload() {
        guard let _ = player else {
            return
        }
        let url = player?.contentURL
        let shouldFlush = RandomBooleanValue()
        player?.reload(url, flush: shouldFlush)
        appendDebugInfoWithString(infoString: "reload \(shouldFlush ? "whit" : "without") flush\n")
    }
    
    func randomPlaybackControl() {
        if arc4random() % 3 == 0 {
            dispatch_main_sync_safe {
                self.stopAndReconfigurePlayer()
            }
        }else{
            let randomNum = arc4random() % 6
            switch randomNum {
            case 0:
                pause()
                break
            case 1:
                resume()
                break
            case 2:
                muteSetting()
                break
            case 3:
                rotate()
                break
            case 4:
                changeVolumeTo(volumeValue: CGFloat(Double(arc4random() % 101) / 100.0))
                break
            case 5:
                reload()
                break
            default:
                ()
            }
        }
    }
    
    // MARK: - Control action methods
    func onControlButton(sender: NSObject) {
        if !isRunning {
            configurePlayerRandomly()
            repeatTimer = Timer.scheduledTimer(timeInterval: 5,
                                               target: self,
                                               selector: #selector(randomPlaybackControl),
                                               userInfo: nil,
                                               repeats: true)
            isRunning = true
        }else{
            stopPlaying()
            repeatTimer?.invalidate()
            isRunning = false
        }
        
    }
    
    func onQuitButton(sender: NSObject) {
        stopPlaying()
        repeatTimer?.invalidate()
        isRunning = false
        dismiss(animated: true, completion: nil)
    }
    
    func onScanButton(sender: NSObject) {
        let URLTableVC = URLTableViewController.init(urls: URLs)
        URLTableVC.getURLs = { [weak self] (scannedURLs) -> Void in
            self?.URLs?.removeAll()
            for url in scannedURLs {
                self?.URLs?.append(url)
            }
        }
        let navVC = UINavigationController.init(rootViewController: URLTableVC)
        present(navVC, animated: true, completion: nil)
    }
    
    deinit {
        removeObserver(self, forKeyPath: "isRunning")
    }
    
}

extension MonkeyTestViewController: UITextViewDelegate {

}
