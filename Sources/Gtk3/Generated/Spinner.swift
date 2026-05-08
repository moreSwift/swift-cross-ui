import CGtk3

/// A GtkSpinner widget displays an icon-size spinning animation.
/// It is often used as an alternative to a #GtkProgressBar for
/// displaying indefinite activity, instead of actual progress.
///
/// To start the animation, use gtk_spinner_start(), to stop it
/// use gtk_spinner_stop().
///
/// # CSS nodes
///
/// GtkSpinner has a single CSS node with the name spinner. When the animation is
/// active, the :checked pseudoclass is added to this node.
open class Spinner: Widget {
    /// Returns a new spinner widget. Not yet started.
    public convenience init() {
        self.init(
            gtk_spinner_new()
        )
    }

    open override func didMoveToParent() {
        super.didMoveToParent()

        let handler0:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::active", handler: gCallback(handler0)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyActive?(self, param0)
        }
    }

    public var notifyActive: ((Spinner, OpaquePointer) -> Void)?
}
