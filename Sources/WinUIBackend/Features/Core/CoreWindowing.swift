@_spi(Backends) import SwiftCrossUI
import WinUI
import Foundation
import UWP

extension WinUIBackend: BackendFeatures.CoreWindowing {
    public typealias Window = CustomWindow

    public var supportsMultipleWindows: Bool { true }
    public var canOverrideWindowColorScheme: Bool { true }
    public var restoresWindowFrames: Bool { true }

    public func createWindow(withDefaultSize size: SIMD2<Int>?, id: String) -> Window {
        let window = CustomWindow()
        windows.append(window)
        window.closed.addHandler { _, _ in
            self.windows.removeAll { other in
                window === other
            }
        }

        if self.dispatcherQueue == nil {
            self.dispatcherQueue = window.dispatcherQueue
        }

        // import WinSDK
        // import CWinRT
        // @_spi(WinRTInternal) import WindowsFoundation
        // let minSizeHook: HOOKPROC = { (nCode: Int32, wParam: WPARAM, lParam: LPARAM) in
        //     if nCode >= 0 {
        //         let ptr = UnsafeRawPointer(bitPattern: Int(lParam))?
        //             .assumingMemoryBound(to: CWPRETSTRUCT.self)
        //         if let msgInfo = ptr?.pointee, msgInfo.message == WM_GETMINMAXINFO {
        //             print("Received WM_GETMINMAXINFO")

        //             // var value: HWND = .init(0)
        //             _ = try! window._inner.perform(
        //                 as: __x_ABI_CMicrosoft_CUI_CXaml_CIWindowNative.self
        //             ) { pThis in
        //                 try! CHECKED(pThis.pointee.lpVtbl.pointee.get_WindowHandle(pThis, nil))
        //             }
        //         }
        //     }
        //     return CallNextHookEx(nil, nCode, wParam, lParam)
        // }

        // _ = SetWindowsHookExW(WH_CALLWNDPROCRET, minSizeHook, nil, GetCurrentThreadId())
        // print("Registered")

        // print(GetDpiForWindow(nil))

        if let size {
            setSize(ofWindow: window, to: size)
        }
        return window
    }

    public func updateWindow(_ window: Window, environment: EnvironmentValues) {
        window.menuBar.requestedTheme = switch environment.colorScheme {
            case .light: .light
            case .dark: .dark
        }

        let backgroundColor: SwiftCrossUI.Color = switch environment.colorScheme {
            case .light: .white
            case .dark: .black
        }
        let brush = WinUI.SolidColorBrush()
        brush.color = backgroundColor.resolve(in: environment).uwpColor
        window.grid.background = brush
    }

    public func setTitle(ofWindow window: Window, to title: String) {
        window.title = title
    }

    public func setChild(ofWindow window: Window, to widget: Widget) {
        window.setChild(widget)
        try! widget.updateLayout()
        widget.actualThemeChanged.addHandler { _, _ in
            Task { @MainActor in
                self.rootEnvironmentChangeHandler?()
            }
        }
    }

    public func size(ofWindow window: Window) -> SIMD2<Int> {
        let size = window.appWindow.clientSize
        let scaleFactor = window.scaleFactor
        let width = Double(size.width) / scaleFactor
        let height = Double(size.height) / scaleFactor
        let out = SIMD2(
            Int(width.rounded(.towardZero)),
            Int(height.rounded(.towardZero)) - window.contentHeightAdjustment
        )
        return out
    }

    public func isWindowProgrammaticallyResizable(_ window: Window) -> Bool {
        // TODO: Detect whether window is fullscreen
        return true
    }

    public func setSize(ofWindow window: Window, to newSize: SIMD2<Int>) {
        let scaleFactor = window.scaleFactor
        let width = scaleFactor * Double(newSize.x)
        let height = scaleFactor * Double(newSize.y + window.contentHeightAdjustment)
        let size = UWP.SizeInt32(
            width: Int32(width.rounded(.towardZero)),
            height: Int32(height.rounded(.towardZero))
        )
        try! window.appWindow.resizeClient(size)
    }

    public func setSizeLimits(
        ofWindow window: Window,
        minimum minimumSize: SIMD2<Int>,
        maximum maximumSize: SIMD2<Int>?
    ) {
        debugLogOnce("\(#function) unimplemented")
    }

    public func setResizeHandler(
        ofWindow window: Window,
        to action: @escaping (SIMD2<Int>) -> Void
    ) {
        window.sizeChanged.addHandler { _, args in
            let size = SIMD2(
                Int(args!.size.width.rounded(.awayFromZero)),
                Int(args!.size.height.rounded(.awayFromZero)) - window.contentHeightAdjustment
            )
            action(size)
        }
    }

    public func show(window: Window) {
        activate(window: window)
    }

    public func activate(window: Window) {
        do {
            try window.activate()
        } catch {
            logger.warning("Failed to activate window: \(error)")
        }
    }

    public func computeWindowEnvironment(
        window: Window,
        rootEnvironment: EnvironmentValues
    ) -> EnvironmentValues {
        // TODO: Compute window scale factor (easy enough, but we would also have to keep
        //   it up-to-date then, which is kinda annoying for now)
        rootEnvironment
            .with(\.scenePhase, window.isActive ? .active : .inactive)
    }

    public func setWindowEnvironmentChangeHandler(
        of window: Window,
        to action: @escaping @Sendable @MainActor () -> Void
    ) {
        // TODO: Notify when window scale factor changes

        // NB: This event fires when the window is activated _or_ deactivated.
        window.activated.addHandler { _, _ in
            if let rootHandler = self.rootEnvironmentChangeHandler {
                rootHandler()
                // Don't bother calling `action` since this window's environment
                // will be recomputed anyway.
            } else {
                action()
            }
        }
    }
}
