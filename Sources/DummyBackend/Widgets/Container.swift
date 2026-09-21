extension DummyBackend {
    public class Container: Widget {
        public var children: [(widget: Widget, position: SIMD2<Int>)] = []

        public override func getChildren() -> [Widget] {
            children.map(\.widget)
        }
    }
}
