// We re-export the classes in addition to exposing them as a typealias. Without
// that Swift's MemberImportVisibility feature (enabled by default in the Swift 6
// language mode) produces compile time errors about the selected backend's
// protocol conformances not being accessible when users attempt to use DefaultBackend.
#if canImport(AppKitBackend)
    @_exported import class AppKitBackend.AppKitBackend
    public typealias DefaultBackend = AppKitBackend
#elseif canImport(GtkBackend)
    @_exported import class GtkBackend.GtkBackend
    public typealias DefaultBackend = GtkBackend
#elseif canImport(Gtk3Backend)
    @_exported import class Gtk3Backend.Gtk3Backend
    public typealias DefaultBackend = Gtk3Backend
#elseif canImport(WinUIBackend)
    @_exported import class WinUIBackend.WinUIBackend
    public typealias DefaultBackend = WinUIBackend
#elseif canImport(QtBackend)
    @_exported import struct QtBackend.QtBackend
    public typealias DefaultBackend = QtBackend
#elseif canImport(CursesBackend)
    @_exported import class CursesBackend.CursesBackend
    public typealias DefaultBackend = CursesBackend
#elseif canImport(UIKitBackend)
    @_exported import class UIKitBackend.UIKitBackend
    public typealias DefaultBackend = UIKitBackend
#elseif canImport(AndroidBackend)
    @_exported import class AndroidBackend.AndroidBackend
    public typealias DefaultBackend = AndroidBackend
#else
    #error("Unknown backend selected")
#endif
