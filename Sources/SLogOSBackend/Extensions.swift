import Foundation
import os
import SLog

extension Level {
    var osLogType: OSLogType {
        switch self {
        case .trace, .debug:
            return .debug
        case .info, .notice, .warning:
            return .info
        case .error:
            return .error
        case .critical:
            return .fault
        }
    }
}

extension TypeWrapper {
    var cVarArg: CVarArg {
        switch self {
        case .null: return "<null>"
        case .int(let value): return value
        case .unsignedLong(let value): return value
        case .bool(let value): return value
        case .double(let value): return value
        case .string(let value): return value
        case .array(let value): return value.map { $0.cVarArg }
        case .dictionary(let value): return value.transform { $0.cVarArg }
        }
    }
}

extension Dictionary {
    func transform<NewValue>(_ transformer: (Value) -> NewValue) -> [Key: NewValue] {
        var result: [Key: NewValue] = [:]
        forEach { result[$0] = transformer($1) }
        return result
    }
}
