import CWinRT
import WinAppSDK
import WinSDK
import WinUI
@preconcurrency import WindowsFoundation

public func getWindowIDFromWindow(_ hWnd: HWND?) -> WinAppSDK.WindowId {
    HWNDInterop.shared.getWindowIDFromWindow(hWnd)
}

public func getWindowFromWindowId(_ windowID: WinAppSDK.WindowId) -> HWND? {
    HWNDInterop.shared.getWindowFromWindowId(windowID)
}

extension WinAppSDK.AppWindow {
    /// Returns the window handle for the app window.
    public func getHWND() -> HWND? {
        HWNDInterop.shared.getWindowFromWindowId(id)
    }
}

extension WinUI.Window {
    /// Returns the window handle for the window.
    ///
    /// - Note: This is a relatively expensive operation, particularly due to its use
    /// of the `appWindow` getter. If an `AppWindow` is already available, prefer to
    /// use `getHWND()` on that instead; better yet, if the window handle will be used
    /// frequently, assign it to a stored property, as it will not change during the
    /// lifetime of the window.
    public func getHWND() -> HWND? {
        // The appWindow can become nil when a Window is closed.
        guard let appWindow else { return nil }
        return appWindow.getHWND()
    }
}

/// - Safety: This is sendable because all of the pointers have static lifetimes
///   and can be shared across threads. The pointers aren't used for internal
///   mutability.
private struct HWNDInterop: @unchecked Sendable {
    private typealias pfnGetWindowIdFromWindow =
        @convention(c) (
            HWND?, UnsafeMutablePointer<__x_ABI_CMicrosoft_CUI_CWindowId>?
        ) -> HRESULT
    private typealias pfnGetWindowFromWindowId =
        @convention(c) (
            __x_ABI_CMicrosoft_CUI_CWindowId, UnsafeMutablePointer<HWND?>?
        ) -> HRESULT
    private var hModule: HMODULE!
    private var getWindowIDFromWindow_impl: pfnGetWindowIdFromWindow!
    private var getWindowFromWindowID_impl: pfnGetWindowFromWindowId!

    static let shared = HWNDInterop()

    init() {
        "Microsoft.Internal.FrameworkUdk.dll".withCString(encodedAs: UTF16.self) {
            hModule = GetModuleHandleW($0)
            if hModule == nil {
                hModule = LoadLibraryW($0)
            }
        }

        if let pfn = GetProcAddress(hModule, "Windowing_GetWindowIdFromWindow") {
            getWindowIDFromWindow_impl = unsafeBitCast(pfn, to: pfnGetWindowIdFromWindow.self)
        }

        if let pfn = GetProcAddress(hModule, "Windowing_GetWindowFromWindowId") {
            getWindowFromWindowID_impl = unsafeBitCast(pfn, to: pfnGetWindowFromWindowId.self)
        }
    }

    fileprivate func getWindowIDFromWindow(_ hWnd: HWND?) -> WinAppSDK.WindowId {
        var windowID = __x_ABI_CMicrosoft_CUI_CWindowId()
        let hr: HRESULT = getWindowIDFromWindow_impl(hWnd, &windowID)
        if hr != S_OK {
            fatalError("Unable to get window ID")
        }
        return .init(value: windowID.Value)
    }

    fileprivate func getWindowFromWindowId(_ windowID: WinAppSDK.WindowId) -> HWND? {
        var hWnd: HWND?
        let hr: HRESULT = getWindowFromWindowID_impl(.from(swift: windowID), &hWnd)
        if hr != S_OK {
            fatalError("Unable to get window from window ID")
        }
        return hWnd
    }
}
