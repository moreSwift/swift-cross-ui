import WinUI

final class TooltipContainer: WinUI.Canvas {
    var child: WinUI.FrameworkElement
    var tooltip: ToolTip

    init(child: WinUI.FrameworkElement) {
        self.child = child
        self.tooltip = ToolTip()

        super.init()

        children.append(child)
        ToolTipService.setToolTip(self, tooltip)
    }
}
