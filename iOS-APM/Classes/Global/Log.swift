//
//  Log.swift
//  iOS-APM
//
//  Created by 荣恒 on 2020/9/8.
//

import Foundation

public func log<T>(_ value: T) {
    #if DEBUG
    print("----->APM:\(Date()) \(value)")
    #endif
}
