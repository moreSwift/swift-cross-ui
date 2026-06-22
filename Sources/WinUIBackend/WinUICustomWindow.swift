import CWinRT
import Foundation
import SwiftCrossUI
import UWP
import WinAppSDK
import WinSDK
import WinUI
import WinUIInterop
import WindowsFoundation

public class CustomWindow: WinUI.Window {
    public typealias Widget = WinUIBackend.Widget
    /// Hardcoded menu bar height from MenuBar_themeresources.xaml in the
    /// microsoft-ui-xaml repository (the MenuBarHeight property)
    static let menuBarHeight = 40

    var menuBar = WinUI.MenuBar()
    var child: WinUIBackend.Widget?
    var grid: WinUI.Grid
    var cachedAppWindow: WinAppSDK.AppWindow!
    var isActive = false

    private(set) var menuBarIsVisible = false

    /// The amount of height to subtract off the window height to obtain the
    /// window's available content height.
    var contentHeightAdjustment: Int {
        menuBarIsVisible ? Self.menuBarHeight : 0
    }

    var scaleFactor: Double {
        // I'm leaving this code here for future travellers. Be warned that this always
        // seems to return 100% even if the scale factor is set to 125% in settings.
        // Perhaps it's only the device's built-in default scaling? But that seems pretty
        // useless, and isn't what the docs seem to imply.
        //
        //   var deviceScaleFactor = SCALE_125_PERCENT
        //   _ = GetScaleFactorForMonitor(monitor, &deviceScaleFactor)

        let hwnd = cachedAppWindow.getHWND()!
        let monitor = MonitorFromWindow(hwnd, DWORD(bitPattern: MONITOR_DEFAULTTONEAREST))!

        var x: UINT = 0
        var y: UINT = 0
        let result = GetDpiForMonitor(monitor, MDT_EFFECTIVE_DPI, &x, &y)

        let windowScaleFactor: Double
        if result == S_OK {
            windowScaleFactor = Double(x) / Double(USER_DEFAULT_SCREEN_DPI)
        } else {
            logger.warning("failed to get window scale factor, defaulting to 1.0")
            windowScaleFactor = 1
        }

        return windowScaleFactor
    }

    public override init() {
        grid = WinUI.Grid()

        super.init()

        let menuBarRowDefinition = WinUI.RowDefinition()
        let contentRowDefinition = WinUI.RowDefinition()
        grid.rowDefinitions.append(menuBarRowDefinition)
        grid.rowDefinitions.append(contentRowDefinition)
        grid.children.append(menuBar)
        WinUI.Grid.setRow(menuBar, 0)
        self.content = grid

        // NB: This event fires when the window is activated _or_ deactivated.
        self.activated.addHandler { [weak self] _, args in
            switch args?.windowActivationState {
                case .codeActivated, .pointerActivated: self?.isActive = true

                case .deactivated: self?.isActive = false

                // NB: The compiler apparently thinks we didn't exhaustively switch
                // over this enum without this `default` (even after adding a `case nil`).
                // Might be because it doesn't treat the underlying C enum as a Swift enum?
                default: break
            }
        }

        // Caching appWindow is apparently a good idea in terms of performance:
        // https://github.com/thebrowsercompany/swift-winrt/issues/199#issuecomment-2611006020
        cachedAppWindow = appWindow

        // Default to not showing the menu bar; we only want to show it when it's non-empty
        setMenuBarVisible(menuBarIsVisible)
    }

    /// Sets whether the menu bar of the current window is visible. The menu bar
    /// is what holds the in-window app menu, it's not the title bar (the one with
    /// the window controls).
    public func setMenuBarVisible(_ visible: Bool) {
        grid.rowDefinitions[0]!.height = WinUI.GridLength(
            value: visible ? Double(Self.menuBarHeight) : 0,
            gridUnitType: .pixel
        )
        menuBarIsVisible = visible
    }

    public func setChild(_ child: WinUIBackend.Widget) {
        self.child = child
        grid.children.append(child)
        WinUI.Grid.setRow(child, 1)
    }
}
