//
//  App.swift
//  SwiftAPM
//
//  Created by 荣恒 on 2020/9/8.
//

import Foundation
import Darwin



public struct App {
    private init() { }
    
    /// 杀掉当前进程
    public static func kill() {
        killApp()
    }
    
    public static var info : String {
        let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? ""
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        return "App: \(displayName) \(shortVersion)(\(version))\n" +
            "Device:\(deviceModel)\n" + "OS Version:\(systemName) \(systemVersion)"
    }
}

/// 杀掉当前进程
private func killApp() {
    kill(getpid(), SIGKILL)
}
