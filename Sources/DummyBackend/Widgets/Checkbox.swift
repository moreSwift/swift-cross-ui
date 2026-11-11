extension DummyBackend {
    public class Checkbox: Widget {
        public var toggleHandler: ((Bool) -> Void)?
        public var state = false

        override public var naturalSize: SIMD2<Int> {
            SIMD2(10, 10)
        }
    }
}
