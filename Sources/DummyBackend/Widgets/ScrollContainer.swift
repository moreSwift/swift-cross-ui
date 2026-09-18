extension DummyBackend {
    public class ScrollContainer: Widget {
        public var child: Widget
        public var hasVerticalScrollBar = false
        public var hasHorizontalScrollBar = false
        public var bouncesVertically = false
        public var bouncesHorizontally = false

        public init(child: Widget) {
            self.child = child
        }

        public override func getChildren() -> [Widget] {
            [child]
        }
    }
}
