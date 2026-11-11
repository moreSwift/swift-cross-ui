@_spi(Backends) import SwiftCrossUI
import UIKit

extension UIKitBackend {
    public func resolveAdaptiveColor(
        _ adaptiveColor: Color.SystemAdaptive,
        in environment: EnvironmentValues
    ) -> Color.Resolved {
        let uiColor: UIColor =
            switch adaptiveColor.kind {
                case .blue: .systemBlue
                case .brown: .systemBrown
                case .gray: .systemGray
                case .green: .systemGreen
                case .orange: .systemOrange
                case .purple: .systemPurple
                case .red: .systemRed
                case .yellow: .systemYellow
            }

        let traitCollection = UITraitCollection(
            userInterfaceStyle: environment.colorScheme.userInterfaceStyle
        )
        let resolvedColor = uiColor.resolvedColor(with: traitCollection)
        return Color.Resolved(resolvedColor)
    }
}

extension Color.Resolved {
    init(_ uiColor: UIColor) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        self.init(
            red: Float(red),
            green: Float(green),
            blue: Float(blue),
            opacity: Float(alpha)
        )
    }

    var uiColor: UIColor {
        UIColor(
            red: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(opacity)
        )
    }

    var cgColor: CGColor {
        CGColor(
            red: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(opacity)
        )
    }
}
