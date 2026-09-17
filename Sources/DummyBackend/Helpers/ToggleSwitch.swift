extension DummyBackend {
    public class ToggleSwitch: Widget {
        public var toggleHandler: ((Bool) -> Void)?
        public var state = false

        override public var naturalSize: SIMD2<Int> {
            SIMD2(20, 10)
        }
    }
}
