import Foundation

/// Namespace for backend protocols.
///
/// Conform to ``AppBackend/Base`` to create a backend that can be used to run
/// an app. Backends are usually built on top of an existing UI framework.
///
/// Default placeholder implementations are available for all non-essential
/// app lifecycle methods. These implementations will fatally crash when called
/// and are simply intended to allow incremental implementation of backends,
/// not a production-ready fallback for views that cannot be represented by a
/// given backend. The methods you need to implemented up-front (which don't
/// have default implementations) are: ``AppBackend/Windowing/createWindow(withDefaultSize:)``,
/// ``AppBackend/Windowing/setTitle(ofWindow:to:)``,
/// ``AppBackend/Windowing/setBehaviors(ofWindow:closable:minimizable:resizable:)``,
/// ``AppBackend/Windowing/setChild(ofWindow:to:)``, ``AppBackend/Windowing/show(window:)``,
/// ``AppBackend/Core/runMainLoop(_:)``, ``AppBackend/Core/runInMainThread(action:)``,
/// ``AppBackend/Windowing/isWindowProgrammaticallyResizable(_:)``,
/// ``AppBackend/Widgets/show(widget:)``.
/// Many of these can simply be given dummy implementations until you're ready
/// to implement them properly.
///
/// If you need to modify the children of a widget after creation but there
/// aren't update methods available, this is an intentional limitation to
/// reduce the complexity of maintaining a multitude of backends -- nest
/// another container, such as a VStack, inside the container to allow you
/// to change its children on demand.
///
/// For interactive controls with values, the method for setting the
/// control's value is always separate from the method for updating the
/// control's properties (e.g. its minimum value, or placeholder label etc).
/// This is because it's very common for view implementations to either
/// update a control's properties without updating its value (in the case
/// of an unbound control), or update a control's value only if it doesn't
/// match its current value (to prevent infinite loops).
///
/// Many views have both a `create` and an `update` method. The `create`
/// method should only have parameters for properties which don't have
/// sensible defaults (e.g. under some backends, image widgets can't be
/// created without an underlying image being selected up-front, so the
/// `create` method requires a `filePath` and will overlap with the `update`
/// method). This design choice was made to reduce the amount of repeated
/// code between the `create` and `update` methods of the various widgets
/// (since the `update` method is always called between calling `create`
/// and actually displaying the widget anyway).
public enum AppBackend {
    /// Denotes a backend that implements all required features of SwiftCrossUI,
    /// but may omit certain features that aren't critical for apps to work
    /// properly.
    public typealias Base =
        Core & Containers & PassiveViews & Controls & Alerts & Sheets & Menus
        & Colors & CornerRadius & Paths & WebViews & Gestures

    /// Denotes a fully-featured backend that implements all features of
    /// SwiftCrossUI.
    public typealias Full =
        Base & IncomingURLs & ExternalURLs & RevealFile & ApplicationMenus & FileDialogs
}
