extension Color {
    /// A resolved RGBA color.
    public struct Resolved: Sendable, Equatable, Hashable, Codable {
        /// The red component.
        public var red: Float
        /// The green component.
        public var green: Float
        /// The blue component.
        public var blue: Float
        /// The alpha component (aka the opacity).
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
        var resolvedColor = switch representation {
            case .rgb(let red, let green, let blue):
                Resolved(red: Float(red), green: Float(green), blue: Float(blue))

            case .adaptive(let light, let dark):
                switch environment.colorScheme {
                    case .light: light.resolve(in: environment)
                    case .dark: dark.resolve(in: environment)
                }

            case .system(let systemColor):
                environment.backend.resolveAdaptiveColor(systemColor, in: environment)
        }

        resolvedColor.opacity *= Float(self.opacityMultiplier)
        return resolvedColor
    }
}
