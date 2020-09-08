//
//  Crash.swift
//  iOS-APM
//
//  Created by rongheng on 2020/9/3.
//

import Foundation
import ThreadBacktrace
import Darwin

// MARK: - Type
typealias SignalClosure = (@convention(c) (Int32, UnsafeMutablePointer<__siginfo>?, UnsafeMutableRawPointer?) -> Void)

typealias SignalSwiftClosure = (Int32, UnsafeMutablePointer<__siginfo>?, UnsafeMutableRawPointer?) -> Void

typealias ExceptionClosure = @convention(c) (NSException) -> Swift.Void

// MARK: - 崩溃处理协议
public protocol CrashHandlerabel {
    /// 注册崩溃处理
    static func registerCrashHandler()
    
    /// 清除崩溃处理
    static func clearCrashHandler()
    
    /// 保存崩溃信息
    static func saveCrash(_ crash: Crash.Data)
}

extension CrashHandlerabel {
    
    static func saveCrash(_ crash: Crash.Data) {
        save(crash: crash)
    }
    
}

/// 异常Handler
struct ExceptionHandler: CrashHandlerabel {
    /// old exceptionHandler
    private static var app_old_exceptionHandler : ExceptionClosure?
    
    private static let RecieveException: ExceptionClosure = { exteption in
        
        // 先执行 new handler
        if Crash.isOpen {
            // 获取当前线程堆栈
            let callStack = exteption.callStackSymbols.joined(separator: "\n")
            let reason = exteption.reason ?? ""
            let name = exteption.name
            let model = Crash.Data(type:.exception,
                                   name:name.rawValue,
                                   reason:reason,
                                   appinfo:App.info,
                                   callStack:callStack)
            // save crash
            saveCrash(model)
        }
        
        // 在执行 oldHandle
        if let oldHandle = app_old_exceptionHandler {
            oldHandle(exteption)
        }
        
        // 杀死进程 防止Crash 被继续捕获
        clearCrashHandler()
        App.kill()
    }
    
    private init() { }
    
    static func registerCrashHandler() {
        // 获取之前 exceptionHandler
        app_old_exceptionHandler = NSGetUncaughtExceptionHandler()
        
        // 设置新的 exceptionHandler
        NSSetUncaughtExceptionHandler(RecieveException)
    }
    
    static func clearCrashHandler() {
        NSSetUncaughtExceptionHandler(app_old_exceptionHandler)
        
        app_old_exceptionHandler = nil
    }
    
}

/// 信号 Handler
struct SignalHandler: CrashHandlerabel {
    /// old signalHandler map
    private static var app_old_signalHandler : [Int32 : SignalClosure] = [:]
    
    /// signalHandler
    private static let RecieveSignal: SignalClosure = { signal, info, context in

        // 先处理自己 handle
        if Crash.isOpen, let signal = Crash.Signal(rawValue: signal) {
            // 获取当前线程堆栈
            let callStack = BacktraceOfCurrentThread().info()
            let reason = "Signal \(signal.name)(\(signal)) was raised.\n"

            let model = Crash.Data(type:.signal,
                                   name:signal.name,
                                   reason:reason,
                                   appinfo:App.info,
                                   callStack:callStack)

            // save crash
            saveCrash(model)
        }

        // 在执行 old signal handler
        if let oldHandler = app_old_signalHandler[signal] {
            oldHandler(signal, info, context)
        }

        // 杀死进程 房子Crash 被继续捕获
        clearCrashHandler()
        App.kill()
    }
    
    /// 注册 崩溃 Signal Handler
    static func registerCrashHandler() {
        Crash.Signal.all.forEach { signal in
            guard
                let (signal, oldHandler) = registerSignalHandler(
                    signal.rawValue,
                    handler: RecieveSignal
                )
            else {
                    return
            }
            
            // 保存旧的 signal Handler
            app_old_signalHandler[signal] = oldHandler
        }
    }
    
    static func clearCrashHandler() {
        app_old_signalHandler.forEach { signal, handler in
            var oldAction = Sigaction(handler)
            sigaction(signal, &oldAction, nil)
        }
        
        app_old_signalHandler.removeAll()
    }
    
    private init() { }
    
    /// 注册 崩溃处理 handler
    private static func registerSignalHandler(_ signal: Int32, handler: @escaping SignalClosure) -> (Int32, SignalClosure)? {
        
        var action = Sigaction(handler)
        var oldAction = sigaction()
        
        /**
         为 signal 设置信号处理程序 action，并将就的处理程序保存到 oldAction
         https://langzi989.github.io/2018/01/28/Unix%E4%BF%A1%E5%8F%B7%E4%B9%8Bsigaction%E5%87%BD%E6%95%B0/
         */
        let result = sigaction(signal, &action, &oldAction)
        if (result != 0) {
            log("signal: \(Crash.Signal(rawValue: signal)!) handler 设置错误")
        }
        
        guard let sa_sigaction = oldAction.sa_sigaction else {
            return nil
        }
        
        return (signal, sa_sigaction)
    }
    
}

//MARK: Crash
final public class Crash {
    
    public private(set) static var isOpen: Bool = false
    
    public private(set) static var crashHandlers : [CrashHandlerabel.Type] = [
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

//MARK: CrashModel
extension Crash {
    
    public struct Data: Codable {
        public var type: Type
        public var name: String
        public var reason: String
        public var appinfo: String
        public var callStack: String
    }
    
    public enum `Type` : Int, Codable {
        case signal = 1
        case exception = 2
    }
    
}

// MARK: - sigaction
extension sigaction {
    
    /// signal 处理函数
    var sa_sigaction: SignalClosure? {
        get {
            guard has_sa_sigaction(self) else {
                return nil
            }
            return __sigaction_u.__sa_sigaction
        }
        
        set {
            guard let value = newValue else {
                return
            }
            __sigaction_u.__sa_sigaction = value
        }
    }
    
}

// MARK: - 全局方法 public

/// UnsafeMutablePointer 快速生成
public func _UnsafeMutablePointer<T>(_ value: T?) -> UnsafeMutablePointer<T> {
    let size = MemoryLayout<T>.stride
    let pointer = UnsafeMutablePointer<T>.allocate(capacity: size)
    if let someValue = value {
        pointer.initialize(to: someValue)
    }
    return pointer
}

// MARK: - 全局方法 private

/// 快速创建 struct sigaction
private func Sigaction(_ handler: @escaping SignalClosure) -> sigaction {
    return sigaction(
        __sigaction_u: __sigaction_u(__sa_sigaction: handler),
        sa_mask: sigset_t(),
        sa_flags: SA_NODEFER | SA_SIGINFO
    )
}
