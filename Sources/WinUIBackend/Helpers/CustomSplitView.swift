import WinUI

final class CustomSplitView: SplitView {
    var sidebarResizeHandler: (() -> Void)?
}
