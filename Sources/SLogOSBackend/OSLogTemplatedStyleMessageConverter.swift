import Foundation
import SLog

public class OSLogTemplatedStyleMessageConverter: TemplatedMessageConverter {
    public static let shared: TemplatedMessageConverter = OSLogTemplatedStyleMessageConverter()

    private init() { }

    public func convertToString(templated: String, arguments: [TypeWrapper]) -> String {
        let cleanTemplatedString = templated
            .replacingOccurrences(of: "{private}", with: "")
            .replacingOccurrences(of: "{public}", with: "")
        return String(format: cleanTemplatedString, arguments: arguments.map { $0.cVarArg })
    }
}
