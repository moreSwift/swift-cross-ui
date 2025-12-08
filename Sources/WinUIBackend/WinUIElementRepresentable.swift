import SwiftCrossUI
import WinUI
import WindowsFoundation

// Many force tries are required for the WinUI backend but we don't really want them
// anywhere else so just disable the lint rule at a file level.
// swiftlint:disable force_try

/// The context associated with an instance of ``Representable``.
public struct WinUIElementRepresentableContext<Representable: WinUIElementRepresentable> {
    public let coordinator: Representable.Coordinator
    public internal(set) var environment: EnvironmentValues
}

/// A wrapper that you use to integrate a WinUI element into your SwiftCrossUI
/// view hierarchy.
public protocol WinUIElementRepresentable: View where Content == Never {
    /// The underlying Gtk widget.
    associatedtype WinUIElementType: WinUI.FrameworkElement
    /// A type providing persistent storage for representable implementations.
    associatedtype Coordinator = Void

    /// Create the initial element instance.
    @MainActor
    func makeWinUIElement(
        context: Context
    ) -> WinUIElementType

    /// Update the widget with new values.
    /// - Parameters:
    ///   - winUIElement: The element to update.
    ///   - context: The context, including the coordinator and potentially new
    ///     environment values.
    /// - Note: This may be called even when `context` has not changed.
    @MainActor
    func updateWinUIElement(
        _ winUIElement: WinUIElementType,
        context: Context
    )

    /// Make the coordinator for this element.
    ///
    /// The coordinator is used when the element needs to communicate changes to
    /// the rest of the view hierarchy (i.e. through bindings), and is often the
    /// element's delegate.
    @MainActor
    func makeCoordinator() -> Coordinator

    /// Compute the element's size.
    /// Compute the element's preferred size for the given proposal.
    /// - Parameters:
    ///   - proposal: The proposed size for the element.
    ///   - winUIElement: The element being queried for its preferred size.
    ///   - context: The context, including the coordinator and environment values.
    /// - Returns: The element's preferred size.
    @MainActor
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        winUIElement: WinUIElementType,
        context: Context
    ) -> ViewSize

    /// Called to clean up the element when it's removed.
    ///
    /// The default implementation does nothing.
    /// - Parameters:
    ///   - gtkElement: The element being dismantled.
    ///   - coordinator: The coordinator.
    static func dismantleWinUIElement(_ winUIElement: WinUIElementType, coordinator: Coordinator)
}

extension WinUIElementRepresentable {
    /// Context associated with the representable element.
    public typealias Context = WinUIElementRepresentableContext<Self>
}

extension WinUIElementRepresentable {
    public static func dismantleWinUIElement(_: WinUIElementType, coordinator _: Coordinator) {
        // no-op
    }

    @MainActor
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        winUIElement: WinUIElementType,
        context _: Context
    ) -> ViewSize {
        let allocation = WindowsFoundation.Size(
            width: proposal.width.map(Float.init) ?? .infinity,
            height: proposal.height.map(Float.init) ?? .infinity
        )
        try! winUIElement.measure(allocation)
        let sizeThatFits = winUIElement.desiredSize

        let adjustment: SIMD2<Int> = WinUIBackend.sizeCorrection(for: winUIElement)

        let idealWidth = Double(sizeThatFits.width) + Double(adjustment.x)
        let idealHeight = Double(sizeThatFits.height) + Double(adjustment.y)

        return ViewSize(
            idealWidth,
            idealHeight
        )
    }
}

extension View where Self: WinUIElementRepresentable {
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
            fatalError("WinUIElementRepresentable requested by \(Backend.self)")
        }
    }

    public func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: any ViewGraphNodeChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let representingWidget = widget as! RepresentingWidget<Self>
        if let child = representingWidget.child,
            let savedSize = representingWidget.savedSize
        {
            child.width = savedSize.x
            child.height = savedSize.y
        }
        representingWidget.update(with: environment)

        let size = representingWidget.representable.sizeThatFits(
            proposedSize,
            winUIElement: representingWidget.child!,
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
        guard let backend = backend as? WinUIBackend else {
            fatalError("WinUIElementRepresentable updated by \(Backend.self)")
        }

        let representingWidget = widget as! RepresentingWidget<Self>
        backend.setSize(of: representingWidget, to: layout.size.vector)
        representingWidget.savedSize = SIMD2(
            representingWidget.child!.width,
            representingWidget.child!.height
        )
        backend.setSize(of: representingWidget.child!, to: layout.size.vector)
    }
}

extension WinUIElementRepresentable where Coordinator == Void {
    public func makeCoordinator() {
        return ()
    }
}

/// Exists to handle `deinit`, the rest of the stuff is just in here cause
/// it's a convenient location.
@MainActor
final class RepresentingWidget<Representable: WinUIElementRepresentable>: WinUI.Canvas {
    var representable: Representable
    var context: Representable.Context?
    var savedSize: SIMD2<Double>?

    init(representable: Representable) {
        self.representable = representable
        super.init()
    }

    var child: Representable.WinUIElementType?
    var cleanUp: (@MainActor @Sendable () -> Void)?

    func update(with environment: EnvironmentValues) {
        if var context, let child {
            context.environment = environment
            representable.updateWinUIElement(child, context: context)
            self.context = context
        } else {
            let context = Representable.Context(
                coordinator: representable.makeCoordinator(),
                environment: environment
            )
            let child = representable.makeWinUIElement(context: context)
            children.append(child)
            representable.updateWinUIElement(child, context: context)
            self.child = child
            self.context = context
        }

        // Work around nonisolated deinit
        let child = child
        let context = context
        cleanUp = {
            if let context, let child {
                Representable.dismantleWinUIElement(child, coordinator: context.coordinator)
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
