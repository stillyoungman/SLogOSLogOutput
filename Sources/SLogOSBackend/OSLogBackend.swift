import Foundation
import os
import _SwiftOSOverlayShims
import SLog

public class OSLogBackend: LogBackend {
    private static var serialQueue = DispatchQueue(label: "OSLogBackendSerialQueue",
                                                   qos: .default)
    public static let bundleId = Bundle.main.bundleIdentifier ?? "<NO_BUNDLE_ID>"

    private let subsystem: String
    private var logs: [String: OSLog] = [:]

    public let logLevel: Level
    public let preferredMessageType: Message.Kind = .templated

    public init(subsystem: String = bundleId, _ logLevel: Level = .trace) {
        self.subsystem = subsystem
        self.logLevel = logLevel
    }

    public func log(level: Level, message: Message, source: String?,
                    file: String, function: String, line: UInt) {
        Self.serialQueue.async { [weak self] in
            guard let self = self else { return }
            let log: OSLog = self.getLog(for: source)
            self.handleMessage(message, level, log)
        }
    }

    func getLog(for category: String?) -> OSLog {
        guard let category = category else { return .default }
        var log: OSLog! = logs[category]
        if log == nil {
            log = OSLog(subsystem: subsystem, category: category)
            logs[category] = log
        }
        return log
    }

    func handleMessage(_ message: Message, _ level: Level, _ log: OSLog) {
        switch message {
        case .regular(let value):
            dump(message: value, log: log, type: level.osLogType)
        case .templated(let value, let args):
            dump(message: value, log: log, type: level.osLogType, args.map { $0.cVarArg })
        }
    }

    /// Blows up `EXC_BAD_ACCESS` if templated string has more placeholders than `args.count`.
    fileprivate func dump(message: String, dso: UnsafeRawPointer = #dsohandle,
                          log: OSLog = .default, type: OSLogType = .default,
                          _ args: [CVarArg] = []) {
        if !log.isEnabled(type: type) { return }

        let ra = _swift_os_log_return_address()
        message.withCString { (buf: UnsafePointer<Int8>) in
            withVaList(args) { vaList in
                _swift_os_log(dso, ra, log, type, buf, vaList)
            }
        }
    }
}
