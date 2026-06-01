public enum ColorScheme: Sendable {
    case light
    case dark

    public var opposite: ColorScheme {
        switch self {
            case .light: .dark
            case .dark: .light
        }
    }

    public var defaultForegroundColor: Color {
        switch self {
            case .light: .black
            case .dark: .white
        }
    }
}
