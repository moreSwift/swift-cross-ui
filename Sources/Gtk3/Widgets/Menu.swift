import CGtk3

// This generated file was converted to a manual one cause it needs special treatment
// that would be kinda annoying to add to GtkCodeGen just for this one type. The main
// issue is that Menus don't really get added to containers so `didMoveToParent` never
// gets called and the signals never get activated. I've moved all the signal handler
// registration into the initializer.

/// A #GtkMenu is a #GtkMenuShell that implements a drop down menu
/// consisting of a list of #GtkMenuItem objects which can be navigated
/// and activated by the user to perform application functions.
///
/// A #GtkMenu is most commonly dropped down by activating a
/// #GtkMenuItem in a #GtkMenuBar or popped up by activating a
/// #GtkMenuItem in another #GtkMenu.
///
/// A #GtkMenu can also be popped up by activating a #GtkComboBox.
/// Other composite widgets such as the #GtkNotebook can pop up a
/// #GtkMenu as well.
///
/// Applications can display a #GtkMenu as a popup menu by calling the
/// gtk_menu_popup() function.  The example below shows how an application
/// can pop up a menu when the 3rd mouse button is pressed.
///
/// ## Connecting the popup signal handler.
///
/// |[<!-- language="C" -->
/// // connect our handler which will popup the menu
/// g_signal_connect_swapped (window, "button_press_event",
/// G_CALLBACK (my_popup_handler), menu);
/// ]|
///
/// ## Signal handler which displays a popup menu.
///
/// |[<!-- language="C" -->
/// static gint
/// my_popup_handler (GtkWidget *widget, GdkEvent *event)
/// {
/// GtkMenu *menu;
/// GdkEventButton *event_button;
///
/// g_return_val_if_fail (widget != NULL, FALSE);
/// g_return_val_if_fail (GTK_IS_MENU (widget), FALSE);
/// g_return_val_if_fail (event != NULL, FALSE);
///
/// // The "widget" is the menu that was supplied when
/// // g_signal_connect_swapped() was called.
/// menu = GTK_MENU (widget);
///
/// if (event->type == GDK_BUTTON_PRESS)
/// {
/// event_button = (GdkEventButton *) event;
/// if (event_button->button == GDK_BUTTON_SECONDARY)
/// {
/// gtk_menu_popup (menu, NULL, NULL, NULL, NULL,
/// event_button->button, event_button->time);
/// return TRUE;
/// }
/// }
///
/// return FALSE;
/// }
/// ]|
///
/// # CSS nodes
///
/// |[<!-- language="plain" -->
/// menu
/// ├── arrow.top
/// ├── <child>┊
/// ├── <child>╰── arrow.bottom
/// ]|
///
/// The main CSS node of GtkMenu has name menu, and there are two subnodes
/// with name arrow, for scrolling menu arrows. These subnodes get the
/// .top and .bottom style classes.
public class Menu: MenuShell {
    /// Creates a new #GtkMenu
    public convenience init() {
        self.init(gtk_menu_new())
    }

    /// Creates a #GtkMenu and populates it with menu items and
    /// submenus according to @model.
    ///
    /// The created menu items are connected to actions found in the
    /// #GtkApplicationWindow to which the menu belongs - typically
    /// by means of being attached to a widget (see gtk_menu_attach_to_widget())
    /// that is contained within the #GtkApplicationWindows widget hierarchy.
    ///
    /// Actions can also be added using gtk_widget_insert_action_group() on the menu's
    /// attach widget or on any of its parent widgets.
    public convenience init(model: UnsafeMutablePointer<GMenuModel>!) {
        self.init(gtk_menu_new_from_model(model))
    }

    public func bindModel(_ model: GMenu) {
        gtk_menu_shell_bind_model(
            castedPointer(),
            UnsafeMutablePointer(model.pointer),
            nil,
            false.toGBoolean()
        )
    }

    public func popUpAtWidget(_ widget: Widget, relativePosition: SIMD2<Int>) {
        setProperty(named: "rect-anchor-dx", newValue: relativePosition.x)
        setProperty(named: "rect-anchor-dy", newValue: relativePosition.y)
        gtk_menu_popup_at_widget(
            castedPointer(),
            widget.widgetPointer,
            GDK_GRAVITY_NORTH_WEST,
            GDK_GRAVITY_NORTH_WEST,
            nil
        )

        registerSignalHandlers()
    }

    public func popUpAtPointer() {
        gtk_menu_popup_at_pointer(castedPointer(), nil)

        // Since the menu doesn't really get added to a parent widget, we just add
        // the signal handlers when popping it up. If we add the signal handlers
        // any earlier then they don't work.
        registerSignalHandlers()
    }

    private func registerSignalHandlers() {
        addSignal(name: "hide") { [weak self] in
            guard let self else { return }
            self.onHide?()
        }

        let handler0:
            @convention(c) (UnsafeMutableRawPointer, GtkScrollType, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<GtkScrollType>.run(data, value1)
            }

        addSignal(name: "move-scroll", handler: gCallback(handler0)) {
            [weak self] (_: GtkScrollType) in
            guard let self else { return }
            self.moveScroll?(self)
        }

        let handler1:
            @convention(c) (
                UnsafeMutableRawPointer,
                gpointer,
                gpointer,
                Bool,
                Bool,
                UnsafeMutableRawPointer
            ) -> Void =
            { _, value1, value2, value3, value4, data in
                SignalBox4<gpointer, gpointer, Bool, Bool>.run(
                    data,
                    value1,
                    value2,
                    value3,
                    value4
                )
            }

        addSignal(name: "popped-up", handler: gCallback(handler1)) {
            [weak self] (_: gpointer, _: gpointer, _: Bool, _: Bool) in
            guard let self else { return }
            self.poppedUp?(self)
        }

        let handler2:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::accel-group", handler: gCallback(handler2)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyAccelGroup?(self)
        }

        let handler3:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::accel-path", handler: gCallback(handler3)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyAccelPath?(self)
        }

        let handler4:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::active", handler: gCallback(handler4)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyActive?(self)
        }

        let handler5:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::anchor-hints", handler: gCallback(handler5)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyAnchorHints?(self)
        }

        let handler6:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::attach-widget", handler: gCallback(handler6)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyAttachWidget?(self)
        }

        let handler7:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::menu-type-hint", handler: gCallback(handler7)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyMenuTypeHint?(self)
        }

        let handler8:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::monitor", handler: gCallback(handler8)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyMonitor?(self)
        }

        let handler9:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::rect-anchor-dx", handler: gCallback(handler9)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyRectAnchorDx?(self)
        }

        let handler10:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::rect-anchor-dy", handler: gCallback(handler10)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyRectAnchorDy?(self)
        }

        let handler11:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::reserve-toggle-size", handler: gCallback(handler11)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyReserveToggleSize?(self)
        }

        let handler12:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::tearoff-state", handler: gCallback(handler12)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyTearoffState?(self)
        }

        let handler13:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::tearoff-title", handler: gCallback(handler13)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyTearoffTitle?(self)
        }
    }

    /// Runs whenever the menu gets 'popped down'.
    public var onHide: (() -> Void)?

    public var moveScroll: ((Menu) -> Void)?

    /// Emitted when the position of @menu is finalized after being popped up
    /// using gtk_menu_popup_at_rect (), gtk_menu_popup_at_widget (), or
    /// gtk_menu_popup_at_pointer ().
    ///
    /// @menu might be flipped over the anchor rectangle in order to keep it
    /// on-screen, in which case @flipped_x and @flipped_y will be set to %TRUE
    /// accordingly.
    ///
    /// @flipped_rect is the ideal position of @menu after any possible flipping,
    /// but before any possible sliding. @final_rect is @flipped_rect, but possibly
    /// translated in the case that flipping is still ineffective in keeping @menu
    /// on-screen.
    ///
    /// ![](popup-slide.png)
    ///
    /// The blue menu is @menu's ideal position, the green menu is @flipped_rect,
    /// and the red menu is @final_rect.
    ///
    /// See gtk_menu_popup_at_rect (), gtk_menu_popup_at_widget (),
    /// gtk_menu_popup_at_pointer (), #GtkMenu:anchor-hints,
    /// #GtkMenu:rect-anchor-dx, #GtkMenu:rect-anchor-dy, and
    /// #GtkMenu:menu-type-hint.
    public var poppedUp: ((Menu) -> Void)?

    public var notifyAccelGroup: ((Menu) -> Void)?

    public var notifyAccelPath: ((Menu) -> Void)?

    public var notifyActive: ((Menu) -> Void)?

    public var notifyAnchorHints: ((Menu) -> Void)?

    public var notifyAttachWidget: ((Menu) -> Void)?

    public var notifyMenuTypeHint: ((Menu) -> Void)?

    public var notifyMonitor: ((Menu) -> Void)?

    public var notifyRectAnchorDx: ((Menu) -> Void)?

    public var notifyRectAnchorDy: ((Menu) -> Void)?

    public var notifyReserveToggleSize: ((Menu) -> Void)?

    public var notifyTearoffState: ((Menu) -> Void)?

    public var notifyTearoffTitle: ((Menu) -> Void)?
}
