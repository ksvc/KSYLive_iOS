//
//  KSYProberVC.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

class KSYProberVC: UIViewController {
    
    var url: URL?
    var prober: KSYMediaInfoProber?
    
    var stat: UILabel?
    
    var btnProbe: UIButton?
    var btnThumbnail: UIButton?
    var btnQuit: UIButton?
    
    
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
    }
    
    func initUI() {
        view.backgroundColor = .white
        // add play button
        btnProbe = addButton(with: "probe", action: #selector(onProbeMediaInfo(sender:)))
        
        // add Thunbnail button
        btnThumbnail = addButton(with: "Thumbnail", action: #selector(onThumbnail(sender:)))
        
        // add quit button
        btnQuit = addButton(with: "quit", action: #selector(onQuit(sender:)))
        
        stat = UILabel()
        stat?.backgroundColor = .clear
        stat?.textColor = .red
        stat?.numberOfLines = -1
        stat?.textAlignment = .left
        view.addSubview(stat!)
        layoutUI()
        
        let aUrlString = url!.isFileURL ? url?.path : url?.absoluteString
        
        stat?.text = "url is : \(aUrlString ?? "")"
        prober = KSYMediaInfoProber.init(contentURL: url)
        prober?.timeout = 10
    }
    
    func addButton(with title: String, action: Selector) -> UIButton {
        let button = UIButton.init(type: .roundedRect)
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: action, for: .touchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        view.addSubview(button)
        
        return button
    }
    
    func layoutUI() {
        let wdt = view.bounds.width
        let hgt = view.bounds.height
        
        let gap: CGFloat = 20
        let btnWdt = (wdt - gap) / 3 - gap
        let btnHgt: CGFloat = 30
        
        var xPos = gap
        let yPos = hgt - btnHgt - gap
        
        btnProbe?.frame = CGRect.init(x: xPos,
                                      y: yPos,
                                      width: btnWdt,
                                      height: btnHgt)
        
        xPos += gap + btnWdt
        btnThumbnail?.frame = CGRect.init(x: xPos,
                                          y: yPos,
                                          width: btnWdt,
                                          height: btnHgt)
        xPos += gap + btnWdt
        btnQuit?.frame = CGRect.init(x: xPos,
                                     y: yPos,
                                     width: btnWdt,
                                     height: btnHgt)
        
        stat?.frame = CGRect.init(x: 20, y: 0, width: wdt, height: hgt)
    }
    
    func onProbeMediaInfo(sender: NSObject) {
        guard let _ = prober else {
            return
        }
        
        var result: String = ""
        if let mediaInfo = prober?.ksyMediaInfo {
            result.append("\nmux type:\(convertMuxType(type: mediaInfo.type))")
            result.append(String.init(format: "\nbitrate:%lld", mediaInfo.bitrate))

            var i = 0
            result.append("\n\nvideo num is : \(mediaInfo.videos.count)")
            for videoInfo in mediaInfo.videos {
                result.append("\n\nvideo[\(i)] codec:\(convertAVCodec(codecID: (videoInfo as! KSYVideoInfo).vcodec))")
                result.append("\nvideo[\(i)] frame width:\((videoInfo as! KSYVideoInfo).frame_width)")
                result.append("\nvideo[\(i)] frame height:\((videoInfo as! KSYVideoInfo).frame_height)")
                i += 1
            }
            
            i = 0
            result.append("\n\naudio num is : \(mediaInfo.audios.count)")
            for audioInfo in mediaInfo.audios {
                result.append("n\naudio[\(i)] codec:\(convertAVCodec(codecID: (audioInfo as! KSYAudioInfo).acodec))")
                result.append("\naudio[\(i)] language:\((audioInfo as! KSYAudioInfo).language)")
                result.append("\naudio[\(i)] bitrate:\((audioInfo as! KSYAudioInfo).bitrate)")
                result.append("\naudio[\(i)] channels:\((audioInfo as! KSYAudioInfo).channels)")
                result.append("\naudio[\(i)] frame_size:\((audioInfo as! KSYAudioInfo).framesize)")
                result.append("\naudio[\(i)] sample_format:\(convertSampleFMT(afmt :(audioInfo as! KSYAudioInfo).sample_format))")
                result.append("\naudio[\(i)] samplerate:\((audioInfo as! KSYAudioInfo).samplerate)")
                i += 1
            }
        }else{
            result.append("\nprobe mediainfo failed!")
        }
        stat?.text = result
    }
    
    func onThumbnail(sender: NSObject) {
        guard let _ = prober else {
            return
        }
        
        let thumbnailImage = prober?.getVideoThumbnailImage(atTime: 0, width: 0, height: 0)
        
        if let _ = thumbnailImage {
            UIImageWriteToSavedPhotosAlbum(thumbnailImage!, self, #selector(didFinishSaving(image:error:contextInfo:)), nil)
        }else {
            let toast = UIAlertView.init(title: "￣へ￣", message: "缩略图截取失败！", delegate: nil, cancelButtonTitle: "确定")
            toast.show()
        }
    }
    
    func onQuit(sender: UIButton) {
        dismiss(animated: false, completion: nil)
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
    
    // MARK: - converMediaInfo
    func convertMuxType(type: MEDIAINFO_MUX_TYPE) -> String {
        var muxTypeStr = "unknow mux type"
        
        switch type {
        case .MUXTYPE_MP2T:
            muxTypeStr = "mpeg-ts"
        case .MUXTYPE_MOV:
            muxTypeStr = "mov"
        case .MUXTYPE_AVI:
            muxTypeStr = "avi"
        case .MUXTYPE_FLV:
            muxTypeStr = "flv"
        case .MUXTYPE_MKV:
            muxTypeStr = "mkv"
        case .MUXTYPE_ASF:
            muxTypeStr = "asf"
        case .MUXTYPE_RM:
            muxTypeStr = "rm"
        case .MUXTYPE_WAV:
            muxTypeStr = "wav"
        case .MUXTYPE_OGG:
            muxTypeStr = "ogg"
        case .MUXTYPE_APE:
            muxTypeStr = "ape"
        case .MUXTYPE_RAWVIDEO:
            muxTypeStr = "rawvideo"
        case .MUXTYPE_HLS:
            muxTypeStr = "hls"
        default:
            ()
        }
        
        return muxTypeStr
    }
    
    func convertAVCodec(codecID: MEDIAINFO_CODEC_ID) -> String {
        var codecIDStr = "unknow codec"
        
        switch codecID {
        case .MPEG2VIDEO:
            codecIDStr = "mpeg2"
        case .MPEG4:
            codecIDStr = "mpeg4"
        case .MJPEG:
            codecIDStr = "mjpeg"
        case .JPEG2000:
            codecIDStr = "jpeg2000"
        case .H264:
            codecIDStr = "h264"
        case .HEVC:
            codecIDStr = "hevc"
        case .VC1:
            codecIDStr = "vc1"
        case .AAC:
            codecIDStr = "aac"
        case .AC3:
            codecIDStr = "ac3"
        case .MP3:
            codecIDStr = "mp3"
        case .PCM:
            codecIDStr = "pcm"
        case .DTS:
            codecIDStr = "dts"
        case .NELLYMOSER:
            codecIDStr = "nellymoser"
        default:
            ()
        }
        
        return codecIDStr
    }
    
    func convertSampleFMT(afmt: MEDIAINFO_SAMPLE_FMT) -> String {
        var sampleFMTStr = "unknown sample formats"
        
        switch afmt {
        case .U8:
            sampleFMTStr = "unsigned 8 bits"
            break
        case .S16:
            sampleFMTStr = "signed 16 bits"
        case .S32:
            sampleFMTStr = "signed 32 bits"
        case .FLT:
            sampleFMTStr = "float"
        case .DBL:
            sampleFMTStr = "double"
        case .U8P:
            sampleFMTStr = "unsigned 8 bits, planar"
        case .S16P:
            sampleFMTStr = "signed 16 bits, planar"
        case .S32P:
            sampleFMTStr = "signed 32 bits, planar"
        case .FLTP:
            sampleFMTStr = "float, planar"
        case .DBLP:
            sampleFMTStr = "double, planar"
        case .NB:
            sampleFMTStr = "Number of sample formats"
        default:
            ()
        }
       
        return sampleFMTStr
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
