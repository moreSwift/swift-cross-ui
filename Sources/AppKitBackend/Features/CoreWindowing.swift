import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.CoreWindowing {
    public typealias Window = NSCustomWindow

    public var supportsMultipleWindows: Bool { true }
    public var canOverrideWindowColorScheme: Bool { true }
    public var restoresWindowFrames: Bool { true }

    public func createWindow(withDefaultSize defaultSize: SIMD2<Int>?, id: String) -> Window {
        // For bundled apps, the default activation policy is `regular`, but for unbundled
        // apps without an Info.plist the default is `prohibited` -- i.e. the app can't
        // create windows. We override that here.
        NSApplication.shared.setActivationPolicy(.regular)

        let window = NSCustomWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: CGFloat(defaultSize?.x ?? 0),
                height: CGFloat(defaultSize?.y ?? 0)
            ),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: true
        )
        window.delegate = window.customDelegate
        window.windowController?.shouldCascadeWindows = false

        // NB: If this isn't set, AppKit will crash within -[NSApplication run]
        // the *second* time `openWindow` is called. I have absolutely no idea
        // why.
        window.isReleasedWhenClosed = false

        window.addObserver(
            focusManager,
            forKeyPath: "firstResponder",
            context: nil
        )

        // For some strange reason, AppKit is refusing to restore the window's
        // persisted size, so for now we just fetch the persisted state ourselves
        // to parse out the window size and manually apply it to the restored window.
        let savedSize: SIMD2<Int>?
        if let state = UserDefaults.standard.string(forKey: "NSWindow Frame \(id)") {
            // Format: window.x window.y window.w window.h screen.x screen.y screen.w screen.h
            //   E.g. "10 25 100 100 0 0 3440 1440"
            let parts = state.split(separator: " ")
            if parts.count == 8 {
                let widthString = parts[2]
                let heightString = parts[3]
                if let width = Int(widthString), let height = Int(heightString) {
                    savedSize = SIMD2(width, height)
                } else {
                    savedSize = nil
                }
            } else {
                savedSize = nil
            }
        } else {
            savedSize = nil

            // Note that window.center doesn't actually center the window. It centers
            // it horizontally, but its vertical location is chosen by AppKit to be
            // "pleasing" (based off the golden ratio apparently?)
            window.center()
        }

        _ = window.setFrameAutosaveName(id)

        if let savedSize {
            var frame = window.frame
            frame.origin.y -= CGFloat(savedSize.y) - frame.size.height
            frame.size = CGSize(width: savedSize.x, height: savedSize.y)

            // If we set the window bigger than its target screen, then AppKit crashes,
            // so we limit the restored window size to the size of the target screen.
            if let screenFrame = window.screen?.visibleFrame {
                frame.size.width = min(frame.size.width, screenFrame.size.width)
                frame.size.height = min(frame.size.height, screenFrame.size.height)
            }

            window.setFrame(frame, display: true, animate: false)
        }

        return window
    }

    public func updateWindow(_ window: Window, environment: EnvironmentValues) {
        window.appearance = environment.colorScheme.nsAppearance
    }

    public func setTitle(ofWindow window: Window, to title: String) {
        window.title = title
    }

    public func setChild(ofWindow window: Window, to child: Widget) {
        window.contentView = child
    }

    public func size(ofWindow window: Window) -> SIMD2<Int> {
        let contentRect = window.contentRect(forFrameRect: window.frame)
        return SIMD2(
            Int(contentRect.width.rounded(.towardZero)),
            Int(contentRect.height.rounded(.towardZero))
        )
    }

    public func isWindowProgrammaticallyResizable(_ window: Window) -> Bool {
        !window.styleMask.contains(.fullScreen)
    }

    public func setSize(ofWindow window: Window, to newSize: SIMD2<Int>) {
        window.setContentSize(NSSize(width: newSize.x, height: newSize.y))
    }

    public func setSizeLimits(
        ofWindow window: Window,
        minimum minimumSize: SIMD2<Int>,
        maximum maximumSize: SIMD2<Int>?
    ) {
        window.contentMinSize = CGSize(width: minimumSize.x, height: minimumSize.y)
        window.contentMaxSize =
            if let maximumSize {
                CGSize(width: maximumSize.x, height: maximumSize.y)
            } else {
                CGSize(width: Double.infinity, height: .infinity)
            }
    }

    public func setResizeHandler(
        ofWindow window: Window,
        to action: @escaping (SIMD2<Int>) -> Void
    ) {
        window.customDelegate.setResizeHandler(action)
    }

    public func show(window: Window) {
        window.makeKeyAndOrderFront(nil)
    }

    public func activate(window: Window) {
        window.makeKeyAndOrderFront(nil)
    }

    public func computeWindowEnvironment(
        window: Window,
        rootEnvironment: EnvironmentValues
    ) -> EnvironmentValues {
        window.lastBackingScaleFactor = window.backingScaleFactor

        return rootEnvironment
            .with(\.windowScaleFactor, window.backingScaleFactor)
            .with(\.scenePhase, window.isKeyWindow ? .active : .inactive)
    }

    public func setWindowEnvironmentChangeHandler(
        of window: Window,
        to action: @escaping @Sendable @MainActor () -> Void
    ) {
        // For updating window scale factor
        NotificationCenter.default.addObserver(
            forName: NSWindow.didChangeBackingPropertiesNotification,
            object: window,
            queue: .main
        ) { _ in
            Task { @MainActor in
                let backingScaleFactorChanged =
                    window.lastBackingScaleFactor != window.backingScaleFactor

                if backingScaleFactorChanged {
                    action()
                }
            }
        }

        // For updating views that rely on `scenePhase`
        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                action()
            }
        }
        NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                action()
            }
        }
    }
}
