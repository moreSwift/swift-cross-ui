import SwiftCrossUI
import UIKit
import UIKitCompatKit

extension Font.Resolved {
    var uiFont: UIFont {
        let uiFont: UIFont
        
        if #available(iOS 8.2, *) {
            switch identifier.kind {
                case .system:
                    let weight: UIFont.Weight =
                        switch weight {
                            case .ultraLight: .ultraLight
                            case .thin: .thin
                            case .light: .light
                            case .regular: .regular
                            case .medium: .medium
                            case .semibold: .semibold
                            case .bold: .bold
                            case .heavy: .heavy
                            case .black: .black
                        }
                
                    switch design {
                        //MARK: Sketchy asf
                        case .monospaced:
                        if #available(iOS 13.0, *) {
                            uiFont = .monospacedSystemFont(ofSize: CGFloat(pointSize), weight: weight)
                        } else {
                            uiFont = .systemFont(ofSize: CGFloat(pointSize), weight: weight)
                        }
                        case .default:
                            uiFont = .systemFont(ofSize: CGFloat(pointSize), weight: weight)
                    }
            }

            if isItalic {
                let descriptor = uiFont.fontDescriptor.withSymbolicTraits(.traitItalic)
                return UIFont(
                    descriptor: descriptor ?? uiFont.fontDescriptor,
                    size: CGFloat(pointSize)
                )
            } else {
                return uiFont
            }
        } else {
            switch identifier.kind {
                case .system:
                    let weight: UIFontWeight =
                        switch weight {
                            case .ultraLight: .ultraLight
                            case .thin: .thin
                            case .light: .light
                            case .regular: .regular
                            case .medium: .medium
                            case .semibold: .semibold
                            case .bold: .bold
                            case .heavy: .heavy
                            case .black: .black
                        }
                
                    switch design {
                        //MARK: Sketchy asf
                        case .monospaced:
                        if #available(iOS 13.0, *) {
                            uiFont = .monospacedSystemFont(ofSize: CGFloat(pointSize), weight: weight)
                        } else {
                            uiFont = .systemFont(ofSize: CGFloat(pointSize), weight: weight)
                        }
                        case .default:
                            uiFont = .systemFont(ofSize: CGFloat(pointSize), weight: weight)
                    }
                return uiFont
            }
        }
    }
}
