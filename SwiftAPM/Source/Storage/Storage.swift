//
//  Save.swift
//  SwiftAPM
//
//  Created by 荣恒 on 2020/9/7.
//

import Foundation
import MMKV
import Darwin

/// 可被 mmap 保存的协议
public protocol Storageable : Codable {
    
    var storageName : String { get }
        
    static var storageMode : Storage.Mode { get }
    
    /// 保存方法
    func save()
}

extension Storageable {
    
    public func save() {
        do {
            try Storage.shared.save(self)
        } catch let error {
            log("保存失败 error: \(error)")
        }
    }
}

/// mmap 保存 class
final public class Storage {
    
    static let shared = Storage()
    
    private init() {}
    
    /// Crash MMKV
    private lazy var crashMMKV : MMKV = {
        let crashPath = "\(NSHomeDirectory())/Documents/Crash"
        return MMKV(mmapID: "com.swift.apm.carsh", rootPath: crashPath)!
    }()
    
    /// ANR MMKV
    private lazy var anrMMKV : MMKV = {
        let crashPath = "\(NSHomeDirectory())/Documents/ANR"
        return MMKV(mmapID: "com.swift.apm.anr", rootPath: crashPath)!
    }()
}

extension Storage {
    
    /// mmap 保存数据
    public func save<T : Storageable>(_ value: T) throws {
        let data = try JSONEncoder().encode(value)
        let key = "\(currentZoneDate)-\(value.storageName)"
              
        // mmap 保存 value
        guard valueMMKV(for: T.storageMode).set(data, forKey: key) else {
            throw Storage.Error.custom("保存\(value.storageName)失败")
        }
    }
    
    /// 根据 mode 获取所有保存的数据
    public func values<T : Storageable>(for mode: Mode) -> [T] {
        let mmkv = valueMMKV(for: mode)
        
        var valueList : [T] = []
        mmkv.enumerateKeys { (key, _) in
            autoreleasepool {
                if
                    let data = mmkv.data(forKey: key),
                    let value = try? JSONDecoder().decode(T.self, from: data) {
                    valueList.append(value)
                }
            }
        }
        
        // 未排序
        return valueList
    }
}

extension Storage {
    
    private func valueMMKV(for mode: Mode) -> MMKV {
        switch mode {
        case .Crash:
            return crashMMKV
            
        case .ANR:
            return anrMMKV
        }
    }
    
}

extension Storage {
    
    public enum Mode {
        case Crash
        case ANR
    }
    
    public enum Error: Swift.Error {
        case custom(String)
    }
}



//MARK: mmap demo
/*
/// mmap data to file
private func mmap(data: Data, to filePath: String, ) throws {
    let fp = open(filePath, O_RDWR, 0)
    guard fp < 0 else {
        throw StorageError.custom("open \(filePath) error")
    }
    
    var statInfo = stat()
    guard fstat(fp, &statInfo) == 0 else {
        throw StorageError.custom("fstat error ")
    }
    
    ftruncate(fp, statInfo.st_size + 4)
    
    fsync(fp)
    
    let mmapStart = mmap(
        nil,
        Int(statInfo.st_size + 4),
        PROT_READ | PROT_WRITE,
        MAP_FILE | MAP_SHARED,
        fp,
        0
    )
    
    guard
        let start = mmapStart,
        start != MAP_FAILED
    else {
        throw StorageError.custom("mmap \(fp) error")
    }
    
    close(fp)
    
    // 写入数据
    memcpy(start, &data, 4)
    
    munmap(start, 7)
}
*/
