//
//  CrashLog.swift
//  LifeCycle
//
//  Created by clobotics_ccp on 2019/9/3.
//  Copyright © 2019 cool-ccp. All rights reserved.
//

import SwiftyJSON

public class CrashLog {
    static func install() {
        NSSetUncaughtExceptionHandler { (exception) in
            let stacks = exception.callStackSymbols
            let reason = exception.reason ?? "unkonwn"
            let name = exception.name
            saveToLocal(JSON([
                "name" : name,
                "reason" : reason,
                "stacks" : stacks,
                "date" : Date().description
                ]))
        }
        signal(SIGABRT, signalHandle)
        signal(SIGILL, signalHandle);
        signal(SIGSEGV, signalHandle);
        signal(SIGFPE, signalHandle);
        signal(SIGBUS, signalHandle);
        signal(SIGPIPE, signalHandle);
    }
}

func signalHandle(_ signal: Int32) {
    let info = JSON([
        "name" : "signal",
        "reason" : "occur a signal crash",
        "stacks" : Thread.callStackSymbols,
        "code" : signal,
        "date" : Date().description
        ]).description
    CCPLog.log(info: info, type: .crash, common: CrashLogCommon())
}

struct CrashLogCommon:  LogCommon{
    var fileTail: String {
        return "_crash_log.txt"
    }
}
