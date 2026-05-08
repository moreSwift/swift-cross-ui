/// A color gradient represented as an array of color stops, each having a normalized location value.
public struct Gradient: Sendable, Hashable {
    /// The array of color stops, ordered by location.
    public var stops: [Gradient.Stop]

    /// Creates a gradient from an array of color stops ordered by location.
    ///
    /// - Parameters:
    ///   - stops: The stops of the Gradient. If no stop is passed, the gradient will be fully transparent.
    init(stops: [Gradient.Stop]) {
        guard let first = stops.first else {
            let invisible = Color.black.opacity(0)
            self.stops = [
                Stop(color: invisible, location: 0),
                Stop(color: invisible, location: 1),
            ]
            return
        }

        #if DEBUG
            if stops != stops.sorted(by: { $0.location < $1.location }) {
                logger.warning("Gradient stop locations must be ordered")
            }
        #endif

        if stops.count == 1 {
            self.stops = [
                Stop(color: first.color, location: 0),
                Stop(color: first.color, location: 1),
            ]
        } else {
            self.stops = stops
        }
    }

    /// Creates a gradient from an array of colors.
    /// - Parameters:
    ///   - colors: The colors of the gradient. The gradient synthesizes its location values to evenly
    ///     space the colors along the gradient. If no color is passed, the gradient will be fully transparent.
    init(colors: [Color]) {
        guard let first = colors.first else {
            let invisible = Color.black.opacity(0)
            self.stops = [
                Stop(color: invisible, location: 0),
                Stop(color: invisible, location: 1),
            ]
            return
        }

        if colors.count == 1 {
            self.stops = [
                Stop(color: first, location: 0),
                Stop(color: first, location: 1),
            ]
            return
        }

        let locationDifference = 1.0 / Double(colors.count - 1)

        var stops = [Stop(color: first, location: 0)]
        var currentLocation = 0.0

        for (i, color) in colors[1...].enumerated() {
            let location = Double(i + 1) / Double(colors.count - 1)
            stops.append(
                Stop(color: color, location: location)
            )
        }

        self.stops = stops
    }

    /// One color stop in a gradient.
    public struct Stop: Sendable, Equatable, Hashable {
        /// Creates a color stop with a color and location.
        /// - Parameters:
        ///   - color: The color that should be placed at this stop.
        ///   - location: The location of this stop. 0 corresponds to the start and 1 to the end.
        public init(color: Color, location: Double) {
            self.color = color
            self.location = location
        }

        /// The color for the stop.
        public var color: Color
        /// The parametric location of the stop.
        public var location: Double
    }
}
