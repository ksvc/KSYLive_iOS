//
//  KSYProgressView.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

let kBoundsMargin: CGFloat = 2.0;
let kTimeLabelWidth: CGFloat = 30.0;
let kTimeLabelHight: CGFloat = 10.0;
let kNullTimeLabelText: String = "--:--";
let kFontName: String = "Helvetica";

class KSYProgressView: UIView {

    var totalTimeInSeconds: Float?
    var cacheProgress: Float?
    var playProgress: Float?
    var dragingSliderCallback: ((_ progress: Float) -> Void)?

    private
    var slider: UISlider?
    var progressView: UIProgressView?
    var playedTimeLabel: UILabel?
    var unplayedTimeLabel: UILabel?
    
    init(){
        super.init(frame: CGRect.zero)
        progressView = UIProgressView()
        progressView?.trackTintColor = UIColor.lightGray
        progressView?.progressTintColor = UIColor.darkGray
        addSubview(progressView!)
        
        slider = UISlider()
        slider?.maximumTrackTintColor = UIColor.clear
        slider?.minimumValue = 0
        slider?.maximumValue = 1
        addSubview(slider!)
        
        playedTimeLabel = addTimeLabel()
        unplayedTimeLabel = addTimeLabel()
        
        addObserver(self, forKeyPath: "cacheProgress", options: .new, context: nil)
        addObserver(self, forKeyPath: "playProgress", options: .new, context: nil)
        
        slider?.addTarget(self, action: #selector(dragSliderDidEnd), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver(self, forKeyPath: "cacheProgress")
        removeObserver(self, forKeyPath: "playProgress")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "cacheProgress" {
            progressView?.setProgress(cacheProgress!, animated: true)
        }else if keyPath == "playProgress" {
            slider?.setValue(playProgress!, animated: true)
            playedTimeLabel!.text = convertToMinutes(seconds: totalTimeInSeconds! * playProgress!)
            unplayedTimeLabel!.text = convertToMinutes(seconds: totalTimeInSeconds! * (1 - playProgress!))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        playedTimeLabel?.frame = CGRect.init(x: 0,
                                             y: (bounds.height - kTimeLabelHight) / 2,
                                             width: kTimeLabelWidth,
                                             height: kTimeLabelHight)
        
        unplayedTimeLabel?.frame = CGRect.init(x: bounds.width - kTimeLabelWidth,
                                               y: (bounds.height - kTimeLabelHight) / 2,
                                               width: kTimeLabelWidth,
                                               height: kTimeLabelHight)

        let progressAreaFrame = CGRect.init(x: kTimeLabelWidth,
                                            y: 0,
                                            width: bounds.width - 2 * kTimeLabelWidth,
                                            height: bounds.height)
        
        progressView?.frame = CGRect.init(x: progressAreaFrame.origin.x,
                                          y: progressAreaFrame.height / 2 - kBoundsMargin / 2,
                                          width: progressAreaFrame.width - 2 * kBoundsMargin,
                                          height: progressAreaFrame.height)
        slider?.frame = progressAreaFrame
    }
    
    func dragSliderDidEnd() {
        if let _ = dragingSliderCallback {
            dragingSliderCallback!(slider!.value)
        }
    }
    
    func convertToMinutes(seconds: Float) -> String {
        let timeStr = String.init(format: "%02d:%02d", Int(seconds) / 60, Int(seconds) % 60)
        return timeStr
    }
    
    func addTimeLabel() -> UILabel {
        let timeLabel = UILabel()
        timeLabel.textColor = UIColor.white
        timeLabel.font = UIFont.init(name: kFontName, size: 10)
        timeLabel.text = kNullTimeLabelText
        timeLabel.textAlignment = .center
        addSubview(timeLabel)
        
        return timeLabel
    }
}
