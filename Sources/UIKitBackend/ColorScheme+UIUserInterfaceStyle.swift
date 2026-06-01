import SwiftCrossUI
import UIKit

extension ColorScheme {
    @available(iOS 12, *)
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
            case .light:
                return .light
            case .dark:
                return .dark
        }
    }
}
