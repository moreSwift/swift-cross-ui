import Foundation
import Mutex
import Logging

private struct SourceLocation: Hashable {
    let file: String
    let line: UInt
}
private let warnedSourceLocations: Mutex<Set<SourceLocation>> = Mutex([])

extension Logger {
    func warnOnce(
        _ message: @autoclosure () -> Logger.Message,
        metadata: @autoclosure () -> Logger.Metadata? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        warnedSourceLocations.withLock { sourceLocations in
            guard sourceLocations.insert(.init(file: file, line: line)).inserted else {
                return
            }
            warning(
                message(),
                metadata: metadata(),
                file: file,
                function: function,
                line: line
            )
        }
    }
}
