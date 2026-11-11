import CGtk3
import Gtk3
@_spi(Backends) import SwiftCrossUI

extension Gtk3Backend: BackendFeatures.CoreWindowing {
    public typealias Window = Gtk3.ApplicationWindow

    public var supportsMultipleWindows: Bool { true }
    public var canOverrideWindowColorScheme: Bool { false }
    public var restoresWindowFrames: Bool { false }

    public func createWindow(withDefaultSize defaultSize: SIMD2<Int>?, id: String) -> Window {
        let window: Gtk3.ApplicationWindow
        if let precreatedWindow {
            self.precreatedWindow = nil
            window = precreatedWindow
            window.setPosition(to: .center)
        } else {
            window = Gtk3.ApplicationWindow(application: gtkApp)
        }

        windows.append(window)

        if let defaultSize {
            window.defaultSize = Size(
                width: defaultSize.x,
                height: defaultSize.y
            )
        }

        window.notifyIsActive = { _ in
            self.rootEnvironmentChangeHandler?()
        }

        return window
    }

    public func updateWindow(_ window: Window, environment: EnvironmentValues) {
        // TODO(stackotter): Support preferredColorScheme
    }

    public func setTitle(ofWindow window: Window, to title: String) {
        window.title = title
    }

    public func setChild(ofWindow window: Window, to child: Widget) {
        let container = CustomRootWidget()
        container.setChild(to: child)
        window.setChild(to: container)
    }

    public func size(ofWindow window: Window) -> SIMD2<Int> {
        let child = window.child! as! CustomRootWidget
        let size = child.getSize()
        return SIMD2(size.width, size.height)
    }

    public func isWindowProgrammaticallyResizable(_ window: Window) -> Bool {
        // TODO: Detect whether window is fullscreen
        return true
    }

    public func setSize(ofWindow window: Window, to newSize: SIMD2<Int>) {
        let child = window.child! as! CustomRootWidget
        child.preemptAllocatedSize(
            allocatedWidth: newSize.x,
            allocatedHeight: newSize.y
        )
        window.size = Size(
            width: newSize.x,
            height: newSize.y + menubarHeight(ofWindow: window)
        )
    }

    public func setSizeLimits(
        ofWindow window: Window,
        minimum minimumSize: SIMD2<Int>,
        maximum maximumSize: SIMD2<Int>?
    ) {
        let child = window.child! as! CustomRootWidget
        child.setMinimumSize(minimumWidth: minimumSize.x, minimumHeight: minimumSize.y)

        // NB: GTK does not support setting maximum sizes for widgets. It just doesn't.
        // https://discourse.gnome.org/t/how-to-build-fixed-size-windows-in-gtk-4/22807/10
        if maximumSize != nil {
            debugLogOnce("GTK does not support setting maximum window sizes")
        }
    }

    public func setResizeHandler(
        ofWindow window: Window,
        to action: @escaping (_ newSize: SIMD2<Int>) -> Void
    ) {
        let child = window.child! as! CustomRootWidget
        child.setResizeHandler { size in
            action(SIMD2(size.width, size.height))
        }
    }

    public func show(window: Window) {
        window.showAll()
    }

    public func activate(window: Window) {
        window.present()
    }

    public func computeWindowEnvironment(
        window: Window,
        rootEnvironment: EnvironmentValues
    ) -> EnvironmentValues {
        let windowScaleFactor = Int(gtk_widget_get_scale_factor(window.widgetPointer))
        return rootEnvironment
            .with(\.windowScaleFactor, Double(windowScaleFactor))
            .with(\.scenePhase, window.isActive ? .active : .inactive)
    }

    public func setWindowEnvironmentChangeHandler(
        of window: Window,
        to action: @escaping @Sendable @MainActor () -> Void
    ) {
        window.notifyScaleFactor = { _ in
            action()
        }
    }

    func menubarHeight(ofWindow window: Window) -> Int {
        #if os(macOS)
            return 0
        #else
            if window.showMenuBar {
                // TODO: Don't hardcode this (if possible), because some Gtk
                //   themes may affect the height of the menu bar.
                25
            } else {
                0
            }
        #endif
    }
}
