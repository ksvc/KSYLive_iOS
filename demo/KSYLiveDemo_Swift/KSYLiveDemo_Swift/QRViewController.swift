//
//  QRViewController.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

class QRViewController: UIViewController {

    var getQrCode: ((_ stringQR: String) -> Void)?
    
    private
    var _viewPreview: UIView?
    var _QRLabel: UILabel?
    var _scanBtn: UIButton?
    var _backBtn: UIButton?
    var _boxView: UIView?
    var _isReading: Bool = false
    var _scanLayer: CALayer?
    var _width: CGFloat = 0
    var _height: CGFloat = 0
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        initVariable()
        addViews()
        startReading()
    }

    func initVariable() {
        captureSession = nil
        _isReading = false
        _width = view.frame.width
        _height = view.frame.height
    }
    
    func addViews() {
        _viewPreview = addViewPreview()
        _QRLabel = addLable()
        _scanBtn = addButton(title: "正在扫描...")
        _backBtn = addButton(title: "返回")
        _scanBtn?.frame = CGRect.init(x: 0,
                                      y: _height - 30,
                                      width: _width,
                                      height: 30)
        _backBtn?.frame = CGRect.init(x: 20,
                                      y: 30,
                                      width: 80,
                                      height: 30)
    }
    
    func addViewPreview() -> UIView {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 64, width: _width, height: _height - 94))
        self.view.addSubview(view)
        return view
    }
    
    func addLable() -> UILabel {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 64, width: _width, height: 30))
        label.backgroundColor = .white
        view.addSubview(label)
        label.layer.masksToBounds = true
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.cornerRadius = 2
        view.addSubview(label)
        return label
    }
    
    func addButton(title: String) -> UIButton {
        let btn = UIButton.init(type: .roundedRect)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = .lightGray
        view.addSubview(btn)
        btn.addTarget(self, action: #selector(onBtn(sender:)), for: .touchUpInside)
        return btn
    }
    
    func onBtn(sender: UIButton){
        if sender == _scanBtn {
            reScan()
        }else if sender == _backBtn {
            dismiss(animated: false, completion: nil)
        }
    }
    
    func reScan() {
        if !_isReading {
            if startReading() {
                _scanBtn?.setTitle("正在扫描...", for: .normal)
                _QRLabel?.text = "Scanning for QR Code"
            }
        }else{
            stopReading()
            _scanBtn?.setTitle("重新扫描", for: .normal)
        }
        _isReading = !_isReading
    }
    
    func startReading() -> Bool {
        // 1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        // 2.用captureDevice创建输入流
        var input: AVCaptureDeviceInput? = nil
        do{
            input = try AVCaptureDeviceInput.init(device: captureDevice)
        }catch let error as NSError{
            print("\(error.debugDescription)")
        }
        
        guard let _ = input else {
            return false
        }

        // 3.创建媒体数据输出流
        let captureMetadataOutput = AVCaptureMetadataOutput()
        // 4.实例化捕捉会话
        captureSession = AVCaptureSession()
        // 4.1 将输入流添加到会话
        captureSession?.addInput(input!)
        // 4.2 将媒体输出流添加到会话中
        captureSession?.addOutput(captureMetadataOutput)
        // 5.创建串行队列，并加媒体输出流添加到队列当中
        let outputQueue = DispatchQueue.init(label: "outputQueue")
        // 5.1.设置代理
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: outputQueue)
        // 5.2.设置输出媒体数据类型为QRCode
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // 6.实例化预览图层
        videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        // 7.设置预览图层填充方式
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        // 8.设置图层的frame
        videoPreviewLayer?.frame = _viewPreview!.layer.bounds
        
        // 9.将图层添加到预览view的图层上
        _viewPreview?.layer.addSublayer(videoPreviewLayer!)
        
        // 10.设置扫描范围
        captureMetadataOutput.rectOfInterest = CGRect.init(x: 0.2, y: 0.2, width: 0.8, height: 0.8)
        // 10.1.扫描框
        _boxView = UIView.init(frame: CGRect.init(x: _viewPreview!.bounds.size.width * 0.2,
                                                  y: _viewPreview!.bounds.size.height * 0.2,
                                                  width: _viewPreview!.bounds.size.width - _viewPreview!.bounds.size.width * 0.4,
                                                  height: _viewPreview!.bounds.size.height - _viewPreview!.bounds.size.height * 0.4))
        _boxView?.layer.borderColor = UIColor.green.cgColor
        _boxView?.layer.borderWidth = 1.0
        
        _viewPreview?.addSubview(_boxView!)
        
        // 10.2.扫描线
        _scanLayer = CALayer()
        _scanLayer?.frame = CGRect.init(x: 0, y: 0, width: _boxView!.frame.width, height: 1)
        _scanLayer?.backgroundColor = UIColor.brown.cgColor
        
        _boxView?.layer.addSublayer(_scanLayer!)
        
        let timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(moveScanLayer(timer:)), userInfo: nil, repeats: true)
        
        timer.fire()
        
        // 11.开始扫描
        captureSession?.startRunning()
        
        return true
    }
    
    func stopReading() {
        captureSession?.stopRunning()
        captureSession = nil
        _scanLayer?.removeFromSuperlayer()
        videoPreviewLayer?.removeFromSuperlayer()
        _scanBtn?.setTitle("重新扫描", for: .normal)
        if let _ = getQrCode {
            getQrCode!(_QRLabel!.text ?? "")
        }
    }

    func moveScanLayer(timer: Timer) {
        var frame = _scanLayer!.frame
        if _boxView!.frame.height < _scanLayer!.frame.origin.y {
            frame.origin.y = 0
            _scanLayer?.frame = frame
        }else {
            frame.origin.y += 5
            UIView.animate(withDuration: 0.1, animations: { [weak self] in
                self?._scanLayer?.frame = frame
            })
        }
    }
}

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // 判断是否有数据
        if metadataObjects != nil && metadataObjects.count > 0 {
            let metadataObj: AVMetadataMachineReadableCodeObject = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            //判断回传的数据类型
            if metadataObj.type == AVMetadataObjectTypeQRCode {
                DispatchQueue.main.async { [weak self] in
                    self?._QRLabel?.text = metadataObj.stringValue
                }
                performSelector(onMainThread: #selector(stopReading), with: nil, waitUntilDone: false)
                _isReading = false
            }
        }
    }
}
