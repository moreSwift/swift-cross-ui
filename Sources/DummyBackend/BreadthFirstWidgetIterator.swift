extension DummyBackend {
    public class BreadthFirstWidgetIterator: IteratorProtocol {
        var queue: [Widget]

        init(for widget: Widget) {
            queue = [widget]
        }

        public func next() -> Widget? {
            guard let next = queue.first else {
                return nil
            }
            queue.removeFirst()
            queue.append(contentsOf: next.getChildren())
            return next
        }
    }
}
