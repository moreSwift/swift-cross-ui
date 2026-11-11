@_spi(Backends) import SwiftCrossUI
import UIKit

extension ColorScheme {
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
            case .light:
                return .light
            case .dark:
                return .dark
        }
    }
}
