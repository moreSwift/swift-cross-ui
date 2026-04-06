import SwiftCrossUI
import UIKit

extension View {
    /// Inspects the native window that backs the window scene enclosing this view.
    public func inspectWindow(
        _ action: @escaping @MainActor @Sendable (UIWindow) -> Void
    ) -> some View {
        InspectWindowView(child: self, action: action)
    }
}

extension View {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (UIView) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints) { (view: any WidgetProtocol) in
            action(view.view)
        }
    }

    nonisolated func inspectAsWrapperWidget<WidgetType: UIView>(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (WrapperWidget<WidgetType>) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints, action: action)
    }
}

extension Button {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (UIButton) -> Void
    ) -> some View {
        inspectAsWrapperWidget(inspectionPoints) { wrapper in
            action(wrapper.child)
        }
    }
}

extension Text {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (UIKitBackend.TextView) -> Void
    ) -> some View {
        inspectAsWrapperWidget(inspectionPoints) { wrapper in
            action(wrapper.child)
        }
    }
}

extension Slider {
    @available(tvOS, unavailable)
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (UISlider) -> Void
    ) -> some View {
        inspectAsWrapperWidget(inspectionPoints) { wrapper in
            action(wrapper.child)
        }
    }
}

// TODO(stackotter): Repair Picker.inspect implementations post PickerStyle refactor
// extension SwiftCrossUI.Picker {
//     /// Inspects the picker's underlying `UIView` on Mac Catalyst. Will be a
//     /// `UIPickerView` if running on Mac Catalyst 14.0+ with the Mac user
//     /// interface idiom, and a `UIPickerView` otherwise.
//     @available(macCatalyst 13.0, *)
//     @available(iOS, unavailable)
//     @available(tvOS, unavailable)
//     @available(visionOS, unavailable)
//     public func inspect(
//         _ inspectionPoints: InspectionPoints = .onCreate,
//         _ action: @escaping @MainActor @Sendable (UIView) -> Void
//     ) -> some View {
//         InspectView(child: self, inspectionPoints: inspectionPoints) { (view: any WidgetProtocol) in
//             if let view = view as? UITableViewPicker {
//                 action(view.child)
//             } else if let view = view as? UIPickerViewPicker {
//                 action(view.child)
//             } else {
//                 action(view.view)
//             }
//         }
//     }

//     /// Inspects the picker's underlying `UITableView` on tvOS.
//     @available(tvOS 13.0, *)
//     @available(iOS, unavailable)
//     @available(visionOS, unavailable)
//     @available(macCatalyst, unavailable)
//     public func inspect(
//         _ inspectionPoints: InspectionPoints = .onCreate,
//         _ action: @escaping @MainActor @Sendable (UITableView) -> Void
//     ) -> some View {
//         inspectAsWrapperWidget(inspectionPoints) { wrapper in
//             action(wrapper.child)
//         }
//     }

//     /// Inspects the picker's underlying `UIPickerView` on iOS or visionOS.
//     @available(iOS 13.0, visionOS 1.0, *)
//     @available(tvOS, unavailable)
//     @available(macCatalyst, unavailable)
//     public func inspect(
//         _ inspectionPoints: InspectionPoints = .onCreate,
//         _ action: @escaping @MainActor @Sendable (UIPickerView) -> Void
//     ) -> some View {
//         inspectAsWrapperWidget(inspectionPoints) { wrapper in
//             action(wrapper.child)
//         }
//     }
// }

extension TextField {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (UITextField) -> Void
    ) -> some View {
        inspectAsWrapperWidget(inspectionPoints) { wrapper in
            action(wrapper.child)
        }
    }
}

extension ScrollView {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (UIScrollView) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints) { (view: ScrollWidget) in
            action(view.scrollView)
        }
    }
}

extension List {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (UITableView) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints) {
            (view: WrapperWidget<UICustomTableView>) in
            action(view.child)
        }
    }
}

extension NavigationSplitView {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (UISplitViewController) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints) {
            (view: WrapperControllerWidget<UISplitViewController>) in
            action(view.child)
        }
    }
}

extension Image {
    public func inspect(
        _ inspectionPoints: InspectionPoints = .onCreate,
        _ action: @escaping @MainActor @Sendable (UIImageView) -> Void
    ) -> some View {
        InspectView(child: self, inspectionPoints: inspectionPoints) {
            (_: UIView, children: ImageChildren) in
            let wrapper: WrapperWidget<UIImageView> = children.imageWidget.into()
            action(wrapper.child)
        }
    }
}
