import Foundation
import AndroidKit
import SwiftJava

@JavaClass("dev.swiftcrossui.androidbackend.AndroidBackendHelpers")
class AndroidBackendHelpers: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func getWindowWidth(_ activity: Activity?) -> Int32

    @JavaMethod
    func getWindowHeight(_ activity: Activity?) -> Int32
}
