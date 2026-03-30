import SwiftCrossUI
import WinUI

extension View {
    /// Inspects the native window that backs the window scene enclosing this view.
    public func inspectWindow(
        _ action: @escaping @MainActor @Sendable (WinUI.Window) -> Void
    ) -> some View {
        InspectWindowView(child: self, action: action)
    }
}

extension View {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WinUI.FrameworkElement) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension SwiftCrossUI.Button {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WinUI.Button) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension Text {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WinUI.TextBlock) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension SwiftCrossUI.Slider {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WinUI.Slider) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

// TODO(stackotter): Repair Picker.inspect implementations post PickerStyle refactor
// extension Picker {
//     public func inspect(
//         _ inspectionPoints: InspectionPoints = .onCreate,
//         _ action: @escaping @MainActor @Sendable (WinUI.ComboBox) -> Void
//     ) -> some View {
//         InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
//     }
// }

extension TextField {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WinUI.TextBox) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension SwiftCrossUI.ScrollView {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WinUI.ScrollViewer) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension List {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WinUI.ListView) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension NavigationSplitView {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WinUI.SplitView) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension SwiftCrossUI.Image {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WinUI.Image) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints) {
            (_: WinUI.FrameworkElement, children: ImageChildren) in
            action(children.imageWidget.into())
        }
    }
}

extension HStack {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WinUI.Canvas) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension VStack {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WinUI.Canvas) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension ZStack {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WinUI.Canvas) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension Group {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WinUI.Canvas) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension SwiftCrossUI.Shape {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WinUI.Path) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}
