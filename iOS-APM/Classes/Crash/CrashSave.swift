//
//  CrashSave.swift
//  iOS-APM
//
//  Created by 荣恒 on 2020/9/7.
//

import Foundation

public func save(crash: Crash.Data) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.timeZone = .autoupdatingCurrent
    let date = formatter.string(from: Date())
    
    guard let crashPath = crashDirectory else {
        return
    }
    
    let filePath = "\(crashPath)/\(date).text"
    
    guard
        let data = try? JSONEncoder().encode(crash)
    else {
        return
    }
    
    do {
        try data.write(to: .init(fileURLWithPath: filePath),
                       options: .atomicWrite)
    }
    catch let error {
        print(error)
    }
}

public var crashDirectory: String? {
    guard let cachePath = NSSearchPathForDirectoriesInDomains(
        .cachesDirectory,
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
