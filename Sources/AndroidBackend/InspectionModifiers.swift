import AndroidKit
import SwiftCrossUI
import SwiftJava

extension SwiftCrossUI.View {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (AndroidKit.View) -> Void
    ) -> some SwiftCrossUI.View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension SwiftCrossUI.Button {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (AndroidKit.Button) -> Void
    ) -> some SwiftCrossUI.View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension Text {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (TextView) -> Void
    ) -> some SwiftCrossUI.View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension TextField {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (EditText) -> Void
    ) -> some SwiftCrossUI.View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension SecureField {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (EditText) -> Void
    ) -> some SwiftCrossUI.View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension TextEditor {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (EditText) -> Void
    ) -> some SwiftCrossUI.View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension Image {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (ImageView) -> Void
    ) -> some SwiftCrossUI.View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension SwiftCrossUI.WebView {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (AndroidKit.WebView) -> Void
    ) -> some SwiftCrossUI.View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension SwiftCrossUI.List {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (AndroidKit.ListView) -> Void
    ) -> some SwiftCrossUI.View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension Activity {
    @JavaMethod
    public func getWindow() -> AndroidKit.Window?
}

extension SwiftCrossUI.View {
    public func inspectWindow(
        _ action: @escaping @MainActor @Sendable (AndroidKit.Window) -> Void
    ) -> some SwiftCrossUI.View {
        // AndroidBackend.Window is a wrapper around the root view, since that's more useful than
        // the actual Window object for most things. There's not a whole lot you can do with a
        // Window object in Android. So if the user specifically requests it, we need to materialize
        // the window from the activity instead of using the backend's "window".
        InspectWindowView(child: self) { (_: AndroidBackend.Window) in
            action(AndroidBackend.activity.getWindow()!)
        }
    }
}
