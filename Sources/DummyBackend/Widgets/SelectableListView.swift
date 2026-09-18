extension DummyBackend {
    public class SelectableListView: Widget {
        public var items: [Widget] = []
        public var rowHeights: [Int] = []
        public var selectionHandler: ((Int) -> Void)?
        public var selectedIndex: Int?

        public override func getChildren() -> [Widget] {
            items
        }
    }
}
