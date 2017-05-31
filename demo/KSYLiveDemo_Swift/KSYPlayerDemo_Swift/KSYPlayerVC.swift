//
//  KSYPlayerVC.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

class KSYPlayerVC: UIViewController {
    
    var url: URL!
    var reloadUrl: URL!
    var player: KSYMoviePlayerController?
    
    var stat: UILabel?
    var msg: UILabel?
    var timer: Timer?
    var lastSize: Double?
    var lastCheckTime: TimeInterval? = 0
    var serverIp: String?
    var videoView: UIView?
    var btnPlay: UIButton?
    var btnPause: UIButton?
    var btnResume: UIButton?
    var btnStop: UIButton?
    var btnQuit: UIButton?
    var btnRotate: UIButton?
    var btnContentMode: UIButton?
    var btnReload: UIButton?
    var btnMute: UIButton?
    var btnShotScreen: UIButton?
    var btnMirror: UIButton?
    
    var lableHWCodec: UILabel?
    var switchHwCodec: UISwitch?
    
    var labelVolume: UILabel?
    var sliderVolume: UISlider?
    
    var progressView: KSYProgressView?
    
    var usingReset: Bool?
    var shouldMute: Bool?
    
    var reloading: Bool?
    
    var prepared_time :Int! = 0
    var fvr_costtime: Int!
    var far_costtime: Int!
    var rotate_degress: Int!
    var content_mode: Int!
    
    var msgNum: Int?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(url: URL) {
        self.init()
        self.url = url
        reloadUrl = url
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        
        addObserver(self, forKeyPath: "player", options: .new, context: nil)
        
        let leftSwip = UISwipeGestureRecognizer.init(target: self, action: #selector(handleSwipeGesture(swip:)))
        leftSwip.direction = .left
        let rightSwip = UISwipeGestureRecognizer.init(target: self, action: #selector(handleSwipeGesture(swip:)))
        rightSwip.direction = .right
        
        let upSwip = UISwipeGestureRecognizer.init(target: self, action: #selector(handleSwipeGesture(swip:)))
        upSwip.direction = .up
        let downSwip = UISwipeGestureRecognizer.init(target: self, action: #selector(handleSwipeGesture(swip:)))
        downSwip.direction = .down
        
        view.addGestureRecognizer(leftSwip)
        view.addGestureRecognizer(rightSwip)
        view.addGestureRecognizer(upSwip)
        view.addGestureRecognizer(downSwip)
        
        // 该变量决定停止播放时使用的接口，YES时调用reset接口，NO时调用stop接口
        usingReset = true
        shouldMute = false
        progressView?.isHidden = true
    }
    
    deinit {
        removeObserver(self, forKeyPath: "player")
    }
    
    func initUI() {
        // add videoView
        videoView = UIView()
        videoView!.backgroundColor = UIColor.white
        view.addSubview(videoView!)
        
        btnPlay = addButton(with: "播放", action: #selector(onPlayVideo(sender:)))
        btnPause = addButton(with: "暂停", action: #selector(onPauseVideo(sender:)))
        btnResume = addButton(with: "继续", action: #selector(onResumeVideo(sender:)))
        btnStop = addButton(with: "停止", action: #selector(onStopVideo(sender:)))
        btnQuit = addButton(with: "退出", action: #selector(onQuit(sender:)))
        btnRotate = addButton(with: "旋转", action: #selector(onRotate(sender:)))
        btnContentMode = addButton(with: "缩放", action: #selector(onContentMode(sender:)))
        btnReload = addButton(with: "reload", action: #selector(onReloadVideo(sender:)))
        btnShotScreen = addButton(with: "截图", action: #selector(onShotScreen(sender:)))
        btnMute = addButton(with: "mute", action: #selector(onMute(sender:)))
        btnMirror = addButton(with: "镜像", action: #selector(onMirror(sender:)))
        
        stat = UILabel()
        stat?.backgroundColor = UIColor.clear
        stat?.textColor = UIColor.red
        stat?.numberOfLines = 0;
        stat?.textAlignment = .left
        view.addSubview(stat!)
        
        msg = UILabel()
        msg?.backgroundColor = UIColor.clear
        msg?.textColor = .blue
        msg?.numberOfLines = 0
        msg?.textAlignment = .left
        view.addSubview(msg!)
        
        lableHWCodec = UILabel()
        lableHWCodec?.text = "硬解码"
        lableHWCodec?.textColor = .lightGray
        view.addSubview(lableHWCodec!)
        
        labelVolume = UILabel()
        labelVolume?.text = "音量"
        labelVolume?.textColor = .lightGray
        view.addSubview(labelVolume!)
        
        switchHwCodec = UISwitch()
        view.addSubview(switchHwCodec!)
        switchHwCodec?.isOn = true
        
        sliderVolume = UISlider()
        sliderVolume?.minimumValue = 0
        sliderVolume?.maximumValue = 100
        sliderVolume?.value = 100
        sliderVolume?.addTarget(self, action: #selector(onVolumeChanged(slider:)), for: .valueChanged)
        view.addSubview(sliderVolume!)
        
        progressView = KSYProgressView()
        view.addSubview(progressView!)
        
        layoutUI()
        
        view.bringSubview(toFront: stat!)
        stat!.frame = UIScreen.main.bounds
        
        view.bringSubview(toFront: msg!)
        msg!.frame = UIScreen.main.bounds
    }
    
    func addButton(with title: String, action: Selector) -> UIButton {
        let btn = UIButton.init(type: .roundedRect)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = UIColor.lightGray
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 5
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 1
        view.addSubview(btn)
        return btn
    }
    
    func layoutUI() {
        let wdt = view.bounds.width
        let hgt = view.bounds.height
        let gap: CGFloat = 15
        let btnWdt = (wdt - gap) / 5 - gap
        let btnHgt: CGFloat = 30
        var xPos: CGFloat = 0
        var yPos: CGFloat = 0
        
        yPos = 2 * gap
        xPos = gap
        labelVolume?.frame = CGRect.init(x: xPos,
                                         y: yPos,
                                         width: btnWdt,
                                         height: btnHgt)
        xPos += btnWdt + gap
        sliderVolume?.frame = CGRect.init(x: xPos,
                                          y: yPos,
                                          width: wdt - 3 * gap - btnWdt,
                                          height: btnHgt)
        yPos += btnHgt + gap
        xPos = gap
        lableHWCodec?.frame = CGRect.init(x: xPos,
                                          y: yPos,
                                          width: btnWdt * 2,
                                          height: btnHgt)
        xPos += btnWdt + gap
        switchHwCodec?.frame = CGRect.init(x: xPos,
                                           y: yPos,
                                           width: btnWdt,
                                           height: btnHgt)
        
        videoView?.frame = CGRect.init(x: 0,
                                       y: 0,
                                       width: wdt,
                                       height: hgt)
        
        xPos = gap
        yPos = hgt - btnHgt - gap
        btnPlay?.frame = CGRect.init(x: xPos,
                                     y: yPos,
                                     width: btnWdt,
                                     height: btnHgt)
        xPos += gap + btnWdt
        btnPause?.frame = CGRect.init(x: xPos,
                                      y: yPos,
                                      width: btnWdt,
                                      height: btnHgt)
        xPos += gap + btnWdt
        btnResume?.frame = CGRect.init(x: xPos,
                                      y: yPos,
                                      width: btnWdt,
                                      height: btnHgt)
        xPos += gap + btnWdt
        btnStop?.frame = CGRect.init(x: xPos,
                                      y: yPos,
                                      width: btnWdt,
                                      height: btnHgt)
        xPos += gap + btnWdt
        btnQuit?.frame = CGRect.init(x: xPos,
                                      y: yPos,
                                      width: btnWdt,
                                      height: btnHgt)
        
        xPos = gap
        yPos -= btnHgt + gap
        btnRotate?.frame = CGRect.init(x: xPos,
                                       y: yPos,
                                       width: btnWdt,
                                       height: btnHgt)
        xPos += gap + btnWdt
        btnContentMode?.frame = CGRect.init(x: xPos,
                                       y: yPos,
                                       width: btnWdt,
                                       height: btnHgt)
        xPos += gap + btnWdt
        btnShotScreen?.frame = CGRect.init(x: xPos,
                                       y: yPos,
                                       width: btnWdt,
                                       height: btnHgt)
        xPos += gap + btnWdt
        btnReload?.frame = CGRect.init(x: xPos,
                                       y: yPos,
                                       width: btnWdt,
                                       height: btnHgt)
        xPos += gap + btnWdt
        btnMute?.frame = CGRect.init(x: xPos,
                                       y: yPos,
                                       width: btnWdt,
                                       height: btnHgt)
        
        xPos = gap
        yPos -= btnHgt + gap
        btnMirror?.frame = CGRect.init(x: xPos,
                                       y: yPos,
                                       width: btnWdt,
                                       height: btnHgt)
        xPos = gap
        yPos = btnMirror!.frame.origin.y - btnHgt - gap
        progressView?.frame = CGRect.init(x: xPos,
                                          y: yPos,
                                          width: wdt - 2 * gap,
                                          height: btnHgt)
    }
    
    override var shouldAutorotate: Bool{
        layoutUI()
        return true
    }
    
    func switchControlEvent(switchControl: UISwitch) {
        if let _ = player {
            player!.shouldEnableKSYStatModule = switchControl.isOn
        }
    }
    
    func onVolumeChanged(slider: UISlider) {
        if let _ = player {
            player!.setVolume(slider.value / 100, rigthVolume: slider.value / 100)
        }
    }
    
    func switchMuteEvent(switchControl: UISwitch) {
        if let _ = player {
            player!.shouldMute = switchControl.isOn
        }
    }
    
    func MD5(raw: String) -> String {
        let cStr = raw.cString(using: String.Encoding.utf8);
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(cStr!,(CC_LONG)(strlen(cStr!)), buffer)
        let md5String = NSMutableString();
        for i in 0 ..< Int(CC_MD5_DIGEST_LENGTH){
            md5String.appendFormat("%02x", buffer[i])
        }
        free(buffer)
        return md5String as String
    }
    
    func getCurrentTime() -> TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    func handlePlayerNotify(notify: Notification) {
        guard let _ = player else {
            return
        }
        
        switch notify.name {
        case Notification.Name.MPMediaPlaybackIsPreparedToPlayDidChange:
            stat?.text = "player prepared"
            // using autoPlay to start live stream
            serverIp = player?.serverAddress
            print("KSYPlayerVC: \(player?.contentURL.absoluteString) -- ip:\(serverIp)")
            StartTimer()
            prepared_time = Int(getCurrentTime() * 1000)
            reloading = false
        case Notification.Name.MPMoviePlayerPlaybackStateDidChange:
            print("------------------------")
            print("player playback state: \(player!.playbackState)")
            print("------------------------")
        case Notification.Name.MPMoviePlayerLoadStateDidChange:
            print("player load state: \(player?.loadState)")
            if player?.loadState == MPMovieLoadState.stalled {
                stat?.text = "player start caching"
                print("player start caching")
            }
            
            if (player?.bufferEmptyCount)! > 0 &&
                player?.loadState == MPMovieLoadState.playable &&
                player?.loadState == MPMovieLoadState.playthroughOK {
                print("player finish caching")
                let message = String.init(format: "loading occurs, %d - %0.3fs", (player?.bufferEmptyCount)!, (player?.bufferEmptyDuration)!)
                toast(message: message)
            }
        case Notification.Name.MPMoviePlayerPlaybackDidFinish:
            print("player finish state: \(player!.playbackState)")
            print("player download flow size: \(player!.readSize) MB")
            print("buffer monitor  result: \n   empty count: \(player!.bufferEmptyCount), lasting: \(player!.bufferEmptyDuration) seconds")
            let reason = MPMovieFinishReason(rawValue: (notify.userInfo?[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! NSNumber).intValue)!
            switch reason {
            case MPMovieFinishReason.playbackEnded:
                stat?.text = "player finish"
                break
            case MPMovieFinishReason.playbackError:
                stat?.text = "player Error : \(notify.userInfo?["error"])"
                break
            case MPMovieFinishReason.userExited:
                stat?.text = "player userExited"
                break
            }
            StopTimer()
        case Notification.Name.MPMovieNaturalSizeAvailable:
            print("video size %.0f-%.0f", player?.naturalSize.width ?? 0, player?.naturalSize.height ?? 0)
        case Notification.Name.MPMoviePlayerFirstVideoFrameRendered:
            fvr_costtime = Int(getCurrentTime() * 1000) - prepared_time
            print("first video frame show, cost time : \(fvr_costtime)ms!\n")
        case Notification.Name.MPMoviePlayerFirstAudioFrameRendered:
            far_costtime = Int(getCurrentTime() * 1000) - prepared_time
            print("first audio frame render, cost time : \(far_costtime)ms!\n")
        case Notification.Name.MPMoviePlayerSuggestReload:
            print("suggest using reload function!\n")
            if !(reloading ?? false) {
                reloading = true
                DispatchQueue.global().async { [weak self] in
                    if let _ = self?.player {
                        print("reload stream")
                        self?.player?.reload(self?.reloadUrl, flush: true, mode: .accurate)
                    }
                }
            }
        case Notification.Name.MPMoviePlayerPlaybackStatus:
            let status = MPMovieStatus(rawValue: (notify.userInfo?[MPMoviePlayerPlaybackStatusUserInfoKey] as! NSNumber).intValue)!
            switch status {
            case MPMovieStatus.videoDecodeWrong:
                print("Video Decode Wrong!")
            case MPMovieStatus.audioDecodeWrong:
                print("Audio Decode Wrong!")
            case MPMovieStatus.hwCodecUsed:
                print("Hardware Codec used!")
            case MPMovieStatus.swCodecUsed:
                print("Software Codec used!")
            default: break
            }
        default:
            ()
        }
    }
    
    func toast(message: String) {
        let toast = UIAlertView.init(title: nil, message: message, delegate: nil, cancelButtonTitle: nil)
        toast.show()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { 
            toast.dismiss(withClickedButtonIndex: 0, animated: true)
        }
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerNotify(notify:)), name: NSNotification.Name.MPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerNotify(notify:)), name: NSNotification.Name.MPMoviePlayerPlaybackStateDidChange, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerNotify(notify:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerNotify(notify:)), name: NSNotification.Name.MPMoviePlayerLoadStateDidChange, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerNotify(notify:)), name: NSNotification.Name.MPMovieNaturalSizeAvailable, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerNotify(notify:)), name: NSNotification.Name.MPMoviePlayerFirstVideoFrameRendered, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerNotify(notify:)), name: NSNotification.Name.MPMoviePlayerFirstAudioFrameRendered, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerNotify(notify:)), name: NSNotification.Name.MPMoviePlayerSuggestReload, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerNotify(notify:)), name: NSNotification.Name.MPMoviePlayerPlaybackStatus, object: player)
    }
    
    func releaseObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initPlayer(withURL aUrl: URL) {
        lastSize = 0
        player = KSYMoviePlayerController.init(contentURL: aUrl)
        setupObservers()
        player!.logBlock = { (logJson) -> Void in
            print("logJson is \(logJson)")
        }
        
        player!.messageDataBlock = {[weak self] (message, pts, param) -> Void in
            if let msg = message {
                var msgString = ""
                for obj in msg.values {
                    msgString.append("\"\(obj)\":\"\(msg[obj as! NSObject])\"\n")
                }
                self?.updateMsg(msgString: msgString)
            }
        }
        
        stat?.text = "url \(aUrl)"
        player?.controlStyle = MPMovieControlStyle.none
        player!.view.frame = videoView!.bounds
        videoView!.addSubview(player!.view)
        videoView?.bringSubview(toFront: stat!)
        videoView?.autoresizesSubviews = true
        player!.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        player!.shouldAutoplay = true
        player!.shouldEnableVideoPostProcessing = true
        player!.scalingMode = .aspectFit
        content_mode = player!.scalingMode.rawValue + 1
        if content_mode > MPMovieScalingMode.fill.rawValue {
            content_mode = MPMovieScalingMode.none.rawValue
        }
        
        player!.videoDecoderMode = switchHwCodec!.isOn ? MPMovieVideoDecoderMode.hardware : MPMovieVideoDecoderMode.software
        player!.shouldMute = shouldMute!
        player!.shouldEnableKSYStatModule = true
        player!.shouldLoop = false
        player!.deinterlaceMode = MPMovieVideoDeinterlaceMode.auto
        player!.setTimeout(10, readTimeout: 60)
        
        player!.addObserver(self, forKeyPath: "currentPlaybackTime", options: .new, context: nil)
        player!.addObserver(self, forKeyPath: "clientIP", options: .new, context: nil)
        player!.addObserver(self, forKeyPath: "localDNSIP", options: .new, context: nil)
        
        print("sdk version:\(player!.getVersion())")
        prepared_time = Int(getCurrentTime() * 1000)
        player!.prepareToPlay()
    }
    
    func didFinishSaving(image: UIImage, error: NSError?, contextInfo: UnsafeMutableRawPointer) {
        if let _ = error {
            let toast = UIAlertView.init(title: "￣へ￣", message: "缩略图截取失败！", delegate: nil, cancelButtonTitle: "确定")
            toast.show()
        }else{
            let toast = UIAlertView.init(title: "O(∩_∩)O~~", message: "截图已保存至手机相册", delegate: nil, cancelButtonTitle: "确定")
            toast.show()
        }
    }

    func onShotScreen(sender: NSObject) {
        guard let _ = player else {
            return
        }
        let thumbnailImage = player!.thumbnailImageAtCurrentTime()
        UIImageWriteToSavedPhotosAlbum(thumbnailImage!, self, #selector(didFinishSaving(image:error:contextInfo:)), nil)
    }
    
    func onPlayVideo(sender: NSObject) {
        if let _ = player {
            player!.setUrl(URL.init(string: "rtmp://live.hkstv.hk.lxdns.com/live/hks"))
            player!.prepareToPlay()
        }else{
            initPlayer(withURL: url!)
        }
    }
    
    func onReloadVideo(sender: NSObject) {
        guard let _ = player else {
            return
        }
        player!.reload(reloadUrl, flush: true, mode: .accurate)
    }
    
    func onPauseVideo(sender: NSObject) {
        guard let _ = player else {
            return
        }
        player!.pause()
    }
    
    func onResumeVideo(sender: NSObject) {
        guard let _ = player else {
            return
        }
        player!.play()
        StartTimer()
    }
    
    func onStopVideo(sender: NSObject) {
        guard let _ = player else {
            return
        }
        print("player download flow size: \(player!.readSize) MB")
        print("buffer monitor  result: \n   empty count: \(player!.bufferEmptyCount), lasting: \(player!.bufferEmptyDuration) seconds")
        if let _ = usingReset {
            player!.reset(false)
        }else{
            player!.stop()
            
            player!.removeObserver(self, forKeyPath: "currentPlaybackTime")
            player!.removeObserver(self, forKeyPath: "clientIP")
            player!.removeObserver(self, forKeyPath: "localDNSIP")
            
            releaseObservers()
            
            player!.view.removeFromSuperview()
            player = nil
        }
        StopTimer()
    }
    
    func StartTimer() {
        progressView?.totalTimeInSeconds = Float((player?.duration)!)
        if let _ = timer {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateStat(time:)), userInfo: nil, repeats: true)
    }
    
    func StopTimer() {
        guard let _ = timer else {
            return
        }
        timer?.invalidate()
        timer = nil
    }
    
    func updateStat(time: Timer) {
        if 0 == lastCheckTime {
            lastCheckTime = getCurrentTime()
            return
        }
        
        guard let _ = player else {
            return
        }
        let flowSize = player!.readSize
        let meta = player!.getMetadata()
        let info = player!.qosInfo

        let infoStr = String.init(format:
            "SDK版本:v%@\n" +
            "播放器实例:%p\n" +
            "拉流URL:%@\n" +
            "服务器IP:%@\n" +
            "客户端IP:%@\n" +
            "本地DNS IP:%@\n" +
            "分辨率:(宽-高: %.0f-%.0f)\n" +
            "已播时长:%.1fs\n" +
            "缓存时长:%.1fs\n" +
            "视频总长%.1fs\n" +
            "cache次数:%.1fs/%ld\n" +
            "最大缓冲时长:%.1fs\n" +
            "速度: %0.1f kbps\n视频/音频渲染用时:%dms/%dms\n" +
            "HTTP连接用时:%ldms\n" +
            "DNS解析用时:%ldms\n" +
            "首包到达用时（连接建立后）:%ldms\n" +
            "音频缓冲队列长度:%.1fMB\n" +
            "音频缓冲队列时长:%.1fs\n" +
            "已下载音频数据量:%.1fMB\n" +
            "视频缓冲队列长度:%.1fMB\n" +
            "视频缓冲队列时长:%.1fs\n" +
            "已下载视频数据量:%.1fMB\n" +
            "已下载总数据量%.1fMB\n" +
            "解码帧率:%.2f 显示帧率:%.2f\n",
            
            player!.getVersion(),
            player!,
            player!.contentURL.absoluteString,
            serverIp!,
            player!.clientIP,
            player!.localDNSIP,
            player!.naturalSize.width,player!.naturalSize.height,
            player!.currentPlaybackTime,
            player!.playableDuration,
            player!.duration,
            player!.bufferEmptyDuration,player!.bufferEmptyCount,
            player!.bufferTimeMax,
            8*1024.0*(flowSize - lastSize!)/(getCurrentTime() - lastCheckTime!),
            fvr_costtime, far_costtime,
            (meta![kKSYPLYHttpConnectTime] as? NSNumber ?? 0).intValue,
            (meta![kKSYPLYHttpAnalyzeDns] as? NSNumber ?? 0).intValue,
            (meta![kKSYPLYHttpFirstDataTime] as? NSNumber ?? 0).intValue,
            Float(Double(info!.audioBufferByteLength) / 1e6),
            Float(Double(info!.audioBufferTimeLength) / 1e3),
            Float(Double(info!.audioTotalDataSize) / 1e6),
            Float(Double(info!.videoBufferByteLength) / 1e6),
            Float(Double(info!.videoBufferTimeLength) / 1e3),
            Float(Double(info!.videoTotalDataSize) / 1e6),
            Float(Double(info!.totalDataSize) / 1e6),
            info!.videoDecodeFPS,info!.videoRefreshFPS)
        
        stat?.text = infoStr
    }
    
    func updateCacheProgress() {
        let duration = player?.duration
        let playableDuration = player?.playableDuration
        if Double(duration!) > 0.0 {
            progressView?.cacheProgress = Float(playableDuration! / duration!)
        }else{
            progressView?.cacheProgress = 0
        }
    }
    
    func onQuit(sender: NSObject) {
        if let _ = player {
            player!.stop()
            player!.removeObserver(self, forKeyPath: "currentPlaybackTime", context: nil)
            player!.removeObserver(self, forKeyPath: "clientIP", context: nil)
            player!.removeObserver(self, forKeyPath: "localDNSIP", context: nil)
            releaseObservers()
            
            player!.view.removeFromSuperview()
            player = nil
        }
        
        StopTimer()
        dismiss(animated: false, completion: nil)
        stat?.text = nil
        msg?.text = nil
    }

    func onRotate(sender: NSObject) {
        guard let _ = player else {
            return
        }
        rotate_degress = Int(player!.rotateDegress)
        rotate_degress! += 90
        if rotate_degress >= 360 {
            rotate_degress = 0
        }
        player!.rotateDegress = Int32(Int(rotate_degress))
    }
    
    func onMute(sender: NSObject) {
        guard let _ = player else {
            return
        }
        shouldMute = shouldMute! ? false : true
        player!.shouldMute = shouldMute!
    }
    
    func onMirror(sender: NSObject) {
        guard let _ = player else {
            return
        }
        
        player!.mirror = !player!.mirror
    }
    
    func onContentMode(sender: NSObject) {
        if let _ = player {
            player!.scalingMode = MPMovieScalingMode(rawValue: content_mode)!
        }
        content_mode! += 1
        if content_mode > MPMovieScalingMode.fill.rawValue {
            content_mode = MPMovieScalingMode.none.rawValue
        }
    }
    
    func remoteControlReceivedWithEvent(receivedEvent: UIEvent) {
        if receivedEvent.type == .remoteControl {
            switch receivedEvent.subtype {
            case .remoteControlPlay:
                player?.play()
                print("play")
                break
            case .remoteControlPause:
                player?.pause()
                print("pause")
                break
            case .remoteControlPreviousTrack: break
            case .remoteControlNextTrack: break
            default:
                ()
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentPlaybackTime" {
            guard let _ = player else {
                return
            }
            progressView?.playProgress = Float(player!.currentPlaybackTime / player!.duration)
        }else if keyPath == "clientIP" {
            if let theChange = change {
                if let approvedNew = theChange[.newKey]{
                    print("client IP is \(approvedNew)\n")
                } 
            }
        }else if keyPath == "localDNSIP" {
            if let theChange = change {
                if let approvedNew = theChange[.newKey]{
                    print("local DNS IP is \(approvedNew)\n")
                }
            }
        }else if keyPath == "player" {
            guard let _ = player else {
                progressView?.isHidden = true
                return
            }
            
            progressView?.isHidden = false
            progressView?.dragingSliderCallback = { [weak self] (progress: Float) -> Void in
                guard let _ = self?.player else{
                    return
                }
                let seekPos = progress * Float((self?.player!.duration)!)
                //strongPlayer.currentPlaybackTime = progress * strongPlayer.duration;
                //使用currentPlaybackTime设置为依靠关键帧定位
                //使用seekTo:accurate并且将accurate设置为YES时为精确定位
                self?.player?.seek(to: Double(seekPos), accurate: true)
            }
        }
    }
    
    func handleSwipeGesture(swip: UISwipeGestureRecognizer) {
        switch swip.direction {
        case UISwipeGestureRecognizerDirection.right:
            if let originalFrame = stat?.frame {
                stat?.frame = CGRect.init(x: 0,
                                          y: originalFrame.origin.y,
                                          width: originalFrame.width,
                                          height: originalFrame.height)
            }
        case UISwipeGestureRecognizerDirection.left:
            if let originalFrame = stat?.frame {
                stat?.frame = CGRect.init(x: -originalFrame.size.width,
                                          y: originalFrame.origin.y,
                                          width: originalFrame.width,
                                          height: originalFrame.height)
            }
        case UISwipeGestureRecognizerDirection.down:
            if let originalFrame = stat?.frame {
                stat?.frame = CGRect.init(x: 0,
                                          y: originalFrame.origin.y,
                                          width: originalFrame.width,
                                          height: originalFrame.height)
            }
        case UISwipeGestureRecognizerDirection.up:
            if let originalFrame = stat?.frame {
                stat?.frame = CGRect.init(x: -originalFrame.size.width,
                                          y: originalFrame.origin.y,
                                          width: originalFrame.width,
                                          height: originalFrame.height)
            }
        default:
            ()
        }
    }
    
    func updateMsg(msgString: String) {
        if msgNum == 0 {
            msg?.text = "message is : \n"
        }
        msg?.text = msg?.text?.appending("\n")
        msg?.text = msg?.text?.appending(msgString)
        if msgNum! + 1 >= 3 {
            msgNum = 0
        }
    }
    
}
