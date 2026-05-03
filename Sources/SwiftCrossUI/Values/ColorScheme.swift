/// A color scheme to apply to views.
public enum ColorScheme: Sendable {
    /// Light mode (usually black on white).
    case light
    /// Dark mode (usually white on black).
    case dark

    /// The opposite of this color scheme.
    package var opposite: ColorScheme {
        switch self {
            case .light: .dark
            case .dark: .light
        }
    }

    /// The default foreground color for this color scheme.
    ///
    /// This only applies on backends that don't define an interpretation of
    /// color schemes themselves.
    public var defaultForegroundColor: Color {
        switch self {
            case .light: .black
            case .dark: .white
        }
    }
}
