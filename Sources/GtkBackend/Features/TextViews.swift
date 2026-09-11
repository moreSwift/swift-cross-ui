import CGtk
import Gtk
@_spi(Backends) import SwiftCrossUI

extension GtkBackend: BackendFeatures.TextViews {
    public func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedWidth: Int?,
        proposedHeight: Int?,
        environment: EnvironmentValues
    ) -> SIMD2<Int> {
        let ellipsize: EllipsizeMode
        if let widget = widget as? CustomLabel {
            ellipsize = widget.ellipsize
        } else if widget as? TextView != nil {
            // We don't ellipsize multi-line text editors
            ellipsize = .none
        } else {
            logger.warning(
                "\(#function) called with unexpected widget type \(type(of: widget))"
            )
            ellipsize = .none
        }

        let pango = Pango(for: widget)
        let (width, height) = pango.getTextSize(
            text,
            ellipsize: proposedHeight == nil ? .none : ellipsize,
            proposedWidth: proposedWidth.map(Double.init),
            proposedHeight: proposedHeight.map(Double.init)
        )

        var imposedHeight = height

        if let lineLimitSettings = environment.lineLimitSettings {
            let multilineString = [String](repeating: "a", count: lineLimitSettings.limit)
                .joined(separator: "\n")
            updateTextView(
                measurementCustomLabel,
                content: "",
                environment: environment
            )

            let pango = Pango(for: measurementCustomLabel)

            let (_, heightLimit) = pango.getTextSize(
                multilineString,
                ellipsize: .none,
                proposedWidth: nil,
                proposedHeight: nil
            )

            if heightLimit < imposedHeight || lineLimitSettings.reservesSpace {
                imposedHeight = heightLimit
            }
        }

        return SIMD2(width, imposedHeight)
    }

    public func createTextView() -> Widget {
        let textView = CustomLabel(string: "")
        textView.horizontalAlignment = .start
        textView.wrap = true
        textView.lineWrapMode = .wordCharacter
        textView.ellipsize = .end
        textView.yalign = 0.0
        return textView
    }

    public func updateTextView(
        _ textView: Widget,
        content: String,
        environment: EnvironmentValues
    ) {
        let textView = textView as! CustomLabel
        textView.label = content
        textView.justify =
            switch environment.multilineTextAlignment {
                case .leading:
                    Justification.left
                case .center:
                    Justification.center
                case .trailing:
                    Justification.right
            }

        textView.selectable = environment.isTextSelectionEnabled
        textView.css.clear()
        textView.css.set(properties: Self.cssProperties(for: environment))
    }
}
