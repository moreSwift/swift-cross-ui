import SwiftCrossUI

extension AndroidBackend: BackendFeatures.Tooltips {
    public func createTooltipContainer(wrapping child: Widget) -> Widget {
        child
    }

    public func updateTooltipContainer(_ widget: Widget, tooltip: String) {
        widget.setTooltipText(charSequence(from: tooltip))
    }
}
