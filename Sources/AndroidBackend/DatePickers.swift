import AndroidKit
import SwiftJava
import JavaTime

@JavaClass(
    "dev.swiftcrossui.androidbackend.datepickers.AbstractDatePicker",
    extends: AndroidKit.LinearLayout.self
)
class AbstractDatePicker: AndroidKit.LinearLayout {
    @JavaMethod
    func setAction(_ action: SwiftAction?)

    @JavaMethod
    func getValue() -> LocalDateTime!

    @JavaMethod
    func setValue(_ newValue: LocalDateTime!)

    @JavaMethod
    func setRange(min: LocalDateTime!, max: LocalDateTime!)

    @JavaMethod
    func setComponents(_ components: Int32)
}

@JavaClass(
    "dev.swiftcrossui.androidbackend.datepickers.CompactDatePicker",
    extends: AbstractDatePicker.self
)
class CompactDatePicker: AbstractDatePicker {
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: FragmentActivity!,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func setForegroundColor(_ color: Int32)
}

@JavaClass(
    "dev.swiftcrossui.androidbackend.datepickers.GraphicalDatePicker",
    extends: AbstractDatePicker.self
)
class GraphicalDatePicker: AbstractDatePicker {
    @JavaMethod
    @_nonoverride convenience init(
        _ context: AndroidKit.Context!,
        environment: JNIEnvironment? = nil
    )
}
