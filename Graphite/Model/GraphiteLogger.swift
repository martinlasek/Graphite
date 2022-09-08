//
//  GraphiteLogger.swift
//  Graphite
//
//  Created by Martin Lasek on 9/3/22.
//

import SolanaSwift

struct GraphiteLogger: SolanaSwiftLogger {
    func log(event: String, data: String?, logLevel: SolanaSwiftLoggerLogLevel) {
        var dataString = data ?? ""

        switch logLevel {
        case .info:
            printInfo(self, "\(event) | \(dataString)")
        case .error:
            printError(self, "\(event) | \(dataString)")
        case .warning:
            printWarning(self, "\(event) | \(dataString)")
        case .debug:
            printDebug(self, "\(event) | \(dataString)")
        }
    }
}
