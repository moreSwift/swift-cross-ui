#if canImport(SwiftUI) && canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    import SwiftUI

    import AppKitBackend
    @_spi(Backends) import SwiftCrossUI

    /// Hosts a SwiftCrossUI view inside a SwiftUI view hierarchy so that it can
    /// be rendered by Xcode Previews.
    ///
    /// SwiftCrossUI views don't conform to `SwiftUI.View`, so SwiftUI's
    /// `#Preview` macro can't render them directly. Wrapping a view in
    /// ``SCUIPreview`` bridges the two worlds by rendering the view with
    /// ``AppKitBackend`` and exposing the resulting `NSView` to SwiftUI.
    ///
    /// Most code doesn't need this type. ``Preview(_:body:)`` applies it, and
    /// needs neither an `import SwiftUI` nor conditional compilation:
    ///
    /// ```swift
    /// #Preview("Greeting") {
    ///     VStack {
    ///         Text("Hello, world!")
    ///         Button("Press me") {}
    ///     }
    /// }
    /// ```
    ///
    /// Reach for ``SCUIPreview`` directly when a preview needs SwiftUI
    /// modifiers around the hosted view. Written by hand it has to be gated,
    /// because both the type and SwiftUI's macro are unavailable off-Apple:
    ///
    /// ```swift
    /// #if canImport(SwiftUI) && canImport(AppKit) && !targetEnvironment(macCatalyst)
    ///     import SwiftUI
    ///
    ///     @available(macOS 14.0, *)
    ///     #Preview("Greeting") { () -> any SwiftUI.View in
    ///         SCUIPreview {
    ///             Text("Hello, world!")
    ///         }
    ///         .frame(width: 300)
    ///     }
    /// #endif
    /// ```
    ///
    /// Each clause of that gate is load-bearing: `canImport(SwiftUI)` and
    /// `canImport(AppKit)` for platforms without them, `!targetEnvironment(...)`
    /// because Mac Catalyst has both but not the AppKit hosting this type uses,
    /// and `@available` because SwiftUI's `#Preview` requires macOS 14.
    ///
    /// The closure's return type has to be spelled out. Importing this module
    /// brings ``Preview(_:body:)`` into scope alongside SwiftUI's macro, and
    /// since ``SCUIPreview`` is a `SwiftUI.View` rather than a
    /// `SwiftCrossUI.View`, an unannotated closure picks the overload and
    /// fails to compile.
    ///
    /// The hosted view is laid out against the size that SwiftUI proposes for
    /// the preview canvas, and re-lays out whenever that proposal changes or the
    /// view's `@State` changes.
    ///
    /// - Note: This type is intended for previews and development only. It hosts
    ///   a single view rather than a whole ``Scene``, so scene-level features
    ///   such as window sizing, menu bars and `onOpenURL` aren't available.
    ///
    /// - Warning: Files defining the SwiftCrossUI views you want to preview
    ///   should not import SwiftUI. With both frameworks imported, ambiguous
    ///   names like `Text` and `Button` silently resolve to SwiftUI's types
    ///   inside a preview body, so you'd be previewing SwiftUI's rendering while
    ///   believing it's SwiftCrossUI's. Preferring ``Preview(_:body:)`` avoids
    ///   this, since it needs no SwiftUI import anywhere.
    public struct SCUIPreview<Content: SwiftCrossUI.View>: SwiftUI.View {
        /// The SwiftCrossUI view to render.
        private let content: Content

        /// Creates a preview that renders a SwiftCrossUI view via ``AppKitBackend``.
        ///
        /// - Parameter content: A closure returning the view to render. It is
        ///   evaluated once when the preview is created.
        public init(@SwiftCrossUI.ViewBuilder _ content: () -> Content) {
            self.content = content()
        }

        public var body: some SwiftUI.View {
            Representable(content: content)
        }
    }

    extension SCUIPreview {
        /// Bridges the ``ViewGraph`` hosting a SwiftCrossUI view into SwiftUI.
        ///
        /// The graph itself lives in ``SCUIPreview/Host``, which is created once
        /// per representable instance and kept alive by SwiftUI as the
        /// coordinator.
        ///
        /// Internal rather than private so that tests can drive the same
        /// `makeNSView`/`updateNSView` path that SwiftUI drives.
        struct Representable: SwiftUI.NSViewRepresentable {
            let content: Content

            func makeCoordinator() -> Host {
                Host(content: content)
            }

            func makeNSView(context: Context) -> NSView {
                context.coordinator.container
            }

            func updateNSView(_ nsView: NSView, context: Context) {
                // SwiftUI hands us the new view value on every re-evaluation of
                // the enclosing body, so forward it to pick up changes to any
                // values captured by the view.
                context.coordinator.update(with: content)
            }

            @available(macOS 13.0, *)
            func sizeThatFits(
                _ proposal: SwiftUI.ProposedViewSize,
                nsView: NSView,
                context: Context
            ) -> CGSize? {
                context.coordinator.sizeThatFits(proposal)
            }
        }
    }

    extension SCUIPreview {
        /// Owns the ``ViewGraph`` rendering the previewed view, and mediates
        /// between AppKit's layout pass and SwiftCrossUI's layout algorithm.
        ///
        /// This is the representable's coordinator, so SwiftUI keeps it alive
        /// for as long as the preview exists. That matters because the state
        /// observations that drive updates are owned by the view graph's nodes
        /// and are cancelled when the graph is deallocated.
        @MainActor
        public final class Host {
            /// The AppKit view handed to SwiftUI, into which the rendered view
            /// is placed.
            let container: ContainerView

            /// The graph rendering the previewed view.
            private let viewGraph: ViewGraph<Content>

            /// The environment that the view graph is updated with.
            ///
            /// Held onto because every ``ViewGraph/computeLayout(with:proposedSize:environment:)``
            /// call needs it, including the ones triggered by state changes.
            private var environment: SwiftCrossUI.EnvironmentValues

            /// The window backing the preview.
            ///
            /// SwiftCrossUI requires a window in the environment (view graph
            /// nodes assert on its presence), and ``AppKitBackend`` measures text
            /// against the window's backing scale factor. The window is never
            /// ordered on screen; it exists purely to satisfy those requirements.
            private let window: AppKitBackend.Window

            /// The size most recently proposed by SwiftUI.
            private var proposedSize: SwiftCrossUI.ProposedViewSize = .zero

            /// The size the previewed view most recently laid out at.
            private var contentSize: ViewSize = .zero

            /// Creates a host rendering the given view.
            ///
            /// - Parameter content: The SwiftCrossUI view to render.
            init(content: Content) {
                let backend = AppKitBackend()
                container = ContainerView()

                // The preview canvas renders at whatever scale the display uses,
                // but the backing scale factor of an off-screen window is
                // unreliable, so pin it for stable text measurement.
                window = backend.createWindow(withDefaultSize: nil, id: "SCUIPreview")
                window.backingScaleFactorOverride = 1

                // View graph nodes propagate size-changing state updates up
                // through `onResize`, which is a no-op by default. The handler
                // has to be in place before the graph is created, because each
                // node captures the environment it's created with -- installing
                // it afterwards leaves state changes unable to reach the widget.
                //
                // `self` isn't available until the stored properties are
                // initialized, so the handler indirects through a box that is
                // filled in below.
                let host = HostBox()
                let environment = SwiftCrossUI.EnvironmentValues(backend: backend)
                    .with(\.window, window)
                    .with(\.onResize) { _ in
                        host.value?.relayout()
                    }
                self.environment = environment
                viewGraph = ViewGraph(
                    for: content,
                    backend: backend,
                    environment: environment
                )
                host.value = self

                let rootWidget: NSView = viewGraph.rootNode.widget.into()
                container.addSubview(rootWidget)
            }

            /// Recomputes the previewed view's layout for a new proposal.
            ///
            /// - Parameter proposal: The size proposed by SwiftUI, if it made
            ///   a proposal in each dimension.
            /// - Returns: The size the view wants to be.
            @available(macOS 13.0, *)
            func sizeThatFits(_ proposal: SwiftUI.ProposedViewSize) -> CGSize {
                // SwiftUI uses `nil` to mean "no proposal in this dimension",
                // which SwiftCrossUI spells the same way.
                let size = layout(
                    proposing: SwiftCrossUI.ProposedViewSize(
                        proposal.width.map(Double.init),
                        proposal.height.map(Double.init)
                    )
                )
                return CGSize(width: size.width, height: size.height)
            }

            /// Lays the previewed view out against a new proposal.
            ///
            /// - Parameter proposal: The size to propose to the view.
            /// - Returns: The size the view wants to be.
            func layout(proposing proposal: SwiftCrossUI.ProposedViewSize) -> ViewSize {
                proposedSize = proposal
                relayout()
                return contentSize
            }

            /// Updates the previewed view with a new value of the root view.
            ///
            /// - Parameter content: The new value of the previewed view.
            func update(with content: Content) {
                contentSize = viewGraph.computeLayout(
                    with: content,
                    proposedSize: proposedSize,
                    environment: environment
                ).size
                viewGraph.commit()
                positionContent()
            }

            /// Recomputes and commits the previewed view's layout at the latest
            /// proposal.
            func relayout() {
                contentSize = viewGraph.computeLayout(
                    proposedSize: proposedSize,
                    environment: environment
                ).size
                viewGraph.commit()
                positionContent()
            }

            /// Centers the rendered view within the container, matching how
            /// ``WindowReference`` positions a window's root view.
            private func positionContent() {
                guard let rootWidget = container.subviews.first else { return }

                let containerSize = container.bounds.size
                rootWidget.frame = NSRect(
                    x: ((containerSize.width - contentSize.width) / 2).rounded(.down),
                    y: ((containerSize.height - contentSize.height) / 2).rounded(.down),
                    width: contentSize.width,
                    height: contentSize.height
                )
            }
        }
    }

    extension SCUIPreview {
        /// A weak, late-filled reference to a ``SCUIPreview/Host``.
        ///
        /// The host's `onResize` handler has to be built before the host itself
        /// finishes initializing, so the handler captures one of these instead
        /// of capturing `self`. The reference is weak so that the handler
        /// doesn't keep the host alive.
        @MainActor
        final class HostBox {
            weak var value: Host?
        }

        /// The view handed to SwiftUI, which holds the rendered SwiftCrossUI
        /// view as its only subview.
        ///
        /// AppKit's coordinate system is flipped relative to SwiftCrossUI's, so
        /// this view flips itself to keep child positioning consistent with the
        /// rest of ``AppKitBackend``.
        final class ContainerView: NSView {
            override var isFlipped: Bool {
                true
            }
        }
    }

#endif
