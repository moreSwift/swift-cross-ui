/// The underlying view used to render the various ``_BuiltinPickerStyle``s.
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

    func asWidget<Backend: AppBackend>(
        _ children: BuiltinPickerChildren,
        backend: Backend
    ) -> Backend.Widget {
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
        backend.setSize(
            of: children.picker!.widget as! Backend.Widget,
            to: layout.size.vector
        )
    }
}

/// The children of a built-in picker. Pickers don't actually have child nodes,
/// we just use this to persist information between updates.
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
