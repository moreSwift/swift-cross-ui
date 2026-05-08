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

    @JavaMethod
    func getSafeAreaLeftInset(_ activity: Activity?) -> Int32

    @JavaMethod
    func getSafeAreaTopInset(_ activity: Activity?) -> Int32

    @JavaMethod
    func clearTextSizeCache()

    @JavaMethod
    func getLargeTextSize(_ activity: Activity?) -> Float

    @JavaMethod
    func getTitleTextSize(_ activity: Activity?) -> Float

    @JavaMethod
    func getMediumTextSize(_ activity: Activity?) -> Float

    @JavaMethod
    func getSmallTextSize(_ activity: Activity?) -> Float
    
    @JavaMethod
    func isNightMode(_ activity: Activity?) -> Bool
}
