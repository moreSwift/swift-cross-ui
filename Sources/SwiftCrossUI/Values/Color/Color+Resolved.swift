extension Color {
    /// A resolved RGBA color.
    public struct Resolved: Sendable, Equatable, Hashable, Codable {
        /// The red component (from 0 to 1).
        public var red: Float
        /// The green component (from 0 to 1).
        public var green: Float
        /// The blue component (from 0 to 1).
        public var blue: Float
        /// The alpha component (aka the opacity, from 0 to 1).
        public var opacity: Float

        /// Creates an instance.
        ///
        /// - Parameters:
        ///   - red: The red component.
        ///   - green: The green component.
        ///   - blue: The blue component.
        ///   - opacity: The alpha component (aka the opacity).
        public init(
            red: Float,
            green: Float,
            blue: Float,
            opacity: Float = 1.0
        ) {
            self.red = red
            self.green = green
            self.blue = blue
            self.opacity = opacity
        }
    }

    /// Resolves this color in the given environment.
    ///
    /// - Parameter environment: The environment.
    /// - Returns: The resolved color.
    @MainActor
    public func resolve(in environment: EnvironmentValues) -> Resolved {
        var resolvedColor =
            switch representation {
                case .rgb(let red, let green, let blue):
                    Resolved(red: Float(red), green: Float(green), blue: Float(blue))

                case .adaptive(let light, let dark):
                    switch environment.colorScheme {
                        case .light: light.resolve(in: environment)
                        case .dark: dark.resolve(in: environment)
                    }

                case .system(let systemColor):
                    if let backend = environment.backend as? any BackendFeatures.Colors {
                        backend.resolveAdaptiveColor(
                            systemColor,
                            in: environment
                        )
                    } else {
                        Color.defaultResolveAdaptiveColor(
                            systemColor,
                            in: environment
                        )
                    }
            }

        resolvedColor.opacity *= Float(self.opacityMultiplier)
        return resolvedColor
    }

    // NB: Also used in the default implementation for
    // `BackendFeatures.Colors.resolveAdaptiveColor(_:in:)`.
    @MainActor
    internal static func defaultResolveAdaptiveColor(
        _ adaptiveColor: Color.SystemAdaptive,
        in environment: EnvironmentValues
    ) -> Color.Resolved {
        let color: Color =
            switch adaptiveColor.kind {
                case .blue: .blue
                case .brown: .brown
                case .gray: .gray
                case .green: .green
                case .orange: .orange
                case .purple: .purple
                case .red: .red
                case .yellow: .yellow
            }

        return color.resolve(in: environment)
    }
}
