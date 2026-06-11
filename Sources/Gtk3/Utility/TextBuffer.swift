import CGtk3

/// You may wish to begin by reading the
/// [text widget conceptual overview](TextWidget.html)
/// which gives an overview of all the objects and data
/// types related to the text widget and how they work together.
open class TextBuffer: GObject {
    /// Creates a new text buffer.
    public convenience init(table: UnsafeMutablePointer<_GtkTextTagTable>?) {
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

        // addSignal(name: "insert-pixbuf", handler: gCallback(handler6)) {
        //     [weak self] (param0: GtkTextIter, param1: OpaquePointer) in
        //     guard let self else { return }
        //     self.insertPixbuf?(self, param0, param1)
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
        //         UnsafeMutableRawPointer, GtkTextMark, UnsafeMutableRawPointer
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
        //         UnsafeMutableRawPointer, GtkTextIter, GtkTextMark, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, value2, data in
        //             SignalBox2<GtkTextIter, GtkTextMark>.run(data, value1, value2)
        //         }

        // addSignal(name: "mark-set", handler: gCallback(handler9)) {
        //     [weak self] (param0: GtkTextIter, param1: GtkTextMark) in
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

        // let handler12:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, GtkTextTag, GtkTextIter, GtkTextIter,
        //         UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, value2, value3, data in
        //             SignalBox3<GtkTextTag, GtkTextIter, GtkTextIter>.run(
        //                 data, value1, value2, value3)
        //         }

        // addSignal(name: "remove-tag", handler: gCallback(handler12)) {
        //     [weak self] (param0: GtkTextTag, param1: GtkTextIter, param2: GtkTextIter) in
        //     guard let self else { return }
        //     self.removeTag?(self, param0, param1, param2)
        // }

        // let handler13:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<OpaquePointer>.run(data, value1)
        //         }

        // addSignal(name: "notify::copy-target-list", handler: gCallback(handler13)) {
        //     [weak self] (param0: OpaquePointer) in
        //     guard let self else { return }
        //     self.notifyCopyTargetList?(self, param0)
        // }

        // let handler14:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<OpaquePointer>.run(data, value1)
        //         }

        // addSignal(name: "notify::cursor-position", handler: gCallback(handler14)) {
        //     [weak self] (param0: OpaquePointer) in
        //     guard let self else { return }
        //     self.notifyCursorPosition?(self, param0)
        // }

        // let handler15:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<OpaquePointer>.run(data, value1)
        //         }

        // addSignal(name: "notify::has-selection", handler: gCallback(handler15)) {
        //     [weak self] (param0: OpaquePointer) in
        //     guard let self else { return }
        //     self.notifyHasSelection?(self, param0)
        // }

        // let handler16:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<OpaquePointer>.run(data, value1)
        //         }

        // addSignal(name: "notify::paste-target-list", handler: gCallback(handler16)) {
        //     [weak self] (param0: OpaquePointer) in
        //     guard let self else { return }
        //     self.notifyPasteTargetList?(self, param0)
        // }

        // let handler17:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<OpaquePointer>.run(data, value1)
        //         }

        // addSignal(name: "notify::tag-table", handler: gCallback(handler17)) {
        //     [weak self] (param0: OpaquePointer) in
        //     guard let self else { return }
        //     self.notifyTagTable?(self, param0)
        // }

        // let handler18:
        //     @convention(c) (
        //         UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer
        //     ) -> Void =
        //         { _, value1, data in
        //             SignalBox1<OpaquePointer>.run(data, value1)
        //         }

        // addSignal(name: "notify::text", handler: gCallback(handler18)) {
        //     [weak self] (param0: OpaquePointer) in
        //     guard let self else { return }
        //     self.notifyText?(self, param0)
        // }
    }

    @GObjectProperty(named: "text") public var text: String

    // /// The ::apply-tag signal is emitted to apply a tag to a
    // /// range of text in a #GtkTextBuffer.
    // /// Applying actually occurs in the default handler.
    // ///
    // /// Note that if your handler runs before the default handler it must not
    // /// invalidate the @start and @end iters (or has to revalidate them).
    // ///
    // /// See also:
    // /// gtk_text_buffer_apply_tag(),
    // /// gtk_text_buffer_insert_with_tags(),
    // /// gtk_text_buffer_insert_range().
    // public var applyTag: ((TextBuffer, GtkTextTag, GtkTextIter, GtkTextIter) -> Void)?

    // /// The ::begin-user-action signal is emitted at the beginning of a single
    // /// user-visible operation on a #GtkTextBuffer.
    // ///
    // /// See also:
    // /// gtk_text_buffer_begin_user_action(),
    // /// gtk_text_buffer_insert_interactive(),
    // /// gtk_text_buffer_insert_range_interactive(),
    // /// gtk_text_buffer_delete_interactive(),
    // /// gtk_text_buffer_backspace(),
    // /// gtk_text_buffer_delete_selection().
    // public var beginUserAction: ((TextBuffer) -> Void)?

    /// The ::changed signal is emitted when the content of a #GtkTextBuffer
    /// has changed.
    public var changed: ((TextBuffer) -> Void)?

    // /// The ::delete-range signal is emitted to delete a range
    // /// from a #GtkTextBuffer.
    // ///
    // /// Note that if your handler runs before the default handler it must not
    // /// invalidate the @start and @end iters (or has to revalidate them).
    // /// The default signal handler revalidates the @start and @end iters to
    // /// both point to the location where text was deleted. Handlers
    // /// which run after the default handler (see g_signal_connect_after())
    // /// do not have access to the deleted text.
    // ///
    // /// See also: gtk_text_buffer_delete().
    // public var deleteRange: ((TextBuffer, GtkTextIter, GtkTextIter) -> Void)?

    // /// The ::end-user-action signal is emitted at the end of a single
    // /// user-visible operation on the #GtkTextBuffer.
    // ///
    // /// See also:
    // /// gtk_text_buffer_end_user_action(),
    // /// gtk_text_buffer_insert_interactive(),
    // /// gtk_text_buffer_insert_range_interactive(),
    // /// gtk_text_buffer_delete_interactive(),
    // /// gtk_text_buffer_backspace(),
    // /// gtk_text_buffer_delete_selection(),
    // /// gtk_text_buffer_backspace().
    // public var endUserAction: ((TextBuffer) -> Void)?

    // /// The ::insert-child-anchor signal is emitted to insert a
    // /// #GtkTextChildAnchor in a #GtkTextBuffer.
    // /// Insertion actually occurs in the default handler.
    // ///
    // /// Note that if your handler runs before the default handler it must
    // /// not invalidate the @location iter (or has to revalidate it).
    // /// The default signal handler revalidates it to be placed after the
    // /// inserted @anchor.
    // ///
    // /// See also: gtk_text_buffer_insert_child_anchor().
    // public var insertChildAnchor: ((TextBuffer, GtkTextIter, GtkTextChildAnchor) -> Void)?

    // /// The ::insert-pixbuf signal is emitted to insert a #GdkPixbuf
    // /// in a #GtkTextBuffer. Insertion actually occurs in the default handler.
    // ///
    // /// Note that if your handler runs before the default handler it must not
    // /// invalidate the @location iter (or has to revalidate it).
    // /// The default signal handler revalidates it to be placed after the
    // /// inserted @pixbuf.
    // ///
    // /// See also: gtk_text_buffer_insert_pixbuf().
    // public var insertPixbuf: ((TextBuffer, GtkTextIter, OpaquePointer) -> Void)?

    // /// The ::insert-text signal is emitted to insert text in a #GtkTextBuffer.
    // /// Insertion actually occurs in the default handler.
    // ///
    // /// Note that if your handler runs before the default handler it must not
    // /// invalidate the @location iter (or has to revalidate it).
    // /// The default signal handler revalidates it to point to the end of the
    // /// inserted text.
    // ///
    // /// See also:
    // /// gtk_text_buffer_insert(),
    // /// gtk_text_buffer_insert_range().
    // public var insertText: ((TextBuffer, GtkTextIter, UnsafePointer<CChar>, Int) -> Void)?

    // /// The ::mark-deleted signal is emitted as notification
    // /// after a #GtkTextMark is deleted.
    // ///
    // /// See also:
    // /// gtk_text_buffer_delete_mark().
    // public var markDeleted: ((TextBuffer, GtkTextMark) -> Void)?

    // /// The ::mark-set signal is emitted as notification
    // /// after a #GtkTextMark is set.
    // ///
    // /// See also:
    // /// gtk_text_buffer_create_mark(),
    // /// gtk_text_buffer_move_mark().
    // public var markSet: ((TextBuffer, GtkTextIter, GtkTextMark) -> Void)?

    // /// The ::modified-changed signal is emitted when the modified bit of a
    // /// #GtkTextBuffer flips.
    // ///
    // /// See also:
    // /// gtk_text_buffer_set_modified().
    // public var modifiedChanged: ((TextBuffer) -> Void)?

    // /// The paste-done signal is emitted after paste operation has been completed.
    // /// This is useful to properly scroll the view to the end of the pasted text.
    // /// See gtk_text_buffer_paste_clipboard() for more details.
    // public var pasteDone: ((TextBuffer, OpaquePointer) -> Void)?

    // /// The ::remove-tag signal is emitted to remove all occurrences of @tag from
    // /// a range of text in a #GtkTextBuffer.
    // /// Removal actually occurs in the default handler.
    // ///
    // /// Note that if your handler runs before the default handler it must not
    // /// invalidate the @start and @end iters (or has to revalidate them).
    // ///
    // /// See also:
    // /// gtk_text_buffer_remove_tag().
    // public var removeTag: ((TextBuffer, GtkTextTag, GtkTextIter, GtkTextIter) -> Void)?

    // public var notifyCopyTargetList: ((TextBuffer, OpaquePointer) -> Void)?

    // public var notifyCursorPosition: ((TextBuffer, OpaquePointer) -> Void)?

    // public var notifyHasSelection: ((TextBuffer, OpaquePointer) -> Void)?

    // public var notifyPasteTargetList: ((TextBuffer, OpaquePointer) -> Void)?

    // public var notifyTagTable: ((TextBuffer, OpaquePointer) -> Void)?

    // public var notifyText: ((TextBuffer, OpaquePointer) -> Void)?
}
