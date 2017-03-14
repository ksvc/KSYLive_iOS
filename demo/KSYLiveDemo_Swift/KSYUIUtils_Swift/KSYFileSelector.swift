//
//  KSYFileSelector.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/9.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

enum KSYSelectType {
    case NEXT
    case RANDOM
    case PREVIOUS
}

class KSYFileSelector: NSObject {
    // MARK: - configs
    
    //目标目录, 比如"Documents/bgms"
    public var filesDir: String
    // 需要匹配的文件后缀列表
    public var suffixList: [String]
    // 满足条件的文件列表
    public var fileList: [String]?
    
    // MARK: - results
    
    // 当前选中的文件的路径(完整路径)
    var filePath: String = String()
    // 当前正在播放的音乐文件的索引
    var fileIdx: Int = 0
    // "文件名(index/满足条件的文件总数)"
    var fileInfo: String = String()
    
    private var _fullDir: String?
    
    
    /**
     @abstract   初始化
     @param      dir 目标地址
     @param      suf 后缀列表, 比如: @[".mp3", ".aac"]
     */
    init(dir: String, suf: [String]) {
        filesDir = dir
        suffixList = suf
        super.init()
        _ = reload()
    }
    
    /**
     @abstract   重新载入
     @discussion 当目标目录和后缀列表有变动, 或者目录中文件有增减时可用与重新生成列表
     @discussion reload后, fileIdx 重置为0
     @return     NO: 1. 目标目录不存在, 2. 目标目录中没有满足条件的文件
     */
    func reload() -> Bool {
        _fullDir = NSHomeDirectory().appending(filesDir)
        
        let fmgr: FileManager = FileManager.default
        let list = try? fmgr.contentsOfDirectory(atPath: _fullDir!) as [String]
        
        fileList = Array()
        
        guard let _ = list else {
            return false
        }
        for f in list!{
            for p in suffixList {
                if f.hasSuffix(p) {
                    fileList!.append(f)
                    break
                }
            }
        }
        
        fileIdx = -1
        print("find \(fileList?.count) in \(filesDir)")
        
        return self.selectFileWithType(type: .NEXT)
    }
    
    /**
     @abstract   获取一个文件
     */
    public func selectFileWithType(type: KSYSelectType) -> Bool {
        let cnt: Int = fileList!.count
        
        if cnt == 0 {
            fileInfo = "can't find any file"
            filePath = String()
            return false
        }
        if type == .NEXT {
            fileIdx = (fileIdx + 1) % cnt
        }else if type == .RANDOM {
            fileIdx = Int(arc4random()) % cnt
        }else if type == .PREVIOUS {
            fileIdx = (fileIdx - 1) % cnt
        }else{
            return false
        }
        
        let name: String = fileList![fileIdx] as! String
        fileInfo = String.init(format: "%@(%d/%d)",name, fileIdx, cnt)
        if let _ = _fullDir {
            filePath = _fullDir!.appending(name)
        }
        
        return true
    }
    
}
