extension DummyBackend {
    public class Table: Widget {
        public var rowCount = 0
        public var columnLabels: [String] = []
        public var cells: [Widget] = []
        public var rowHeights: [Int] = []

        public override func getChildren() -> [Widget] {
            cells
        }
    }
}
