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
public struct APM {
    /// 串行队列
    static var ampQueue: DispatchQueue = .init(label: "SwiftAPM")
    
    /// 插件表
    static var plugins : [APMPluginable.Type] = [
        Crash.self
    ]
    
    /// 通知处理者
    static let notificationHandle = AMPNotificationHandle()
}

extension APM {
    
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
        
        Storage.shared.initialize()
        
        notificationHandle.addNotifications()
    }
    
    /// 结束监控
    public static func stopMonitor() {
        for plugin in plugins {
            plugin.stopMonitor()
        }
        
        notificationHandle.removeNotifications()
    }
}

final class AMPNotificationHandle : NSObject {
    
    /// 添加预定义通知
    func addNotifications() {
        NotificationCenter.default.addObserver(
            forName: .OpenCrashBrowser,
            object: nil,
            queue: .main) { _ in
            CrashBrowser.share.openCrashList()
        }
        
        NotificationCenter.default.addObserver(
            forName: .OpenSandBoxBrowser,
            object: nil,
            queue: .main) { _ in
            
        }
    }
    
    /// 移除预定义通知
    func removeNotifications() {
        
    }
}
