import SwiftJava

@JavaClass("dev.swiftcrossui.androidbackend.activityresults.FilesActivityCallback")
class FilesActivityCallback: JavaObject {
    @JavaMethod
    func setAction(_ action: SwiftAction?)

    @JavaMethod
    func getUrlStrings() -> [String]
}

@JavaClass("dev.swiftcrossui.androidbackend.activityresults.FolderActivityCallback")
class FolderActivityCallback: JavaObject {
    @JavaMethod
    func setAction(_ action: SwiftAction?)

    @JavaMethod
    func getUrlString() -> JavaString?
}

@JavaClass("dev.swiftcrossui.androidbackend.activityresults.FilesActivityContract")
class FilesActivityContract: JavaObject {
    @JavaClass("dev.swiftcrossui.androidbackend.activityresults.FilesActivityContract$Options")
    class Options: JavaObject {
        @JavaMethod
        convenience init(
            _ allowMultiple: Bool,
            _ mimeTypes: [String],
            _ rootDirectory: JavaString?,
            environment: JNIEnvironment? = nil
        )
    }
}
