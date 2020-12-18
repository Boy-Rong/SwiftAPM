//
//  CrashHandler.swift
//  SwiftAPM
//
//  Created by rongheng on 2020/12/16.
//

import Foundation
import ThreadBacktrace

//MARK: 异常 Handler

typealias ExceptionClosure = @convention(c) (NSException) -> Swift.Void

/// 异常 Handler
struct ExceptionHandler: CrashHandlerable {
    /// old exceptionHandler
    private static var app_old_exceptionHandler : ExceptionClosure?
    
    private static let RecieveException: ExceptionClosure = { exteption in
        
        // 先执行 new handler
        if Crash.isOpen {
            // 获取当前线程堆栈
            let callStack = exteption.callStackSymbols.joined(separator: "\n")
            let reason = exteption.reason ?? ""
            let name = exteption.name
            let data = Crash.Data(
                type:.exception,
                name:name.rawValue,
                date: currentZoneDate,
                reason:reason,
                appinfo:App.info,
                callStack:callStack
            )
            // save crash
            save(crash: data)
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

//MARK: 信号 Handler

typealias SignalClosure = (@convention(c) (Int32, UnsafeMutablePointer<__siginfo>?, UnsafeMutableRawPointer?) -> Void)

/// 信号 Handler
struct SignalHandler: CrashHandlerable {
    /// old signalHandler map
    private static var app_old_signalHandler : [Int32 : SignalClosure] = [:]
    
    /// signalHandler
    private static let RecieveSignal: SignalClosure = { signal, info, context in

        // 先处理自己 handle
        if Crash.isOpen, let signal = Crash.Signal(rawValue: signal) {
            // 获取当前线程堆栈
            let callStack = BacktraceOfCurrentThread().reduce("") { $0 + $1 }
            let reason = "Signal \(signal.name)(\(signal)) was raised.\n"
            let data = Crash.Data(
                type:.signal,
                name:signal.name,
                date:currentZoneDate,
                reason:reason,
                appinfo:App.info,
                callStack:callStack
            )

            // save crash
            save(crash: data)
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
    
    private init() {}
    
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

// MARK: - sigaction 相关
/// 快速创建 struct sigaction
private func Sigaction(_ handler: @escaping SignalClosure) -> sigaction {
    return sigaction(
        __sigaction_u: __sigaction_u(__sa_sigaction: handler),
        sa_mask: sigset_t(),
        sa_flags: SA_NODEFER | SA_SIGINFO
    )
}

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
