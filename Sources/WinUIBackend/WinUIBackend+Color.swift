import SwiftCrossUI
import UWP

extension WinUIBackend {
    public func resolveAdaptiveColor(
        _ adaptiveColor: SwiftCrossUI.Color.SystemAdaptive,
        in environment: EnvironmentValues
    ) -> SwiftCrossUI.Color.Resolved {
        // Source: https://storybooks.fluentui.dev/react/?path=/docs/theme-colors--docs
        switch environment.colorScheme {
            case .light:
                switch adaptiveColor.kind {
                    case .blue: .init(red: 0.0, green: 0.471, blue: 0.831)  // colorPaletteBlueBorderActive
                    case .brown: .init(red: 0.557, green: 0.337, blue: 0.18)  // colorPaletteBrownBorderActive
                    case .gray: .init(red: 0.478, green: 0.459, blue: 0.455)  // colorPaletteBeigeBorderActive
                    case .green: .init(red: 0.067, green: 0.569, blue: 0.051)  // colorPaletteLightGreenForeground1
                    case .orange: .init(red: 1.0, green: 0.549, blue: 0.0)  // colorPalettePeachBorderActive
                    case .purple: .init(red: 0.686, green: 0.2, blue: 0.631)  // colorPaletteBerryForeground1
                    case .red: .init(red: 0.737, green: 0.184, blue: 0.196)  // colorPaletteRedForeground1
                    case .yellow: .init(red: 0.992, green: 0.89, blue: 0.0)  // colorPaletteYellowForeground3
                }
            case .dark:
                switch adaptiveColor.kind {
                    case .blue: .init(red: 0.361, green: 0.667, blue: 0.898)  // colorPaletteBlueBorderActive
                    case .brown: .init(red: 0.733, green: 0.561, blue: 0.435)  // colorPaletteBrownBorderActive
                    case .gray: .init(red: 0.686, green: 0.671, blue: 0.667)  // colorPaletteBeigeBorderActive
                    case .green: .init(red: 0.369, green: 0.78, blue: 0.353)  // colorPaletteLightGreenForeground1
                    case .orange: .init(red: 1.0, green: 0.729, blue: 0.4)  // colorPalettePeachBorderActive
                    case .purple: .init(red: 0.855, green: 0.494, blue: 0.816)  // colorPaletteBerryForeground1
                    case .red: .init(red: 0.89, green: 0.49, blue: 0.502)  // colorPaletteRedForeground1
                    case .yellow: .init(red: 0.992, green: 0.918, blue: 0.239)  // colorPaletteYellowForeground3
                }
        }
    }
}

extension SwiftCrossUI.Color.Resolved {
    var uwpColor: UWP.Color {
        UWP.Color(
            a: UInt8((opacity * Float(UInt8.max)).rounded()),
            r: UInt8((red * Float(UInt8.max)).rounded()),
            g: UInt8((green * Float(UInt8.max)).rounded()),
            b: UInt8((blue * Float(UInt8.max)).rounded())
        )
    }

    init(uwpColor: UWP.Color) {
        self.init(
            red: Float(uwpColor.r) / Float(UInt8.max),
            green: Float(uwpColor.g) / Float(UInt8.max),
            blue: Float(uwpColor.b) / Float(UInt8.max),
            opacity: Float(uwpColor.a) / Float(UInt8.max)
        )
    }
}
