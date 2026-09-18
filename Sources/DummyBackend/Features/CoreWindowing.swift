@_spi(Backends) import SwiftCrossUI

extension DummyBackend: BackendFeatures.CoreWindowing {
    public var supportsMultipleWindows: Bool { true }
    public var canOverrideWindowColorScheme: Bool { true }
    public var restoresWindowFrames: Bool { false }

    public func createWindow(withDefaultSize defaultSize: SIMD2<Int>?, id: String) -> Window {
        Window(defaultSize: defaultSize, id: id)
    }

    public func updateWindow(_ window: Window, environment: EnvironmentValues) {
        window.colorScheme = environment.colorScheme
    }

    public func setTitle(ofWindow window: Window, to title: String) {
        window.title = title
    }

    public func setChild(ofWindow window: Window, to child: Widget) {
        window.content = child
    }

    public func size(ofWindow window: Window) -> SIMD2<Int> {
        window.size
    }

    public func isWindowProgrammaticallyResizable(_ window: Window) -> Bool {
        true
    }

    public func setSize(ofWindow window: Window, to newSize: SIMD2<Int>) {
        window.size = newSize
    }

    public func setSizeLimits(
        ofWindow window: Window,
        minimum minimumSize: SIMD2<Int>,
        maximum maximumSize: SIMD2<Int>?
    ) {
        window.minimumSize = minimumSize
        window.maximumSize = maximumSize
    }

    public func setResizeHandler(
        ofWindow window: Window,
        to action: @escaping (SIMD2<Int>) -> Void
    ) { window.resizeHandler = action }

    public func show(window: Window) {
        window.phase = .active
    }

    public func activate(window: Window) {
        window.phase = .active
    }

    public func computeWindowEnvironment(
        window: Window,
        rootEnvironment: EnvironmentValues
    ) -> EnvironmentValues {
        rootEnvironment
            .with(\.scenePhase, window.phase)
    }

    public func setWindowEnvironmentChangeHandler(
        of window: Window,
        to action: @escaping @Sendable @MainActor () -> Void
    ) {}
}
