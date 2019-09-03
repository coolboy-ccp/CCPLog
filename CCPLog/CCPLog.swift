//
//  CCPLog.swift
//  LifeCycle
//
//  Created by clobotics_ccp on 2019/9/3.
//  Copyright © 2019 cool-ccp. All rights reserved.
//

import UIKit

public enum LogType: String {
    case info
    case warning
    case error
    case debug
    case crash
}


public typealias LogUploadCallback = (_ data: Data, _ completion: (Bool) -> ()) -> ()

class CCPLog {
    
    public static func log(info: String, type: LogType = .info, common: LogCommon = LogCommonDefault()) {
        instance.logCommon = common
        instance.log(info: info, type: type)
    }
    
    public static func upload(common: LogCommon = LogCommonDefault(), handler: @escaping LogUploadCallback) {
        instance.logCommon = common
        instance.upload(handler: handler)
    }
    
    private let logQueue = DispatchQueue(label: "CCPLogQueue")
    private var logCommon: LogCommon = LogCommonDefault()
    //确保上传任务的单一性
    private let sema = DispatchSemaphore(value: 1)
    /*
     * 在发起upload的时候，获取当前log的offset，当上传成功，删除之前的log
     */
     private var removeOffset: UInt64 = 0
    
    //不存储在cache或temp的原因是怕清除缓存时误删
    private lazy var logPath: String = {
        return "NSHomeDirectory()/\(logCommon.fileName)"
    }()
    
    private func logString(info: String, type: LogType) -> String {
        return logCommon.header + "type: \(type.rawValue) " + info + "\n\n"
    }
    
    private static let instance = CCPLog()
   
    private init() {}
    
    private var data: Data? {
        return FileManager.default.contents(atPath: logPath)
    }
    
    private func log(info: String, type: LogType) {
        dp("Log: \(info)")
        //确保新增log的顺序
        let work = DispatchWorkItem(qos: .default, flags: .barrier) {
            self.createFileIfNeed()
            self.write(self.logString(info: info, type: type))
        }
        logQueue.async(execute: work)
    }
    
    private func upload(handler: @escaping LogUploadCallback) {
        logQueue.async {
            guard let data = self.getData() else {
                return
            }
            handler(data) { self.uploadCallback($0) }
        }
        
    }
    
    private func getData() -> Data? {
        sema.wait()
        guard let data = data else {
            dp("没有日志")
            sema.signal()
            return nil
        }
        removeOffset = UInt64(data.count)
        return data
    }
    
    private func uploadCallback(_ success: Bool) {
        sema.signal()
        if success { remove() }
    }
    
    private func createFileIfNeed() {
        if !FileManager.default.fileExists(atPath: logPath) {
            FileManager.default.createFile(atPath: logPath, contents: nil)
        }
    }
    
    private func write(_ log: String) {
        guard let handler = FileHandle(forWritingAtPath: logPath) else {
            dp("Failed to init FileHandle")
            return
        }
        
        handler.seekToEndOfFile()
        defer { handler.closeFile() }
        guard let data = log.data(using: .utf8) else {
            dp("\(log) 无法转成utf8格式的data")
            return
        }
        handler.write(data)
    }
    
    private func remove() {
        if let handler = FileHandle(forWritingAtPath: logPath) {
            handler.seekToEndOfFile()
            handler.truncateFile(atOffset: 0)
            handler.closeFile()
            return
        }
        dp("Failed to init FileHandle")
    }
    
    private func dp(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
        print(items, separator: separator, terminator: terminator)
        #endif
    }
}


