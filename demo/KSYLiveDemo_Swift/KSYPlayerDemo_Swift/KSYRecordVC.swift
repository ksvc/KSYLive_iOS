//
//  KSYRecordVC.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 2017/1/23.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

class KSYRecordVC: UIViewController {
    var url: URL!
    var player: KSYMoviePlayerController?
    var kit: KSYUIRecorderKit?
    
    var stat: UILabel!
    var videoView: UIView!
    var btnPlay: UIButton!
    var btnPause: UIButton!
    var btnResume: UIButton!
    var btnStop: UIButton!
    var btnQuit: UIButton!
    
    var labelHWCodec: UILabel!
    var switchHWCodec: UISwitch!
    
    var labelVolume: UILabel!
    var sliderVolume: UISlider!
    
    var btnStartRecord: UIButton!
    var btnStopRecord: UIButton!
    
    var recordFilePath: String!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(url: URL) {
        self.init()
        self.url = url
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        setupUIKit()
    }

    func initUI() {
        videoView = UIView()
        videoView.backgroundColor = .white
        view.addSubview(videoView)
        
        btnPlay = addButton(with: "播放", action: #selector(onPlayVideo(sender:)))
        btnPause = addButton(with: "暂停", action: #selector(onPauseVideo(sender:)))
        btnResume = addButton(with: "继续", action: #selector(onResumeVideo(sender:)))
        btnStop = addButton(with: "停止", action: #selector(onStopVideo(sender:)))
        btnQuit = addButton(with: "退出", action: #selector(onQuit(sender:)))
        btnStartRecord = addButton(with: "开始录屏", action: #selector(onStartRecordVideo(sender:)))
        btnStopRecord = addButton(with: "停止录屏", action: #selector(onStopRecordVideo(sender:)))
        btnStartRecord.isEnabled = false
        btnStopRecord.isEnabled = false
        
        stat = UILabel()
        stat.backgroundColor = .clear
        stat.textColor = .red
        stat.numberOfLines = 0
        stat.textAlignment = .left
        view.addSubview(stat)
        
        labelHWCodec = UILabel()
        labelHWCodec.text = "硬解码"
        labelHWCodec.textColor = .lightGray
        view.addSubview(labelHWCodec)
        
        labelVolume = UILabel()
        labelVolume.text = "音量"
        labelVolume.textColor = .lightGray
        view.addSubview(labelVolume)
        
        switchHWCodec = UISwitch()
        view.addSubview(switchHWCodec)
        switchHWCodec.isOn = true
        
        sliderVolume = UISlider()
        sliderVolume.minimumValue = 0
        sliderVolume.maximumValue = 100
        sliderVolume.value = 100
        sliderVolume.addTarget(self, action: #selector(onVolumeChanged(slider:)), for: .valueChanged)
        view.addSubview(sliderVolume)
        
        layoutUI()
        
        view.bringSubview(toFront: stat)
        stat.frame = UIScreen.main.bounds
    }
    
    func addButton(with title: String, action: Selector) -> UIButton {
        let btn = UIButton.init(type: .roundedRect)
        
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = .lightGray
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 5
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 1
        
        view.addSubview(btn)
        
        return btn
    }

    func layoutUI() {
        let wdt: CGFloat = view.bounds.width
        let hgt: CGFloat = view.bounds.height
        let gap: CGFloat = 15
        let btnWdt: CGFloat = (wdt - gap) / 5 - gap
        let btnHgt: CGFloat = 30
        var xPos: CGFloat = 0
        var yPos: CGFloat = 0
        
        yPos = gap * 2
        xPos = gap
        labelVolume.frame = CGRect.init(x: xPos,
                                        y: yPos,
                                        width: btnWdt,
                                        height: btnHgt)
        xPos += btnWdt + gap
        sliderVolume.frame = CGRect.init(x: xPos,
                                         y: yPos,
                                         width: wdt - 3 * gap - btnWdt,
                                         height: btnHgt)
        yPos += btnHgt + gap
        xPos = gap
        labelHWCodec.frame = CGRect.init(x: xPos,
                                         y: yPos,
                                         width: btnWdt * 2,
                                         height: btnHgt)
        xPos += btnWdt + gap
        switchHWCodec.frame = CGRect.init(x: xPos,
                                          y: yPos,
                                          width: btnWdt,
                                          height: btnHgt)
        
        videoView.frame = CGRect.init(x: 0,
                                      y: 0,
                                      width: wdt,
                                      height: hgt)
        
        xPos = gap
        yPos = hgt - btnHgt - gap
        btnPlay.frame = CGRect.init(x: xPos,
                                    y: yPos,
                                    width: btnWdt,
                                    height: btnHgt)
        xPos += gap + btnWdt
        btnPause.frame = CGRect.init(x: xPos,
                                     y: yPos,
                                     width: btnWdt,
                                     height: btnHgt)
        
        xPos += gap + btnWdt
        btnResume.frame = CGRect.init(x: xPos,
                                     y: yPos,
                                     width: btnWdt,
                                     height: btnHgt)
        xPos += gap + btnWdt
        btnStop.frame = CGRect.init(x: xPos,
                                     y: yPos,
                                     width: btnWdt,
                                     height: btnHgt)
        xPos += gap + btnWdt
        btnQuit.frame = CGRect.init(x: xPos,
                                     y: yPos,
                                     width: btnWdt,
                                     height: btnHgt)
        
        xPos = gap
        yPos -= btnHgt + gap
        
        let newWidth: CGFloat = btnWdt * 2
        btnStartRecord.frame = CGRect.init(x: xPos,
                                           y: yPos,
                                           width: newWidth,
                                           height: btnHgt)
        xPos += gap + newWidth
        btnStopRecord.frame = CGRect.init(x: xPos,
                                          y: yPos,
                                          width: newWidth,
                                          height: btnHgt)
    }
    
    func handlePlayerNotify(notify: Notification) {
        guard let _ = player else {
            return
        }
        
        if Notification.Name.MPMoviePlayerPlaybackDidFinish == notify.name {
            let reason: Int = (notify.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! NSNumber).intValue
            if reason == MPMovieFinishReason.playbackEnded.rawValue {
                stat.text = "player finish";
            }else if reason == MPMovieFinishReason.playbackError.rawValue {
                stat.text = "player Error : \(notify.userInfo!["error"])"
            }else if reason == MPMovieFinishReason.userExited.rawValue {
                stat.text = "player userExited"
            }
        }
    }
    
    func toast(message: String) {
        let toast = UIAlertView.init(title: nil,
                                     message: message,
                                     delegate: nil,
                                     cancelButtonTitle: nil)
        toast.show()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            toast.dismiss(withClickedButtonIndex: 0, animated: true)
        }
    }
    
    func initPlayer(with url: URL) {
        player = KSYMoviePlayerController.init(contentURL: self.url, sharegroup: GPUImageContext.sharedImageProcessing().context.sharegroup)
        
        setupObservers()
        
        // player 视频数据输入
        player?.textureBlock = { [weak self] (textureId: GLuint, width: Int32, height: Int32, pts: Double) -> Void in
            let size = CGSize.init(width: CGFloat(width), height: CGFloat(height))
            let _pts = CMTime.init(value: Int64(pts * 1000), timescale: 1000)
            self?.kit?.process(with: textureId, textureSize: size, time: _pts)
        }
        
        // player 音频数据输入
        player?.audioDataBlock = { [weak self] (buf) -> Void in
            let pts = CMSampleBufferGetPresentationTimeStamp(buf!)
            if pts.value < 0 {
                print("audio pts < 0")
                return
            }
            self?.kit?.processAudioSampleBuffer(buf: buf!)
        }
        
        player?.videoDecoderMode = switchHWCodec.isOn ? MPMovieVideoDecoderMode.hardware : MPMovieVideoDecoderMode.software
        player?.view.frame = videoView.bounds
        videoView.addSubview(player!.view)
        videoView.bringSubview(toFront: stat)
        
        player?.prepareToPlay()
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerNotify(notify:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(onStreamStateChange(notify:)), name: NSNotification.Name.KSYStreamStateDidChange, object: nil)
    }
    
    func releaseObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: player)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.KSYStreamStateDidChange, object: nil)
    }
    
    func onVolumeChanged(slider: UISlider) {
        guard let _ = player else {
            return
        }
        player!.setVolume(slider.value / 100, rigthVolume: slider.value / 100)
    }
    
    func onPlayVideo(sender: NSObject) {
        if let _ = player {
            player!.setUrl(URL.init(string: "rtmp://live.hkstv.hk.lxdns.com/live/hks"))
            player!.prepareToPlay()
        } else {
            initPlayer(with: url)
            btnStartRecord.isEnabled = true
            btnStopRecord.isEnabled = false
        }
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
    }
    
    func onStopVideo(sender: UIButton?) {
        guard let _ = player else {
            return
        }
        player!.stop()
        releaseObservers()
        player!.view.removeFromSuperview()
        player = nil
    }
    
    func onQuit(sender: NSObject) {
        onStopVideo(sender: nil)
        dismiss(animated: false, completion: nil)
        stat.text = nil
    }
    
    func onStartRecordVideo(sender: NSObject) {
        guard let _ = recordFilePath else {
            return
        }
        deleteFile(file: recordFilePath!)
        let path: URL = URL.init(string: recordFilePath!)!
        kit?.startRecord(path: path)
        btnStartRecord.isEnabled = false
        btnStopRecord.isEnabled = true
    }
    
    func onStopRecordVideo(sender: NSObject) {
        kit?.stopRecord()
        btnStartRecord.isEnabled = true
        btnStopRecord.isEnabled = false
    }
    
    // MARK: record kit setup
    func setupUIKit() {
        recordFilePath = (NSHomeDirectory() as NSString).appendingPathComponent("Documents/RecordAv.mp4")
        kit = KSYUIRecorderKit()
        addUIToKit()
    }
    
    func addUIToKit() {
        kit?.contentView.addSubview(labelVolume)
        kit?.contentView.addSubview(sliderVolume)
        kit?.contentView.addSubview(labelHWCodec)
        kit?.contentView.addSubview(switchHWCodec)
        kit?.contentView.addSubview(btnPlay)
        kit?.contentView.addSubview(btnPause)
        kit?.contentView.addSubview(btnResume)
        kit?.contentView.addSubview(btnStopRecord)
        kit?.contentView.addSubview(btnQuit)
        kit?.contentView.addSubview(btnStartRecord)
        kit?.contentView.addSubview(btnStopRecord)
        kit?.contentView.addSubview(stat)
        
        if let _ = player {
            kit?.contentView.addSubview((player?.view)!)
        }
        view.addSubview((kit?.contentView)!)
        kit?.contentView.sendSubview(toBack: videoView)
    }
    
    func onStreamError(errCode: KSYStreamErrorCode) {
        switch errCode {
        case KSYStreamErrorCode.CONNECT_BREAK:
            // Reconnect
            tryReconnect()
            break
        case KSYStreamErrorCode.AV_SYNC_ERROR:
            print("audio video is not synced, please check timestamp")
            tryReconnect()
            break
        case KSYStreamErrorCode.CODEC_OPEN_FAILED:
            print("video codec open failed, try software codec")
            kit?.writer?.videoCodec = KSYVideoCodec.X264
            tryReconnect()
            break
        default:
            ()
        }
    }
    
    func onStreamStateChange(notify: Notification) {
        guard let _ = kit?.writer else {
            return
        }
        
        print("stream State \(kit!.writer!.getCurStreamStateName())")
        
        // 状态为KSYStreamStateIdle且_bRecord为true时，录制视频
        if kit!.writer!.streamState == KSYStreamState.idle && !kit!.bPlayRecord {
            saveVideoToAlbum(path: recordFilePath)
        }
        
        if kit!.writer!.streamState == KSYStreamState.error {
            onStreamError(errCode: kit!.writer!.streamErrorCode)
        }
    }
    
    func tryReconnect() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            print("try again")
            let path: URL = URL.init(string: (self?.recordFilePath)!)!
            self?.kit?.startRecord(path: path)
        }
    }
    
    //保存视频到相簿
    func saveVideoToAlbum(path: String) {
        let fm = FileManager.default
        if !fm.fileExists(atPath: path) {
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(self?.didFinishSaving(videoPath:error:contextInfo:)), nil)
            }
        }
    }
    
    //保存mp4文件完成时的回调
    func didFinishSaving(videoPath: String, error: Error?, contextInfo: UnsafeMutableRawPointer) {
        var msg: String
        if let _ = error {
            msg = "Failed to save the album!"
        } else {
            msg = "Save album success!"
        }
        toast(message: msg)
    }
    
    //删除文件,保证保存到相册里面的视频时间是更新的
    func deleteFile(file: String) {
        let fm = FileManager.default
        if fm.fileExists(atPath: file) {
            try! fm.removeItem(atPath: file)
        }
    }
    
    override var shouldAutorotate: Bool{
        layoutUI()
        return true
    }
}
