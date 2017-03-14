//
//  KSYLiveVC.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

class KSYLiveVC: UIViewController {

    let kCellIdentifier = "com.ksyun.tableCellIdentifier"
    var _textField: UITextField?
    var _buttonQR: UIButton?
    var _buttonClose: UIButton?
    var _ctrTableView: UITableView?
    var _addressTable: UITableView?
    var _controllers: [String]?
    var _width: CGFloat = 0
    var _height: CGFloat = 0
    var _addressMulArray: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "KSYDEMO"
        view.backgroundColor = .white
        _addressMulArray = [String]()
        let devCode = (UIDevice.current.identifierForVendor!.uuidString as NSString).substring(to: 3)
        let streamSrv = "rtmp://test.uplive.ksyun.com/live"
        let streamUrl = "\(streamSrv)/\(devCode)"
        let playUrl = "rtmp://live.hkstv.hk.lxdns.com/live/hks"
        let recordFile = "RecordAv.mp4"
        
        _addressMulArray?.append(streamUrl)
        _addressMulArray?.append(playUrl)
        _addressMulArray?.append(recordFile)
        
        initVariable()
        initLiveVCUI()
        KSYDBCreater.initDatabase()
    }
    
    func addTextField() -> UITextField {
        let text = UITextField()
        text.delegate = self
        text.layer.masksToBounds = true
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.black.cgColor
        text.layer.cornerRadius = 2
        
        view.addSubview(text)
        return text
    }
    
    func addTableView() -> UITableView {
        let table = UITableView()
        table.layer.masksToBounds = true
        table.layer.borderColor = UIColor.black.cgColor
        table.layer.borderWidth = 1
        table.delegate = self
        table.dataSource = self
        view.addSubview(table)
        return table
    }
    
    func addButton(title: String) -> UIButton {
        let btn = UIButton.init(type: .roundedRect)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = .lightGray
        btn.addTarget(self, action: #selector(onBtn(sender:)), for: .touchUpInside)
        view.addSubview(btn)
        
        return btn
    }
    
    func initVariable() {
        _width = view.frame.width
        _height = view.frame.height
        _controllers = ["播放demo",
                        "文件格式探测",
                        "播放自动化测试",
                        "推流demo",
                        "录制推流短视频",
                        "录制播放短视频",
                        "网络探测"]
    }
    
    func initFrame() {
        var textY = UIApplication.shared.statusBarFrame.height
        let btnH: CGFloat = 30
        let btnW: CGFloat = 80
        _buttonQR?.frame = CGRect.init(x: 20,
                                       y: textY + 5,
                                       width: btnW,
                                       height: btnH)
        _buttonClose?.frame = CGRect.init(x: _width - 20 - btnW,
                                          y: textY + 5,
                                          width: btnW,
                                          height: btnH)
        
        textY += btnH + 10
        
        let textX: CGFloat = 1
        let textWdh = _width - 2
        let textHgh: CGFloat = 30
        _textField?.frame = CGRect.init(x: textX,
                                        y: textY,
                                        width: textWdh,
                                        height: textHgh)
        
        let adTaY = textY + textHgh
        let adTaHgh = _height / 2 - adTaY
        _addressTable?.frame = CGRect.init(x: textX,
                                           y: adTaY,
                                           width: textWdh,
                                           height: adTaHgh)
        
        
        let tableX: CGFloat = 1
        let tableY = _height / 2
        let tableWdh = _width - 2
        let tableHgh = _height / 2
        _ctrTableView?.frame = CGRect.init(x: tableX,
                                          y: tableY,
                                          width: tableWdh,
                                          height: tableHgh)
    }
    
    func initLiveVCUI() {
        _textField = addTextField()
        _addressTable = addTableView()
        _ctrTableView = addTableView()
        _buttonQR = addButton(title: "扫描二维码")
        _buttonClose = addButton(title: "关闭键盘")
        initFrame()
    }
    
    func onBtn(sender: UIButton) {
        if sender == _buttonQR {
            scanQR()
        }else if sender == _buttonClose {
            closeKeyBoard()
        }
    }
    
    func closeKeyBoard() {
        _textField?.resignFirstResponder()
    }
    
    func scanQR() {
        let qrVC = QRViewController()
        qrVC.getQrCode = { [weak self] (strQR) -> Void in
            self?.showAddress(str: strQR)
        }
        present(qrVC, animated: true, completion: nil)
    }
    
    func showAddress(str: String) {
        _textField?.text = str
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        _textField?.resignFirstResponder()
    }

    func myReloadData() {
        let addrArray = KSYSQLite.sharedInstance.getAddress()
        for dic in addrArray {
            if let addr = dic["address"] {
                _addressMulArray?.append(addr)
            }
        }
        _addressTable?.reloadData()
    }
}

extension KSYLiveVC: UITableViewDataSource,UITableViewDelegate , UITextFieldDelegate {

    public func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == _ctrTableView {
            return 1
        }else if tableView == _addressTable{
            return 3
        }else{
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == _ctrTableView {
            return _controllers!.count
        }else if tableView == _addressTable{
            return 1
        }else{
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier)
        
        if let _ = cell {
        }else {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: kCellIdentifier)
        }
        
        if tableView == _ctrTableView {
            cell?.textLabel?.text = _controllers?[indexPath.row]
        }else if tableView == _addressTable {
            cell?.textLabel?.text = _addressMulArray?[indexPath.section]
            
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
            let cellView = UIView.init(frame: cell!.frame)
            cellView.backgroundColor = .gray
            cell?.backgroundView = cellView
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == _ctrTableView {
            guard let _ = _textField, let _ = _textField!.text, _textField!.text!.lengthOfBytes(using: .utf8) > 0 else{
                return
            }
            print("url:\(_textField!.text!)")
            var dir: String? = nil
            var url = URL.init(string: _textField!.text!)
            var vc: UIViewController? = nil
            if indexPath.row == 0 {
                vc = KSYPlayerVC.init(url: url!)
            }else if indexPath.row == 1 {
                vc = KSYProberVC.init(url: url!)
            }else if indexPath.row == 2 {
                vc = MonkeyTestViewController()
            }else if indexPath.row == 3 {
                vc = KSYPresetCfgVC.init(url: _textField!.text!)
            }else if indexPath.row == 4 {
                let scheme = url!.scheme
                if scheme == "rtmp" ||
                    scheme == "http" ||
                    scheme == "https" {
                    print("invalid local file name")
                }else{
                    dir = NSHomeDirectory().appending("/Documents/")
                    let urlStr = (dir! as NSString).appendingPathComponent(_textField!.text!)
                    url = URL.init(string: urlStr)
                    let preVC = KSYPresetCfgVC.init(url: urlStr)
                    preVC.cfgView.btn0?.setTitle("开始录制", for: .normal)
                    vc = preVC
                }
            }else if indexPath.row == 5 {
                vc = KSYRecordVC.init(url: url!)
            }else if indexPath.row == 6 {
                vc = KSYNetTrackerVC()
            }
            
            if let _ = vc {
                present(vc!, animated: true, completion: nil)
            }
        }else if tableView == _addressTable {
            _textField?.text = _addressMulArray?[indexPath.section] ?? ""
            _textField?.resignFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == _ctrTableView {
            return "控制器栏"
        }else if tableView == _addressTable {
            if section == 0 {
                return "推流地址"
            }else if section == 1 {
                return "拉流地址"
            }else if section == 2 {
                return "录制文件"
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
}
