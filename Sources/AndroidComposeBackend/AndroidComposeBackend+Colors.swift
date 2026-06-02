import AndroidKit
import SwiftCrossUI

extension SwiftCrossUI.Color.Resolved {
    func asColorInt() -> Int32 {
        let alpha = UInt32(opacity * 255.0 + 0.5)
        let red = UInt32(red * 255.0 + 0.5)
        let green = UInt32(green * 255.0 + 0.5)
        let blue = UInt32(blue * 255.0 + 0.5)

        let combined = (alpha << 24) | (red << 16) | (green << 8) | blue

        return Int32(bitPattern: combined)
    }

    init(fromColorInt int: Int32) {
        let uint = UInt32(bitPattern: int)

        let alpha = Float(uint >> 24) / 255.0
        let red = Float((uint & 0x00FF0000) >> 16) / 255.0
        let green = Float((uint & 0x0000FF00) >> 8) / 255.0
        let blue = Float(uint & 0x000000FF) / 255.0

        self.init(
            red: red,
            green: green,
            blue: blue,
            opacity: alpha
        )
    }
}

// swiftlint:disable force_try
extension AndroidComposeBackend: BackendFeatures.Colors {
    public func createColorableRectangle() -> Widget {
        // AndroidKit.View(Self.activity, environment: Self.env)
        return 1
    }

    public func setColor(
        ofColorableRectangle widget: Widget,
        to color: SwiftCrossUI.Color.Resolved
    ) {
        // widget.setBackgroundColor(color.asColorInt())
    }

    public func resolveAdaptiveColor(
        _ adaptiveColor: SwiftCrossUI.Color.SystemAdaptive,
        in environment: EnvironmentValues
    ) -> SwiftCrossUI.Color.Resolved {
        let Rcolor = try! JavaClass<AndroidKit.R.color>()

        let resId: Int32? =
            switch (adaptiveColor, environment.colorScheme) {
                case (.blue, .light): Rcolor.holo_blue_dark
                case (.blue, .dark): Rcolor.holo_blue_light
                case (.gray, _): Rcolor.darker_gray
                case (.green, .light): Rcolor.holo_green_dark
                case (.green, .dark): Rcolor.holo_green_light
                case (.orange, .light): Rcolor.holo_orange_dark
                case (.orange, .dark): Rcolor.holo_orange_light
                case (.red, .light): Rcolor.holo_red_dark
                case (.red, .dark): Rcolor.holo_red_light
                case (.purple, _): Rcolor.holo_purple
                default: // brown, yellow
                    nil
            }

        guard let resId else {
            return SwiftCrossUI.Color.defaultResolveAdaptiveColor(adaptiveColor, in: environment)
        }

        let colorInt = Self.activity.getColor(resId)

        return SwiftCrossUI.Color.Resolved(fromColorInt: colorInt)
    }
}
