//
//  KSYSQLite.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

private let kDatabaseName = "myDatabase.db"
class KSYSQLite: NSObject {
    static let sharedInstance = KSYSQLite()
    
    var database: OpaquePointer?
    
    private override init() {
        super.init()
        openDb(dataName: kDatabaseName)
    }
    
    func openDb(dataName: String) {
        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let filePath = (directory as NSString).appendingPathComponent(dataName)
        //如果有数据库则直接打开，否则创建并打开（注意filePath是ObjC中的字符串，需要转化为C语言字符串类型）
        if SQLITE_OK == sqlite3_open(filePath, &database) {
            return
        }else{
            print("open sqlite dadabase fail!")
        }
    }

    func executeNonQuery(sql: String) {
        var error: UnsafeMutablePointer<Int8>? = nil
        if SQLITE_OK == sqlite3_exec(database, sql, nil, nil, &error) {
            return
        }else {
            print("table creat error \(error)")
            sqlite3_free(error)
        }
    }
    
    func executeQuery(sql: String) -> [[String: String]] {
        var rows = Array<Dictionary<String, String>>()
        
        var stmt: OpaquePointer? = nil
        //检查语法正确性
        if SQLITE_OK == sqlite3_prepare_v2(database, sql, -1, &stmt, nil) {
            //单步执行sql语句
            while SQLITE_ROW == sqlite3_step(stmt) {
                let columnCount = sqlite3_column_count(stmt)
                var dic = [String: String]()
                
                for i: Int32 in 0..<columnCount {
                    let name = sqlite3_column_name(stmt, i)
                    let value = sqlite3_column_text(stmt, i)
                    guard let _ = name, let _ = value else {
                        continue
                    }
                    
                    let nameStr = String.init(utf8String: name!)
                    let valueStr = String(cString: value!)
                    
                    dic[nameStr!] = valueStr
                }
                rows.append(dic)
            }
        }
        
        // 释放句柄
        sqlite3_finalize(stmt)
        
        return rows
    }
    
    func insertAddress(addr: String) {
        let sql = "INSERT INTO Address (address) VALUES('\(addr)')"
        let array = getAddress()
        for dic: [String: String] in array {
            let address = dic["address"]
            if address == addr {
                return
            }
        }
        executeNonQuery(sql: sql)
    }
    
    func getAddress() -> [[String: String]] {
        let sql = "SELECT * FROM Address"
        let arr = executeQuery(sql: sql)
        return arr
    }
}
