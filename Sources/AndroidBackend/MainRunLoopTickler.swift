import Foundation
import AndroidKit

@JavaClass("dev.swiftcrossui.androidbackend.MainRunLoopTickler")
class MainRunLoopTickler: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(environment: JNIEnvironment? = nil)

    @JavaMethod
    func start()
}

@JavaImplementation("dev.swiftcrossui.androidbackend.MainRunLoopTickler")
extension MainRunLoopTickler {
    @JavaMethod
    func getDefaultDelay() -> Int32 {
        50
    }

    @JavaMethod
    func tickle() -> Int32 {
        // This approach was adapted from the GtkBackend implementation
        // (as GtkBackend.mainRunLoopTicklingLoop(nextDelayMilliseconds))

        // This performs one pass through the run loop
        let nextDate = RunLoop.main.limitDate(forMode: .default)

        // This isn't expected to be nil, but if it is we can just loop
        // again quickly with the default delay.
        let nextDelay = nextDate.map {
            return max(min(Int($0.timeIntervalSinceNow * 1000), 50), 0)
        } ?? Int(getDefaultDelay())

        return Int32(nextDelay)
    }
}
