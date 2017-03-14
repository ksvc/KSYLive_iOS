//
//  KSYStateLableView.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/10.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

struct StreamState {
    var timeSecond: Double;     // 更新时间
    var uploadKByte: Int;       // 上传的字节数(KB)
    var encodedFrames: Int;     // 编码的视频帧数
    var droppedVFrames: Int;    // 丢弃的视频帧数
}


/**
 KSY 推流SDK的状态监控控件
 
 streamerVC 每秒钟刷新一次监控的数据
 视图中文字为底部对齐
 */


class KSYStateLableView: UILabel {
    // 上一次更新时的数据, 假定每秒更新一次
    var _lastStD: StreamState?
    
    var startTime: Double? = 0      // 开始推流的时间
    var notGoodCnt: Int?            // 网络拥塞事件发生次数
    var bwRaiseCnt: Int?            // 码率上调事件发生次数
    var bwDropCnt: Int?             // 码率下调事件发生次数
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .clear
        textColor = .red
        numberOfLines = 7
        textAlignment = .left
        initStreamStat()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 将推流状态信息清0
    func initStreamStat() {
        // TODO: 不确定是否写对了
        memset(&_lastStD, 0, MemoryLayout<StreamState>.size)
        startTime = Date().timeIntervalSince1970
        notGoodCnt = 0
        bwRaiseCnt = 0
        bwDropCnt = 0
    }
    
    // 更新数据(需要每秒被调用一次)
    func updateState(str: KSYStreamerBase) {
        var curState: StreamState = StreamState(timeSecond: 0,uploadKByte: 0,encodedFrames: 0,droppedVFrames: 0)
        curState.timeSecond = Date().timeIntervalSince1970
        curState.uploadKByte = Int(str.uploadedKByte)
        curState.encodedFrames = Int(str.encodedFrames)
        curState.droppedVFrames = Int(str.droppedVideoFrames)
        
        var deltaS: StreamState = StreamState(timeSecond: 0,uploadKByte: 0,encodedFrames: 0,droppedVFrames: 0)
        if let _ = _lastStD {
        }else{
            deltaS = curState
        }
        
        if _lastStD == nil {
            _lastStD = StreamState(timeSecond: 0, uploadKByte: 0, encodedFrames: 0, droppedVFrames: 0)
        }
        
        deltaS.timeSecond = curState.timeSecond - _lastStD!.timeSecond
        deltaS.uploadKByte = curState.uploadKByte - _lastStD!.uploadKByte
        deltaS.encodedFrames = curState.encodedFrames - _lastStD!.encodedFrames
        deltaS.droppedVFrames = curState.droppedVFrames - _lastStD!.droppedVFrames
        _lastStD = curState
        
        let realTKbps = Double(deltaS.uploadKByte * 8) / deltaS.timeSecond
        let encFps = Double(deltaS.encodedFrames) / deltaS.timeSecond
        let dropPercent = deltaS.droppedVFrames * 100 / max(curState.encodedFrames, 1)
        
        let liveTime = KSYUIVC().timeFormatted(totalSeconds: Int(curState.timeSecond - startTime!))
        let uploadDateSize = KSYUIVC().sizeFormatted(kb: curState.uploadKByte)
        let stateUrl = "\(str.hostURL.absoluteString)\n"
        let stateKbps = String.init(format: "实时码率(kbps)%4.1f\tA%4.1f\tV%4.1f\n", realTKbps, str.encodeAKbps, str.encodeVKbps)
        let stateFps = String.init(format: "实时帧率(fps)%2.1f\t总上传:%@\n", encFps, uploadDateSize )
        let stateDrop = String.init(format: "视频丢帧 %4d\t %2.1f%% \n", curState.droppedVFrames, dropPercent)
        let netEvent = String.init(format: "网络事件计数 %d bad\t bw %d Raise\t %d drop\n", notGoodCnt!, bwRaiseCnt!, bwDropCnt!)
        let cup_use = String.init(format: "%@ \tcpu: %.2f mem: %.1fMB",liveTime, KSYHelper.cpu_usage(), KSYHelper.memory_usage())
        
        if let _ = text {
        }else{
            text = ""
        }
        text = stateUrl + stateKbps
        text! += stateFps
        text! += stateDrop
        text! += netEvent
        text! += cup_use
    }
    
    override func drawText(in rect: CGRect) {
        guard let _ = text else { return }
        
        var newRect = rect
        let oldH: CGFloat = newRect.height
        
        let attributeText = NSAttributedString.init(string: text!,
                                                    attributes: [NSFontAttributeName:self.font])
        
        
        newRect.size = CGSize.init(width: newRect.width, height: attributeText.boundingRect(with: newRect.size, options: .usesLineFragmentOrigin, context: nil).height)
        
        if numberOfLines != 0 {
            newRect.size = CGSize.init(width: newRect.width, height: min(newRect.height, CGFloat(numberOfLines) * font.lineHeight))
        }
        newRect.origin.y = oldH - newRect.height
        super.drawText(in: newRect)
    }
}
