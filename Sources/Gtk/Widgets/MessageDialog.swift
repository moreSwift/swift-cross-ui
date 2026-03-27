import CGtk
import GtkCHelpers

/// `GtkMessageDialog` presents a dialog with some message text.
///
/// ![An example GtkMessageDialog](messagedialog.png)
///
/// It’s simply a convenience widget; you could construct the equivalent of
/// `GtkMessageDialog` from `GtkDialog` without too much effort, but
/// `GtkMessageDialog` saves typing.
///
/// The easiest way to do a modal message dialog is to use the %GTK_DIALOG_MODAL
/// flag, which will call [method@Gtk.Window.set_modal] internally. The dialog will
/// prevent interaction with the parent window until it's hidden or destroyed.
/// You can use the [signal@Gtk.Dialog::response] signal to know when the user
/// dismissed the dialog.
///
/// An example for using a modal dialog:
/// ```c
/// GtkDialogFlags flags = GTK_DIALOG_DESTROY_WITH_PARENT | GTK_DIALOG_MODAL;
/// dialog = gtk_message_dialog_new (parent_window,
/// flags,
/// GTK_MESSAGE_ERROR,
/// GTK_BUTTONS_CLOSE,
/// "Error reading “%s”: %s",
/// filename,
/// g_strerror (errno));
/// // Destroy the dialog when the user responds to it
/// // (e.g. clicks a button)
///
/// g_signal_connect (dialog, "response",
/// G_CALLBACK (gtk_window_destroy),
/// NULL);
/// ```
///
/// You might do a non-modal `GtkMessageDialog` simply by omitting the
/// %GTK_DIALOG_MODAL flag:
///
/// ```c
/// GtkDialogFlags flags = GTK_DIALOG_DESTROY_WITH_PARENT;
/// dialog = gtk_message_dialog_new (parent_window,
/// flags,
/// GTK_MESSAGE_ERROR,
/// GTK_BUTTONS_CLOSE,
/// "Error reading “%s”: %s",
/// filename,
/// g_strerror (errno));
///
/// // Destroy the dialog when the user responds to it
/// // (e.g. clicks a button)
/// g_signal_connect (dialog, "response",
/// G_CALLBACK (gtk_window_destroy),
/// NULL);
/// ```
///
/// # GtkMessageDialog as GtkBuildable
///
/// The `GtkMessageDialog` implementation of the `GtkBuildable` interface exposes
/// the message area as an internal child with the name “message_area”.
public class MessageDialog: Dialog {
    public convenience init() {
        self.init(wrapped_gtk_message_dialog_new())
    }

    @GObjectProperty(named: "text") public var text: String

    override func registerSignalHandlers() {
        super.registerSignalHandlers()

        let handler0:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::buttons", handler: gCallback(handler0)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyButtons?(self)
        }

        let handler1:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::message-area", handler: gCallback(handler1)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyMessageArea?(self)
        }

        let handler2:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::message-type", handler: gCallback(handler2)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyMessageType?(self)
        }

        let handler3:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::secondary-text", handler: gCallback(handler3)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifySecondaryText?(self)
        }

        let handler4:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::secondary-use-markup", handler: gCallback(handler4)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifySecondaryUseMarkup?(self)
        }

        let handler5:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::text", handler: gCallback(handler5)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyText?(self)
        }

        let handler6:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer) -> Void =
                { _, value1, data in
                    SignalBox1<OpaquePointer>.run(data, value1)
                }

        addSignal(name: "notify::use-markup", handler: gCallback(handler6)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyUseMarkup?(self)
        }
    }

    public var notifyButtons: ((MessageDialog) -> Void)?

    public var notifyMessageArea: ((MessageDialog) -> Void)?

    public var notifyMessageType: ((MessageDialog) -> Void)?

    public var notifySecondaryText: ((MessageDialog) -> Void)?

    public var notifySecondaryUseMarkup: ((MessageDialog) -> Void)?

    public var notifyText: ((MessageDialog) -> Void)?

    public var notifyUseMarkup: ((MessageDialog) -> Void)?
}
