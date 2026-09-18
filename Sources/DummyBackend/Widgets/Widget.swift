extension DummyBackend {
    public class Widget {
        public var tag: String?
        public var cornerRadius = 0
        public var size = SIMD2<Int>.zero
        public var naturalSize: SIMD2<Int> {
            SIMD2<Int>.zero
        }

        public func getChildren() -> [Widget] {
            []
        }

        /// Finds the first widget of type `T` in the hierarchy defined by this
        /// widget (including the widget itself).
        public func firstWidget<T: Widget>(ofType type: T.Type) -> T? {
            let iterator = BreadthFirstWidgetIterator(for: self)
            while let child = iterator.next() {
                if let child = child as? T {
                    return child
                }
            }
            return nil
        }
    }
}
