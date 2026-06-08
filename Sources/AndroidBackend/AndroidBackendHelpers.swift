import Foundation
import AndroidKit
import SwiftJava

@JavaClass("dev.swiftcrossui.androidbackend.AndroidBackendHelpers")
class AndroidBackendHelpers: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        environment: JNIEnvironment? = nil
    )

    /// Get the width of the window's usable safe area.
    @JavaMethod
    func getSafeWindowWidth(_ activity: Activity?) -> Int32

    /// Get the height of the window's usable safe area.
    @JavaMethod
    func getSafeWindowHeight(_ activity: Activity?) -> Int32

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

    @JavaMethod
    func getDeviceClass(_ activity: Activity?) -> Int16

    @JavaMethod
    func getTimeZoneIdentifier() -> JavaString?

    @JavaMethod
    func registerActivityResults(
        _ activity: FragmentActivity!,
        _ filesCallback: FilesActivityCallback!,
        _ folderCallback: FolderActivityCallback!,
    )

    @JavaMethod
    func launchFilesActivity(_ options: FilesActivityContract.Options!)

    @JavaMethod
    func launchFolderActivity(_ urlString: JavaString?)
}
