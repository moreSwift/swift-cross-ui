import CGtk
import Gtk
import SwiftCrossUI

extension GtkBackend {
    public func resolveAdaptiveColor(
        _ adaptiveColor: SwiftCrossUI.Color.SystemAdaptive,
        in environment: EnvironmentValues
    ) -> SwiftCrossUI.Color.Resolved {
        // Source: https://developer.gnome.org/hig/reference/palette.html
        switch environment.colorScheme {
            case .light:
                switch adaptiveColor.kind {
                    case .blue: .init(red: 0.208, green: 0.518, blue: 0.894)  // Blue 3
                    case .brown: .init(red: 0.596, green: 0.416, blue: 0.267)  // Brown 3
                    case .gray: .init(red: 0.467, green: 0.463, blue: 0.482)  // Dark 1
                    case .green: .init(red: 0.2, green: 0.819, blue: 0.478)  // Green 3
                    case .orange: .init(red: 1.0, green: 0.471, blue: 0.0)  // Orange 3
                    case .purple: .init(red: 0.569, green: 0.255, blue: 0.674)  // Purple 3
                    case .red: .init(red: 0.878, green: 0.106, blue: 0.141)  // Red 3
                    case .yellow: .init(red: 0.965, green: 0.827, blue: 0.176)  // Yellow 3
                }
            case .dark:
                switch adaptiveColor.kind {
                    case .blue: .init(red: 0.384, green: 0.627, blue: 0.918)  // Blue 2
                    case .brown: .init(red: 0.709, green: 0.514, blue: 0.353)  // Brown 2
                    case .gray: .init(red: 0.604, green: 0.6, blue: 0.588)  // Light 5
                    case .green: .init(red: 0.341, green: 0.89, blue: 0.537)  // Green 2
                    case .orange: .init(red: 1.0, green: 0.639, blue: 0.282)  // Orange 2
                    case .purple: .init(red: 0.753, green: 0.379, blue: 0.796)  // Purple 2
                    case .red: .init(red: 0.929, green: 0.2, blue: 0.231)  // Red 2
                    case .yellow: .init(red: 0.973, green: 0.894, blue: 0.361)  // Yellow 2
                }
        }
    }
}

extension SwiftCrossUI.Color.Resolved {
    public var gtkColor: Gtk.Color {
        Gtk.Color(red, green, blue, opacity)
    }
}
