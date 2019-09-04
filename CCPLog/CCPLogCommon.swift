//
//  CCPLogCommon.swift
//  LifeCycle
//
//  Created by clobotics_ccp on 2019/9/3.
//  Copyright © 2019 cool-ccp. All rights reserved.
//

import UIKit
import CCPAppInfo

/// log通用配置
/// system表示系统级的，可以写入name, version等信息
/// custom表示自定义的，可以写用户名等信息
/// header = system + custom + time 可直接重写
/// fileName = system + custom + fileTail 可直接重写
public protocol LogCommon {
    var system: String { get }
    var custom: String { get }
    var header: String { get }
    var fileTail: String { get }
    var fileName: String { get }
}

public extension LogCommon {
    var system: String {
        return "APP: \(appName)[\(appVersion)] Device: \(deviceModel)[\(deviceVersion)] "
    }
    
    var custom: String {
        return ""
    }
    
    var header: String {
        return system + custom + "Time: \(Date()) "
    }
    
    var fileTail: String {
        return "_log.txt"
    }
    
    var fileName: String {
        return system + custom + fileTail
    }
}

public struct LogCommonDefault: LogCommon {
    public init() {}
}
