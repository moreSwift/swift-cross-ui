//
//  Copyright © 2015 Tomas Linhart. All rights reserved.
//

import CGtk3
import Foundation

open class Widget: GObject {
    public var widgetPointer: UnsafeMutablePointer<GtkWidget> {
        gobjectPointer.cast()
    }

    public weak var parentWidget: Widget? {
        willSet {

        }
        didSet {
            if parentWidget != nil {
                didMoveToParent()
            } else {
                didMoveFromParent()
            }
        }
    }

    open func didMoveToParent() {
        // The Gtk3 docs claim that this handler should take GdkEventButton as a
        // value, but that leads to crashes on Rocky Linux. These crashes are
        // fixed by instead taking the event as a pointer. I've confirmed that
        // this also leads to correct functionality on Rocky Linux (with correct
        // mouse coordinates etc). The weird part is that this code works
        // perfectly on macOS and Ubuntu with and without indirection. Huh??
        //
        // The docs: https://docs.gtk.org/gtk3/signal.Widget.button-press-event.html
        let handler1:
            @convention(c) (
                UnsafeMutableRawPointer,
                UnsafePointer<GdkEventButton>,
                UnsafeMutableRawPointer
            ) -> Void = { _, value1, data in
                SignalBox1<GdkEventButton>.run(data, value1.pointee)
            }

        addSignal(
            name: "button-press-event",
            handler: gCallback(handler1)
        ) { [weak self] (buttonEvent: GdkEventButton) in
            guard let self else { return }
            self.onButtonPress?(self, buttonEvent)
        }

        let handler2:
            @convention(c) (
                UnsafeMutableRawPointer,
                OpaquePointer,
                UnsafeMutableRawPointer
            ) -> Bool = { _, cairo, data in
                SignalBox1<OpaquePointer>.run(data, cairo)
                // Propagate event to next handler
                return false
            }

        addSignal(
            name: "draw",
            handler: gCallback(handler2)
        ) { [weak self] (cairo: OpaquePointer) in
            guard let self else { return }
            self.doDraw?(cairo)
        }

        let handler3:
            @convention(c) (
                UnsafeMutableRawPointer,
                OpaquePointer,
                UnsafeMutableRawPointer
            ) -> Void = { _, screen, data in
                SignalBox1<OpaquePointer>.run(data, screen)
            }

        addSignal(
            name: "screen-changed",
            handler: gCallback(handler3)
        ) { [weak self] (_: OpaquePointer) in
            guard let self else { return }
            self.screenChanged?()
        }

        let handler4:
            @convention(c) (
                UnsafeMutableRawPointer,
                UnsafeMutableRawPointer
            ) -> Void = { _, data in
                SignalBox1<Void>.run(data, ())
            }

        addSignal(
            name: "style-updated",
            handler: gCallback(handler4)
        ) { [weak self] (_: Void) in
            guard let self else { return }
            self.styleUpdated?()
        }
    }

    open func didMoveFromParent() {}

    public func queueDraw() {
        gtk_widget_queue_draw(widgetPointer)
    }

    /// The CSS rules applied directly to this widget.
    public lazy var css: CSSBlock = CSSBlock(forClass: customCSSClass) {
        didSet {
            guard oldValue != css else { return }
            cssProvider.loadCss(from: css.stringRepresentation)
        }
    }

    /// A unique CSS class for this widget. The class is lazily added to the
    /// widget when this property is first accessed.
    private lazy var customCSSClass: String = {
        let className = ObjectIdentifier(self).debugDescription
            .replacingOccurrences(of: "ObjectIdentifier(0x", with: "class_")
            .replacingOccurrences(of: ")", with: "")
        let context = gtk_widget_get_style_context(widgetPointer)
        gtk_style_context_add_class(context, className)
        return className
    }()

    /// A CSS provider specifically for this widget. Will get removed when
    /// it deinits.
    public lazy var cssProvider = CSSProvider(
        forContext: gtk_widget_get_style_context(widgetPointer)
    )

    public func showAll() {
        gtk_widget_show_all(widgetPointer)
    }

    public func show() {
        gtk_widget_show(widgetPointer)
    }

    public func hide() {
        gtk_widget_show(widgetPointer)
    }

    open func setSizeRequest(width: Int, height: Int) {
        gtk_widget_set_size_request(widgetPointer, Int32(width), Int32(height))
    }

    public func getSizeRequest() -> Size {
        var width: Int32 = 0
        var height: Int32 = 0
        gtk_widget_get_size_request(widgetPointer, &width, &height)
        return Size(width: Int(width), height: Int(height))
    }

    public func getNaturalSize() -> (width: Int, height: Int) {
        var minimumSize = GtkRequisition()
        var naturalSize = GtkRequisition()
        gtk_widget_get_preferred_size(widgetPointer, &minimumSize, &naturalSize)
        return (
            width: Int(naturalSize.width),
            height: Int(naturalSize.height)
        )
    }

    public struct MeasureResult {
        public var minimum: Int
        public var natural: Int
    }

    public func measure(
        orientation: Orientation,
        forPerpendicularSize perpendicularSize: Int
    ) -> MeasureResult {
        var minimum: gint = 0
        var natural: gint = 0
        switch orientation {
            case .horizontal:
                gtk_widget_get_preferred_width_for_height(
                    widgetPointer,
                    gint(perpendicularSize),
                    &minimum,
                    &natural
                )
            case .vertical:
                gtk_widget_get_preferred_height_for_width(
                    widgetPointer,
                    gint(perpendicularSize),
                    &minimum,
                    &natural
                )
        }
        return MeasureResult(
            minimum: Int(minimum),
            natural: Int(natural)
        )
    }

    public func insertActionGroup(_ name: String, _ actionGroup: any GActionGroup) {
        gtk_widget_insert_action_group(
            widgetPointer,
            name,
            actionGroup.actionGroupPointer
        )
    }

    public var onButtonPress: ((Widget, GdkEventButton) -> Void)?

    public var doDraw: ((_ cairo: OpaquePointer) -> Void)?

    public var screenChanged: (() -> Void)?

    public var styleUpdated: (() -> Void)?

    @GObjectProperty(named: "name") public var name: String?

    @GObjectProperty(named: "sensitive") public var sensitive: Bool

    @GObjectProperty(named: "opacity") public var opacity: Double

    @GObjectProperty(named: "margin-top") public var marginTop: Int

    @GObjectProperty(named: "margin-bottom") public var marginBottom: Int

    @GObjectProperty(named: "margin-start") public var marginStart: Int

    @GObjectProperty(named: "margin-end") public var marginEnd: Int

    @GObjectProperty(named: "halign") public var horizontalAlignment: Align

    @GObjectProperty(named: "valign") public var verticalAlignment: Align

    /// Whether to expand horizontally.
    @GObjectProperty(named: "hexpand") public var expandHorizontally: Bool

    /// Whether to use the expandHorizontally property.
    @GObjectProperty(named: "hexpand-set") public var useExpandHorizontally: Bool

    /// Whether to expand vertically.
    @GObjectProperty(named: "vexpand") public var expandVertically: Bool

    /// Whether to use the expandVertically property.
    @GObjectProperty(named: "vexpand-set") public var useExpandVertically: Bool

    /// Set to -1 for no min width request
    @GObjectProperty(named: "width-request") public var minWidth: Int

    /// Set to -1 for no min height request
    @GObjectProperty(named: "height-request") public var minHeight: Int

    /// Sets the name of the Gtk view for useful debugging in inspector (Ctrl+Shift+D)
    public func tag(as tag: String) {
        name = tag
    }
}
