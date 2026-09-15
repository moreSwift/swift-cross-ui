#if canImport(SwiftUI) && canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    import Foundation
    import SwiftUI
    import Testing

    import SwiftCrossUI
    @testable import SwiftCrossUIPreviews

    @Suite("SCUIPreview hosting")
    struct SCUIPreviewTests {
        /// Drives the same entry points that SwiftUI drives when rendering a
        /// preview, since the preview canvas itself can't be exercised headlessly.
        @Test("Hosting a view through the representable renders visible content")
        @MainActor
        func testRepresentableRendersContent() throws {
            let representable = SCUIPreview<SnapshotFixture>.Representable(
                content: SnapshotFixture()
            )
            let host = representable.makeCoordinator()

            // The canvas proposes a size before asking for the view, matching
            // the order SwiftUI uses.
            let proposal = SwiftUI.ProposedViewSize(width: 300, height: 200)
            let fittingSize = host.sizeThatFits(proposal)

            #expect(fittingSize.width > 0, "View reported zero width")
            #expect(fittingSize.height > 0, "View reported zero height")

            let container = host.container
            container.frame = NSRect(
                x: 0,
                y: 0,
                width: fittingSize.width,
                height: fittingSize.height
            )
            host.relayout()

            #expect(container.subviews.count == 1, "Expected exactly one hosted root widget")

            let rootWidget = try #require(container.subviews.first)
            #expect(rootWidget.frame.width > 0, "Hosted widget has zero width")
            #expect(rootWidget.frame.height > 0, "Hosted widget has zero height")

            // A view that laid out but never rendered would still produce a
            // uniformly blank bitmap, so assert on actual drawn pixels.
            let image = try Self.snapshot(container)
            #expect(
                Self.hasNonUniformContent(image),
                "Rendered snapshot was blank, so nothing was actually drawn"
            )

            if let path = ProcessInfo.processInfo.environment["SCUI_PREVIEW_SNAPSHOT_PATH"] {
                try Self.writePNG(image, to: URL(fileURLWithPath: path))
            }
        }

        /// Ensures the hosted view re-lays out when the canvas proposes a new
        /// size, which is what happens as the preview canvas is resized.
        @Test("Hosted view responds to a new size proposal")
        @MainActor
        func testRespondsToSizeProposal() throws {
            let representable = SCUIPreview<WideView>.Representable(content: WideView())
            let host = representable.makeCoordinator()

            let narrow = host.sizeThatFits(SwiftUI.ProposedViewSize(width: 100, height: 400))
            let wide = host.sizeThatFits(SwiftUI.ProposedViewSize(width: 600, height: 400))

            #expect(
                narrow.width != wide.width,
                "View ignored the proposed width, so the canvas proposal isn't reaching layout"
            )
        }

        /// Ensures a state change that grows the view reaches the hosted
        /// widget, which requires the view graph to have been given the host's
        /// `onResize` handler.
        @Test("State changes that resize the view update the hosted widget")
        @MainActor
        func testStateChangeResizesHostedWidget() async throws {
            let model = TextModel()
            let representable = SCUIPreview<GrowingView>.Representable(
                content: GrowingView(model: model)
            )
            let host = representable.makeCoordinator()

            _ = host.sizeThatFits(SwiftUI.ProposedViewSize(width: 400, height: 400))
            let rootWidget = try #require(host.container.subviews.first)
            let originalWidth = rootWidget.frame.width

            // Mutating the model is what a button press would do.
            model.text = String(repeating: "wide ", count: 20)

            // SwiftCrossUI dispatches state-driven updates through a serial
            // queue and back onto the main thread, so the update lands after
            // this point rather than synchronously.
            try await Self.waitUntil {
                rootWidget.frame.width != originalWidth
            }

            #expect(
                rootWidget.frame.width != originalWidth,
                """
                Hosted widget didn't resize after a state change, so state-driven \
                updates aren't reaching the preview
                """
            )
        }

        /// Backing state for ``GrowingView``.
        private final class TextModel: SwiftCrossUI.ObservableObject {
            @SwiftCrossUI.Published var text = "narrow"
        }

        /// A view whose width is driven by observable state.
        private struct GrowingView: SwiftCrossUI.View {
            @SwiftCrossUI.State var model: TextModel

            init(model: TextModel) {
                _model = SwiftCrossUI.State(wrappedValue: model)
            }

            var body: some SwiftCrossUI.View {
                SwiftCrossUI.Text(model.text)
            }
        }

        /// A view that fills the width it's offered, so that its measured size
        /// tracks the proposal.
        private struct WideView: SwiftCrossUI.View {
            var body: some SwiftCrossUI.View {
                SwiftCrossUI.Color.blue.frame(
                    maxWidth: .infinity,
                    minHeight: 50,
                    maxHeight: 50
                )
            }
        }

        /// A view with visible content, used to exercise hosting and snapshot
        /// rendering without depending on an example app's views.
        private struct SnapshotFixture: SwiftCrossUI.View {
            var body: some SwiftCrossUI.View {
                SwiftCrossUI.VStack {
                    SwiftCrossUI.Text("Snapshot fixture")
                    SwiftCrossUI.Button("Press me") {}
                }
                .padding()
            }
        }

        /// Snapshotting is only useful as regression evidence if the same view
        /// renders to the same bytes every time.
        @Test("Snapshots are reproducible across renders")
        @MainActor
        func testSnapshotsAreReproducible() throws {
            let first = try SCUIPreviewSnapshot.png(of: SnapshotFixture())
            let second = try SCUIPreviewSnapshot.png(of: SnapshotFixture())

            #expect(first == second, "Rendering the same view twice produced different bytes")
        }

        /// Snapshots are rendered at 1x explicitly so that they don't differ
        /// between Retina and non-Retina machines.
        @Test("Snapshots render at one pixel per point")
        @MainActor
        func testSnapshotsRenderAtOnePixelPerPoint() throws {
            let bitmap = try SCUIPreviewSnapshot.bitmap(
                of: WideView(),
                size: ProposedViewSize(400, nil)
            )

            #expect(
                bitmap.pixelsWide == 400,
                """
                Snapshot was \(bitmap.pixelsWide)px wide for a 400pt proposal, so it \
                picked up the display's scale factor
                """
            )
        }

        /// Polls a condition until it holds or the timeout elapses.
        ///
        /// Returns as soon as the condition holds so that passing runs stay
        /// fast; the caller asserts on the condition afterwards so that a
        /// timeout surfaces as a normal expectation failure.
        ///
        /// - Parameters:
        ///   - timeout: How long to keep polling before giving up.
        ///   - condition: The condition to poll.
        @MainActor
        static func waitUntil(
            timeout: Duration = .seconds(2),
            _ condition: () -> Bool
        ) async throws {
            let deadline = ContinuousClock.now + timeout
            while ContinuousClock.now < deadline {
                if condition() {
                    return
                }
                try await Task.sleep(for: .milliseconds(10))
            }
        }

        /// Renders a view into a bitmap.
        ///
        /// Adapted from the `snapshotView` helper in `SwiftCrossUITests`.
        @MainActor
        static func snapshot(_ view: NSView) throws -> NSBitmapImageRep {
            view.wantsLayer = true
            view.layer?.backgroundColor = CGColor.white

            let bitmap = try #require(
                view.bitmapImageRepForCachingDisplay(in: view.bounds),
                "Failed to create bitmap backing"
            )
            view.cacheDisplay(in: view.bounds, to: bitmap)
            return bitmap
        }

        /// Reports whether a bitmap contains more than one distinct color.
        ///
        /// A blank render produces a single uniform color, so this distinguishes
        /// "drew something" from "drew nothing".
        static func hasNonUniformContent(_ bitmap: NSBitmapImageRep) -> Bool {
            guard let firstPixel = bitmap.colorAt(x: 0, y: 0) else { return false }

            for y in 0..<bitmap.pixelsHigh {
                for x in 0..<bitmap.pixelsWide {
                    guard let pixel = bitmap.colorAt(x: x, y: y) else { continue }
                    if pixel != firstPixel {
                        return true
                    }
                }
            }

            return false
        }

        /// Writes a bitmap to disk as a PNG, for manual inspection.
        static func writePNG(_ bitmap: NSBitmapImageRep, to url: URL) throws {
            let data = try #require(
                bitmap.representation(using: .png, properties: [:]),
                "Failed to encode PNG"
            )
            try data.write(to: url)
        }
    }
#endif
