//
//  KSYStreamerVC.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

/**
 KSY 推流SDK的主要演示视图
 
 主要演示了SDK 提供的API的基本使用方法
 */

// 为防止将手机存储写满,限制录像时长为30s
let REC_MAX_TIME = 30   //录制视频的最大时间，单位s


class KSYStreamerVC: KSYUIVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var bAutoStart: Bool = false
    var presetCfgView: KSYPresetCfgView?
    
    var ctrlView: KSYCtrlView?          /// 摄像头的基本控制视图
    var menuNames: [String]?
    var ksyBgmView: KSYBgmView?         /// 背景音乐配置页面
    var ksyFilterView: KSYFilterView?   /// 视频滤镜相关参数配置页面
    var audioView: KSYAudioCtrlView?    /// 声音配置页面
    var miscView: KSYMiscView?          /// 其他功能配置页面
    
    var kit: KSYGPUStreamerKit?
    
    var hostURL: NSURL?                  /// 推流地址 完整的URL
    
    private
    var _swipeGest: UISwipeGestureRecognizer?
    var _dateFormatter: DateFormatter?
//    var _obsDict: [Selector: Notification]?
    var _strSeconds: Int = 0                    // 推流持续的时间 , 单位s
    
    // 旁路录制:一边推流到rtmp server, 一边录像到本地文件
    // 本地录制:直接存储到本地
    var _bRecord: Bool? = false              //是推流还是录制到本地
    var _bypassRecFile: String?              // 旁路录制
    
    var _foucsCursor: UIImageView?           //对焦框
    var _currentPinchZoomFactor: CGFloat?     //当前触摸缩放因子
    
//    override init() {
//        super.init()
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     @abstract   构造函数
     @param      presetCfgView    含有用户配置的启动参数的视图 (前一个页面)
     @discussion presetCfgView 为nil时, 使用默认参数
     */
    init(Cfg presetCfgView: KSYPresetCfgView) {
        super.init()
        self.presetCfgView = presetCfgView
        menuNames = ["背景音乐", "图像/美颜", "声音", "其他"]
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if kit == nil {
            kit = KSYGPUStreamerKit.init(defaultCfg: ())
        }
        
        addSubViews()
        addSwipeGesture()
        addFoucsCursor()
        addPinchGestureRecognizer()
        if presetCfgView!.profileUI!.selectedSegmentIndex != 0 {
            setCustomizeCfg()
        }else{
            kit?.streamerProfile = KSYStreamerProfile(rawValue: presetCfgView!.curProfileIdx)!
        }
        
        // 采集相关设置初始化
        setCaptureCfg()
        //推流相关设置初始化
        setStreamerCfg()
        // 打印版本号信息
        print("version: \(kit?.getKSYVersion())")
        
        if kit != nil {
            kit?.videoOrientation = UIApplication.shared.statusBarOrientation
            kit?.setupFilter(ksyFilterView!.curFilter)
            kit?.startPreview(view)
        }
        setupLogo()
        _bypassRecFile = NSHomeDirectory().appending("/Library/Caches/rec.mp4")
        kit?.streamerBase.bypassRecordStateChange = { [weak self] (state) -> Void in
            self?.onBypassRecordStateChange(newState: state)
        }
    }
    
    func addSwipeGesture() {
        let onSwip: Selector = #selector(swipeController(swipGes:))
        _swipeGest = UISwipeGestureRecognizer.init(target: self, action: onSwip)
        
        _swipeGest?.direction = [.left, .right]
        view.addGestureRecognizer(_swipeGest!)
    }
    
    func addFoucsCursor() {
        _foucsCursor = UIImageView.init(image: UIImage.init(named: "camera_focus_red"))
        _foucsCursor?.frame = CGRect.init(x: 80, y: 80, width: 80, height: 80)
        view.addSubview(_foucsCursor!)
        _foucsCursor?.alpha = 0
    }
    
    func addSubViews() {
        ctrlView = KSYCtrlView.init(menuNames: menuNames!)
        view.addSubview(ctrlView!)
        ctrlView?.frame = view.frame
        ksyFilterView = KSYFilterView.init(withParent: ctrlView!)
        ksyBgmView = KSYBgmView.init(withParent: ctrlView!)
        audioView = KSYAudioCtrlView.init(withParent: ctrlView!)
        miscView = KSYMiscView.init(withParent: ctrlView!)
        
        // connect UI
        ctrlView?.onBtnBlock = { [weak self] (sender) -> Void in
            self?.onBasicCtrl(btn: sender)
        }
        
        // bgmView
        ksyBgmView?.onBtnBlock = { [weak self] (sender) -> Void in
            self?.onBgmBtnPress(btn: sender as! UIButton)
        }
        
        ksyBgmView?.onSliderBlock = { [weak self] (sender) -> Void in
            self?.onBgmVolume(sl: sender as! UIView)
        }

        ksyBgmView?.onSegCtrlBlock = { [weak self] (sender) -> Void in
            self?.onBgmCtrSle(sender: sender as! UISegmentedControl)
        }

        // filter view
        ksyFilterView?.onSegCtrlBlock = { [weak self] (sender) -> Void in
            self?.onFilterChange(sender: sender)
        }
        ksyFilterView?.onBtnBlock = { [weak self] (sender) -> Void in
            self?.onFilterBtn(sender: sender)
        }
        ksyFilterView?.onSwitchBlock = { [weak self] (sender) -> Void in
            self?.onFilterSwitch(sender: sender)
        }

        // audio view
        audioView?.onSwitchBlock = { [weak self] (sender) -> Void in
            self?.onAMixerSwitch(sw: sender as! UISwitch)
        }
        
        audioView?.onSliderBlock = { [weak self] (sender) -> Void in
            self?.onAMixerSlider(slider: sender as! UIView)
        }
        
        audioView?.onSegCtrlBlock = { [weak self] (sender) -> Void in
            self?.onAMixerSegCtrl(seg: sender as! UISegmentedControl)
        }
        
        // other
        miscView?.onBtnBlock = { [weak self] (sender) -> Void in
            self?.onMiscBtns(sender: sender)
        }
        
        miscView?.onSwitchBlock = { [weak self] (sender) -> Void in
            self?.onMiscSwitch(sw: sender as! UISwitch)
        }
        
        miscView?.onSliderBlock = { [weak self] (sender) -> Void in
            self?.onMiscSlider(slider: sender as! KSYNameSlider)
        }
        
        miscView?.onSegCtrlBlock = { [weak self] (sender) -> Void in
            self?.onMisxSegCtrl(seg: sender as! UISegmentedControl)
        }
        
        onNetworkChange = { [weak self] (msg) -> Void in
            self?.ctrlView?.lblNetwork?.text = msg
        }
    }
    
    override func addObservers() {
        super.addObservers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onCaptureStateChange(not:)), name: NSNotification.Name.KSYCaptureStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onStreamStateChange(not:)), name: NSNotification.Name.KSYStreamStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNetStateEvent(not:)), name: NSNotification.Name.KSYNetStateEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onBgmPlayerStateChange(not:)), name: NSNotification.Name.KSYAudioStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterBg(not:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(becameActive(not:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        
    }
    
    override func rmObservers() {
        super.rmObservers()
        NotificationCenter.default.removeObserver(self)
    }

    func enterBg(not: Notification) {
        kit?.appEnterBackground()
    }
    
    func becameActive(not: Notification) {
        kit?.appBecomeActive()
    }
    
    override var shouldAutorotate: Bool{
        get{
            if let filter = ksyFilterView {
                return filter.swUiRotate?.isOn ?? false
            }
            return false
        }
    }
    
    override func layoutUI() {
        if ctrlView != nil {
            ctrlView?.frame = view.frame
            ctrlView?.layoutUI()
        }
    }
    
    // MARK: - logo setup
    
    func setupLogo() {
        var yPos: CGFloat = 0.05
        let hgt: CGFloat = 0.1  // logo图片的高度是预览画面的十分之一
        
        let logoFile = NSHomeDirectory().appending("/Documents/ksvc.png")
        if FileManager.default.fileExists(atPath: logoFile) {
            let url = NSURL.init(fileURLWithPath: logoFile)
            kit?.logoPic = KSYGPUPicture.init(url: url as URL!)
            kit?.logoRect = CGRect.init(x: 0.05, y: yPos, width: 0, height: hgt)
            kit?.logoAlpha = 0.5
            yPos += hgt
            miscView?.alphaSl?.normalValue = Float(kit?.logoAlpha ?? 0)
        }
        kit?.textLabel.numberOfLines = 2
        kit?.textLabel.textAlignment = .center
        
        _dateFormatter = DateFormatter()
        _dateFormatter!.dateFormat = "HH:mm:ss"
        
        let now: Date = Date()
        let timeStr = _dateFormatter!.string(from: now)
        kit?.textLabel.text = "ksyun\n\(timeStr)"
        kit?.textLabel.sizeToFit()
        kit?.textRect = CGRect.init(x: 0.05, y: yPos, width: 0, height: 0.04)
        kit?.updateTextLabel()
    }
    
    func updateLogoText() {
        let appState = UIApplication.shared.applicationState
        if appState != .active {
            return
        }
        // 将当前时间显示在左上角
        let now = Date()
        let timeStr = _dateFormatter!.string(from: now)
        kit?.textLabel.text = "ksyun\n\(timeStr)"
        kit?.updateTextLabel()
    }
    
    // MARK: - Capture & stream setup
    func setCustomizeCfg() {
        kit?.capPreset = presetCfgView!.capResolution() as NSString!
        kit?.previewDimension = presetCfgView!.capResolutionSize()
        kit?.streamDimension = presetCfgView!.strResolutionSize()
        kit?.videoFPS = Int32(presetCfgView!.frameRate())
        kit?.streamerBase.videoCodec = presetCfgView!.videoCodec()
        kit?.streamerBase.videoMaxBitrate = Int32(presetCfgView!.videoKbps())
        kit?.streamerBase.audioCodec = presetCfgView!.audioCodec()
        kit?.streamerBase.audiokBPS = Int32(presetCfgView!.audioKbps())
        kit?.streamerBase.videoFPS = Int32(presetCfgView!.frameRate())
        kit?.streamerBase.bwEstimateMode = presetCfgView!.bwEstMode()
    }
    
    func setCaptureCfg() {
        kit?.cameraPosition = presetCfgView!.cameraPos()
        kit?.gpuOutputPixelFormat = presetCfgView!.gpuOutputPixelFmt()
        kit?.capturePixelFormat = presetCfgView!.gpuOutputPixelFmt()
        kit?.videoProcessingCallback = { (buf) -> Void in
            // 在此处添加自定义图像处理, 直接修改buf中的图像数据会传递到观众端
            // 或复制图像数据之后再做其他处理, 则观众端仍然看到处理前的图像
        }
        
        kit?.audioProcessingCallback = { (buf) -> Void in
            // 在此处添加自定义音频处理, 直接修改buf中的pcm数据会传递到观众端
            // 或复制音频数据之后再做其他处理, 则观众端仍然听到原始声音
        }
        
        kit?.interruptCallback = { (bInterrupt) -> Void in
            // 在此处添加自定义图像采集被打断的处理 (比如接听电话等)
        }
    }
    
    func defaultStramCfg() {
        // stream default settings
        kit?.streamerBase.videoCodec = KSYVideoCodec.AUTO
        kit?.streamerBase.videoInitBitrate = 800
        kit?.streamerBase.videoMaxBitrate = 1000
        kit?.streamerBase.videoMinBitrate = 0
        kit?.streamerBase.audiokBPS = 48
        kit?.streamerBase.shouldEnableKSYStatModule = true
        kit?.streamerBase.videoFPS = 15
        kit?.streamerBase.logBlock = { (str) -> Void in
            print(str ?? "")
        }
        hostURL = NSURL.init(string: "rtmp://mobile.kscvbu.cn/live/123")
    }
    
    // 推流的参数设置 must set after capture
    func setStreamerCfg() {
        guard let _ = kit?.streamerBase else {
            return
        }
        
        if let _ = presetCfgView {
            kit?.streamerBase.videoInitBitrate = Int32(presetCfgView!.videoKbps() * 6 / 10)
            kit?.streamerBase.videoMinBitrate = 0
            kit?.streamerBase.shouldEnableKSYStatModule = true
            kit?.streamerBase.logBlock = { (str) -> Void in
                print(str ?? "")
            }
            hostURL = NSURL.init(string: presetCfgView!.hostUrl()!)
        }else{
            defaultStramCfg()
        }
    }
    
    func updateStreamCfg(bStart: Bool) {
        kit?.streamerBase.liveScene = (miscView?.liveScene)!
        kit?.streamerBase.videoEncodePerf = (miscView?.vEncPerf)!
        kit?.streamerBase.bWithVideo = !audioView!.swAudioOnly!.isOn
        _strSeconds = 0
        
        miscView?.liveSceneSeg?.isEnabled = !bStart
        miscView?.vEncPerfSeg?.isEnabled = !bStart
        
        miscView?.swBypassRec?.isOn = false
        miscView?.autoReconnect?.slider.isEnabled = !bStart
        kit?.maxAutoRetry = Int32(Int(miscView!.autoReconnect!.slider.value))
        
        //判断是直播还是录制
        let title = (ctrlView?.btnStream?.currentTitle)!
        _bRecord = (title == "开始录制")
        miscView?.swBypassRec?.isEnabled = !_bRecord! // 直接录制时, 不能旁路录制
        
        if _bRecord! && bStart {
            deleteFile(file: presetCfgView!.hostUrl()!)
        }
    }
    
    // MARK: - state change
    func onCaptureStateChange(not: Notification) {
        print("new capStat: \(kit?.getCurCaptureStateName())")
        ctrlView?.lblStat?.text = kit?.getCurCaptureStateName()
    }

    func onNetStateEvent(not: Notification) {
        if let _ = kit {
            switch kit!.streamerBase.netStateCode {
            case KSYNetStateCode.SEND_PACKET_SLOW:
                (ctrlView!.lblStat!.notGoodCnt)! += 1
                break
            case KSYNetStateCode.EST_BW_RAISE:
                (ctrlView!.lblStat!.bwRaiseCnt)! += 1
                break
            case KSYNetStateCode.EST_BW_DROP:
                (ctrlView!.lblStat!.bwDropCnt)! += 1
                break
            default:
                break
            }
        }
    }
    
    func onBgmPlayerStateChange(not: Notification) {
        let st = kit?.bgmPlayer.getCurBgmStateName()
        if let s = st {
            let status = (s as NSString).substring(from: 17)
            ksyBgmView?.bgmStatus = status
        }
    }
    
    func onStreamStateChange(not: Notification) {
        if kit?.streamerBase != nil {
            print("stream State \(kit!.streamerBase.getCurStreamStateName() ?? "")")
        }
        
        ctrlView?.lblStat?.text = kit?.streamerBase.getCurStreamStateName()
        if kit?.streamerBase.streamState == .error {
            onStreamError(errCode: (kit?.streamerBase.streamErrorCode)!)
        }else if kit?.streamerBase.streamState == .connecting {
            ctrlView?.lblStat?.initStreamStat()
        }else if kit?.streamerBase.streamState == .connected {
            if (audioView?.swAudioOnly?.isOn)! {
                kit?.streamerBase.bWithVideo = false
            }
        }
        //状态为KSYStreamStateIdle且_bRecord为ture时，录制视频
        if kit?.streamerBase.streamState == .idle && _bRecord! {
            saveVideoToAlbum(path: (presetCfgView?.hostUrl())!)
        }
    }
    
    //保存视频到相簿
    func saveVideoToAlbum(path: String) {
        if !FileManager.default.fileExists(atPath: path) {
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(self?.videoDidFinishedSaving(videoPath:error:contextInfo:)), nil);
            }
        }
    }
    
    //保存mp4文件完成时的回调
    func videoDidFinishedSaving(videoPath: String, error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        let msg: String
        if error == nil {
            msg = "Save album success!"
        }else{
            msg = "Failed to save the album!"
        }
        KSYUIVC().toast(message: msg, duration: 3)
    }
    
    func onStreamError(errCode: KSYStreamErrorCode) {
        ctrlView?.lblStat?.text = kit?.streamerBase.getCurKSYStreamErrorCodeName()
        
        if errCode == KSYStreamErrorCode.CONNECT_BREAK {
            tryReconnect()
        }else if errCode == KSYStreamErrorCode.AV_SYNC_ERROR {
            print("audio video is not synced, please check timestamp")
            tryReconnect()
        }else if errCode == KSYStreamErrorCode.CODEC_OPEN_FAILED {
            print("video codec open failed, try software codec")
            kit?.streamerBase.videoCodec = KSYVideoCodec.X264
            tryReconnect()
        }
    }
    
    func tryReconnect() {
        if (kit?.maxAutoRetry)! > 0 { // retry by kit
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            print("try again")
            self?.updateStreamCfg(bStart: true)
            self?.kit?.streamerBase.startStream(self?.hostURL as! URL)
        }
    }
    
    func onBypassRecordStateChange(newState: KSYRecordState) {
        if newState == KSYRecordState.recording {
            print("start bypass record")
        }else if newState == KSYRecordState.stopped {
            print("stop bypass record")
            saveVideoToAlbum(path: _bypassRecFile!)
        }else if newState == KSYRecordState.error {
            print("bypass record error \(kit?.streamerBase.bypassRecordErrorName)")
        }
    }
    
    // MARK: - timer respond per second
    override func onTimer(timer: Timer) {
        if kit?.streamerBase.streamState == KSYStreamState.connected {
            ctrlView?.lblStat?.updateState(str: (kit?.streamerBase)!)
        }
        if ((kit?.bgmPlayer) != nil) && kit?.bgmPlayer.bgmPlayerState == KSYBgmPlayerState.playing {
            ksyBgmView?.progressV?.progress = (kit?.bgmPlayer.bgmProcess)!
        }
        _strSeconds += 1
        updateLogoText()
        updateRecLabel()        // 本地录制:直接存储到本地, 不推流
        updateBypassRecLable()  // 旁路录制:一边推流一边录像
    }
    
    // MARK: - UI respond
    // ctrView control (for basic ctrl)
    func onBasicCtrl(btn: AnyObject) {
        if btn as? NSObject == ctrlView?.btnFlash {
            onFlash()
        }else if (btn as? NSObject == (ctrlView?.btnCameraToggle)!){
            onCameraToggle()
        }else if (btn as? NSObject == (ctrlView?.btnQuit)!){
            onQuit()
        }else if (btn as? NSObject == ctrlView?.btnCapture){
            onCapture()
        }else if (btn as? NSObject == (ctrlView?.btnStream)!){
            onStream()
        }else{
            onMenuBtnPress(btn: btn as! UIButton)
        }
    }
    
    // menuView control
    func onMenuBtnPress(btn: UIButton) {
        var view: KSYUIView? = nil
        if let _ = ctrlView {
            if let _ = ctrlView!.menuBtns {
                if btn == (ctrlView!.menuBtns![0]) {
                    view = ksyBgmView       // 背景音乐播放相关
                }else if btn == (ctrlView!.menuBtns![1]) {
                    view = ksyFilterView    // 美颜滤镜相关
                }else if btn == (ctrlView!.menuBtns![2]) {
                    view = audioView        // 混音控制台
                    audioView?.micType = AVAudioSession.sharedInstance().currentMicType
                    audioView?.initMicInput()
                }else if btn == (ctrlView!.menuBtns![3]) {
                    view = miscView
                }
            }
        }
        
        if let _ = view {
            ctrlView?.showSubMenuView(view: view!)
        }
    }
    
    func swipeController(swipGes: UISwipeGestureRecognizer) {
        if swipGes == _swipeGest {
            var rect = view.frame
            if rect.equalTo(ctrlView!.frame) {
                rect.origin.x = rect.width  //hide
            }
            UIView.animate(withDuration: 0.1, animations: { 
                self.ctrlView?.frame = rect
            })
        }
    }
    
    // MARK: - subviews: bgmView
    func onBgmCtrSle(sender: UISegmentedControl) {
        if sender == ksyBgmView?.loopType {
            if sender.selectedSegmentIndex == 0 {
                kit?.bgmPlayer.bgmFinishBlock = {}
            }else{
                // loop to next
                kit?.bgmPlayer.bgmFinishBlock = { [weak self] in
                    _ = self?.ksyBgmView?.loopNextBgmPath()
                    self?.onBgmPlay()
                }
            }
        }
    }
    
    // bgmView Control
    func onBgmBtnPress(btn: UIButton) {
        if btn == ksyBgmView?.playBtn {
            onBgmPlay()
        }else if btn == ksyBgmView?.pauseBtn {
            if kit?.bgmPlayer.bgmPlayerState == KSYBgmPlayerState.playing {
                kit?.bgmPlayer.pauseBgm()
            }else if kit?.bgmPlayer.bgmPlayerState == KSYBgmPlayerState.paused {
                kit?.bgmPlayer.resumeBgm()
            }
        }else if btn == ksyBgmView?.stopBtn {
            onBgmStop()
        }else if btn == ksyBgmView?.nextBtn {
            _ = ksyBgmView?.nextBgmPath()
            playNextBgm()
        }else if btn == ksyBgmView?.previousBtn {
            _ = ksyBgmView?.previousBgmPath()
            playNextBgm()
        }else if btn == ksyBgmView?.muteBtn {
            // 仅仅是静音了本地播放, 推流中仍然有音乐
            kit?.bgmPlayer.bMuteBgmPlay = !(kit?.bgmPlayer.bMuteBgmPlay)!
        }
    }
    
    func playNextBgm() {
        if kit?.bgmPlayer.bgmPlayerState == KSYBgmPlayerState.playing {
            kit?.bgmPlayer.stopPlayBgm()
            onBgmPlay()
        }
    }
    
    func onBgmPlay() {
        guard let _ = ksyBgmView?.bgmPath else{
            kit?.bgmPlayer.stopPlayBgm()
            return
        }
        
        kit?.bgmPlayer.startPlayBgm((ksyBgmView?.bgmPath)!, isLoop: false)
    }
    
    func onBgmStop() {
        if kit?.bgmPlayer.bgmPlayerState == KSYBgmPlayerState.playing {
            kit?.bgmPlayer.stopPlayBgm()
        }
    }
    
    // 背景音乐音量调节
    func onBgmVolume(sl: UIView) {
        if sl == ksyBgmView?.volumSl {
            kit?.bgmPlayer.bgmVolume = Double((ksyBgmView?.volumSl?.normalValue)!)
        }
    }
    
    // MARK: - subviews: basic ctrl
    func onFlash() {
        kit?.toggleTorch()
    }
    
    func onCameraToggle() {
        kit?.switchCamera()
        if let _ = kit?.vCapDev {
            if kit?.vCapDev!.cameraPosition() == AVCaptureDevicePosition.back {
                ctrlView?.btnFlash?.isEnabled = true
            }else{
                ctrlView?.btnFlash?.isEnabled = false
            }
        }else {
            ctrlView?.btnFlash?.isEnabled = false
        }
    }
    
    func onCapture() {
        if !(kit?.vCapDev.isRunning)! {
            kit?.videoOrientation = UIApplication.shared.statusBarOrientation
            kit?.startPreview(view)
        }else{
            kit?.stopPreview()
        }
    }
    
    func onStream() {
        print(kit?.audioCaptureType ?? "")
        if kit?.streamerBase.streamState == KSYStreamState.idle ||
            kit?.streamerBase.streamState == KSYStreamState.error {
            updateStreamCfg(bStart: true)
            kit?.streamerBase.startStream(hostURL! as URL!)
        }else{
            updateStreamCfg(bStart: false)
            kit?.streamerBase.stopStream()
        }
    }
    
    func onQuit() {
        kit?.stopPreview()
        kit = nil
        rmObservers()
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - UI respond : gpu filters
    func onFilterChange(sender: AnyObject) {
        if ksyFilterView?.curFilter != kit?.filter {
            kit?.setupFilter(ksyFilterView?.curFilter)
        }
    }
    
    func onFilterBtn(sender: AnyObject) {
    }
    
    func onFilterSwitch(sender: AnyObject) {
        let sw = sender as! UISwitch
        
        if sw == ksyFilterView?.swPrevewFlip {
            kit?.previewMirrored = sw.isOn
        }else if sw == ksyFilterView?.swStreamFlip {
            kit?.streamerMirrored = sw.isOn
        }
    }
    
    // MARK: - UI respond : audio ctrl
    func onAMixerSwitch(sw: UISwitch) {
        if sw == audioView?.muteStream {
        // 静音推流(发送音量为0的数据)
            let mute = audioView?.muteStream?.isOn
            kit?.streamerBase.muteStream(mute ?? false)
        }else if sw == audioView?.bgmMix {
            // 背景音乐 是否 参与混音
            kit?.aMixer.setTrack((kit?.bgmTrack)!, enable: sw.isOn)
        }else if sw == audioView?.swAudioOnly && kit?.streamerBase != nil {
            if kit?.streamerBase.isStreaming() ?? false {
                // disable video, only stream with audio
                kit?.streamerFreezed = sw.isOn
            }
        }else if sw == audioView?.swPlayCapture {
            if !KSYAUAudioCapture.isHeadsetPluggedIn() {
                KSYUIVC().toast(message: "没有耳机, 开启耳返会有刺耳的声音", duration: 0.3)
                sw.isOn = false
                kit?.aCapDev.bPlayCapturedAudio = false
                return
            }
            kit?.aCapDev.bPlayCapturedAudio = sw.isOn
        }
    }
    
    func onAMixerSegCtrl(seg: UISegmentedControl) {
        if let _ = kit {
            if seg == audioView?.micInput {
                AVAudioSession.sharedInstance().currentMicType = (audioView?.micType)!
            }else if seg == audioView?.reverbType {
                let t: Int = seg.selectedSegmentIndex
                kit?.aCapDev.reverbType = Int32(t)
                return
            }
        }
    }
    
    func onAMixerSlider(slider: UIView) {
        var val: Float = 0.0
        if slider.isKind(of: KSYNameSlider.self) {
            val = (slider as! KSYNameSlider).normalValue
        }else {
            return
        }
        
        if slider == self.audioView?.bgmVol {
            kit?.aMixer.setMixVolume(val, of: (kit?.bgmTrack)!)
        }else if slider == self.audioView?.micVol {
            kit?.aMixer.setMixVolume(val, of: (kit?.micTrack)!)
        }else if slider == audioView?.playCapVol {
            if ((kit?.aCapDev) != nil) {
                kit?.aCapDev.micVolume = (slider as! KSYNameSlider).normalValue
            }
        }
    }
    
    // MARK: - misc features
    func onMiscBtns(sender: AnyObject) {
        // 截图的三种方法:
        if sender as! NSObject == (miscView?.btn0)! {
            // 方法1: 开始预览后, 从streamer 直接将待编码的图片存为本地的文件
            let path = "snapshot/c.jpg"
            kit?.streamerBase.takePhoto(withQuality: 1, fileName: path)
            print("Snapshot save to \(path)")
        }else if sender as! NSObject == (miscView?.btn1)! {
            // 方法2: 开始预览后, 从streamer获取UIImage对象
            kit?.streamerBase.getSnapshotWithCompletion({ (img) in
                if let _ = img {
                    KSYUIVC.saveImage(image: img!, path: "snap1.png")
                    UIImageWriteToSavedPhotosAlbum(img!, nil, nil, nil)
                }
            })
        }else if sender as! NSObject == (miscView?.btn2)! {
            // 方法3: 如果有美颜滤镜, 可以从滤镜上获取截图(UIImage)
            let filter = ksyFilterView?.curFilter
            if filter != nil {
                filter!.useNextFrameForImageCapture()
                let img = filter!.imageFromCurrentFramebuffer()
                if let _ = img {
                    KSYUIVC.saveImage(image: img!, path: "snap2.png")
                    UIImageWriteToSavedPhotosAlbum(img!, nil, nil, nil)
                }
            }
        }else if sender as? NSObject == miscView?.btn3 {
            let picker = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }else if sender as? NSObject == miscView?.btn4 {
            let picker = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
    }
    
    func onMiscSwitch(sw: UISwitch) {
        if sw == miscView?.swBypassRec {
            onBypassRecord()
        }
    }
    
    func onMiscSlider(slider: KSYNameSlider) {
        let layerIdx = miscView?.layerSeg?.selectedSegmentIndex
        if slider == miscView?.alphaSl {
            let flt = slider.normalValue
            if layerIdx == kit?.logoPicLayer {
                kit?.logoAlpha = CGFloat(flt)
            }else{
                kit?.textLabel.alpha = CGFloat(flt)
                kit?.updateTextLabel()
            }
        }
    }
    
    func onMisxSegCtrl(seg: UISegmentedControl) {
        let layerIdx = miscView?.layerSeg?.selectedSegmentIndex
        if seg == miscView?.layerSeg {
            if layerIdx == kit?.logoPicLayer {
                miscView?.alphaSl?.normalValue = Float((kit?.logoAlpha)!)
            }else{
                miscView?.alphaSl?.normalValue = Float((kit?.textLabel.alpha)!)
            }
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //显示的图片
        if let image = info[UIImagePickerControllerOriginalImage] {
            kit?.logoPic = KSYGPUPicture.init(image: image as! UIImage, smoothlyScaleOutput: true)
            picker.dismiss(animated: true, completion: nil)
        }
        
        if picker.sourceType == .camera {
            // kGPUImageRotateRight
            kit?.vPreviewMixer.setPicRotation(GPUImageRotationMode.init(2), ofLayer: (kit?.logoPicLayer)!)
            kit?.vStreamMixer.setPicRotation(GPUImageRotationMode.init(2), ofLayer: (kit?.logoPicLayer)!)
            restartVideoCapSession()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        if picker.sourceType == .camera {
            restartVideoCapSession()
        }
    }
    
    func restartVideoCapSession() {
        #if TARGET_OS_IPHONE
            if NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_8_4 &&
                ((kit?.vCapDev.captureSession) != nil) {
                kit?.vCapDev.captureSession.stopRunning()
                kit?.vCapDev.captureSession.startRunning()
            }
        #endif
    }
    
    // MARK: - ui rotate
    override func onViewRotate() {
        layoutUI()
        if kit != nil && !(ksyFilterView?.swUiRotate?.isOn)! {
            return
        }
        
        let orient = UIApplication.shared.statusBarOrientation
        kit?.rotatePreview(to: orient)
        if (ksyFilterView?.swStrRotate?.isOn)! {
            kit?.rotateStream(to: orient)
        }
    }
    
    // MARK: - bypass record & record
    func onBypassRecord() {
        let bRec = (kit?.streamerBase.bypassRecordState == KSYRecordState.recording)
        if (miscView?.swBypassRec?.isOn)! {
            if (kit?.streamerBase.isStreaming())! && !bRec {
                // 如果启动录像时使用和上次相同的路径,则会覆盖掉上一次录像的文件内容
                deleteFile(file: _bypassRecFile!)
                let url: URL = URL.init(fileURLWithPath: _bypassRecFile!)
                kit?.streamerBase.startBypassRecord(url)
                updateBypassRecLable()
            }else {
                let msg = "推流过程中才能旁路录像"
                KSYUIVC().toast(message: msg, duration: 1)
                miscView?.swBypassRec?.isOn = false
            }
        }else if (bRec){
            kit?.streamerBase.stopBypassRecord()
        }
    }
    
    func updateBypassRecLable() {
        if (miscView?.swBypassRec?.isOn)! {
            return
        }
        
        let dur: Double = kit?.streamerBase.bypassRecordDuration ?? 0
        let durStr = String.init(format: "%3.0fs/%ds", dur,REC_MAX_TIME)
        miscView?.lblRecDur?.text = durStr
        if dur > Double(REC_MAX_TIME) {  // 为防止将手机存储写满,限制旁路录像时长为30s
            miscView?.swBypassRec?.isOn = false
            kit?.streamerBase.stopBypassRecord()
        }
    }
    
    func updateRecLabel() {
        if !_bRecord! {  // 直接录制短视频
            return
        }
        let diff = REC_MAX_TIME - _strSeconds
        //保持连接和限制短视频长度
        if (kit?.streamerBase.isStreaming())! && diff < 0 {
            onStream() // 结束录制
        }
        if (kit?.streamerBase.isStreaming())! { //录制时的倒计时时间
            let durMsg = "\(diff)s\n"
            ctrlView?.lblNetwork?.text = durMsg
        }else{
            ctrlView?.lblNetwork?.text = ""
        }
    }

    //删除文件,保证保存到相册里面的视频时间是更新的
    func deleteFile(file: String) {
        if FileManager.default.fileExists(atPath: file) {
            do {
                try FileManager.default.removeItem(atPath: file)
            } catch _ {
                
            }
        }
    }
    
    /**
     @abstract 将UI的坐标转换成相机坐标
     */
    func convertToPointOfInterestFromViewCoordinates(viewCoordinates: CGPoint) -> CGPoint {
        var pointOfInterest = CGPoint.init(x: 0.5, y: 0.5)
        let frameSize = view.frame.size
        guard let _ = kit else {
            return pointOfInterest
        }
        let apertureSize = kit!.captureDimension()
        let point = viewCoordinates
        let apertureRatio = apertureSize.height / apertureSize.width
        let viewRatio = frameSize.width / frameSize.height
        var xc: CGFloat = 0.5
        var yc: CGFloat = 0.5
        
        if viewRatio > apertureRatio {
            let y2 = frameSize.height
            let x2 = frameSize.height * apertureRatio
            let x1 = frameSize.width
            let blackBar = (x1 - x2) / 2
            if point.x >= blackBar && point.x <= blackBar + x2 {
                
                xc = point.y.divided(by: y2)
                yc = CGFloat(1.0) - ((point.x - blackBar) / x2)
            }
        }else{
            let y2 = frameSize.width / apertureRatio
            let y1 = frameSize.height
            let x2 = frameSize.width
            let blackBar = (y1 - y2) / 2
            if point.y >= blackBar && point.y <= blackBar + y2 {
                xc = ((point.y - blackBar) / y2)
                yc = 1.0 - (point.x / x2)
            }
        }
        pointOfInterest = CGPoint.init(x: xc, y: yc)
        
        return pointOfInterest
    }
    
    //设置摄像头对焦位置
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let current = touch?.location(in: view)
        let point = convertToPointOfInterestFromViewCoordinates(viewCoordinates: current!)
        kit?.exposure(at: point)
        kit?.focus(at: point)
        _foucsCursor?.center = current!
        _foucsCursor?.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        _foucsCursor?.alpha = 1.0
        
        UIView.animate(withDuration: 1.0, animations: { [weak self] in
            self?._foucsCursor?.transform = CGAffineTransform.identity
        }) { [weak self] (finished) in
            self?._foucsCursor?.alpha = 0
        }
    }
    
    //添加缩放手势，缩放时镜头放大或缩小
    func addPinchGestureRecognizer() {
        let pinch = UIPinchGestureRecognizer.init(target: self, action: #selector(pinchDetected(rec:)))
        view.addGestureRecognizer(pinch)
    }
    
    func pinchDetected(rec: UIPinchGestureRecognizer) {
        if rec.state == .began {
            _currentPinchZoomFactor = kit?.pinchZoomFactor
        }
        let zoomFactor = _currentPinchZoomFactor! * rec.scale    //当前触摸缩放因子*坐标比例
        kit?.pinchZoomFactor = zoomFactor
    }
    
}
