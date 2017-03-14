//
//  KSYDBCreater.swift
//  KSYLiveDemo_Swift
//
//  Created by iVermisseDich on 17/1/13.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

import UIKit

class KSYDBCreater: NSObject {

    override init() {
        super.init()
    }
    
    class func initDatabase() {
        let key = "IsCreatedDb"
        let defaults = UserDefaults()
        if let value: Bool = defaults.value(forKey: key) as? Bool, !value{
            createUrlTable()
            defaults.setValue(true, forKey: key)
        }
    }
    
    class func createUrlTable() {
        let sql = "CREATE TABLE Address (address text)"
        KSYSQLite.sharedInstance.executeNonQuery(sql: sql)
    }
}
