//
//  KSYNetTrackerVC.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 2017/1/23.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

class KSYNetTrackerVC: UIViewController {

    var lbDomain: UILabel?
    var tfDomain: UITextField?
    var tfDomainLine: UIView?
    
    var btnMTR: UIButton?
    var btnPing: UIButton?
    var btnQuit: UIButton?
    
    var textView_ret: UITextView?
    
    var tracker: KSYNetTracker?
    var isRunning: Bool = false
    var action: KSY_NETTRACKER_ACTION?
    var infoLog: String = ""
    var stateStr: String? = ""
    var displayStr: String? = ""
    var _registeredNotifications: [NSNotification.Name]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initNetTracker()
    }
    
    deinit {
        unregisterObserver()
    }
    
    func initUI() {
        let wdt: CGFloat = view.bounds.width
        let hgt: CGFloat = view.bounds.height
        
        var xPos: CGFloat = 0, yPos: CGFloat = 0
        let elem_width: CGFloat = 100, elem_height: CGFloat = 100
        
        view.backgroundColor = .white
        xPos = wdt / 8
        yPos = hgt / 15
        
        lbDomain = UILabel.init(frame: CGRect.init(x: xPos,
                                                   y: yPos,
                                                   width: wdt * 4 / 5,
                                                   height: elem_height))
        lbDomain?.textColor = .black
        lbDomain?.text = "请输入待探测地址："
        view.addSubview(lbDomain!)
        
        xPos += 20
        yPos += elem_height
        tfDomain = UITextField.init(frame: CGRect.init(x: xPos,
                                                       y: yPos,
                                                       width: wdt * 3 / 5,
                                                       height: elem_height))
        tfDomain?.returnKeyType = .done
        tfDomain?.text = "www.baidu.com"
        
        tfDomainLine = UIView.init(frame: CGRect.init(x: 0,
                                                      y: elem_height,
                                                      width: tfDomain!.frame.width,
                                                      height: 2))
        tfDomainLine?.backgroundColor = .black
        view.addSubview(tfDomainLine!)
        tfDomain?.addSubview(tfDomainLine!)
        
        xPos = wdt / 12
        yPos += elem_height + 25
        btnPing = UIButton.init(type: .roundedRect)
        btnPing?.accessibilityLabel = "Ping"
        btnPing?.frame = CGRect.init(x: xPos,
                                     y: yPos,
                                     width: elem_width,
                                     height: elem_height)
        btnPing?.backgroundColor = .lightGray
        btnPing?.setTitle("Ping", for: .normal)
        btnPing?.addTarget(self, action: #selector(startNetDiagnosis(btn:)), for: .touchUpInside)
        view.addSubview(btnPing!)
        
        xPos += elem_width + 25
        btnMTR = UIButton.init(type: .roundedRect)
        btnMTR?.accessibilityLabel = "MTR"
        btnMTR?.frame = CGRect.init(x: xPos,
                                    y: yPos,
                                    width: elem_width,
                                    height: elem_height)
        btnMTR?.backgroundColor = .lightGray
        btnMTR?.setTitle("MTR", for: .normal)
        btnMTR?.addTarget(self, action: #selector(startNetDiagnosis(btn:)), for: .touchUpInside)
        view.addSubview(btnMTR!)
        
        xPos += elem_width + 25
        btnQuit = UIButton.init(type: .roundedRect)
        btnQuit?.frame = CGRect.init(x: xPos,
                                    y: yPos,
                                    width: elem_width,
                                    height: elem_height)
        btnQuit?.backgroundColor = .lightGray
        btnQuit?.setTitle("btnQuit", for: .normal)
        btnQuit?.addTarget(self, action: #selector(onQuit(sender:)), for: .touchUpInside)
        view.addSubview(btnQuit!)
        
        yPos += elem_height + 25
        textView_ret = UITextView.init(frame: .zero)
        textView_ret?.layer.borderWidth = 1.0
        textView_ret?.layer.borderColor = UIColor.lightGray.cgColor
        textView_ret?.backgroundColor = .white
        textView_ret?.font = UIFont.init(name: "Courier New", size: 12)
        textView_ret?.textAlignment = .left
        textView_ret?.isScrollEnabled = true
        textView_ret?.isEditable = false
        textView_ret?.frame = CGRect.init(x: 0,
                                          y: yPos,
                                          width: wdt,
                                          height: hgt - yPos)
        view.addSubview(textView_ret!)
        
    }
    
    func initNetTracker() {
        tracker = KSYNetTracker()
        if let _ = tracker {
            print("init tracker failed")
        }
        setupObserver()
    }
    
    func setupObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTrackerNotify(notify:)), name: NSNotification.Name.KSYNetTrackerOnceDone, object: tracker)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTrackerNotify(notify:)), name: NSNotification.Name.KSYNetTrackerFinished, object: tracker)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTrackerNotify(notify:)), name: NSNotification.Name.KSYNetTrackerError, object: tracker)
        _registeredNotifications = [.KSYNetTrackerOnceDone, .KSYNetTrackerFinished, .KSYNetTrackerError]
    }
    
    func unregisterObserver() {
        guard let _ = _registeredNotifications else {
            NotificationCenter.default.removeObserver(self)
            return
        }
        
        for name in _registeredNotifications! {
            NotificationCenter.default.removeObserver(self, name: name, object: tracker)
        }
    }
    
    func onQuit(sender: UIButton) {
        displayStr = ""
        displayInfo()
        stopNetDiagnosis()
        dismiss(animated: false, completion: nil)
    }
    
    func startNetDiagnosis(btn: UIButton) {
        if !isRunning {
            displayStr = ""
            
            if btn.accessibilityLabel == "Ping" {
                action = KSY_NETTRACKER_ACTION.PING
            }else{
                action = KSY_NETTRACKER_ACTION.MTR
            }
            
            tracker?.action = action!
            if let _ = tracker ,let _ = tfDomain{
                if tracker!.start((tfDomain!.text)!) != 0 {
                    displayStr = "启动探测失败，请检查网络或待探测地址!"
                    displayInfo()
                    return
                }
            }
            
            btn.setTitle("stop", for: .normal)
            if btn.accessibilityLabel == "Ping" {
                btnMTR?.alpha = 0.4
                btnMTR?.isEnabled = false
            }else {
                btnPing?.alpha = 0.4
                btnPing?.isEnabled = false
            }
            
            isRunning = !isRunning
            displayStr = "开始探测......\n"
            stateStr = "开始探测......\n"
            displayInfo()
        }else{
            stopNetDiagnosis()
            if action == KSY_NETTRACKER_ACTION.PING {
                displayStr = displayStr?.appending(getPingRetStr())
            }else{
                displayStr = "停止探测，已统计结果如下：\n"
                stateStr = "停止探测，已统计结果如下：\n"
                displayStr = displayStr?.appending(infoLog ?? "")
            }
            displayInfo()
        }
    }
    
    func stopNetDiagnosis() {
        btnPing?.setTitle("Ping", for: .normal)
        btnMTR?.setTitle("MTR", for: .normal)
        btnMTR?.alpha = 1
        btnPing?.alpha = 1
        btnMTR?.isEnabled = true
        btnPing?.isEnabled = true
        
        tracker?.stop()
        isRunning = false
    }
    
    func handleTrackerNotify(notify: NSNotification) {
        guard let _ = tracker else {
            return
        }
        
        switch notify.name {
        case Notification.Name.KSYNetTrackerOnceDone:
            if action == KSY_NETTRACKER_ACTION.PING {
                let rtt = ((notify.userInfo! as NSDictionary).object(forKey: "rtt") as! NSString).floatValue
                let count = ((notify.userInfo! as NSDictionary).object(forKey: "count") as! NSString).intValue
                if rtt < 0.00000001 {
                    displayStr = displayStr?.appending("Request timeout for icmp_seq \(count)")
                }else{
                    let pingRet = tracker?.routerInfo?.firstObject as! KSYNetRouterInfo
                    displayStr = displayStr?.appending(String(format: "ping \(pingRet.ips?.firstObject ?? "") icmp_seq \(count) time=%0.3f ms", rtt))
                }
            }else {
                getRouterInfo()
                displayStr = ""
                displayStr = displayStr?.appending(stateStr ?? "")
                displayStr = displayStr?.appending(infoLog ?? "")
            }
            break
        case Notification.Name.KSYNetTrackerFinished:
            if action == KSY_NETTRACKER_ACTION.PING {
                displayStr = displayStr?.appending(getPingRetStr())
            }else {
                stateStr = "探测完成，结果如下：\n\n"
                displayStr = ""
                displayStr = displayStr?.appending(stateStr ?? "")
                displayStr = displayStr?.appending(infoLog ?? "")
            }
            
            btnPing?.setTitle("Ping", for: .normal)
            btnMTR?.setTitle("MTR", for: .normal)
            btnMTR?.alpha = 1
            btnPing?.alpha = 1
            btnMTR?.isEnabled = true
            btnPing?.isEnabled = true
            isRunning = false
            tracker?.stop()
            break
        case Notification.Name.KSYNetTrackerError:
            break
        default:
            ()
        }
        displayInfo()
    }
    
    func displayInfo() {
        DispatchQueue.main.async { [weak self] in
            self?.textView_ret?.text = self?.displayStr
        }
    }
    
    func getPingRetStr() -> String {
        var pingRetStr: String = ""
        let pingRet = tracker?.routerInfo?[0] as! KSYNetRouterInfo
        
        pingRetStr = pingRetStr.appending("\n ------ping statics-----\n")
        pingRetStr = pingRetStr.appendingFormat("%d packets transmitted, %d packets received,  %0.3f packet loss\n", pingRet.number, Int(Float(pingRet.number) * (1 - pingRet.loss)), pingRet.loss)
        
        pingRetStr = pingRetStr.appendingFormat("round-trip min/avg/max/stdev = %0.3f/%0.3f/%0.3f/%0.3fms\n", pingRet.tmin, pingRet.tavg, pingRet.tmax, pingRet.tdev)
        return pingRetStr
    }
    
    func getInfoHeader() -> String {
        var header = ""
        header = header.appendingFormat("%-8s", "idx")
        header = header.appendingFormat("%-10s", "ip")
        header = header.appendingFormat("%-8s", "number")
        header = header.appendingFormat("%-7s", "max")
        header = header.appendingFormat("%-7s", "min")
        header = header.appendingFormat("%-6s", "avg")
        header = header.appendingFormat("%-6s", "stdev")
        header = header.appendingFormat("%-4s\n", "loss")
        return header
    }
    
    func getRouterInfo() {
        infoLog = getInfoHeader()
        var i = 1, j = 0
        
        guard let _ = tracker?.routerInfo else {
            return
        }
        
        tracker!.routerInfo?.enumerateObjects( { (netInfo, idx, _) in
            if let info: KSYNetRouterInfo = (netInfo as! KSYNetRouterInfo) {
                
                if let _ = info.ips {
                    j = 0;
                    
                    for ip in info.ips! {
                        if let ip: String = (ip as! String) {
                            if j == 0 {
                                infoLog = infoLog.appendingFormat("%-3d", i)
                                infoLog = infoLog.appendingFormat("%-16s", (ip as NSString).utf8String!)
                                infoLog = infoLog.appendingFormat("%-4d", info.number)
                                infoLog = infoLog.appendingFormat("%5.1fms", info.tmax)
                                infoLog = infoLog.appendingFormat("%5.1fms", info.tmin)
                                infoLog = infoLog.appendingFormat("%5.1fms", info.tavg)
                                infoLog = infoLog.appendingFormat("%  %-6.1f", info.tdev)
                                infoLog = infoLog.appendingFormat("%-4.1f\n", info.loss)
                            }else{
                                infoLog = infoLog.appendingFormat("    %-16s\n", ip)
                            }
                            
                            j += 1
                        }
                    }
                }else{
                    infoLog = infoLog.appendingFormat("%-3d", i)
                    infoLog = infoLog.appendingFormat("%-16s", "--")
                    infoLog = infoLog.appendingFormat("%-4s", "--")
                    infoLog = infoLog.appendingFormat("%-7s", "--")
                    infoLog = infoLog.appendingFormat("%-7s", "--")
                    infoLog = infoLog.appendingFormat("%-7s", "--")
                    infoLog = infoLog.appendingFormat("%-6s", "--")
                    infoLog = infoLog.appendingFormat("%-4s\n\n", "--")
                }
                i += 1
            }
        });
        
//        for netInfo in tracker!.routerInfo {
//            if let info: KSYNetRouterInfo = (netInfo as! KSYNetRouterInfo) {
//                
//                if let _ = info.ips {
//                    j = 0;
//                    
//                    for ip in info.ips {
//                        if let ip: String = (ip as! String) {
//                            if j == 0 {
//                                infoLog = infoLog.appendingFormat("%-3d", i)
//                                infoLog = infoLog.appendingFormat("%-16s", ip)
//                                infoLog = infoLog.appendingFormat("%-4d", info.number)
//                                infoLog = infoLog.appendingFormat("%5.1fms", info.tmax)
//                                infoLog = infoLog.appendingFormat("%5.1fms", info.tmin)
//                                infoLog = infoLog.appendingFormat("%5.1fms", info.tavg)
//                                infoLog = infoLog.appendingFormat("%  %-6.1f", info.tdev)
//                                infoLog = infoLog.appendingFormat("%-4.1f\n", info.loss)
//                            }else{
//                                infoLog = infoLog.appendingFormat("    %-16s\n", ip)
//                            }
//                            
//                            j += 1
//                        }
//                    }
//                }else{
//                    infoLog = infoLog.appendingFormat("%-3d", i)
//                    infoLog = infoLog.appendingFormat("%-16s", "--")
//                    infoLog = infoLog.appendingFormat("%-4s", "--")
//                    infoLog = infoLog.appendingFormat("%-7s", "--")
//                    infoLog = infoLog.appendingFormat("%-7s", "--")
//                    infoLog = infoLog.appendingFormat("%-7s", "--")
//                    infoLog = infoLog.appendingFormat("%-6s", "--")
//                    infoLog = infoLog.appendingFormat("%-4s\n\n", "--")
//                }
//                i += 1
//            }
//        }
    }
    
}
