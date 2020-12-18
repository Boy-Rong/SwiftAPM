//
//  General.swift
//  SwiftAPM
//
//  Created by rongheng on 2020/12/18.
//

import Foundation

// MARK: - 全局方法 public

/// 转换当前时区时间
public var currentZoneDate: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.timeZone = .autoupdatingCurrent
    return formatter.string(from: Date())
}


/// 主线程执行 closure
public func mainThread(closure: @escaping () -> Void) {
    if Thread.isMainThread {
        closure()
    }
    else {
        DispatchQueue.main.async {
            closure()
        }
    }
}

/// UnsafeMutablePointer 快速生成
public func _UnsafeMutablePointer<T>(_ value: T?) -> UnsafeMutablePointer<T> {
    let size = MemoryLayout<T>.stride
    let pointer = UnsafeMutablePointer<T>.allocate(capacity: size)
    if let someValue = value {
        pointer.initialize(to: someValue)
    }
    return pointer
}

//MARK: Log
public func log<T>(_ value: T) {
    #if DEBUG
    print("----->SwiftAPM:\(currentZoneDate) \n\(value)")
    #endif
}
