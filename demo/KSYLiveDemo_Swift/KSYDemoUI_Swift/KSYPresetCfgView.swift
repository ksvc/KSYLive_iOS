//
//  KSYPresetCfgView.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit
import AVFoundation

func FLOAT_EQ(f0: CGFloat, f1: CGFloat) -> Bool {
    return (f0 - f1 < 0.001) && (f0 - f1 > -0.001)
}

class KSYPresetCfgView: KSYUIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // UI elements
    var btn0: UIButton?
    var btn1: UIButton?
    var btn2: UIButton?
    var btn3: UIButton?
    var btn4: UIButton?

    // preset settings
    // capture
    var hostUrlUI: UITextField?             // host URL
    var lblResolutionUI: UILabel?
    var resolutionUI: UISegmentedControl?   // 采集分辨率
    var lblStreamResoUI: UILabel?
    var streamResoUI: UISegmentedControl?   // 推流分辨率
    var lblCameraPosUI: UILabel?
    var cameraPosUI: UISegmentedControl?
    
    var lblProfileUI: UILabel?
    var profileUI: UISegmentedControl?//预设等级 and 自定义
    var profilePicker: UIPickerView?
    
    var frameRateUI: KSYNameSlider?
    
    // stream
    var lblVideoCodecUI: UILabel?
    var videoCodecUI: UISegmentedControl?
    var lblAudioCodecUI: UILabel?
    var audioCodecUI: UISegmentedControl?
    var videoKbpsUI: KSYNameSlider?
    var lblAudioKbpsUI: UILabel?
    var audioKbpsUI: UISegmentedControl?
    var lblGpuPixFmtUI: UILabel?
    var gpuPixFmtUI: UISegmentedControl?
    
    // bandwith adapter
    var lblBwEstMode: UILabel?
    var bwEstModeUI: UISegmentedControl?
    
    // current profile id
    var curProfileIdx: Int = 0
    
    private
    var doneBtn: UIButton?
    var demoLable: UILabel?
    var _profileNames: [String]?
    
    override init() {
        super.init()
        backgroundColor = .white
        // hostURL = rtmpSrv + streamName(随机数,避免多个demo推向同一个流
        let rtmpSrv = "rtmp://mobile.kscvbu.cn/live"
        
        let devCode = (KSYUIView.init().getUuid()! as NSString).substring(to: 3)
        let url = "\(rtmpSrv)/\(devCode)"
        
        hostUrlUI = addTextField(text: url)
        doneBtn = addButton(title: "ok")
        btn0 = addButton(title: "开始直播")
        btn1 = addButton(title: "画中画直播")
//#ifdef KSYSTREAMER_DEMO
//        btn2 = addButton(title "forTest);
//#else
        btn2 = addButton(title: "返回")
//#endif
        
        lblCameraPosUI = addLabel(title: "摄像头")
        cameraPosUI = addSegCtrlWithItems(items: ["前置", "后置"])
        lblGpuPixFmtUI = addLabel(title: "像素格式")
        gpuPixFmtUI = addSegCtrlWithItems(items: ["rgba", "nv12"])
        lblProfileUI = addLabel(title: "配置")
        profileUI = addSegCtrlWithItems(items: ["预设等级", "自定义"])
        profileUI?.selectedSegmentIndex = 0
        _profileNames = ["360p_1","360p_2","360p_3","360p_auto",
                         "540p_1","540p_2","540p_3","540p_auto",
                          "720p_1","720p_2","720p_3","720p_auto"]
        
        let screenRect = UIScreen.main.bounds
        let ratio = screenRect.width / screenRect.size.height
        lblResolutionUI = addLabel(title: "采集分辨率")
        lblStreamResoUI = addLabel(title: "推流分辨率")
        
        resolutionUI = addSegCtrlWithItems(items: ["360p", "540p", "720p", "480p"])
        streamResoUI = addSegCtrlWithItems(items: ["360p", "540p", "720p", "480p", "400"])
        resolutionUI?.selectedSegmentIndex = 2
        if FLOAT_EQ(f0: ratio, f1: 16.0/9) || FLOAT_EQ(f0: ratio, f1: 9.0/16) {
            // 360p: 640x360(16:9)  480p: 640x480(4:3)
            streamResoUI?.selectedSegmentIndex = 3
        }else{
            resolutionUI?.setWidth(0.5, forSegmentAt: 3)
            streamResoUI?.setWidth(0.5, forSegmentAt: 3)
        }
        
        
        frameRateUI = addSlider(name: "视频帧率fps", from: 1.0, to: 30.0, initV: 15.0)
        lblVideoCodecUI = addLabel(title: "视频编码器")
        videoCodecUI = addSegCtrlWithItems(items: ["自动", "软264", "硬264", "软265"])
        lblAudioCodecUI = addLabel(title: "音频编码器")
        
        audioCodecUI = addSegCtrlWithItems(items: ["软AAC-HE","软AAC-LC","硬AAC-LC"])
        videoKbpsUI = addSlider(name: "视频码率kbps", from: 100.0, to: 1500.0, initV: 800.0)
        lblAudioKbpsUI = addLabel(title: "音频码率")
        audioKbpsUI = addSegCtrlWithItems(items: ["12", "24", "32", "48", "64", "128"])
        
        audioKbpsUI?.selectedSegmentIndex = 2
        lblBwEstMode = addLabel(title: "带宽估计模式")
        bwEstModeUI = addSegCtrlWithItems(items: ["默认", "流畅", "关闭"])
        demoLable = addLabel(title: "选择demo开始")
        demoLable?.textAlignment = .center
        
        profilePicker = UIPickerView()
        addSubview(profilePicker!)
        profilePicker!.isHidden = true
        profilePicker!.delegate = self
        profilePicker!.dataSource = self
        profilePicker!.showsSelectionIndicator = true
        profilePicker!.backgroundColor = UIColor.init(white: 0.8, alpha: 0.3)
        
        curProfileIdx = 0
        selectProfile(idx: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutUI() {
        super.layoutUI()
        if width > height {
            winWdt = width / 2
        }
        
        var rowHeight = min(30, height/14)
        rowHeight = max(rowHeight, 20)
        btnH = rowHeight * 2
        putSlider(sl: hostUrlUI!, andSwitch: doneBtn!)
        btnH = rowHeight
        putRow(subV: [lblCameraPosUI!, cameraPosUI!, lblGpuPixFmtUI!, gpuPixFmtUI!])
        putLabel(lbl: lblProfileUI!, andView: profileUI!)
        if profileUI!.selectedSegmentIndex > 0 {
            putLabel(lbl: lblResolutionUI!, andView: resolutionUI!)
            putLabel(lbl: lblStreamResoUI!, andView: streamResoUI!)
            putRow1(subV: frameRateUI)
            putLabel(lbl: lblVideoCodecUI!, andView: videoCodecUI!)
            putLabel(lbl: lblAudioCodecUI!, andView: audioCodecUI!)
            putRow1(subV: videoKbpsUI)
            putLabel(lbl: lblAudioKbpsUI!, andView: audioKbpsUI!)
            putLabel(lbl: lblBwEstMode!, andView: bwEstModeUI!)
        } else {
            if width > height {
                profilePicker?.frame = CGRect.init(x: winWdt,
                                                   y: self.yPos,
                                                   width: winWdt,
                                                   height: 162)
            }else{
                btnH = 162
                putRow1(subV: profilePicker)
            }
        }
        
        putRow1(subV: demoLable)
        
        //剩余空间全部用来放按钮
        let yPos = self.yPos > height ? self.yPos - height : self.yPos
        btnH = height - yPos - gap * 2
        putRow(subV: [btn0!, btn1! , btn2!])
    }
    
    // get config data
    func hostUrl() -> String? {
        return hostUrlUI?.text
    }
    
    func capResolution() -> String {
        //@"360p",@"540p",@"720p", @"480p"
        let idx = resolutionUI!.selectedSegmentIndex
        switch idx {
        case 0:
            return AVCaptureSessionPreset640x480
        case 1:
            return AVCaptureSessionPresetiFrame960x540
        case 2:
            return AVCaptureSessionPreset1280x720
        case 3:
            return AVCaptureSessionPreset640x480
        default:
            return AVCaptureSessionPreset640x480
        }
    }
    
    func capResolutionSize() -> CGSize {
        let idx = resolutionUI!.selectedSegmentIndex
        return dimensionToSize(idx: idx)
    }

    func strResolutionSize() -> CGSize {
        let idx = streamResoUI!.selectedSegmentIndex
        return dimensionToSize(idx: idx)
    }

    func dimensionToSize(idx: Int) -> CGSize {
        switch idx {
        case 0:
            return CGSize.init(width: 640, height: 360)
        case 1:
            return CGSize.init(width: 960, height: 540)
        case 2:
            return CGSize.init(width: 1280, height: 720)
        case 3:
            return CGSize.init(width: 640, height: 480)
        default:
            return CGSize.init(width: 400, height: 400)
        }
    }
    
    func cameraPos() -> AVCaptureDevicePosition {
        switch cameraPosUI!.selectedSegmentIndex {
        case 0:
            return .front
        case 1:
            return .back
        default:
            return .front
        }
    }
    
    func frameRate() -> Int {
        return Int(frameRateUI!.slider.value)
    }
    
    func videoCodec() -> KSYVideoCodec {
        switch videoCodecUI!.selectedSegmentIndex {
        case 0:
            return .AUTO
        case 1:
            return .X264
        case 2:
            return .VT264
        case 3:
            return .QY265
        default:
            return .AUTO
        }
    }
    
    func audioCodec() -> KSYAudioCodec {
        switch audioKbpsUI!.selectedSegmentIndex {
        case 0:
            return KSYAudioCodec.AAC_HE
        case 1:
            return KSYAudioCodec.AAC
        case 2:
            return KSYAudioCodec.AT_AAC
        default:
            return KSYAudioCodec.AAC_HE
        }
    }
    
    func videoKbps() -> Int {
        return Int(videoKbpsUI!.slider.value)
    }
    
    func audioKbps() -> Int {
        //@"12",@"24",@"32", @"48", @"64", @"128"
        let title = audioKbpsUI?.titleForSegment(at: audioKbpsUI!.selectedSegmentIndex)
        let aKbps = Int(title!)!
        if aKbps == 0 {
            return 32
        }
        return aKbps
    }
    
    func gpuOutputPixelFmt() -> OSType {
        if gpuPixFmtUI?.selectedSegmentIndex == 0 {
            return kCVPixelFormatType_32BGRA
        }else if gpuPixFmtUI?.selectedSegmentIndex == 1 {
            return kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        }
        
        return kCVPixelFormatType_32BGRA
    }
    
    func bwEstMode() -> KSYBWEstimateMode {
        switch bwEstModeUI!.selectedSegmentIndex {
        case 0:
            return .estMode_Default
        case 1:
            return .estMode_Negtive
        case 2:
            return .estMode_Disable
        default:
            return .estMode_Default
        }
    }
    
    override func onBtn(sender: AnyObject) {
        if sender as? NSObject == doneBtn {
            hostUrlUI?.resignFirstResponder()
            return
        }
        super.onBtn(sender: sender)
    }
    
    override func onSegCtrl(sender: AnyObject) {
        if sender as? NSObject == audioCodecUI {
            let idx = audioCodecUI!.selectedSegmentIndex
            
            if idx == 2 {
                audioKbpsUI?.selectedSegmentIndex = 4
            }else{
                audioKbpsUI?.selectedSegmentIndex = 2
            }
        }else if sender as? NSObject == profileUI {
            selectProfile(idx: profileUI!.selectedSegmentIndex)
        }
    }
    
    func selectProfile(idx: Int) {
        lblResolutionUI?.isHidden = true
        resolutionUI?.isHidden = true
        lblStreamResoUI?.isHidden = true
        streamResoUI?.isHidden = true
        frameRateUI?.isHidden = true
        lblVideoCodecUI?.isHidden = true
        videoCodecUI?.isHidden = true
        lblAudioCodecUI?.isHidden = true
        audioCodecUI?.isHidden = true
        videoKbpsUI?.isHidden = true
        lblAudioKbpsUI?.isHidden = true
        audioKbpsUI?.isHidden = true
        lblBwEstMode?.isHidden = true
        bwEstModeUI?.isHidden = true
        profilePicker?.isHidden = true
        
        if idx == 0 {
            profilePicker?.isHidden = false
            getStreamerProfile(profile: KSYStreamerProfile(rawValue: curProfileIdx)!)
            btn0?.setTitle("预设配置直播", for: .normal)
        }else{
            lblResolutionUI?.isHidden = false
            resolutionUI?.isHidden = false
            lblStreamResoUI?.isHidden = false
            streamResoUI?.isHidden = false
            frameRateUI?.isHidden = false
            lblVideoCodecUI?.isHidden = false
            videoCodecUI?.isHidden = false
            lblAudioCodecUI?.isHidden = false
            audioCodecUI?.isHidden = false
            videoKbpsUI?.isHidden = false
            lblAudioKbpsUI?.isHidden = false
            audioKbpsUI?.isHidden = false
            lblBwEstMode?.isHidden = false
            bwEstModeUI?.isHidden = false
            btn0?.setTitle("自定义配置直播", for: .normal)
        }
        layoutUI()
    }
    
    
    ///获取采集和推流配置参数
    func getStreamerProfile(profile: KSYStreamerProfile) {
        switch profile {
        case ._360p_1:
            resolutionUI?.selectedSegmentIndex = 0
            streamResoUI?.selectedSegmentIndex = 0
            frameRateUI?.slider.value = 15
            videoCodecUI?.selectedSegmentIndex = 0
            videoKbpsUI?.slider.value = 512
            audioCodecUI?.selectedSegmentIndex = 2
            audioKbpsUI?.selectedSegmentIndex = 3
            bwEstModeUI?.selectedSegmentIndex = 0
            break
        case ._360p_2:
            resolutionUI?.selectedSegmentIndex = 1
            streamResoUI?.selectedSegmentIndex = 0
            frameRateUI?.slider.value = 15
            videoCodecUI?.selectedSegmentIndex = 0
            videoKbpsUI?.slider.value = 512
            audioCodecUI?.selectedSegmentIndex = 2
            audioKbpsUI?.selectedSegmentIndex = 3
            bwEstModeUI?.selectedSegmentIndex = 0
            break
        case ._360p_3:
            resolutionUI?.selectedSegmentIndex = 2
            streamResoUI?.selectedSegmentIndex = 0
            frameRateUI?.slider.value = 20
            videoCodecUI?.selectedSegmentIndex = 0
            videoKbpsUI?.slider.value = 768
            audioCodecUI?.selectedSegmentIndex = 2
            audioKbpsUI?.selectedSegmentIndex = 3
            bwEstModeUI?.selectedSegmentIndex = 0
            break
        case ._360p_auto:
            resolutionUI?.selectedSegmentIndex = 0
            streamResoUI?.selectedSegmentIndex = 0
            frameRateUI?.slider.value = 15
            videoCodecUI?.selectedSegmentIndex = 0
            videoKbpsUI?.slider.value = 512
            audioCodecUI?.selectedSegmentIndex = 2
            audioKbpsUI?.selectedSegmentIndex = 3
            bwEstModeUI?.selectedSegmentIndex = 0
            break
        case ._540p_1:
            resolutionUI?.selectedSegmentIndex = 1
            streamResoUI?.selectedSegmentIndex = 1
            frameRateUI?.slider.value = 15
            videoCodecUI?.selectedSegmentIndex = 0
            videoKbpsUI?.slider.value = 768
            audioCodecUI?.selectedSegmentIndex = 2
            audioKbpsUI?.selectedSegmentIndex = 4
            bwEstModeUI?.selectedSegmentIndex = 0
            break
        case ._540p_2:
            resolutionUI?.selectedSegmentIndex = 2
            streamResoUI?.selectedSegmentIndex = 1
            frameRateUI?.slider.value = 15
            videoCodecUI?.selectedSegmentIndex = 0
            videoKbpsUI?.slider.value = 768
            audioCodecUI?.selectedSegmentIndex = 2
            audioKbpsUI?.selectedSegmentIndex = 4
            bwEstModeUI?.selectedSegmentIndex = 0
            break
        case ._540p_3:
            resolutionUI?.selectedSegmentIndex = 2
            streamResoUI?.selectedSegmentIndex = 1
            frameRateUI?.slider.value = 20
            videoCodecUI?.selectedSegmentIndex = 0
            videoKbpsUI?.slider.value = 1024
            audioCodecUI?.selectedSegmentIndex = 2
            audioKbpsUI?.selectedSegmentIndex = 4
            bwEstModeUI?.selectedSegmentIndex = 0
            break
        case ._540p_auto:
            resolutionUI?.selectedSegmentIndex = 1
            streamResoUI?.selectedSegmentIndex = 1
            frameRateUI?.slider.value = 15
            videoCodecUI?.selectedSegmentIndex = 0
            videoKbpsUI?.slider.value = 768
            audioCodecUI?.selectedSegmentIndex = 2
            audioKbpsUI?.selectedSegmentIndex = 4
            bwEstModeUI?.selectedSegmentIndex = 0
            break
        case ._720p_1:
            resolutionUI?.selectedSegmentIndex = 2
            streamResoUI?.selectedSegmentIndex = 2
            frameRateUI?.slider.value = 15
            videoCodecUI?.selectedSegmentIndex = 0
            videoKbpsUI?.slider.value = 1024
            audioCodecUI?.selectedSegmentIndex = 2
            audioKbpsUI?.selectedSegmentIndex = 5
            bwEstModeUI?.selectedSegmentIndex = 0
            break
        case ._720p_2:
            resolutionUI?.selectedSegmentIndex = 2
            streamResoUI?.selectedSegmentIndex = 2
            frameRateUI?.slider.value = 20
            videoCodecUI?.selectedSegmentIndex = 0
            videoKbpsUI?.slider.value = 1280
            audioCodecUI?.selectedSegmentIndex = 2
            audioKbpsUI?.selectedSegmentIndex = 5
            bwEstModeUI?.selectedSegmentIndex = 0
            break
        case ._720p_3:
            resolutionUI?.selectedSegmentIndex = 2
            streamResoUI?.selectedSegmentIndex = 2
            frameRateUI?.slider.value = 24
            videoCodecUI?.selectedSegmentIndex = 0
            videoKbpsUI?.slider.value = 1536
            audioCodecUI?.selectedSegmentIndex = 2
            audioKbpsUI?.selectedSegmentIndex = 5
            bwEstModeUI?.selectedSegmentIndex = 0
            break
        case ._720p_auto:
            resolutionUI?.selectedSegmentIndex = 2
            streamResoUI?.selectedSegmentIndex = 2
            frameRateUI?.slider.value = 15
            videoCodecUI?.selectedSegmentIndex = 0
            videoKbpsUI?.slider.value = 1024
            audioCodecUI?.selectedSegmentIndex = 2
            audioKbpsUI?.selectedSegmentIndex = 5
            bwEstModeUI?.selectedSegmentIndex = 0
            break
        }
        frameRateUI?.valueL.text = "\(Int(frameRateUI?.slider.value ?? 0))"
    }
}

extension KSYPresetCfgView: UIPickerViewDelegate, UIPickerViewDataSource {
    @available(iOS 2.0, *)
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return _profileNames?.count ?? 0
    }

    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return _profileNames?[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row >= 0 && row <= 3 {
            self.curProfileIdx = row
        }else if row >= 4 && row <= 7 {
            self.curProfileIdx = 100 + (row - 4)
        }else if row >= 8 && row <= 11 {
            self.curProfileIdx = 200 + (row - 8)
        }else{
            self.curProfileIdx = 103
        }
        getStreamerProfile(profile: KSYStreamerProfile(rawValue: self.curProfileIdx)!)
    }

}
