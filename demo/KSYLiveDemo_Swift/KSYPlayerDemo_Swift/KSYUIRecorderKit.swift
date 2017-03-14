//
//  KSYUIRecorderKit.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 2017/1/23.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

class KSYUIRecorderKit: NSObject {
    /* ui图层*/
    var contentView: UIView!
    /*是否开启录屏*/
    var bPlayRecord: Bool = false
    /*录制视频文件*/
    var writer: KSYMovieWriter?
    
    private
    // player
    var textureInput: GPUImageTextureInput?
    var playerLayer: Int = 0
    // UI
    var uiElementInput: GPUImageUIElement?
    var uiLayer: Int = 0
    // mixer
    var uiMixer: KSYGPUPicMixer?
    var aMixer: KSYAudioMixer?
    
    var dummyAudio: KSYDummyAudioSource?
    var dummyTrack: Int = 0
    var playerTrack: Int = 0
    
    var gpuToStr: KSYGPUPicOutput?
    var lastPts: CMTime = CMTime()
    
    var bBackground: Bool = false
    var processQueue: DispatchQueue = DispatchQueue.init(label: "com.ksyun.recordProcessQueue")
    
    override init() {
        super.init()
        bPlayRecord = false
        contentView = UIView.init(frame: CGRect.init(x: 0,
                                                     y: 0,
                                                     width: UIScreen.main.bounds.width,
                                                     height: UIScreen.main.bounds.height))
        contentView.backgroundColor = .clear
        
        playerLayer = 0
        uiLayer = 1
        
        dummyTrack = 0
        playerTrack = 1
        
        bBackground = false
        
        createMixer()
        
        createWriter()
        
        registerApplicationObservers()
    }
    
    deinit {
        contentView = nil
        uiElementInput = nil
        if let _ = uiMixer {
            uiMixer!.clearPic(ofLayer: playerLayer)
            uiMixer!.clearPic(ofLayer: uiLayer)
            uiMixer = nil
        }
        
        aMixer = nil
        gpuToStr = nil
        
        if let _ = writer {
            writer!.stopWrite()
            writer = nil
        }
        
        if let _ = dummyAudio {
            dummyAudio!.stop()
            dummyAudio = nil
        }
        unregisterApplicationObservers()
    }
    
    func startRecord(path: URL) {
        processQueue.sync {
            writer?.startWrite(path)
            bPlayRecord = true
        }
    }
    
    func stopRecord() {
        processQueue.sync {
            writer?.stopWrite()
            bPlayRecord = false
        }
    }
    
    func createWriter() {
        gpuToStr = KSYGPUPicOutput.init(outFmt: kCVPixelFormatType_32BGRA)
        writer = KSYMovieWriter()
        writer?.videoCodec = KSYVideoCodec.VT264
        writer?.audioCodec = KSYAudioCodec.AAC
        writer?.bWithVideo = true
        writer?.bWithAudio = true
        
        aMixer?.audioProcessingCallback = { [weak self] (buf) -> Void in
            self?.writer?.processAudioSampleBuffer(buf)
        }
        
        gpuToStr?.videoProcessingCallback = { [weak self] (pixelBuffer, timeInfo) -> Void in
            self?.writer?.processVideoPixelBuffer(pixelBuffer, timeInfo: timeInfo)
        }
        
        uiMixer?.addTarget(gpuToStr!)
    }
    
    func createMixer() {
        uiMixer = KSYGPUPicMixer()
        uiMixer!.masterLayer = UInt(uiLayer)
        uiMixer!.setPicRect(CGRect.init(x: -1, y: -1, width: 0, height: 0), ofLayer: playerLayer)
        uiMixer!.setPicRotation(kGPUImageFlipVertical, ofLayer: playerLayer)
        uiMixer!.setPicAlpha(1.0, ofLayer: playerLayer)
        
        uiMixer!.setPicRect(CGRect.init(x: 0, y: 0, width: 1, height: 1), ofLayer: uiLayer)
        uiMixer!.setPicAlpha(1.0, ofLayer: uiLayer)
        
        aMixer = KSYAudioMixer()
        aMixer!.mainTrack = Int32(dummyTrack)
        
        aMixer!.setTrack(Int32(dummyTrack), enable: true)
        aMixer!.setTrack(Int32(playerTrack), enable: true)
        
        var format: AudioStreamBasicDescription = AudioStreamBasicDescription()
        memset(&format, 0, MemoryLayout.size(ofValue: format))
        format.mSampleRate = 44100
        format.mFormatID = kAudioFormatLinearPCM
        format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked
        format.mChannelsPerFrame = 2
        format.mBitsPerChannel = 16
        format.mBytesPerFrame = format.mBitsPerChannel * format.mChannelsPerFrame / 8
        format.mFramesPerPacket = 1
        format.mBytesPerPacket = format.mBytesPerFrame * format.mFramesPerPacket
        
        dummyAudio = KSYDummyAudioSource.init(audioFmt: format)
        dummyAudio!.audioProcessingCallback = { [weak self] (sampleBuffer) -> Void in
            self?.aMixer?.processAudioSampleBuffer(sampleBuffer, of: Int32(self?.dummyTrack ?? 0))
            self?.lastPts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer!)
        }
        let startPts = CMTime.init(value: 0, timescale: 1000)
        dummyAudio?.start(at: startPts)
    }

    func processAudioSampleBuffer(buf: CMSampleBuffer) {
        processQueue.sync {
            if !bPlayRecord {
                return
            }
            
            aMixer?.processAudioSampleBuffer(buf, of: Int32(playerTrack))
        }
    }
    
    func process(with inputTexture: GLuint, textureSize: CGSize, time: CMTime) {
        processQueue.sync {
            if !bPlayRecord && bBackground {
                return
            }
            
            if let _ = uiMixer {
                textureInput = GPUImageTextureInput.init(texture: inputTexture, size: textureSize)
                uiMixer!.clearPic(ofLayer: playerLayer)
                textureInput!.addTarget(uiMixer!, atTextureLocation: playerLayer)
                textureInput!.processTexture(withFrameTime: time)
                
                uiElementInput = GPUImageUIElement.init(view: contentView)
                uiMixer!.clearPic(ofLayer: uiLayer)
                uiElementInput!.addTarget(uiMixer!, atTextureLocation: uiLayer)
                uiElementInput!.update(withTimestamp: lastPts)
            }
        }
    }

    func registerApplicationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    func unregisterApplicationObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    func applicationWillEnterForeground() {
        bBackground = false
    }
    
    func applicationDidBecomeActive() {
        bBackground = false
    }
    
    func applicationWillResignActive() {
        bBackground = true
    }

    func applicationDidEnterBackground() {
        bBackground = true
    }
    
    func applicationWillTerminate() {
        bBackground = true
    }
}
