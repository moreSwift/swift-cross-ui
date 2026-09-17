extension DummyBackend {
    public class Slider: Widget {
        public var value: Double = 0
        public var minimumValue: Double = 0
        public var maximumValue: Double = 100
        public var decimalPlaces = 1
        public var changeHandler: ((Double) -> Void)?

        override public var naturalSize: SIMD2<Int> {
            SIMD2(20, 10)
        }
    }
}
