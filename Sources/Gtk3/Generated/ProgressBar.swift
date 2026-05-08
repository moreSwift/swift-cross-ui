import CGtk3

/// The #GtkProgressBar is typically used to display the progress of a long
/// running operation. It provides a visual clue that processing is underway.
/// The GtkProgressBar can be used in two different modes: percentage mode
/// and activity mode.
///
/// When an application can determine how much work needs to take place
/// (e.g. read a fixed number of bytes from a file) and can monitor its
/// progress, it can use the GtkProgressBar in percentage mode and the
/// user sees a growing bar indicating the percentage of the work that
/// has been completed. In this mode, the application is required to call
/// gtk_progress_bar_set_fraction() periodically to update the progress bar.
///
/// When an application has no accurate way of knowing the amount of work
/// to do, it can use the #GtkProgressBar in activity mode, which shows
/// activity by a block moving back and forth within the progress area. In
/// this mode, the application is required to call gtk_progress_bar_pulse()
/// periodically to update the progress bar.
///
/// There is quite a bit of flexibility provided to control the appearance
/// of the #GtkProgressBar. Functions are provided to control the orientation
/// of the bar, optional text can be displayed along with the bar, and the
/// step size used in activity mode can be set.
///
/// # CSS nodes
///
/// |[<!-- language="plain" -->
/// progressbar[.osd]
/// ├── [text]
/// ╰── trough[.empty][.full]
/// ╰── progress[.pulse]
/// ]|
///
/// GtkProgressBar has a main CSS node with name progressbar and subnodes with
/// names text and trough, of which the latter has a subnode named progress. The
/// text subnode is only present if text is shown. The progress subnode has the
/// style class .pulse when in activity mode. It gets the style classes .left,
/// .right, .top or .bottom added when the progress 'touches' the corresponding
/// end of the GtkProgressBar. The .osd class on the progressbar node is for use
/// in overlays like the one Epiphany has for page loading progress.
open class ProgressBar: Widget, Orientable {
    /// Creates a new #GtkProgressBar.
    public convenience init() {
        self.init(
            gtk_progress_bar_new()
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

        addSignal(name: "notify::ellipsize", handler: gCallback(handler0)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyEllipsize?(self, param0)
        }

        let handler1:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::fraction", handler: gCallback(handler1)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyFraction?(self, param0)
        }

        let handler2:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::inverted", handler: gCallback(handler2)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyInverted?(self, param0)
        }

        let handler3:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::pulse-step", handler: gCallback(handler3)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyPulseStep?(self, param0)
        }

        let handler4:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::show-text", handler: gCallback(handler4)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyShowText?(self, param0)
        }

        let handler5:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::text", handler: gCallback(handler5)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyText?(self, param0)
        }

        let handler6:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::orientation", handler: gCallback(handler6)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyOrientation?(self, param0)
        }
    }

    /// The preferred place to ellipsize the string, if the progress bar does
    /// not have enough room to display the entire string, specified as a
    /// #PangoEllipsizeMode.
    ///
    /// Note that setting this property to a value other than
    /// %PANGO_ELLIPSIZE_NONE has the side-effect that the progress bar requests
    /// only enough space to display the ellipsis ("..."). Another means to set a
    /// progress bar's width is gtk_widget_set_size_request().
    @GObjectProperty(named: "ellipsize") public var ellipsize: EllipsizeMode

    @GObjectProperty(named: "fraction") public var fraction: Double

    @GObjectProperty(named: "inverted") public var inverted: Bool

    @GObjectProperty(named: "pulse-step") public var pulseStep: Double

    @GObjectProperty(named: "text") public var text: String?

    public var notifyEllipsize: ((ProgressBar, OpaquePointer) -> Void)?

    public var notifyFraction: ((ProgressBar, OpaquePointer) -> Void)?

    public var notifyInverted: ((ProgressBar, OpaquePointer) -> Void)?

    public var notifyPulseStep: ((ProgressBar, OpaquePointer) -> Void)?

    public var notifyShowText: ((ProgressBar, OpaquePointer) -> Void)?

    public var notifyText: ((ProgressBar, OpaquePointer) -> Void)?

    public var notifyOrientation: ((ProgressBar, OpaquePointer) -> Void)?
}
