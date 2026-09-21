extension DummyBackend {
    public class SplitView: Widget {
        public var leadingChild: Widget
        public var trailingChild: Widget

        public var sidebarResizeHandler: (() -> Void)?

        private var _sidebarWidth = 100

        public var sidebarWidth: Int {
            get {
                _sidebarWidth
            }
            set {
                var width = newValue
                if let minimumSidebarWidth {
                    width = max(minimumSidebarWidth, width)
                }
                if let maximumSidebarWidth {
                    width = min(maximumSidebarWidth, width)
                }
                width = max(0, min(size.x, width))
                _sidebarWidth = width
            }
        }

        public var minimumSidebarWidth: Int? {
            didSet {
                if let minimumSidebarWidth {
                    sidebarWidth = max(minimumSidebarWidth, sidebarWidth)
                }
            }
        }

        public var maximumSidebarWidth: Int? {
            didSet {
                if let maximumSidebarWidth {
                    sidebarWidth = min(maximumSidebarWidth, sidebarWidth)
                }
            }
        }

        override public var size: SIMD2<Int> {
            didSet {
                if sidebarWidth > size.x {
                    sidebarWidth = size.x
                }
            }
        }

        public init(leadingChild: Widget, trailingChild: Widget) {
            self.leadingChild = leadingChild
            self.trailingChild = trailingChild
        }

        public override func getChildren() -> [Widget] {
            [leadingChild, trailingChild]
        }
    }
}
