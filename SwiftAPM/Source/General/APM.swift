//
//  APM.swift
//  SwiftAPM
//
//  Created by rongheng on 2020/12/18.
//

import Foundation

public protocol APMPluginable {
    /// 开始监控
    static func startMonitor()
    
    /// 停止监控
    static func stopMonitor()
    
    /// 唯一标识
    static var identifies : String { get }
}

/// 性能监控 AMP
public struct AMP {
    /// 串行队列
    static var ampQueue: DispatchQueue = .init(label: "SwiftAPM")
    
    /// 插件表
    static var plugins : [APMPluginable.Type] = []
}

extension AMP {
    
    /// 注册插件
    public static func register(plugin: APMPluginable.Type) {
        ampQueue.async {
            plugins.append(plugin)
        }
    }
    
    /// 开始监控
    public static func startMonitor() {
        for plugin in plugins {
            plugin.startMonitor()
        }
    }
    
    /// 结束监控
    public static func stopMonitor() {
        for plugin in plugins {
            plugin.stopMonitor()
        }
    }
}
