import SwiftCrossUI
import UIKit
import UIKitCompatKit

extension UIColor {
    convenience init(color: Color) {
        self.init(
            red: CGFloat(color.red),
            green: CGFloat(color.green),
            blue: CGFloat(color.blue),
            alpha: CGFloat(color.alpha)
        )
    }
}

extension Color {
    init(_ uiColor: UIColor) {
        let ciColor = CIColor(color: uiColor)

        self.init(
            Float(ciColor.red),
            Float(ciColor.green),
            Float(ciColor.blue),
            Float(ciColor.alpha)
        )
    }

    var uiColor: UIColor {
        UIColor(color: self)
    }

    var cgColor: CGColor {
        /*if #available(iOS 13.0, *) {
            CGColor(
                red: CGFloat(red),
                green: CGFloat(green),
                blue: CGFloat(blue),
                alpha: CGFloat(alpha)
            )
        } else {
            //MARK: this won't work right now, get back to me on it.
            
        }*/
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let components: [CGFloat] = [CGFloat(red), CGFloat(green), CGFloat(blue), CGFloat(alpha)]
        return CGColor(colorSpace: colorSpace, components: components)!
    }
}
