import CGtk

/// The `GtkColorButton` allows to open a color chooser dialog to change
/// the color.
///
/// <picture><source srcset="color-button-dark.png" media="(prefers-color-scheme: dark)"><img alt="An example GtkColorButton" src="color-button.png"></picture>
///
/// It is suitable widget for selecting a color in a preference dialog.
///
/// # CSS nodes
///
/// ```
/// colorbutton
/// ╰── button.color
/// ╰── [content]
/// ```
///
/// `GtkColorButton` has a single CSS node with name colorbutton which
/// contains a button node. To differentiate it from a plain `GtkButton`,
/// it gets the .color style class.
open class ColorButton: Widget {
    public convenience init() {
        self.init(
            gtk_color_button_new()
        )
    }

    open override func registerSignals() {
        super.registerSignals()

        addSignal(name: "color-set") { [weak self] () in
            guard let self else { return }
            self.colorSet?(self)
        }
    }

    /// Whether colors may have alpha (translucency).
    ///
    /// When ::use-alpha is %FALSE, the `GdkRGBA` struct obtained
    /// via the [property@Gtk.ColorChooser:rgba] property will be
    /// forced to have alpha == 1.
    ///
    /// Implementations are expected to show alpha by rendering the color
    /// over a non-uniform background (like a checkerboard pattern).
    @GObjectProperty(named: "use-alpha") public var useAlpha: Bool

    /// Emitted when the user selects a color.
    ///
    /// When handling this signal, use [method@Gtk.ColorChooser.get_rgba]
    /// to find out which color was just selected.
    ///
    /// Note that this signal is only emitted when the user changes the color.
    /// If you need to react to programmatic color changes as well, use
    /// the notify::rgba signal.
    public var colorSet: ((ColorButton) -> Void)?
}
