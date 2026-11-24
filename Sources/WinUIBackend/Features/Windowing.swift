@_spi(Backends) import SwiftCrossUI
import WinUI 

extension WinUIBackend: BackendFeatures.Windowing {
    public func setBehaviors(
        ofWindow window: Window,
        closable: Bool,
        minimizable: Bool,
        resizable: Bool
    ) {
        // Source: https://devblogs.microsoft.com/oldnewthing/20100604-00/?p=13803
        let hwnd = window.getHWND()!
        let flags = if closable { MF_ENABLED } else { MF_DISABLED | MF_GRAYED }
        EnableMenuItem(
            GetSystemMenu(hwnd, false),
            numericCast(SC_CLOSE),
            numericCast(MF_BYCOMMAND | flags)
        )

        (window.appWindow.presenter as? OverlappedPresenter)?.isMinimizable = minimizable
        (window.appWindow.presenter as? OverlappedPresenter)?.isResizable = resizable
    }

    public func close(window: Window) {
        do {
            try window.close()
        } catch {
            logger.warning("Failed to close window: \(error)")
        }
    }

    public func setCloseHandler(
        ofWindow window: Window,
        to action: @escaping () -> Void
    ) {
        window.closed.addHandler { _, _ in
            action()
        }
    }
}
