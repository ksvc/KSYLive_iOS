//
//  KSYUIVC.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/5.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

/**
 ksy自定义视图控制器
 
 主要增加一些工具函数
 */
func SYSTEM_VERSION_GE_TO() -> Int {
    let os = ProcessInfo().operatingSystemVersion
    return os.majorVersion
}

class KSYUIVC: UIViewController {
    
    var timer: Timer?               // 在addObservers 中会注册此timer, 没秒重复调用onTimer
    var layoutView: KSYUIView?      // 默认的控制视图
    // 网络状态
    var networkStatus: String?
    var onNetworkChange: ((String) -> Void)?
    
    private
    var _reach: KSYReachability?
    var _preStatue: NetworkStatus
    
    init() {
        _preStatue = .NotReachable
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
        networkStatus = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.layoutUI()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    public func addObservers() {
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(onTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(networkChange),
                                               name: NSNotification.Name(rawValue: kReachabilityChangedNotification),
                                               object: nil)
        
        _reach = KSYReachability.init(hostName: "http://www.kingsoft.com")
        if _reach!.startNotifier() {
            print("start notifier success")
        }else{
            print("start notifier failed")
        }
    }
    
    // 如果没有主动调用, 会在 dealloc时调用
    public func rmObservers() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    // 重载本函数进行UI重新布局
    public func layoutUI() {
    
    }
    
    func networkChange() {
        let currentStatus = _reach!.currentReachabilityStatus()
        if currentStatus == _preStatue {
            return
        }
        
        _preStatue = currentStatus
        switch currentStatus {
        case .NotReachable:
            networkStatus = "无网络"
            break
        case .ReachableViaWWAN:
            networkStatus = "移动网络"
            break
        case .ReachableViaWiFi:
            networkStatus = "WIFI"
            break
        }
        
        if onNetworkChange != nil {
            onNetworkChange!(networkStatus!)
        }
        
    }
    
    // MARK: - UI Rotate
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (contex) in
            
        }) { (contex) in
            if SYSTEM_VERSION_GE_TO() >= 8 {
                self.onViewRotate()
            }
        }
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if SYSTEM_VERSION_GE_TO() >= 8 {
            return
        }
        self.onViewRotate()
    }
    
    func onViewRotate() {
        // 子类 重新该方法来响应屏幕旋转
    }
    
    // 定时更新调试信息 // 每秒重复调用
    public func onTimer(timer: Timer){
        
    }
    
    // ksy util functions
    public func sizeFormatted(kb: Int) -> String {
        if kb > 1000 {
            let MB = (Double)(kb) / 1000.0
            return String.init(format: " %4.2f MB", MB)
        }else{
            return " \(kb) KB"
        }
    }
    
    public func timeFormatted(totalSeconds: Int) -> String {
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600
        
        return String.init(format: "%02d:%02d:%02d",hours, minutes, seconds)
    }
    
    public func toast(message: String, duration: Double) {
        let toast: UIAlertView = UIAlertView.init(title: nil, message: message, delegate: nil, cancelButtonTitle: "OK")
        toast.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            toast.dismiss(withClickedButtonIndex: 0, animated: true)
        }
    }
    
    // TODO: cpu use rate
    class func cpu_usage() -> Float{
        return 0
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        var kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }

        if kerr != KERN_SUCCESS {
            return -1
        }
        
        var thread_list: thread_array_t?
        var thread_count: mach_msg_type_number_t = 0
        
        var thinfo: thread_info_data_t?
        var thread_info_count: mach_msg_type_number_t = 0
        
        var basic_info_th: thread_basic_info_t
        var stat_thread: UInt32 = 0 // mach threads
        
        // get threads in the task
        kerr = task_threads(mach_task_self_, UnsafeMutablePointer(&thread_list), &thread_count)
        
        if kerr != KERN_SUCCESS {
            return -1
        }
        
        if thread_count > 0 {
            stat_thread += thread_count
        }
        
        var tot_sec: CLong = 0
        var tot_usec: CLong = 0
        var tot_cpu: Float = 0
        for i in 0..<thread_count {
            thread_info_count = mach_msg_type_number_t(THREAD_INFO_MAX)
            kerr = withUnsafeMutablePointer(to: &thinfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(thread_list![Int(i)],
                                thread_flavor_t(THREAD_BASIC_INFO),
                                $0,
                                &thread_info_count)
                }
            }
            if kerr != KERN_SUCCESS {
                return -1
            }
            
            /*
             basic_info_th = (thread_basic_info_t)thinfo;
             
             if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
             tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
             tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
             tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
             }
             */
            
            // TODO:
//            basic_info_th = withUnsafeMutablePointer(to: &thinfo) {
//                $0.withMemoryRebound(to: thread_info_data_t.self, capacity: 1) {info_th in
//                    return
//                }
//            }
//            basic_info_th = thinfo
//            thread_basic_info_t  UnsafeMutablePointer<thread_basic_info>
            
        }
        
        /*
         kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
         assert(kr == KERN_SUCCESS);
         
         return tot_cpu
         */
    }
    
    
    class func memory_usage() -> Float{
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            print("Memory in use (in bytes): \(info.resident_size)")
            return Float(info.resident_size) / 100.0
        }
        else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
            return 0.0
        }
    }
    
    // TODO: 将UIImage 保存到path对应的文件
    class func saveImage(image: UIImage, path: String) {
        let dir = NSHomeDirectory().appending("/Documents/")
        let file = (dir as NSString).appendingPathComponent(path)
        let imageData = UIImagePNGRepresentation(image)
        var ret = false
        if let _ = imageData {
            ret = (imageData! as NSData).write(toFile: file, atomically: true)
        }
        print("write \(file) \(ret)")
    }

    override var shouldAutorotate: Bool{
//        self.layoutUI()
        return super.shouldAutorotate
    }

    override func transition(from fromViewController: UIViewController, to toViewController: UIViewController, duration: TimeInterval, options: UIViewAnimationOptions = [], animations: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        layoutUI()
    }
    
    deinit {
        if timer != nil {
            self.rmObservers()
        }
        _reach = nil
        NotificationCenter.default.removeObserver(self)
    }
    
}
