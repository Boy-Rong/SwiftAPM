//
//  Crash.swift
//  SwiftAPM
//
//  Created by rongheng on 2020/9/3.
//

import Foundation

//MARK: Crash
public struct Crash: APMPluginable {
    
    public private(set) static var isOpen: Bool = false
    
    public private(set) static var crashHandlers : [CrashHandlerable.Type] = [
        ExceptionHandler.self,
        SignalHandler.self
    ]
    
    /// 开始监控
    public static func startMonitor() {
        if (isOpen) {
            return
        }
        
        isOpen = true
        crashHandlers.forEach {
            $0.registerCrashHandler()
        }
        
    }
    
    /// 停止监控
    public static func stopMonitor() {
        if (!isOpen) {
            return
        }
        
        isOpen = false
        crashHandlers.forEach {
            $0.clearCrashHandler()
        }
    }
    
    /// 唯一标识
    public static var identifies : String {
        return "SwiftAPM-Crash"
    }
    
}

// MARK: - Signal
extension Crash {
    
    /**
     其中SIGKILL,SIGSTOP信号是无法被捕获或忽略等自定义处理的
     http://stackoverflow.com/questions/36325140/how-to-catch-a-swift-crash-and-do-some-logging
     */
    public enum Signal: Int32 {
        case SIGILL = 4
        case SIGTRAP = 5
        case SIGABRT = 6
        case SIGFPE = 8
        //  kill
        case SIGKILL = 9
        case SIGBUS = 10
        case SIGSEGV = 11
        case SIGSYS = 12
        case SIGPIPE = 13
        
        var name: String {
            switch self {
                case .SIGILL: return "SIGILL"
                case .SIGTRAP: return "SIGTRAP"
                case .SIGABRT: return "SIGABRT"
                case .SIGFPE: return "SIGFPE"
                case .SIGKILL: return "SIGKILL"
                case .SIGBUS: return "SIGBUS"
                case .SIGSEGV: return "SIGSEGV"
                case .SIGSYS: return "SIGSYS"
                case .SIGPIPE: return "SIGPIPE"
            }
        }
        
        static var all : [Signal] {
            return [
                .SIGILL,
                .SIGTRAP,
                .SIGABRT,
                .SIGFPE,
                .SIGBUS,
                .SIGSEGV,
                .SIGSYS,
                .SIGPIPE
            ]
        }
    }
}

//MARK: Crash Type
extension Crash {
    
    public enum `Type` : Int, Codable {
        case signal = 1
        case exception = 2
    }
    
    public struct Data: Storageable {
        public var type: Type
        public var name: String
        public var date: String
        public var reason: String
        public var appinfo: String
        public var callStack: String
        
        public static var storageMode: Storage.Mode {
            return .Crash
        }
        
        public var storageName: String {
            return name
        }
    }
    
}



