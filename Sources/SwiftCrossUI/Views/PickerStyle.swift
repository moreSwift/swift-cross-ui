/// The picker styles that need special backend support.
///
/// Some picker styles are built on top of existing views. Only the picker styles enumerated here
/// need special backend support. This is passed to the backend when creating a picker.
public enum BackendPickerStyle: Hashable, Sendable, BitwiseCopyable {
    case menu, radioGroup, segmented, wheel
}

/// A type that specifies the appearance and interaction of all pickers within a view hierarchy.
@MainActor
public protocol PickerStyle {
    associatedtype Body: View

    /// The method used to render ``Picker``.
    /// - Parameters:
    ///   - options: The `options` passed to the picker.
    ///   - selection: A binding to the picker's currently selected value. May hold nil if no value
    ///     has been chosen.
    ///   - environment: The environment the picker is being rendered in.
    func makeView<Value: Equatable>(
        options: [Value],
        selection: Binding<Value?>,
        environment: EnvironmentValues
    ) -> Body

    /// A method that can be used to check whether a picker style is currently supported by a
    /// specific backend.
    ///
    /// To determine whether a picker style is supported, use the environment action
    /// ``EnvironmentValues/isPickerStyleSupported`` instead. This method is used to implement that
    /// check.
    ///
    /// The default implementation always returns `true`.
    /// - Parameter backend: The backend being queried for support.
    func isSupported<Backend: AppBackend>(backend: Backend) -> Bool
}

extension PickerStyle {
    // Default implementation for custom picker styles
    public func isSupported<Backend: AppBackend>(backend: Backend) -> Bool {
        true
    }
}

public struct _BuiltinPickerImplementation: TypeSafeView {
    public var body: EmptyView { return EmptyView() }

    var style: BackendPickerStyle
    var options: [String]
    var selectedIndex: Binding<Int?>

    func children<Backend: AppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> BuiltinPickerChildren {
        BuiltinPickerChildren(
            container: AnyWidget(backend.createContainer()),
            picker: nil,
            style: style
        )
    }

    func asWidget<Backend: AppBackend>(_ children: BuiltinPickerChildren, backend: Backend)
        -> Backend.Widget
    {
        children.container.widget as! Backend.Widget
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: BuiltinPickerChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        var pickerWidget: Backend.Widget

        if let picker = children.picker, children.style == self.style {
            pickerWidget = picker.widget as! Backend.Widget
        } else {
            let containerWidget = children.container.widget as! Backend.Widget
            backend.removeAllChildren(of: containerWidget)

            pickerWidget = backend.createPicker(style: style)
            children.style = self.style
            children.picker = AnyWidget(pickerWidget)

            backend.insert(pickerWidget, into: containerWidget, at: 0)
            backend.setPosition(ofChildAt: 0, in: containerWidget, to: .zero)
        }

        // TODO: Implement picker sizing within SwiftCrossUI so that we can
        //   properly separate committing logic out into `commit`.
        backend.updatePicker(
            pickerWidget,
            options: options,
            environment: environment
        ) {
            selectedIndex.wrappedValue = $0
        }
        backend.setSelectedOption(ofPicker: pickerWidget, to: selectedIndex.wrappedValue)

        // Special handling for UIKitBackend:
        // When backed by a UITableView, its natural size is -1 x -1,
        // but it can and should be as large as reasonable
        let naturalSize = backend.naturalSize(of: pickerWidget)
        let size: ViewSize
        if naturalSize == SIMD2(-1, -1) {
            size = proposedSize.replacingUnspecifiedDimensions(by: ViewSize(10, 10))
        } else {
            size = ViewSize(naturalSize)
        }
        return ViewLayoutResult.leafView(size: size)
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: BuiltinPickerChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.setSize(of: widget, to: layout.size.vector)
        backend.setSize(of: children.picker!.widget as! Backend.Widget, to: layout.size.vector)
    }
}

final class BuiltinPickerChildren: ViewGraphNodeChildren {
    var container: AnyWidget
    var picker: AnyWidget?
    var style: BackendPickerStyle

    init(container: AnyWidget, picker: AnyWidget? = nil, style: BackendPickerStyle) {
        self.container = container
        self.picker = picker
        self.style = style
    }

    var widgets: [AnyWidget] { [container] }
    var erasedNodes: [ErasedViewGraphNode] { [] }
}

public protocol _BuiltinPickerStyle {
    @MainActor
    func _asBackendPickerStyle<Backend: AppBackend>(backend: Backend) -> BackendPickerStyle
}

extension PickerStyle where Self: _BuiltinPickerStyle {
    public func makeView<Value: Equatable>(
        options: [Value],
        selection: Binding<Value?>,
        environment: EnvironmentValues
    ) -> _BuiltinPickerImplementation {
        _BuiltinPickerImplementation(
            style: self._asBackendPickerStyle(backend: environment.backend),
            options: options.map { "\($0)" },
            selectedIndex: Binding {
                selection.wrappedValue.flatMap(options.firstIndex(of:))
            } set: {
                selection.wrappedValue = $0.map { options[$0] }
            }
        )
    }

    public func isSupported<Backend: AppBackend>(backend: Backend) -> Bool {
        backend.supportedPickerStyles.contains(_asBackendPickerStyle(backend: backend))
    }
}

/// A picker style that presents the options in a drop-down menu.
public struct MenuPickerStyle: PickerStyle, _BuiltinPickerStyle {
    public nonisolated init() {}

    public func _asBackendPickerStyle<Backend: AppBackend>(backend: Backend) -> BackendPickerStyle {
        .menu
    }
}

/// A picker style that presents the options in a scrollable wheel.
public struct WheelPickerStyle: PickerStyle, _BuiltinPickerStyle {
    public nonisolated init() {}

    public func _asBackendPickerStyle<Backend: AppBackend>(backend: Backend) -> BackendPickerStyle {
        .wheel
    }
}

/// A picker style that presents the options in a horizontal segmented control.
public struct SegmentedPickerStyle: PickerStyle, _BuiltinPickerStyle {
    public nonisolated init() {}

    public func _asBackendPickerStyle<Backend: AppBackend>(backend: Backend) -> BackendPickerStyle {
        .segmented
    }
}

/// An alias for ``SegmentedPickerStyle``, provided for SwiftUI compatibility.
public typealias PalettePickerStyle = SegmentedPickerStyle

/// A picker style that presents the options as a group of radio buttons.
public struct RadioGroupPickerStyle: PickerStyle, _BuiltinPickerStyle {
    public nonisolated init() {}

    public func _asBackendPickerStyle<Backend: AppBackend>(backend: Backend) -> BackendPickerStyle {
        .radioGroup
    }
}

/// The default picker style that adapts to the current platform and context.
public struct DefaultPickerStyle: PickerStyle, _BuiltinPickerStyle {
    public nonisolated init() {}

    public func _asBackendPickerStyle<Backend: AppBackend>(backend: Backend) -> BackendPickerStyle {
        backend.defaultPickerStyle
    }
}

/// A picker style that shows all options in the picker's content.
///
/// This may look like any built-in style other than ``MenuPickerStyle``, and adapts to the current
/// platform and context.
public struct InlinePickerStyle: PickerStyle, _BuiltinPickerStyle {
    public nonisolated init() {}

    public func _asBackendPickerStyle<Backend: AppBackend>(backend: Backend) -> BackendPickerStyle {
        // If the backend only supports .menu, or doesn't support pickers at all, then inline
        // pickers aren't supported regardless -- so it doesn't matter which of the three is
        // returned in that case.
        if backend.supportedPickerStyles.contains(.radioGroup) {
            .radioGroup
        } else if backend.supportedPickerStyles.contains(.wheel) {
            .wheel
        } else {
            .segmented
        }
    }
}

extension PickerStyle where Self == RadioGroupPickerStyle {
    /// A picker style that presents the options as a group of radio buttons.
    public static nonisolated var radioGroup: Self { Self() }
}

extension PickerStyle where Self == MenuPickerStyle {
    /// A picker style that presents the options in a drop-down menu.
    public static nonisolated var menu: Self { Self() }
}

extension PickerStyle where Self == WheelPickerStyle {
    /// A picker style that presents the options in a scrollable wheel.
    public static nonisolated var wheel: Self { Self() }
}

extension PickerStyle where Self == SegmentedPickerStyle {
    /// A picker style that presents the options in a horizontal segmented control.
    public static nonisolated var segmented: Self { Self() }
    /// An alias for ``segmented``, provided for SwiftUI compatibility.
    public static nonisolated var palette: Self { Self() }
}

extension PickerStyle where Self == DefaultPickerStyle {
    /// The default picker style that adapts to the current platform and context.
    public static nonisolated var automatic: Self { Self() }
}

extension PickerStyle where Self == InlinePickerStyle {
    /// A picker style that shows all options in the picker's content.
    ///
    /// This may be any built-in style other than ``menu``, and adapts to the current platform and
    /// context.
    public static nonisolated var inline: Self { Self() }
}
