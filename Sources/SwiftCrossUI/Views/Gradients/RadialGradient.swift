/// A radial gradient.
public struct RadialGradient: ElementaryView {
    /// The gradient represented as an array of color stops, each having a parametric location value.
    public let gradient: Gradient
    /// The radius at which the first gradient stop will be placed.
    ///
    /// All space inside this radius gets filled with the color of the first gradient stop.
    public let startRadius: Double
    /// The radius at which the last gradient stop will be placed.
    ///
    /// All space outside this radius gets filled with the color of the last gradient stop.
    public let endRadius: Double
    /// The normalized center point of the gradient in its coordinate space.
    public let center: UnitPoint

    private static let idealSize = ViewSize(10, 10)

    /// Creates a radial gradient from a base gradient.
    public init(
        gradient: Gradient,
        center: UnitPoint,
        startRadius: Double,
        endRadius: Double
    ) {
        self.gradient = gradient
        self.startRadius = startRadius
        self.center = center
        self.endRadius = endRadius
    }

    @CastBackend<BackendFeatures.RadialGradients>(returnsWidget: true)
    public func asWidget<Backend: BaseAppBackend>(
        backend: Backend
    ) -> Backend.Widget {
        backend.createRadialGradientWidget()
    }
    
    public func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        ViewLayoutResult.leafView(
            size: proposedSize.replacingUnspecifiedDimensions(by: Self.idealSize)
        )
    }

    @CastBackend<BackendFeatures.RadialGradients>
    public func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.setSize(of: widget, to: layout.size.vector)
        backend.updateRadialGradientWidget(
            widget,
            gradient: self,
            withSize: layout.size.vector,
            in: environment
        )
    }
}

extension RadialGradient {
    /// Creates a radial gradient from a collection of colors.
    public init(
        stops: [Gradient.Stop],
        center: UnitPoint,
        startRadius: Double,
        endRadius: Double
    ) {
        self.init(
            gradient: Gradient(stops: stops),
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }

    /// Creates a radial gradient from a collection of color stops.
    public init(
        colors: [Color],
        center: UnitPoint,
        startRadius: Double,
        endRadius: Double
    ) {
        self.init(
            gradient: Gradient(colors: colors),
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }

    /// Stops adjusted to accomodate startRadius on backends without native support.
    package var adjustedStops: [Gradient.Stop] {
        guard startRadius != 0 else { return gradient.stops }
        
        let range = endRadius - startRadius
        
        if range < 0 {
            let dividableRange = abs(range) / startRadius
            let innerCircle = (startRadius - abs(range)) / startRadius
            
            let invertedStops = gradient.stops.reversed().map { stop in
                Gradient.Stop(
                    color: stop.color,
                    location: innerCircle + (1.0 - stop.location) * dividableRange
                )
            }
            
            return invertedStops
        }
        
        let dividableRange = range / endRadius
        let innerCircle = (endRadius - range) / endRadius
        
        return gradient.stops.map { stop in
            Gradient.Stop(
                color: stop.color,
                location: innerCircle + stop.location * dividableRange
            )
        }
    }
}
