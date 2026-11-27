import WinUI

final class TapGestureTarget: WinUI.Canvas {
    var clickHandler: (() -> Void)?
    var child: WinUI.FrameworkElement?
}
