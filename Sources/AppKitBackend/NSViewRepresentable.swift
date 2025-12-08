import AppKit
import SwiftCrossUI

/// The context associated with an instance of ``Representable``.
@MainActor
public struct NSViewRepresentableContext<Representable: NSViewRepresentable> {
    public let coordinator: Representable.Coordinator
    public internal(set) var environment: EnvironmentValues
}

/// A wrapper that you use to integrate an AppKit view into your SwiftCrossUI
/// view hierarchy.
public protocol NSViewRepresentable: View where Content == Never {
    /// The underlying AppKit view.
    associatedtype NSViewType: NSView
    /// A type providing persistent storage for representable implementations.
    associatedtype Coordinator = Void

    /// Create the initial NSView instance.
    @MainActor
    func makeNSView(context: Context) -> NSViewType

    /// Update the view with new values.
    /// - Parameters:
    ///   - nsView: The view to update.
    ///   - context: The context, including the coordinator and potentially new
    ///     environment values.
    /// - Note: This may be called even when `context` has not changed.
    @MainActor
    func updateNSView(
        _ nsView: NSViewType,
        context: Context
    )

    /// Make the coordinator for this view.
    ///
    /// The coordinator is used when the view needs to communicate changes to
    /// the rest of the view hierarchy (i.e. through bindings), and is often the
    /// view's delegate.
    @MainActor
    func makeCoordinator() -> Coordinator

    /// Compute the view's preferred size for the given proposal.
    ///
    /// The default implementation uses `nsView.intrinsicContentSize` and
    /// `nsView.contentHuggingPriority(for:)` to determine the view's
    /// preferred size.
    /// - Parameters:
    ///   - proposal: The proposed size for the view.
    ///   - nsView: The view being queried for its preferred size.
    ///   - context: The context, including the coordinator and environment values.
    /// - Returns: The view's preferred size.
    @MainActor
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsView: NSViewType,
        context: Context
    ) -> ViewSize

    /// Called to clean up the view when it's removed.
    ///
    /// This method is called after all AppKit lifecycle methods, such as
    /// `nsView.didMoveToSuperview()`. The default implementation does nothing.
    ///
    /// - Parameters:
    ///   - nsView: The view being dismantled.
    ///   - coordinator: The coordinator.
    static func dismantleNSView(_ nsView: NSViewType, coordinator: Coordinator)
}

extension NSViewRepresentable {
    /// Context associated with the representable view.
    public typealias Context = NSViewRepresentableContext<Self>
}

/// Default implementations.
extension NSViewRepresentable {
    public static func dismantleNSView(_: NSViewType, coordinator _: Coordinator) {
        // no-op
    }

    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsView: NSViewType,
        context _: Context
    ) -> ViewSize {
        let intrinsicSize = nsView.intrinsicContentSize

        let growsHorizontally = nsView.contentHuggingPriority(for: .horizontal) < .defaultHigh
        let growsVertically = nsView.contentHuggingPriority(for: .vertical) < .defaultHigh

        let idealWidth =
            intrinsicSize.width == NSView.noIntrinsicMetric
            ? 10 : intrinsicSize.width
        let idealHeight =
            intrinsicSize.height == NSView.noIntrinsicMetric
            ? 10 : intrinsicSize.height

        // When the view doesn't grow along a dimension, we use its fittingSize
        // (rather than its intrinsicContentSize), because the intrinsicContentSize
        // of some views (such as NSButton) are too small. In NSButton's case, the
        // intrinsicContentSize doesn't include padding.
        return ViewSize(
            growsHorizontally
                ? (proposal.width ?? idealWidth)
                : nsView.fittingSize.width,
            growsVertically
                ? (proposal.height ?? idealHeight)
                : nsView.fittingSize.height
        )
    }
}

extension View where Self: NSViewRepresentable {
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
            fatalError("NSViewRepresentable requested by \(Backend.self)")
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
        representingWidget.update(with: environment)

        let size = representingWidget.representable.sizeThatFits(
            proposedSize,
            nsView: representingWidget.view,
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
        backend.setSize(of: widget, to: layout.size.vector)
    }
}

extension NSViewRepresentable where Coordinator == Void {
    public func makeCoordinator() {
        return ()
    }
}

/// Exists to handle `deinit`, the rest of the stuff is just in here cause
/// it's a convenient location.
final class RepresentingWidget<Representable: NSViewRepresentable>: NSView {
    var representable: Representable
    var context: Representable.Context?

    init(representable: Representable) {
        self.representable = representable
        super.init(frame: .zero)

        self.translatesAutoresizingMaskIntoConstraints = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not used for this view")
    }

    var subview: Representable.NSViewType?

    var view: Representable.NSViewType {
        if let subview {
            return subview
        } else {
            let view = representable.makeNSView(context: context!)

            self.addSubview(view)

            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: self.topAnchor),
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ])

            subview = view
            return view
        }
    }

    func update(with environment: EnvironmentValues) {
        if var context {
            context.environment = environment
            representable.updateNSView(view, context: context)
            self.context = context
        } else {
            let context = Representable.Context(
                coordinator: representable.makeCoordinator(),
                environment: environment
            )
            self.context = context
            representable.updateNSView(view, context: context)
        }
    }

    deinit {
        if let context, let subview {
            Task { @MainActor in
                Representable.dismantleNSView(subview, coordinator: context.coordinator)
            }
        }
    }
}
