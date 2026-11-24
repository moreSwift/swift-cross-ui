import Testing
import Foundation

import DummyBackend
@testable @_spi(Backends) import SwiftCrossUI

#if canImport(AppKitBackend)
    import AppKit
    import CoreGraphics
    @testable import AppKitBackend
#endif

struct CounterView: View {
    @State var count = 0

    var body: some View {
        VStack {
            Text("Decrease")
            Text("Count: 1")
            Text("Increase")
        }.padding()
    }
}

struct TestError: LocalizedError {
    var message: String

    var errorDescription: String? {
        message
    }
}

@Suite("Testing for SwiftCrossUI")
struct SwiftCrossUITests {
    @Test("Ensures that a NavigationPath can be round tripped to and from JSON")
    func testCodableNavigationPath() throws {
        var path = NavigationPath()
        path.append("a")
        path.append(1)
        path.append([1, 2, 3])
        path.append(5.0)

        let components = path.path(destinationTypes: [
            String.self,
            Int.self,
            [Int].self,
            Double.self,
        ])

        let encoded = try JSONEncoder().encode(path)
        let decodedPath = try JSONDecoder().decode(NavigationPath.self, from: encoded)

        let decodedComponents = decodedPath.path(destinationTypes: [
            String.self,
            Int.self,
            [Int].self,
            Double.self,
        ])

        #expect(Self.compareComponents(ofType: String.self, components[0], decodedComponents[0]))
        #expect(Self.compareComponents(ofType: Int.self, components[1], decodedComponents[1]))
        #expect(Self.compareComponents(ofType: [Int].self, components[2], decodedComponents[2]))
        #expect(Self.compareComponents(ofType: Double.self, components[3], decodedComponents[3]))
    }

    /// Helper function for `testCodableNavigationPath`.
    static func compareComponents<T: Equatable>(
        ofType type: T.Type,
        _ original: Any,
        _ decoded: Any
    ) -> Bool {
        guard
            let original = original as? T,
            let decoded = decoded as? T
        else {
            return false
        }

        return original == decoded
    }

    @Test("Ensure that ScrollView satisfies basic invariants")
    @MainActor
    func testBasicScrollView() async throws {
        let backend = DummyBackend()
        let window = backend.createWindow(withDefaultSize: nil, id: "window")
        let environment = EnvironmentValues(backend: backend)
            .with(\.window, window)

        let blueRectangleHeight = Double(100)
        let view = ScrollView {
            Color.blue.frame(height: blueRectangleHeight)
        }

        let viewGraph = ViewGraph(
            for: view,
            backend: backend,
            environment: environment
        )
        let proposedSize = ViewSize(80, 80)
        let result = viewGraph.computeLayout(
            proposedSize: ProposedViewSize(proposedSize),
            environment: environment
        )
        viewGraph.commit()

        #expect(result.size == ViewSize(80, 80))

        let rootWidget: DummyBackend.Widget = viewGraph.rootNode.widget.into()
        let scrollView = try #require(
            rootWidget.firstWidget(ofType: DummyBackend.ScrollContainer.self)
        )

        #expect(scrollView.hasVerticalScrollBar)
        #expect(!scrollView.hasHorizontalScrollBar)

        #expect(scrollView.size == proposedSize.vector)
        let expectedSize = ViewSize(
            proposedSize.width - Double(backend.scrollBarWidth),
            blueRectangleHeight
        )

        // Direct child of ScrollView is container used to position actual child
        // (for alignment purposes)
        let child = scrollView.child.getChildren()[0]
        #expect(child.size == expectedSize.vector)
    }

    @Test("Ensure that preferredColorScheme modifier works")
    @MainActor
    func testPreferredColorScheme() async throws {
        let backend = DummyBackend()
        let environment = EnvironmentValues(backend: backend)
            .with(\.defaultLaunchBehavior, .presented)

        #expect(environment.colorScheme == .light)

        let ambientColorScheme = Box<ColorScheme?>(nil)

        struct TestView: View {
            @Environment(\.colorScheme) var colorScheme
            var ambientColorScheme: Box<ColorScheme?>

            var body: some View {
                VStack {
                    Text("Button")
                    Button("Button") {}
                        .preferredColorScheme(.dark)
                }
                .onChange(of: colorScheme) {
                    ambientColorScheme.value = colorScheme
                }
            }
        }

        let scene = Window("Test", id: "test") {
            TestView(ambientColorScheme: ambientColorScheme)
        }

        let node = type(of: scene).Node(from: scene, backend: backend, environment: environment)
        node.update(backend: backend, environment: environment)

        let window = node.windowReference!.window as! DummyBackend.Window
        #expect(window.colorScheme == .dark)
        #expect(ambientColorScheme.value == .dark)
    }

    @Test("Ensure that a basic view has the expected dimensions under DummyBackend")
    @MainActor
    func testBasicLayout() async throws {
        let backend = DummyBackend()
        let window = backend.createWindow(withDefaultSize: SIMD2(200, 200), id: "window")

        let environment = EnvironmentValues(backend: backend)
            .with(\.window, window)
        let viewGraph = ViewGraph(
            for: CounterView(),
            backend: backend,
            environment: environment
        )
        backend.setChild(ofWindow: window, to: viewGraph.rootNode.widget.into())

        let result = viewGraph.computeLayout(
            proposedSize: ProposedViewSize(200, 200),
            environment: environment
        )

        // CounterView is a padded VStack of two Buttons ("Decrease"/"Increase",
        // 8 characters each) and a Text ("Count: 1", 8 characters), laid out under
        // DummyBackend's character-metric approximation for the default (`.body`)
        // font: pointSize 13, lineHeight 16 (Font.TextStyle's desktop table).
        //
        // Text sizing (DummyBackend.size(of:)): characterWidth = Int(13) * 2 / 3 = 8,
        //   width = 8 * 8 = 64, height = lineHeight = 16
        // Button size = label size + DummyBackend.buttonPadding (0, 0) = 64 x 16
        //
        // VStack union width = max(64, 64, 64) = 64
        // VStack height = 16 + 16 + 16 + 2 * VStack.defaultSpacing(10) = 68
        // .padding() adds DummyBackend.defaultPaddingAmount(10) on every edge:
        //   width = 64 + 2 * 10 = 84, height = 68 + 2 * 10 = 88
        #expect(
            result.size == ViewSize(84, 88),
            "View update result mismatch"
        )

        #expect(
            result.preferences.onOpenURL == nil,
            "onOpenURL not nil"
        )
    }

    @Test("Ensure that views with non-TupleView bodies create and commit the expected widgets")
    @MainActor
    func testDirectReturnBodyViews() throws {
        struct DirectTextView: View {
            var body: some View {
                return Text("Hello")
            }
        }

        struct DirectScrollView: View {
            var body: some View {
                return ScrollView {
                    Text("Hello")
                }
            }
        }

        struct OuterDirectView: View {
            var body: some View {
                return DirectTextView()
            }
        }

        struct ImplicitTupleTextView: View {
            var body: some View {
                Text("Hello")
            }
        }

        let backend = DummyBackend()
        let window = backend.createWindow(withDefaultSize: SIMD2(200, 200), id: "window")
        let environment = EnvironmentValues(backend: backend)
            .with(\.window, window)

        let textGraph = ViewGraph(
            for: DirectTextView(),
            backend: backend,
            environment: environment
        )
        _ = textGraph.computeLayout(
            proposedSize: ProposedViewSize(200, 200),
            environment: environment
        )
        textGraph.commit()

        let textWidget: DummyBackend.Widget = textGraph.rootNode.widget.into()
        let directTextView = try #require(textWidget as? DummyBackend.TextView)
        #expect(directTextView.content == "Hello")

        _ = textGraph.computeLayout(
            proposedSize: ProposedViewSize(100, 100),
            environment: environment
        )
        textGraph.commit()
        #expect(directTextView.content == "Hello")

        let scrollGraph = ViewGraph(
            for: DirectScrollView(),
            backend: backend,
            environment: environment
        )
        _ = scrollGraph.computeLayout(
            proposedSize: ProposedViewSize(80, 80),
            environment: environment
        )
        scrollGraph.commit()

        let scrollWidget: DummyBackend.Widget = scrollGraph.rootNode.widget.into()
        #expect(scrollWidget is DummyBackend.ScrollContainer)

        _ = scrollGraph.computeLayout(
            proposedSize: ProposedViewSize(120, 120),
            environment: environment
        )
        scrollGraph.commit()

        let nestedGraph = ViewGraph(
            for: OuterDirectView(),
            backend: backend,
            environment: environment
        )
        _ = nestedGraph.computeLayout(
            proposedSize: ProposedViewSize(200, 200),
            environment: environment
        )
        nestedGraph.commit()

        let nestedWidget: DummyBackend.Widget = nestedGraph.rootNode.widget.into()
        let nestedTextView = try #require(nestedWidget as? DummyBackend.TextView)
        #expect(nestedTextView.content == "Hello")

        _ = nestedGraph.computeLayout(
            proposedSize: ProposedViewSize(100, 100),
            environment: environment
        )
        nestedGraph.commit()
        #expect(nestedTextView.content == "Hello")

        let tupleGraph = ViewGraph(
            for: ImplicitTupleTextView(),
            backend: backend,
            environment: environment
        )
        _ = tupleGraph.computeLayout(
            proposedSize: ProposedViewSize(200, 200),
            environment: environment
        )
        tupleGraph.commit()

        let tupleWidget: DummyBackend.Widget = tupleGraph.rootNode.widget.into()
        #expect(tupleWidget is DummyBackend.Container)
        let tupleTextView = try #require(
            tupleWidget.firstWidget(ofType: DummyBackend.TextView.self)
        )
        #expect(tupleTextView.content == "Hello")
    }

    #if canImport(AppKitBackend)
        @Test("Direct-return gesture modifiers commit on AppKit")
        @MainActor
        func testDirectReturnGestureModifiersAppKit() throws {
            struct DirectHoverView: View {
                var body: some View {
                    return Text("Test").onHover { _ in }
                }
            }

            struct DirectTapGestureView: View {
                var body: some View {
                    return Text("Test").onTapGesture {}
                }
            }

            let backend = AppKitBackend()
            let window = backend.createWindow(withDefaultSize: SIMD2(200, 200), id: "window")
            let environment = EnvironmentValues(backend: backend)
                .with(\.window, window)

            let hoverGraph = ViewGraph(
                for: DirectHoverView(),
                backend: backend,
                environment: environment
            )
            _ = hoverGraph.computeLayout(
                proposedSize: ProposedViewSize(200, 200),
                environment: environment
            )
            hoverGraph.commit()

            let hoverWidget: NSView = hoverGraph.rootNode.widget.into()
            try #require(hoverWidget.subviews.count >= 2)
            #expect(hoverWidget.subviews[1] is NSCustomHoverTarget)

            _ = hoverGraph.computeLayout(
                proposedSize: ProposedViewSize(100, 100),
                environment: environment
            )
            hoverGraph.commit()

            let tapGraph = ViewGraph(
                for: DirectTapGestureView(),
                backend: backend,
                environment: environment
            )
            _ = tapGraph.computeLayout(
                proposedSize: ProposedViewSize(200, 200),
                environment: environment
            )
            tapGraph.commit()

            let tapWidget: NSView = tapGraph.rootNode.widget.into()
            try #require(tapWidget.subviews.count >= 2)
            #expect(tapWidget.subviews[1] is NSCustomTapGestureTarget)

            _ = tapGraph.computeLayout(
                proposedSize: ProposedViewSize(100, 100),
                environment: environment
            )
            tapGraph.commit()
        }

        /// Snapshots an AppKit view to a TIFF image.
        @MainActor
        static func snapshotView(_ view: NSView) throws -> Data {
            view.wantsLayer = true
            view.layer?.backgroundColor = CGColor.white

            guard let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
                throw TestError(message: "Failed to create bitmap backing")
            }

            view.cacheDisplay(in: view.bounds, to: bitmap)

            guard let data = bitmap.tiffRepresentation else {
                throw TestError(message: "Failed to create tiff representation")
            }

            return data
        }
    #endif
}
