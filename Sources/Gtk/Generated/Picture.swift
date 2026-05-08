import CGtk

/// Displays a `GdkPaintable`.
///
/// picture><source srcset="picture-dark.png" media="(prefers-color-scheme: dark)"><img alt="An example GtkPicture" src="picture.png"></picture>
///
/// Many convenience functions are provided to make pictures simple to use.
/// For example, if you want to load an image from a file, and then display
/// it, there’s a convenience function to do this:
///
/// ```c
/// GtkWidget *widget = gtk_picture_new_for_filename ("myfile.png");
/// ```
///
/// If the file isn’t loaded successfully, the picture will contain a
/// “broken image” icon similar to that used in many web browsers.
/// If you want to handle errors in loading the file yourself,
/// for example by displaying an error message, then load the image with
/// [ctor@Gdk.Texture.new_from_file], then create the `GtkPicture` with
/// [ctor@Gtk.Picture.new_for_paintable].
///
/// Sometimes an application will want to avoid depending on external data
/// files, such as image files. See the documentation of `GResource` for details.
/// In this case, [ctor@Gtk.Picture.new_for_resource] and
/// [method@Gtk.Picture.set_resource] should be used.
///
/// `GtkPicture` displays an image at its natural size. See [class@Gtk.Image]
/// if you want to display a fixed-size image, such as an icon.
///
/// ## Sizing the paintable
///
/// You can influence how the paintable is displayed inside the `GtkPicture`
/// by changing [property@Gtk.Picture:content-fit]. See [enum@Gtk.ContentFit]
/// for details. [property@Gtk.Picture:can-shrink] can be unset to make sure
/// that paintables are never made smaller than their ideal size - but
/// be careful if you do not know the size of the paintable in use (like
/// when displaying user-loaded images). This can easily cause the picture to
/// grow larger than the screen. And [property@Gtk.Widget:halign] and
/// [property@Gtk.Widget:valign] can be used to make sure the paintable doesn't
/// fill all available space but is instead displayed at its original size.
///
/// ## CSS nodes
///
/// `GtkPicture` has a single CSS node with the name `picture`.
///
/// ## Accessibility
///
/// `GtkPicture` uses the [enum@Gtk.AccessibleRole.img] role.
open class Picture: Widget {
    /// Creates a new empty `GtkPicture` widget.
    public convenience init() {
        self.init(
            gtk_picture_new()
        )
    }

    /// Creates a new `GtkPicture` displaying the file @filename.
    ///
    /// This is a utility function that calls [ctor@Gtk.Picture.new_for_file].
    /// See that function for details.
    public convenience init(filename: String) {
        self.init(
            gtk_picture_new_for_filename(filename)
        )
    }

    /// Creates a new `GtkPicture` displaying @paintable.
    ///
    /// The `GtkPicture` will track changes to the @paintable and update
    /// its size and contents in response to it.
    public convenience init(paintable: OpaquePointer) {
        self.init(
            gtk_picture_new_for_paintable(paintable)
        )
    }

    /// Creates a new `GtkPicture` displaying the resource at @resource_path.
    ///
    /// This is a utility function that calls [ctor@Gtk.Picture.new_for_file].
    /// See that function for details.
    public convenience init(resourcePath: String) {
        self.init(
            gtk_picture_new_for_resource(resourcePath)
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

        addSignal(name: "notify::alternative-text", handler: gCallback(handler0)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyAlternativeText?(self, param0)
        }

        let handler1:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::can-shrink", handler: gCallback(handler1)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyCanShrink?(self, param0)
        }

        let handler2:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::content-fit", handler: gCallback(handler2)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyContentFit?(self, param0)
        }

        let handler3:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::file", handler: gCallback(handler3)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyFile?(self, param0)
        }

        let handler4:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::keep-aspect-ratio", handler: gCallback(handler4)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyKeepAspectRatio?(self, param0)
        }

        let handler5:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::paintable", handler: gCallback(handler5)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyPaintable?(self, param0)
        }
    }

    /// The alternative textual description for the picture.
    @GObjectProperty(named: "alternative-text") public var alternativeText: String?

    /// If the `GtkPicture` can be made smaller than the natural size of its contents.
    @GObjectProperty(named: "can-shrink") public var canShrink: Bool

    /// Whether the GtkPicture will render its contents trying to preserve the aspect
    /// ratio.
    @GObjectProperty(named: "keep-aspect-ratio") public var keepAspectRatio: Bool

    /// The `GdkPaintable` to be displayed by this `GtkPicture`.
    @GObjectProperty(named: "paintable") public var paintable: OpaquePointer?

    public var notifyAlternativeText: ((Picture, OpaquePointer) -> Void)?

    public var notifyCanShrink: ((Picture, OpaquePointer) -> Void)?

    public var notifyContentFit: ((Picture, OpaquePointer) -> Void)?

    public var notifyFile: ((Picture, OpaquePointer) -> Void)?

    public var notifyKeepAspectRatio: ((Picture, OpaquePointer) -> Void)?

    public var notifyPaintable: ((Picture, OpaquePointer) -> Void)?
}
