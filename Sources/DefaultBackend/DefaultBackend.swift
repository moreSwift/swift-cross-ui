#if canImport(AppKitBackend)
    import AppKitBackend
    public typealias DefaultBackend = AppKitBackend
#elseif canImport(GtkBackend)
    import GtkBackend
    public typealias DefaultBackend = GtkBackend
#elseif canImport(Gtk3Backend)
    import Gtk3Backend
    public typealias DefaultBackend = Gtk3Backend
#elseif canImport(WinUIBackend)
    import WinUIBackend
    public typealias DefaultBackend = WinUIBackend
#elseif canImport(QtBackend)
    import QtBackend
    public typealias DefaultBackend = QtBackend
#elseif canImport(CursesBackend)
    import CursesBackend
    public typealias DefaultBackend = CursesBackend
#elseif canImport(UIKitBackend)
    import UIKitBackend
    public typealias DefaultBackend = UIKitBackend
#elseif canImport(AndroidBackend)
    import AndroidBackend
    public typealias DefaultBackend = AndroidBackend
#else
    #error("Unknown backend selected")
#endif
