import Gtk
import SwiftCrossUI

/// The context associated with an instance of ``Representable``.
@MainActor
public struct GtkWidgetRepresentableContext<Representable: GtkWidgetRepresentable> {
    public let coordinator: Representable.Coordinator
    public internal(set) var environment: EnvironmentValues
}

/// A wrapper that you use to integrate a Gtk widget into your SwiftCrossUI
/// view hierarchy.
public protocol GtkWidgetRepresentable: View where Content == Never {
    /// The underlying Gtk widget.
    associatedtype GtkWidgetType: Gtk.Widget
    /// A type providing persistent storage for representable implementations.
    associatedtype Coordinator = Void

    /// Create the initial `Gtk.Widget` instance.
    @MainActor
    func makeGtkWidget(context: Context) -> GtkWidgetType

    /// Update the widget with new values.
    /// - Parameters:
    ///   - gtkWidget: The widget to update.
    ///   - context: The context, including the coordinator and potentially new
    ///     environment values.
    /// - Note: This may be called even when `context` has not changed.
    @MainActor
    func updateGtkWidget(
        _ gtkWidget: GtkWidgetType,
        context: Context
    )

    /// Make the coordinator for this widget.
    ///
    /// The coordinator is used when the widget needs to communicate changes to
    /// the rest of the view hierarchy (i.e. through bindings), and is often the
    /// widget's delegate.
    @MainActor
    func makeCoordinator() -> Coordinator

    /// Compute the widget's preferred size for the given proposal.
    ///
    /// The default implementation uses `gtkWidget.naturalSize()` and
    /// `hexpand`/`vexpand` to determine the widget's preferred size.
    ///   - proposal: The proposed size for the widget.
    ///   - gtkWidget: The widget being queried for its preferred size.
    ///   - context: The context, including the coordinator and environment values.
    /// - Returns: The widget's preferred size.
    @MainActor
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        gtkWidget: GtkWidgetType,
        context: Context
    ) -> ViewSize

    /// Called to clean up the widget when it's removed.
    ///
    /// The default implementation does nothing.
    /// - Parameters:
    ///   - gtkWidget: The widget being dismantled.
    ///   - coordinator: The coordinator.
    static func dismantleGtkWidget(_ gtkWidget: GtkWidgetType, coordinator: Coordinator)
}

extension GtkWidgetRepresentable {
    /// Context associated with the representable widget.
    public typealias Context = GtkWidgetRepresentableContext<Self>
}

extension GtkWidgetRepresentable {
    public static func dismantleGtkWidget(_: GtkWidgetType, coordinator _: Coordinator) {
        // no-op
    }

    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        gtkWidget: GtkWidgetType,
        context _: Context
    ) -> ViewSize {
        let naturalSize = gtkWidget.getNaturalSize()
        let idealWidth = naturalSize.width == -1 ? 10 : Double(naturalSize.width)
        let idealHeight = naturalSize.height == -1 ? 10 : Double(naturalSize.height)
        let growsHorizontally = gtkWidget.expandHorizontally && gtkWidget.useExpandHorizontally
        let growsVertically = gtkWidget.expandVertically && gtkWidget.useExpandVertically

        return ViewSize(
            growsHorizontally
                ? max(proposal.width ?? idealWidth, idealWidth)
                : idealWidth,
            growsVertically
                ? max(proposal.height ?? idealHeight, idealHeight)
                : idealHeight
        )
    }
}

extension View where Self: GtkWidgetRepresentable {
    public var body: Never {
        preconditionFailure("This should never be called")
    }

    public func children<Backend: AppBackend>(
        backend _: Backend,
        snapshots _: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment _: EnvironmentValues
    ) -> any ViewGraphNodeChildren {
        EmptyViewChildren()
    }

    public func layoutableChildren<Backend: AppBackend>(
        backend _: Backend,
        children _: any ViewGraphNodeChildren
    ) -> [LayoutSystem.LayoutableChild] {
        []
    }

    public func asWidget<Backend: AppBackend>(
        _: any ViewGraphNodeChildren,
        backend _: Backend
    ) -> Backend.Widget {
        if let widget = RepresentingWidget(representable: self) as? Backend.Widget {
            return widget
        } else {
            fatalError("GtkWidgetRepresentable requested by \(Backend.self)")
        }
    }

    public func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        guard let backend = backend as? GtkBackend else {
            fatalError("GtkWidgetRepresentable updated by \(Backend.self)")
        }

        let representingWidget = widget as! RepresentingWidget<Self>
        if let child = representingWidget.child,
            let savedSizeRequest = representingWidget.savedSizeRequest
        {
            backend.setSize(of: child, to: savedSizeRequest)
        }
        representingWidget.update(with: environment)

        let size = representingWidget.representable.sizeThatFits(
            proposedSize,
            gtkWidget: representingWidget.child!,
            context: representingWidget.context!
        )

        return ViewLayoutResult.leafView(size: size)
    }

    public func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        guard let backend = backend as? GtkBackend else {
            fatalError("GtkWidgetRepresentable updated by \(Backend.self)")
        }

        let representingWidget = widget as! RepresentingWidget<Self>
        backend.setSize(of: representingWidget, to: layout.size.vector)
        let sizeRequest = representingWidget.child!.getSizeRequest()
        representingWidget.savedSizeRequest = SIMD2(
            sizeRequest.width,
            sizeRequest.height
        )
        backend.setSize(of: representingWidget.child!, to: layout.size.vector)
    }
}

extension GtkWidgetRepresentable where Coordinator == Void {
    public func makeCoordinator() {
        return ()
    }
}

/// Exists to handle `deinit`, the rest of the stuff is just in here cause
/// it's a convenient location.
@MainActor
final class RepresentingWidget<Representable: GtkWidgetRepresentable>: Gtk.Fixed {
    var representable: Representable
    var context: Representable.Context?
    var savedSizeRequest: SIMD2<Int>?

    init(representable: Representable) {
        self.representable = representable
        super.init()
    }

    var child: Representable.GtkWidgetType?
    var cleanUp: (@MainActor @Sendable () -> Void)?

    func update(with environment: EnvironmentValues) {
        if var context, let child {
            context.environment = environment
            representable.updateGtkWidget(child, context: context)
            self.context = context
        } else {
            let context = Representable.Context(
                coordinator: representable.makeCoordinator(),
                environment: environment
            )
            let child = representable.makeGtkWidget(context: context)
            put(child, x: 0, y: 0)
            representable.updateGtkWidget(child, context: context)
            self.child = child
            self.context = context
        }

        // Work around nonisolated deinit
        let child = child
        let context = context
        cleanUp = {
            if let context, let child {
                Representable.dismantleGtkWidget(child, coordinator: context.coordinator)
            }
        }
    }

    deinit {
        if let cleanUp {
            Task { @MainActor in
                cleanUp()
            }
        }
    }
}
