//
//  Save.swift
//  SwiftAPM
//
//  Created by 荣恒 on 2020/9/7.
//

import Foundation
import MMKV

public func save(crash: Crash.Data) {
     guard
         let data = try? JSONEncoder().encode(crash)
     else {
         return
     }
     
     let formatter = DateFormatter()
     formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
     formatter.timeZone = .autoupdatingCurrent
     let date = formatter.string(from: Date())
     let fileName = "\(date)-\(crash.name)"
     
     let result = MMKV.default()?.set(data, forKey: fileName) ?? false
     if !result {
         log("保存\(fileName)失败")
     }
}

public func getAllCrash() -> [Crash.Data] {
    guard let mmkv = MMKV.default() else {
        return []
    }
    
    var crashList : [Crash.Data] = []
    mmkv.enumerateKeys { (key, _) in
        autoreleasepool {
            if
                let data = mmkv.data(forKey: key),
                let crash = try? JSONDecoder().decode(Crash.Data.self, from: data) {
                crashList.append(crash)
            }
        }
    }
    
    // sort
    return crashList.sorted {
        $0.date > $1.date
    }    
}

public var crashDirectory: String? {
    guard let cachePath = NSSearchPathForDirectoriesInDomains(
        .documentDirectory,
        .userDomainMask,
        true
    ).first else {
        return nil
    }
    
    let directory = "\(cachePath)/Crash"
    if !FileManager.default.fileExists(atPath: directory) {
        do {
            try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }
    }
    
    return directory
}

/// 转换当前时区时间
public var currentZoneDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.timeZone = .autoupdatingCurrent
    return formatter.string(from: Date())
}
