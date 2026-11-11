import CGtk

/// `GtkPopoverMenu` is a subclass of `GtkPopover` that implements menu
/// behavior.
///
/// ![An example GtkPopoverMenu](menu.png)
///
/// `GtkPopoverMenu` treats its children like menus and allows switching
/// between them. It can open submenus as traditional, nested submenus,
/// or in a more touch-friendly sliding fashion.
/// The property [property@Gtk.PopoverMenu:flags] controls this appearance.
///
/// `GtkPopoverMenu` is meant to be used primarily with menu models,
/// using [ctor@Gtk.PopoverMenu.new_from_model]. If you need to put
/// other widgets such as a `GtkSpinButton` or a `GtkSwitch` into a popover,
/// you can use [method@Gtk.PopoverMenu.add_child].
///
/// For more dialog-like behavior, use a plain `GtkPopover`.
///
/// ## Menu models
///
/// The XML format understood by `GtkBuilder` for `GMenuModel` consists
/// of a toplevel `<menu>` element, which contains one or more `<item>`
/// elements. Each `<item>` element contains `<attribute>` and `<link>`
/// elements with a mandatory name attribute. `<link>` elements have the
/// same content model as `<menu>`. Instead of `<link name="submenu">`
/// or `<link name="section">`, you can use `<submenu>` or `<section>`
/// elements.
///
/// ```xml
/// <menu id='app-menu'><section><item><attribute name='label' translatable='yes'>_New Window</attribute><attribute name='action'>app.new</attribute></item><item><attribute name='label' translatable='yes'>_About Sunny</attribute><attribute name='action'>app.about</attribute></item><item><attribute name='label' translatable='yes'>_Quit</attribute><attribute name='action'>app.quit</attribute></item></section></menu>
/// ```
///
/// Attribute values can be translated using gettext, like other `GtkBuilder`
/// content. `<attribute>` elements can be marked for translation with a
/// `translatable="yes"` attribute. It is also possible to specify message
/// context and translator comments, using the context and comments attributes.
/// To make use of this, the `GtkBuilder` must have been given the gettext
/// domain to use.
///
/// The following attributes are used when constructing menu items:
///
/// - "label": a user-visible string to display
/// - "use-markup": whether the text in the menu item includes [Pango markup](https://docs.gtk.org/Pango/pango_markup.html)
/// - "action": the prefixed name of the action to trigger
/// - "target": the parameter to use when activating the action
/// - "icon" and "verb-icon": names of icons that may be displayed
/// - "submenu-action": name of an action that may be used to track
/// whether a submenu is open
/// - "hidden-when": a string used to determine when the item will be hidden.
/// Possible values include "action-disabled", "action-missing", "macos-menubar".
/// This is mainly useful for exported menus, see [method@Gtk.Application.set_menubar].
/// - "custom": a string used to match against the ID of a custom child added with
/// [method@Gtk.PopoverMenu.add_child], [method@Gtk.PopoverMenuBar.add_child],
/// or in the ui file with `<child type="ID">`.
///
/// The following attributes are used when constructing sections:
///
/// - "label": a user-visible string to use as section heading
/// - "display-hint": a string used to determine special formatting for the section.
/// Possible values include "horizontal-buttons", "circular-buttons" and
/// "inline-buttons". They all indicate that section should be
/// displayed as a horizontal row of buttons.
/// - "text-direction": a string used to determine the `GtkTextDirection` to use
/// when "display-hint" is set to "horizontal-buttons". Possible values
/// include "rtl", "ltr", and "none".
///
/// The following attributes are used when constructing submenus:
///
/// - "label": a user-visible string to display
/// - "icon": icon name to display
///
/// Menu items will also show accelerators, which are usually associated
/// with actions via [method@Gtk.Application.set_accels_for_action],
/// [method@WidgetClass.add_binding_action] or
/// [method@Gtk.ShortcutController.add_shortcut].
///
/// # CSS Nodes
///
/// `GtkPopoverMenu` is just a subclass of `GtkPopover` that adds custom content
/// to it, therefore it has the same CSS nodes. It is one of the cases that add
/// a `.menu` style class to the main `popover` node.
///
/// Menu items have nodes with name `button` and class `.model`. If a section
/// display-hint is set, the section gets a node `box` with class `horizontal`
/// plus a class with the same text as the display hint. Note that said box may
/// not be the direct ancestor of the item `button`s. Thus, for example, to style
/// items in an `inline-buttons` section, select `.inline-buttons button.model`.
/// Other things that may be of interest to style in menus include `label` nodes.
///
/// # Accessibility
///
/// `GtkPopoverMenu` uses the %GTK_ACCESSIBLE_ROLE_MENU role, and its
/// items use the %GTK_ACCESSIBLE_ROLE_MENU_ITEM,
/// %GTK_ACCESSIBLE_ROLE_MENU_ITEM_CHECKBOX or
/// %GTK_ACCESSIBLE_ROLE_MENU_ITEM_RADIO roles, depending on the
/// action they are connected to.
public class PopoverMenu: Popover {
    public convenience init() {
        self.init(
            gtk_popover_menu_new_from_model(nil)
        )
    }

    /// Creates a `GtkPopoverMenu` and populates it according to @model.
    ///
    /// The created buttons are connected to actions found in the
    /// `GtkApplicationWindow` to which the popover belongs - typically
    /// by means of being attached to a widget that is contained within
    /// the `GtkApplicationWindow`s widget hierarchy.
    ///
    /// Actions can also be added using [method@Gtk.Widget.insert_action_group]
    /// on the menus attach widget or on any of its parent widgets.
    ///
    /// This function creates menus with sliding submenus.
    /// See [ctor@Gtk.PopoverMenu.new_from_model_full] for a way
    /// to control this.
    public convenience init(model: UnsafeMutablePointer<GMenuModel>!) {
        self.init(
            gtk_popover_menu_new_from_model(model)
        )
    }

    /// Creates a `GtkPopoverMenu` and populates it according to @model.
    ///
    /// The created buttons are connected to actions found in the
    /// action groups that are accessible from the parent widget.
    /// This includes the `GtkApplicationWindow` to which the popover
    /// belongs. Actions can also be added using [method@Gtk.Widget.insert_action_group]
    /// on the parent widget or on any of its parent widgets.
    public convenience init(model: UnsafeMutablePointer<GMenuModel>!, flags: GtkPopoverMenuFlags) {
        self.init(
            gtk_popover_menu_new_from_model_full(model, flags)
        )
    }

    /// This method is specifically tailored to SwiftCrossUI's use case.
    public func popUpAtWidget(_ widget: Widget, relativePosition: SIMD2<Int>) {
        gtk_widget_set_parent(widgetPointer, widget.widgetPointer)
        let widgetSizeRequest = widget.getSizeRequest()
        let widgetNaturalSize = widget.getNaturalSize()
        let widgetSize = Size(
            width: widgetSizeRequest.width == -1
                ? widgetNaturalSize.width
                : widgetSizeRequest.width,
            height: widgetSizeRequest.height == -1
                ? widgetNaturalSize.height
                : widgetSizeRequest.height
        )
        var menuMinimumSize = GtkRequisition()
        var menuNaturalSize = GtkRequisition()
        gtk_popover_popup(castedPointer())

        gtk_widget_get_preferred_size(widgetPointer, &menuMinimumSize, &menuNaturalSize)

        // TODO: Figure out why this is actually happening and whether it's just specific to
        //   my machines. Probably just some weird menu CSS from the default themes, but
        //   debugging menu's is so annoying cause they close when you switch to the debugger
        //   window.
        #if os(Linux)
            menuNaturalSize.width -= 48
        #elseif os(macOS)
            menuNaturalSize.width -= 8
        #endif

        gtk_popover_set_offset(
            castedPointer(),
            gint(relativePosition.x + (Int(menuNaturalSize.width) - widgetSize.width) / 2),
            gint(relativePosition.y - widgetSize.height)
        )
    }

    private var _model: GMenu?
    public var model: GMenu? {
        get {
            _model
        }
        set {
            gtk_popover_menu_set_menu_model(
                opaquePointer,
                (newValue?.pointer).map(UnsafeMutablePointer.init)
            )
            _model = newValue
        }
    }

    open override func didMoveToParent() {
        removeSignals()

        super.didMoveToParent()

        addSignal(name: "hid") { [weak self] in
            self?.onHide?()
        }

        let handler0:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::flags", handler: gCallback(handler0)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyFlags?(self)
        }

        let handler1:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::menu-model", handler: gCallback(handler1)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyMenuModel?(self)
        }

        let handler2:
            @convention(c) (UnsafeMutableRawPointer, OpaquePointer, UnsafeMutableRawPointer)
            -> Void =
            { _, value1, data in
                SignalBox1<OpaquePointer>.run(data, value1)
            }

        addSignal(name: "notify::visible-submenu", handler: gCallback(handler2)) {
            [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.notifyVisibleSubmenu?(self)
        }
    }

    public var onHide: (() -> Void)?

    public var notifyFlags: ((PopoverMenu) -> Void)?

    public var notifyMenuModel: ((PopoverMenu) -> Void)?

    public var notifyVisibleSubmenu: ((PopoverMenu) -> Void)?
}
