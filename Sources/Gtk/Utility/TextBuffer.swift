import CGtk

/// Stores text and attributes for display in a `GtkTextView`.
///
/// You may wish to begin by reading the
/// [text widget conceptual overview](section-text-widget.html),
/// which gives an overview of all the objects and data types
/// related to the text widget and how they work together.
///
/// GtkTextBuffer can support undoing changes to the buffer
/// content, see [method@Gtk.TextBuffer.set_enable_undo].
open class TextBuffer: GObject {
    /// Creates a new text buffer.
    public convenience init(table: OpaquePointer?) {
        self.init(
            gtk_text_buffer_new(table)
        )
        // Not a widget so we just register signals at creation.
        registerSignals()
    }

    public override func registerSignals() {
        super.registerSignals()

        // I've commented out all signals we don't use because many of
        // them are causing crashes on Linux. I believe it's because
        // The GtkTextTag and GtkTextIter types should be wrapped in pointers
        // (even though they work both ways on macOS with and without being pointers).

        // let handler0:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, GtkTextTag, GtkTextIter, GtkTextIter,
        //         UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, value2, value3, data in
        //             SignalBox3<GtkTextTag, GtkTextIter, GtkTextIter>.run(
        //                 data, value1, value2, value3)
        //         }

        // addSignal(name: "apply-tag", handler: gCallback(handler0)) {
        //     [weak self] (param0: GtkTextTag, param1: GtkTextIter, param2: GtkTextIter) in
        //     guard let self else { return }
        //     self.applyTag?(self, param0, param1, param2)
        // }

        // addSignal(name: "begin-user-action") { [weak self] () in
        //     guard let self else { return }
        //     self.beginUserAction?(self)
        // }

        addSignal(name: "changed") { [weak self] () in
            guard let self else { return }
            self.changed?(self)
        }

        // let handler3:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, GtkTextIter, GtkTextIter, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, value2, data in
        //             SignalBox2<GtkTextIter, GtkTextIter>.run(data, value1, value2)
        //         }

        // addSignal(name: "delete-range", handler: gCallback(handler3)) {
        //     [weak self] (param0: GtkTextIter, param1: GtkTextIter) in
        //     guard let self else { return }
        //     self.deleteRange?(self, param0, param1)
        // }

        // addSignal(name: "end-user-action") { [weak self] () in
        //     guard let self else { return }
        //     self.endUserAction?(self)
        // }

        // let handler5:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, GtkTextIter, GtkTextChildAnchor, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, value2, data in
        //             SignalBox2<GtkTextIter, GtkTextChildAnchor>.run(data, value1, value2)
        //         }

        // addSignal(name: "insert-child-anchor", handler: gCallback(handler5)) {
        //     [weak self] (param0: GtkTextIter, param1: GtkTextChildAnchor) in
        //     guard let self else { return }
        //     self.insertChildAnchor?(self, param0, param1)
        // }

        // let handler6:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, GtkTextIter, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, value2, data in
        //             SignalBox2<GtkTextIter, OpaquePointer>.run(data, value1, value2)
        //         }

        // addSignal(name: "insert-paintable", handler: gCallback(handler6)) {
        //     [weak self] (param0: GtkTextIter, param1: OpaquePointer) in
        //     guard let self else { return }
        //     self.insertPaintable?(self, param0, param1)
        // }

        // let handler7:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, GtkTextIter, UnsafePointer<CChar>, Int,
        //         UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, value2, value3, data in
        //             SignalBox3<GtkTextIter, UnsafePointer<CChar>, Int>.run(
        //                 data, value1, value2, value3)
        //         }

        // addSignal(name: "insert-text", handler: gCallback(handler7)) {
        //     [weak self] (param0: GtkTextIter, param1: UnsafePointer<CChar>, param2: Int) in
        //     guard let self else { return }
        //     self.insertText?(self, param0, param1, param2)
        // }

        // let handler8:
        //     @convention(c) (
        //        UnsafeMutableRawPointer, GtkTextMark, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<GtkTextMark>.run(data, value1)
        //         }

        // addSignal(name: "mark-deleted", handler: gCallback(handler8)) {
        //     [weak self] (param0: GtkTextMark) in
        //     guard let self else { return }
        //     self.markDeleted?(self, param0)
        // }

        // let handler9:
        //     @convention(c) (
        //         UnsafeMutableRawPointer,
        //         UnsafeMutablePointer<GtkTextIter>,
        //         UnsafeMutablePointer<GtkTextMark>,
        //         UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, value2, data in
        //             SignalBox2<
        //                 UnsafeMutablePointer<GtkTextIter>,
        //                 UnsafeMutablePointer<GtkTextMark>
        //             >.run(data, value1, value2)
        //         }

        // addSignal(name: "mark-set", handler: gCallback(handler9)) {
        //     [weak self] (
        //         param0: UnsafeMutablePointer<GtkTextIter>,
        //         param1: UnsafeMutablePointer<GtkTextMark>
        //     ) in
        //     guard let self else { return }
        //     self.markSet?(self, param0, param1)
        // }

        // addSignal(name: "modified-changed") { [weak self] () in
        //     guard let self else { return }
        //     self.modifiedChanged?(self)
        // }

        // let handler11:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<OpaquePointer>.run(data, value1)
        //         }

        // addSignal(name: "paste-done", handler: gCallback(handler11)) {
        //     [weak self] (param0: OpaquePointer) in
        //     guard let self else { return }
        //     self.pasteDone?(self, param0)
        // }

        // addSignal(name: "redo") { [weak self] () in
        //     guard let self else { return }
        //     self.redo?(self)
        // }

        // let handler13:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, GtkTextTag, GtkTextIter, GtkTextIter,
        //         UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, value2, value3, data in
        //             SignalBox3<GtkTextTag, GtkTextIter, GtkTextIter>.run(
        //                 data, value1, value2, value3)
        //         }

        // addSignal(name: "remove-tag", handler: gCallback(handler13)) {
        //     [weak self] (param0: GtkTextTag, param1: GtkTextIter, param2: GtkTextIter) in
        //     guard let self else { return }
        //     self.removeTag?(self, param0, param1, param2)
        // }

        // addSignal(name: "undo") { [weak self] () in
        //     guard let self else { return }
        //     self.undo?(self)
        // }

        // let handler15:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<OpaquePointer>.run(data, value1)
        //         }

        // addSignal(name: "notify::can-redo", handler: gCallback(handler15)) {
        //     [weak self] (param0: OpaquePointer) in
        //     guard let self else { return }
        //     self.notifyCanRedo?(self, param0)
        // }

        // let handler16:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<OpaquePointer>.run(data, value1)
        //         }

        // addSignal(name: "notify::can-undo", handler: gCallback(handler16)) {
        //     [weak self] (param0: OpaquePointer) in
        //     guard let self else { return }
        //     self.notifyCanUndo?(self, param0)
        // }

        // let handler17:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<OpaquePointer>.run(data, value1)
        //         }

        // addSignal(name: "notify::cursor-position", handler: gCallback(handler17)) {
        //     [weak self] (param0: OpaquePointer) in
        //     guard let self else { return }
        //     self.notifyCursorPosition?(self, param0)
        // }

        // let handler18:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<OpaquePointer>.run(data, value1)
        //         }

        // addSignal(name: "notify::enable-undo", handler: gCallback(handler18)) {
        //     [weak self] (param0: OpaquePointer) in
        //     guard let self else { return }
        //     self.notifyEnableUndo?(self, param0)
        // }

        // let handler19:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<OpaquePointer>.run(data, value1)
        //         }

        // addSignal(name: "notify::has-selection", handler: gCallback(handler19)) {
        //     [weak self] (param0: OpaquePointer) in
        //     guard let self else { return }
        //     self.notifyHasSelection?(self, param0)
        // }

        // let handler20:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<OpaquePointer>.run(data, value1)
        //         }

        // addSignal(name: "notify::tag-table", handler: gCallback(handler20)) {
        //     [weak self] (param0: OpaquePointer) in
        //     guard let self else { return }
        //     self.notifyTagTable?(self, param0)
        // }

        // let handler21:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<OpaquePointer>.run(data, value1)
        //         }

        // addSignal(name: "notify::text", handler: gCallback(handler21)) {
        //     [weak self] (param0: OpaquePointer) in
        //     guard let self else { return }
        //     self.notifyText?(self, param0)
        // }
    }

    /// Denotes that the buffer can reapply the last undone action.
    @GObjectProperty(named: "can-redo") public var canRedo: Bool

    /// Denotes that the buffer can undo the last applied action.
    @GObjectProperty(named: "can-undo") public var canUndo: Bool

    /// Denotes if support for undoing and redoing changes to the buffer is allowed.
    @GObjectProperty(named: "enable-undo") public var enableUndo: Bool

    /// Whether the buffer has some text currently selected.
    @GObjectProperty(named: "has-selection") public var hasSelection: Bool

    /// The text content of the buffer.
    ///
    /// Without child widgets and images,
    /// see [method@Gtk.TextBuffer.get_text] for more information.
    @GObjectProperty(named: "text") public var text: String

    // /// Emitted to apply a tag to a range of text in a `GtkTextBuffer`.
    // ///
    // /// Applying actually occurs in the default handler.
    // ///
    // /// Note that if your handler runs before the default handler
    // /// it must not invalidate the @start and @end iters (or has to
    // /// revalidate them).
    // ///
    // /// See also:
    // /// [method@Gtk.TextBuffer.apply_tag],
    // /// [method@Gtk.TextBuffer.insert_with_tags],
    // /// [method@Gtk.TextBuffer.insert_range].
    // public var applyTag: ((TextBuffer, GtkTextTag, GtkTextIter, GtkTextIter) -> Void)?

    // /// Emitted at the beginning of a single user-visible
    // /// operation on a `GtkTextBuffer`.
    // ///
    // /// See also:
    // /// [method@Gtk.TextBuffer.begin_user_action],
    // /// [method@Gtk.TextBuffer.insert_interactive],
    // /// [method@Gtk.TextBuffer.insert_range_interactive],
    // /// [method@Gtk.TextBuffer.delete_interactive],
    // /// [method@Gtk.TextBuffer.backspace],
    // /// [method@Gtk.TextBuffer.delete_selection].
    // public var beginUserAction: ((TextBuffer) -> Void)?

    /// Emitted when the content of a `GtkTextBuffer` has changed.
    public var changed: ((TextBuffer) -> Void)?

    // /// Emitted to delete a range from a `GtkTextBuffer`.
    // ///
    // /// Note that if your handler runs before the default handler
    // /// it must not invalidate the @start and @end iters (or has
    // /// to revalidate them). The default signal handler revalidates
    // /// the @start and @end iters to both point to the location
    // /// where text was deleted. Handlers which run after the default
    // /// handler (see g_signal_connect_after()) do not have access to
    // /// the deleted text.
    // ///
    // /// See also: [method@Gtk.TextBuffer.delete].
    // public var deleteRange: ((TextBuffer, GtkTextIter, GtkTextIter) -> Void)?

    // /// Emitted at the end of a single user-visible
    // /// operation on the `GtkTextBuffer`.
    // ///
    // /// See also:
    // /// [method@Gtk.TextBuffer.end_user_action],
    // /// [method@Gtk.TextBuffer.insert_interactive],
    // /// [method@Gtk.TextBuffer.insert_range_interactive],
    // /// [method@Gtk.TextBuffer.delete_interactive],
    // /// [method@Gtk.TextBuffer.backspace],
    // /// [method@Gtk.TextBuffer.delete_selection],
    // /// [method@Gtk.TextBuffer.backspace].
    // public var endUserAction: ((TextBuffer) -> Void)?

    // /// Emitted to insert a `GtkTextChildAnchor` in a `GtkTextBuffer`.
    // ///
    // /// Insertion actually occurs in the default handler.
    // ///
    // /// Note that if your handler runs before the default handler
    // /// it must not invalidate the @location iter (or has to
    // /// revalidate it). The default signal handler revalidates
    // /// it to be placed after the inserted @anchor.
    // ///
    // /// See also: [method@Gtk.TextBuffer.insert_child_anchor].
    // public var insertChildAnchor: ((TextBuffer, GtkTextIter, GtkTextChildAnchor) -> Void)?

    // /// Emitted to insert a `GdkPaintable` in a `GtkTextBuffer`.
    // ///
    // /// Insertion actually occurs in the default handler.
    // ///
    // /// Note that if your handler runs before the default handler
    // /// it must not invalidate the @location iter (or has to
    // /// revalidate it). The default signal handler revalidates
    // /// it to be placed after the inserted @paintable.
    // ///
    // /// See also: [method@Gtk.TextBuffer.insert_paintable].
    // public var insertPaintable: ((TextBuffer, GtkTextIter, OpaquePointer) -> Void)?

    // /// Emitted to insert text in a `GtkTextBuffer`.
    // ///
    // /// Insertion actually occurs in the default handler.
    // ///
    // /// Note that if your handler runs before the default handler
    // /// it must not invalidate the @location iter (or has to
    // /// revalidate it). The default signal handler revalidates
    // /// it to point to the end of the inserted text.
    // ///
    // /// See also: [method@Gtk.TextBuffer.insert],
    // /// [method@Gtk.TextBuffer.insert_range].
    // public var insertText: ((TextBuffer, GtkTextIter, UnsafePointer<CChar>, Int) -> Void)?

    // /// Emitted as notification after a `GtkTextMark` is deleted.
    // ///
    // /// See also: [method@Gtk.TextBuffer.delete_mark].
    // public var markDeleted: ((TextBuffer, GtkTextMark) -> Void)?

    // /// Emitted as notification after a `GtkTextMark` is set.
    // ///
    // /// See also:
    // /// [method@Gtk.TextBuffer.create_mark],
    // /// [method@Gtk.TextBuffer.move_mark].
    // public var markSet: ((
    //    TextBuffer,
    //    UnsafeMutablePointer<GtkTextIter>,
    //    UnsafeMutablePointer<GtkTextMark>
    // ) -> Void)?

    // /// Emitted when the modified bit of a `GtkTextBuffer` flips.
    // ///
    // /// See also: [method@Gtk.TextBuffer.set_modified].
    // public var modifiedChanged: ((TextBuffer) -> Void)?

    // /// Emitted after paste operation has been completed.
    // ///
    // /// This is useful to properly scroll the view to the end
    // /// of the pasted text. See [method@Gtk.TextBuffer.paste_clipboard]
    // /// for more details.
    // public var pasteDone: ((TextBuffer, OpaquePointer) -> Void)?

    // /// Emitted when a request has been made to redo the
    // /// previously undone operation.
    // public var redo: ((TextBuffer) -> Void)?

    // /// Emitted to remove all occurrences of @tag from a range
    // /// of text in a `GtkTextBuffer`.
    // ///
    // /// Removal actually occurs in the default handler.
    // ///
    // /// Note that if your handler runs before the default handler
    // /// it must not invalidate the @start and @end iters (or has
    // /// to revalidate them).
    // ///
    // /// See also: [method@Gtk.TextBuffer.remove_tag].
    // public var removeTag: ((TextBuffer, GtkTextTag, GtkTextIter, GtkTextIter) -> Void)?

    // /// Emitted when a request has been made to undo the
    // /// previous operation or set of operations that have
    // /// been grouped together.
    // public var undo: ((TextBuffer) -> Void)?

    // public var notifyCanRedo: ((TextBuffer, OpaquePointer) -> Void)?

    // public var notifyCanUndo: ((TextBuffer, OpaquePointer) -> Void)?

    // public var notifyCursorPosition: ((TextBuffer, OpaquePointer) -> Void)?

    // public var notifyEnableUndo: ((TextBuffer, OpaquePointer) -> Void)?

    // public var notifyHasSelection: ((TextBuffer, OpaquePointer) -> Void)?

    // public var notifyTagTable: ((TextBuffer, OpaquePointer) -> Void)?

    // public var notifyText: ((TextBuffer, OpaquePointer) -> Void)?
}
