import SwiftCrossUI
import AndroidKit
import SwiftJava

@JavaClass(
    "dev.swiftcrossui.androidbackend.CornerRadiusContainer",
    extends: AndroidKit.ViewGroup.self
)
class CornerRadiusContainer: AndroidKit.ViewGroup {
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: AndroidKit.Activity!,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func setCornerRadius(_ newCornerRadius: Float)
}

extension AndroidBackend: BackendFeatures.CornerRadius {
    public func createCornerRadiusContainer(wrapping child: Widget) -> Widget {
        let widget = CornerRadiusContainer(Self.activity, environment: Self.env)
        widget.addView(child)
        return widget
    }

    public func setCornerRadius(of widget: Widget, to radius: Int) {
        let density = widget.getResources().getDisplayMetrics().density

        let scaledRadius = Float(radius) * density

        widget.as(CornerRadiusContainer.self)!.setCornerRadius(scaledRadius)
    }
}
