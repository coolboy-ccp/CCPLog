//
//  AppInfo.swift
//  LifeCycle
//
//  Created by clobotics_ccp on 2019/9/3.
//  Copyright © 2019 cool-ccp. All rights reserved.
//

import UIKit

private let info = Bundle.main.infoDictionary ?? [:]
public let appName: String = (info["CFBundleDisplayName"] as? String) ?? ""
public let appVersion: String = (info["CFBundleShortVersionString"] as? String) ?? ""
public let appBuild: String = (info["CFBundleVersion"] as? String) ?? ""
public let bundleId: String = (info["CFBundleIdentifierKey"] as? String) ?? ""
public let projName: String = (info["CFBundleExecutableKey"] as? String) ?? ""
//这个id不能保证唯一，如果要保证唯一，需要存到KeyChain中
public let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
public let deviceName = UIDevice.current.systemName
public let deviceVersion = UIDevice.current.systemVersion
public let deviceModel = UIDevice.current.model
public let deviceLocalModel = UIDevice.current.localizedModel
