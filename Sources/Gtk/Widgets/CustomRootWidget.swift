import CGtk
import Dispatch
import GtkCHelpers

/// A custom widget made specifically for SwiftCrossUI. This widget provides the
/// control of window and pane resizing that SwiftCrossUI requires.
public class CustomRootWidget: Widget {
    public var child: Widget?

    public convenience init() {
        self.init(gtk_custom_root_widget_new())
    }

    public func setChild(to widget: Widget) {
        if let child {
            child.parentWidget = nil
        }
        gtk_custom_root_widget_set_child(castedPointer(), widget.widgetPointer)
        child = widget
        widget.parentWidget = self
    }

    public func setMinimumSize(
        minimumWidth: Int,
        minimumHeight: Int
    ) {
        gtk_custom_root_widget_set_minimum_size(
            castedPointer(),
            gint(minimumWidth),
            gint(minimumHeight)
        )
    }

    public func preemptAllocatedSize(
        allocatedWidth: Int,
        allocatedHeight: Int
    ) {
        gtk_custom_root_widget_preempt_allocated_size(
            castedPointer(),
            gint(allocatedWidth),
            gint(allocatedHeight)
        )
    }

    public func getSize() -> Size {
        var width: gint = 0
        var height: gint = 0
        gtk_custom_root_widget_get_size(castedPointer(), &width, &height)
        return Size(width: Int(width), height: Int(height))
    }

    public func setResizeHandler(_ handler: @escaping (Size) -> Void) {
        let box = SignalBox1<Size> { size in
            handler(size)
        }
        gtk_custom_root_widget_set_resize_callback(
            castedPointer(),
            { data, size in
                SignalBox1<Size>.run(
                    data!,
                    Size(width: Int(size.width), height: Int(size.height))
                )
            },
            Unmanaged.passRetained(box).toOpaque()
        )
    }
}
