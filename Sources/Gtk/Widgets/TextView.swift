import CGtk

/// Displays the contents of a [class@Gtk.TextBuffer].
///
/// <picture><source srcset="multiline-text-dark.png" media="(prefers-color-scheme: dark)"><img alt="An example GtkTextView" src="multiline-text.png"></picture>
///
/// You may wish to begin by reading the [conceptual overview](section-text-widget.html),
/// which gives an overview of all the objects and data types related to the
/// text widget and how they work together.
///
/// ## Shortcuts and Gestures
///
/// `GtkTextView` supports the following keyboard shortcuts:
///
/// - <kbd>Shift</kbd>+<kbd>F10</kbd> or <kbd>Menu</kbd> opens the context menu.
/// - <kbd>Ctrl</kbd>+<kbd>Z</kbd> undoes the last modification.
/// - <kbd>Ctrl</kbd>+<kbd>Y</kbd> or <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>Z</kbd>
/// redoes the last undone modification.
///
/// Additionally, the following signals have default keybindings:
///
/// - [signal@Gtk.TextView::backspace]
/// - [signal@Gtk.TextView::copy-clipboard]
/// - [signal@Gtk.TextView::cut-clipboard]
/// - [signal@Gtk.TextView::delete-from-cursor]
/// - [signal@Gtk.TextView::insert-emoji]
/// - [signal@Gtk.TextView::move-cursor]
/// - [signal@Gtk.TextView::paste-clipboard]
/// - [signal@Gtk.TextView::select-all]
/// - [signal@Gtk.TextView::toggle-cursor-visible]
/// - [signal@Gtk.TextView::toggle-overwrite]
///
/// ## Actions
///
/// `GtkTextView` defines a set of built-in actions:
///
/// - `clipboard.copy` copies the contents to the clipboard.
/// - `clipboard.cut` copies the contents to the clipboard and deletes it from
/// the widget.
/// - `clipboard.paste` inserts the contents of the clipboard into the widget.
/// - `menu.popup` opens the context menu.
/// - `misc.insert-emoji` opens the Emoji chooser.
/// - `selection.delete` deletes the current selection.
/// - `selection.select-all` selects all of the widgets content.
/// - `text.redo` redoes the last change to the contents.
/// - `text.undo` undoes the last change to the contents.
///
/// ## CSS nodes
///
/// ```
/// textview.view
/// ├── border.top
/// ├── border.left
/// ├── text
/// │   ╰── [selection]
/// ├── border.right
/// ├── border.bottom
/// ╰── [window.popup]
/// ```
///
/// `GtkTextView` has a main css node with name textview and style class .view,
/// and subnodes for each of the border windows, and the main text area,
/// with names border and text, respectively. The border nodes each get
/// one of the style classes .left, .right, .top or .bottom.
///
/// A node representing the selection will appear below the text node.
///
/// If a context menu is opened, the window node will appear as a subnode
/// of the main node.
///
/// ## Accessibility
///
/// `GtkTextView` uses the [enum@Gtk.AccessibleRole.text_box] role.
open class TextView: Widget, Scrollable {
    /// Create a text view with an empty text buffer.
    public init() {
        buffer = TextBuffer(table: nil)
        super.init(
            gtk_text_view_new_with_buffer(buffer.gobjectPointer.cast())
        )
    }

    /// Create a text view for the given text buffer.
    public init(buffer: TextBuffer) {
        self.buffer = buffer
        super.init(
            gtk_text_view_new_with_buffer(self.buffer.gobjectPointer.cast())
        )
    }

    open var buffer: TextBuffer

    open override func didMoveToParent() {
        super.didMoveToParent()

        addSignal(name: "backspace") { [weak self] () in
            guard let self else { return }
            self.backspace?(self)
        }

        addSignal(name: "copy-clipboard") { [weak self] () in
            guard let self else { return }
            self.copyClipboard?(self)
        }

        addSignal(name: "cut-clipboard") { [weak self] () in
            guard let self else { return }
            self.cutClipboard?(self)
        }

        let handler3:
            @convention(c) (UnsafeMutableRawPointer, GtkDeleteType, Int, UnsafeMutableRawPointer) ->
            Void =
            { _, value1, value2, data in
                SignalBox2<GtkDeleteType, Int>.run(data, value1, value2)
            }

        addSignal(name: "delete-from-cursor", handler: gCallback(handler3)) {
            [weak self] (param0: GtkDeleteType, param1: Int) in
            guard let self else { return }
            self.deleteFromCursor?(self, param0, param1)
        }

        let handler4:
            @convention(c) (
                UnsafeMutableRawPointer,
                GtkTextExtendSelection,
                GtkTextIter,
                GtkTextIter,
                GtkTextIter,
                UnsafeMutableRawPointer
            ) -> Void =
            { _, value1, value2, value3, value4, data in
                SignalBox4<GtkTextExtendSelection, GtkTextIter, GtkTextIter, GtkTextIter>.run(
                    data,
                    value1,
                    value2,
                    value3,
                    value4
                )
            }

        addSignal(name: "extend-selection", handler: gCallback(handler4)) {
            [weak self]
            (
                param0: GtkTextExtendSelection,
                param1: GtkTextIter,
                param2: GtkTextIter,
                param3: GtkTextIter
            ) in
            guard let self else { return }
            self.extendSelection?(self, param0, param1, param2, param3)
        }

        let handler5:
            @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CChar>, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<UnsafePointer<CChar>>.run(data, value1)
            }

        addSignal(name: "insert-at-cursor", handler: gCallback(handler5)) {
            [weak self] (param0: UnsafePointer<CChar>) in
            guard let self else { return }
            self.insertAtCursor?(self, param0)
        }

        addSignal(name: "insert-emoji") { [weak self] () in
            guard let self else { return }
            self.insertEmoji?(self)
        }

        let handler7:
            @convention(c) (
                UnsafeMutableRawPointer,
                GtkMovementStep,
                Int,
                Bool,
                UnsafeMutableRawPointer
            ) -> Void =
            { _, value1, value2, value3, data in
                SignalBox3<GtkMovementStep, Int, Bool>.run(data, value1, value2, value3)
            }

        addSignal(name: "move-cursor", handler: gCallback(handler7)) {
            [weak self] (param0: GtkMovementStep, param1: Int, param2: Bool) in
            guard let self else { return }
            self.moveCursor?(self, param0, param1, param2)
        }

        let handler8:
            @convention(c) (UnsafeMutableRawPointer, GtkScrollStep, Int, UnsafeMutableRawPointer) ->
            Void =
            { _, value1, value2, data in
                SignalBox2<GtkScrollStep, Int>.run(data, value1, value2)
            }

        addSignal(name: "move-viewport", handler: gCallback(handler8)) {
            [weak self] (param0: GtkScrollStep, param1: Int) in
            guard let self else { return }
            self.moveViewport?(self, param0, param1)
        }

        addSignal(name: "paste-clipboard") { [weak self] () in
            guard let self else { return }
            self.pasteClipboard?(self)
        }

        let handler10:
            @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CChar>, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<UnsafePointer<CChar>>.run(data, value1)
            }

        addSignal(name: "preedit-changed", handler: gCallback(handler10)) {
            [weak self] (param0: UnsafePointer<CChar>) in
            guard let self else { return }
            self.preeditChanged?(self, param0)
        }

        addSignal(name: "set-anchor") { [weak self] () in
            guard let self else { return }
            self.setAnchor?(self)
        }

        addSignal(name: "toggle-cursor-visible") { [weak self] () in
            guard let self else { return }
            self.toggleCursorVisible?(self)
        }

        addSignal(name: "toggle-overwrite") { [weak self] () in
            guard let self else { return }
            self.toggleOverwrite?(self)
        }

        let handler14:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::accepts-tab", handler: gCallback(handler14)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyAcceptsTab?(self, param0)
        }

        let handler15:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::bottom-margin", handler: gCallback(handler15)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyBottomMargin?(self, param0)
        }

        let handler16:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::buffer", handler: gCallback(handler16)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyBuffer?(self, param0)
        }

        let handler17:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::cursor-visible", handler: gCallback(handler17)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyCursorVisible?(self, param0)
        }

        let handler18:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::editable", handler: gCallback(handler18)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyEditable?(self, param0)
        }

        let handler19:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::extra-menu", handler: gCallback(handler19)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyExtraMenu?(self, param0)
        }

        let handler20:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::im-module", handler: gCallback(handler20)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyImModule?(self, param0)
        }

        let handler21:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::indent", handler: gCallback(handler21)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyIndent?(self, param0)
        }

        let handler22:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::input-hints", handler: gCallback(handler22)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyInputHints?(self, param0)
        }

        let handler23:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::input-purpose", handler: gCallback(handler23)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyInputPurpose?(self, param0)
        }

        let handler24:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::justification", handler: gCallback(handler24)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyJustification?(self, param0)
        }

        let handler25:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::left-margin", handler: gCallback(handler25)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyLeftMargin?(self, param0)
        }

        let handler26:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::monospace", handler: gCallback(handler26)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyMonospace?(self, param0)
        }

        let handler27:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::overwrite", handler: gCallback(handler27)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyOverwrite?(self, param0)
        }

        let handler28:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::pixels-above-lines", handler: gCallback(handler28)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyPixelsAboveLines?(self, param0)
        }

        let handler29:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::pixels-below-lines", handler: gCallback(handler29)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyPixelsBelowLines?(self, param0)
        }

        let handler30:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::pixels-inside-wrap", handler: gCallback(handler30)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyPixelsInsideWrap?(self, param0)
        }

        let handler31:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::right-margin", handler: gCallback(handler31)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyRightMargin?(self, param0)
        }

        let handler32:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::tabs", handler: gCallback(handler32)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyTabs?(self, param0)
        }

        let handler33:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::top-margin", handler: gCallback(handler33)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyTopMargin?(self, param0)
        }

        let handler34:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::wrap-mode", handler: gCallback(handler34)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyWrapMode?(self, param0)
        }

        let handler35:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::hadjustment", handler: gCallback(handler35)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyHadjustment?(self, param0)
        }

        let handler36:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::hscroll-policy", handler: gCallback(handler36)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyHscrollPolicy?(self, param0)
        }

        let handler37:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::vadjustment", handler: gCallback(handler37)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyVadjustment?(self, param0)
        }

        let handler38:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::vscroll-policy", handler: gCallback(handler38)) {
            [weak self] (param0: OpaquePointer) in
            guard let self else { return }
            self.notifyVscrollPolicy?(self, param0)
        }
    }

    /// Whether Tab will result in a tab character being entered.
    @GObjectProperty(named: "accepts-tab") public var acceptsTab: Bool

    /// The bottom margin for text in the text view.
    ///
    /// Note that this property is confusingly named. In CSS terms,
    /// the value set here is padding, and it is applied in addition
    /// to the padding from the theme.
    ///
    /// Don't confuse this property with [property@Gtk.Widget:margin-bottom].
    @GObjectProperty(named: "bottom-margin") public var bottomMargin: Int

    /// If the insertion cursor is shown.
    @GObjectProperty(named: "cursor-visible") public var cursorVisible: Bool

    /// Whether the text can be modified by the user.
    @GObjectProperty(named: "editable") public var editable: Bool

    /// Amount to indent the paragraph, in pixels.
    ///
    /// A negative value of indent will produce a hanging indentation.
    /// That is, the first line will have the full width, and subsequent
    /// lines will be indented by the absolute value of indent.
    @GObjectProperty(named: "indent") public var indent: Int

    /// The purpose of this text field.
    ///
    /// This property can be used by on-screen keyboards and other input
    /// methods to adjust their behaviour.
    @GObjectProperty(named: "input-purpose") public var inputPurpose: InputPurpose

    /// Left, right, or center justification.
    @GObjectProperty(named: "justification") public var justification: Justification

    /// The default left margin for text in the text view.
    ///
    /// Tags in the buffer may override the default.
    ///
    /// Note that this property is confusingly named. In CSS terms,
    /// the value set here is padding, and it is applied in addition
    /// to the padding from the theme.
    @GObjectProperty(named: "left-margin") public var leftMargin: Int

    /// Whether text should be displayed in a monospace font.
    ///
    /// If %TRUE, set the .monospace style class on the
    /// text view to indicate that a monospace font is desired.
    @GObjectProperty(named: "monospace") public var monospace: Bool

    /// Whether entered text overwrites existing contents.
    @GObjectProperty(named: "overwrite") public var overwrite: Bool

    /// Pixels of blank space above paragraphs.
    @GObjectProperty(named: "pixels-above-lines") public var pixelsAboveLines: Int

    /// Pixels of blank space below paragraphs.
    @GObjectProperty(named: "pixels-below-lines") public var pixelsBelowLines: Int

    /// Pixels of blank space between wrapped lines in a paragraph.
    @GObjectProperty(named: "pixels-inside-wrap") public var pixelsInsideWrap: Int

    /// The default right margin for text in the text view.
    ///
    /// Tags in the buffer may override the default.
    ///
    /// Note that this property is confusingly named. In CSS terms,
    /// the value set here is padding, and it is applied in addition
    /// to the padding from the theme.
    @GObjectProperty(named: "right-margin") public var rightMargin: Int

    /// The top margin for text in the text view.
    ///
    /// Note that this property is confusingly named. In CSS terms,
    /// the value set here is padding, and it is applied in addition
    /// to the padding from the theme.
    ///
    /// Don't confuse this property with [property@Gtk.Widget:margin-top].
    @GObjectProperty(named: "top-margin") public var topMargin: Int

    /// Whether to wrap lines never, at word boundaries, or at character boundaries.
    @GObjectProperty(named: "wrap-mode") public var wrapMode: WrapMode

    /// Determines when horizontal scrolling should start.
    @GObjectProperty(named: "hscroll-policy") public var hscrollPolicy: ScrollablePolicy

    /// Determines when vertical scrolling should start.
    @GObjectProperty(named: "vscroll-policy") public var vscrollPolicy: ScrollablePolicy

    /// Gets emitted when the user asks for it.
    ///
    /// The ::backspace signal is a [keybinding signal](class.SignalAction.html).
    ///
    /// The default bindings for this signal are
    /// <kbd>Backspace</kbd> and <kbd>Shift</kbd>+<kbd>Backspace</kbd>.
    public var backspace: ((TextView) -> Void)?

    /// Gets emitted to copy the selection to the clipboard.
    ///
    /// The ::copy-clipboard signal is a [keybinding signal](class.SignalAction.html).
    ///
    /// The default bindings for this signal are
    /// <kbd>Ctrl</kbd>+<kbd>c</kbd> and
    /// <kbd>Ctrl</kbd>+<kbd>Insert</kbd>.
    public var copyClipboard: ((TextView) -> Void)?

    /// Gets emitted to cut the selection to the clipboard.
    ///
    /// The ::cut-clipboard signal is a [keybinding signal](class.SignalAction.html).
    ///
    /// The default bindings for this signal are
    /// <kbd>Ctrl</kbd>+<kbd>x</kbd> and
    /// <kbd>Shift</kbd>+<kbd>Delete</kbd>.
    public var cutClipboard: ((TextView) -> Void)?

    /// Gets emitted when the user initiates a text deletion.
    ///
    /// The ::delete-from-cursor signal is a [keybinding signal](class.SignalAction.html).
    ///
    /// If the @type is %GTK_DELETE_CHARS, GTK deletes the selection
    /// if there is one, otherwise it deletes the requested number
    /// of characters.
    ///
    /// The default bindings for this signal are <kbd>Delete</kbd> for
    /// deleting a character, <kbd>Ctrl</kbd>+<kbd>Delete</kbd> for
    /// deleting a word and <kbd>Ctrl</kbd>+<kbd>Backspace</kbd> for
    /// deleting a word backwards.
    public var deleteFromCursor: ((TextView, GtkDeleteType, Int) -> Void)?

    /// Emitted when the selection needs to be extended at @location.
    public var extendSelection:
        ((TextView, GtkTextExtendSelection, GtkTextIter, GtkTextIter, GtkTextIter) -> Void)?

    /// Gets emitted when the user initiates the insertion of a
    /// fixed string at the cursor.
    ///
    /// The ::insert-at-cursor signal is a [keybinding signal](class.SignalAction.html).
    ///
    /// This signal has no default bindings.
    public var insertAtCursor: ((TextView, UnsafePointer<CChar>) -> Void)?

    /// Gets emitted to present the Emoji chooser for the @text_view.
    ///
    /// The ::insert-emoji signal is a [keybinding signal](class.SignalAction.html).
    ///
    /// The default bindings for this signal are
    /// <kbd>Ctrl</kbd>+<kbd>.</kbd> and
    /// <kbd>Ctrl</kbd>+<kbd>;</kbd>
    public var insertEmoji: ((TextView) -> Void)?

    /// Gets emitted when the user initiates a cursor movement.
    ///
    /// The ::move-cursor signal is a [keybinding signal](class.SignalAction.html).
    /// If the cursor is not visible in @text_view, this signal causes
    /// the viewport to be moved instead.
    ///
    /// Applications should not connect to it, but may emit it with
    /// g_signal_emit_by_name() if they need to control the cursor
    /// programmatically.
    ///
    ///
    /// The default bindings for this signal come in two variants,
    /// the variant with the <kbd>Shift</kbd> modifier extends the
    /// selection, the variant without it does not.
    /// There are too many key combinations to list them all here.
    ///
    /// - <kbd>←</kbd>, <kbd>→</kbd>, <kbd>↑</kbd>, <kbd>↓</kbd>
    /// move by individual characters/lines
    /// - <kbd>Ctrl</kbd>+<kbd>←</kbd>, etc. move by words/paragraphs
    /// - <kbd>Home</kbd> and <kbd>End</kbd> move to the ends of the buffer
    /// - <kbd>PgUp</kbd> and <kbd>PgDn</kbd> move vertically by pages
    /// - <kbd>Ctrl</kbd>+<kbd>PgUp</kbd> and <kbd>Ctrl</kbd>+<kbd>PgDn</kbd>
    /// move horizontally by pages
    public var moveCursor: ((TextView, GtkMovementStep, Int, Bool) -> Void)?

    /// Gets emitted to move the viewport.
    ///
    /// The ::move-viewport signal is a [keybinding signal](class.SignalAction.html),
    /// which can be bound to key combinations to allow the user to move the viewport,
    /// i.e. change what part of the text view is visible in a containing scrolled
    /// window.
    ///
    /// There are no default bindings for this signal.
    public var moveViewport: ((TextView, GtkScrollStep, Int) -> Void)?

    /// Gets emitted to paste the contents of the clipboard
    /// into the text view.
    ///
    /// The ::paste-clipboard signal is a [keybinding signal](class.SignalAction.html).
    ///
    /// The default bindings for this signal are
    /// <kbd>Ctrl</kbd>+<kbd>v</kbd> and
    /// <kbd>Shift</kbd>+<kbd>Insert</kbd>.
    public var pasteClipboard: ((TextView) -> Void)?

    /// Emitted when preedit text of the active IM changes.
    ///
    /// If an input method is used, the typed text will not immediately
    /// be committed to the buffer. So if you are interested in the text,
    /// connect to this signal.
    ///
    /// This signal is only emitted if the text at the given position
    /// is actually editable.
    public var preeditChanged: ((TextView, UnsafePointer<CChar>) -> Void)?

    /// Gets emitted when the user initiates settings the "anchor" mark.
    ///
    /// The ::set-anchor signal is a [keybinding signal](class.SignalAction.html)
    /// which gets emitted when the user initiates setting the "anchor"
    /// mark. The "anchor" mark gets placed at the same position as the
    /// "insert" mark.
    ///
    /// This signal has no default bindings.
    public var setAnchor: ((TextView) -> Void)?

    /// Gets emitted to toggle the `cursor-visible` property.
    ///
    /// The ::toggle-cursor-visible signal is a
    /// [keybinding signal](class.SignalAction.html).
    ///
    /// The default binding for this signal is <kbd>F7</kbd>.
    public var toggleCursorVisible: ((TextView) -> Void)?

    /// Gets emitted to toggle the overwrite mode of the text view.
    ///
    /// The ::toggle-overwrite signal is a [keybinding signal](class.SignalAction.html).
    ///
    /// The default binding for this signal is <kbd>Insert</kbd>.
    public var toggleOverwrite: ((TextView) -> Void)?

    public var notifyAcceptsTab: ((TextView, OpaquePointer) -> Void)?

    public var notifyBottomMargin: ((TextView, OpaquePointer) -> Void)?

    public var notifyBuffer: ((TextView, OpaquePointer) -> Void)?

    public var notifyCursorVisible: ((TextView, OpaquePointer) -> Void)?

    public var notifyEditable: ((TextView, OpaquePointer) -> Void)?

    public var notifyExtraMenu: ((TextView, OpaquePointer) -> Void)?

    public var notifyImModule: ((TextView, OpaquePointer) -> Void)?

    public var notifyIndent: ((TextView, OpaquePointer) -> Void)?

    public var notifyInputHints: ((TextView, OpaquePointer) -> Void)?

    public var notifyInputPurpose: ((TextView, OpaquePointer) -> Void)?

    public var notifyJustification: ((TextView, OpaquePointer) -> Void)?

    public var notifyLeftMargin: ((TextView, OpaquePointer) -> Void)?

    public var notifyMonospace: ((TextView, OpaquePointer) -> Void)?

    public var notifyOverwrite: ((TextView, OpaquePointer) -> Void)?

    public var notifyPixelsAboveLines: ((TextView, OpaquePointer) -> Void)?

    public var notifyPixelsBelowLines: ((TextView, OpaquePointer) -> Void)?

    public var notifyPixelsInsideWrap: ((TextView, OpaquePointer) -> Void)?

    public var notifyRightMargin: ((TextView, OpaquePointer) -> Void)?

    public var notifyTabs: ((TextView, OpaquePointer) -> Void)?

    public var notifyTopMargin: ((TextView, OpaquePointer) -> Void)?

    public var notifyWrapMode: ((TextView, OpaquePointer) -> Void)?

    public var notifyHadjustment: ((TextView, OpaquePointer) -> Void)?

    public var notifyHscrollPolicy: ((TextView, OpaquePointer) -> Void)?

    public var notifyVadjustment: ((TextView, OpaquePointer) -> Void)?

    public var notifyVscrollPolicy: ((TextView, OpaquePointer) -> Void)?
}
