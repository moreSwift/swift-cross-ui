import SwiftCrossUI
import UIKit

extension UIKitBackend {
    public typealias Sheet = CustomSheet

    public func createSheet(content: Widget) -> CustomSheet {
        let sheet = CustomSheet()
        #if !os(tvOS)
            sheet.modalPresentationStyle = .pageSheet
        #else
            sheet.modalPresentationStyle = .overFullScreen
        #endif

        let contentView = UIView()
        // Fetch the child controller before adding the child to the view
        // hierarchy. Otherwise, if the child doesn't have its own controller, we'd
        // get back a reference to the sheet controller and attempt to add it as a
        // child of itself.
        if let childController = content.controller {
            sheet.addChild(childController)
        }
        contentView.addSubview(content.view)

        sheet.topConstraint = contentView.topAnchor.constraint(
            equalTo: content.view.topAnchor,
            constant: 0
        )
        sheet.leadingConstraint = contentView.centerXAnchor.constraint(
            equalTo: content.view.centerXAnchor
        )
        sheet.topConstraint?.isActive = true
        sheet.leadingConstraint?.isActive = true

        sheet.view = contentView

        return sheet
    }

    public func updateSheet(
        _ sheet: CustomSheet,
        window: Window,
        environment: EnvironmentValues,
        size: SIMD2<Int>,
        onDismiss: @escaping () -> Void,
        cornerRadius: Double?,
        detents: [PresentationDetent],
        dragIndicatorVisibility: Visibility,
        backgroundColor: Color.Resolved?,
        interactiveDismissDisabled: Bool
    ) {
        sheet.onDismiss = onDismiss
        setPresentationDetents(of: sheet, to: detents)
        setPresentationCornerRadius(of: sheet, to: cornerRadius)
        setPresentationDragIndicatorVisibility(
            of: sheet, to: dragIndicatorVisibility, detents: detents)

        let defaultColor: UIColor?
        #if targetEnvironment(macCatalyst)
            defaultColor = nil
        #else
            // These values were obtained by measuring the colors on my Mac, so they
            // are likely not completely accurate (these are just how they appeared
            // in my Mac's color space).
            switch environment.colorScheme {
                case .light:
                    defaultColor = UIColor(
                        red: 1, green: 1, blue: 1, alpha: 1
                    )
                case .dark:
                    #if os(tvOS)
                        defaultColor = UIColor(
                            red: 15 / 255, green: 15 / 255, blue: 15 / 255, alpha: 1
                        )
                    #else
                        defaultColor = UIColor(
                            red: 28 / 255, green: 28 / 255, blue: 30 / 255, alpha: 1
                        )
                    #endif
            }
        #endif
        sheet.view.backgroundColor = backgroundColor?.uiColor ?? defaultColor

        // From the UIKit docs for isModalInPresentation:
        //   When you set it to true, UIKit ignores events outside the view controller’s
        //   bounds and prevents the interactive dismissal of the view controller while
        //   it is onscreen.
        sheet.isModalInPresentation = interactiveDismissDisabled
    }

    public func presentSheet(
        _ sheet: CustomSheet,
        window: Window,
        parentSheet: Sheet?
    ) {
        // We use the controller of the parent sheet (if present) or the controller
        // of the root window. This allows us to walk the chain of nested presentations
        // easily by repeatedly accessing presentedViewController. If we just used the
        // 'closest' controller to the view that caused the presentation, then the
        // chain wouldn't be continuous (and we can't do that anyway with the way
        // AppBackend's sheet API has been constructed).
        let enclosingController = parentSheet ?? window.rootViewController
        enclosingController!.present(sheet, animated: true)
    }

    public func dismissSheet(_ sheet: CustomSheet, window: Window, parentSheet: Sheet?) {
        // UIKit automatically dismisses nested presentations on our behalf.
        sheet.dismissProgrammatically()
    }

    public func sizeOf(_ sheet: CustomSheet) -> SIMD2<Int> {
        let size = sheet.view.frame.size
        return SIMD2(x: Int(size.width), y: Int(size.height))
    }

    private func setPresentationDetents(of sheet: CustomSheet, to detents: [PresentationDetent]) {
        if #available(iOS 15.0, macCatalyst 15.0, *) {
            #if !os(tvOS) && !os(visionOS)
                if let sheetPresentation = sheet.sheetPresentationController {
                    // From the UIKit docs for `detents`:
                    //   The default value is an array that contains the value
                    //   large(). This array must contain at least one element.
                    guard !detents.isEmpty else {
                        sheetPresentation.detents = [.large()]
                        return
                    }

                    sheetPresentation.detents = detents.map {
                        switch $0 {
                            case .medium: return .medium()
                            case .large: return .large()
                            case .fraction(let fraction):
                                if #available(iOS 16.0, *) {
                                    return .custom(
                                        identifier: .init("Fraction:\(fraction)"),
                                        resolver: { context in
                                            context.maximumDetentValue * fraction
                                        }
                                    )
                                } else {
                                    return .medium()
                                }
                            case .height(let height):
                                if #available(iOS 16.0, *) {
                                    return .custom(
                                        identifier: .init("Height:\(height)"),
                                        resolver: { context in
                                            height
                                        }
                                    )
                                } else {
                                    return .medium()
                                }
                        }
                    }
                }
            #endif
        } else {
            // TODO: Maybe we can backport the detent behaviour?
            debugLogOnce(
                """
                your current OS version doesn't support variable sheet heights; \
                setting presentationDetents only has an effect from iOS 15.0; \
                tvOS and visionOS do not support it at all
                """
            )
        }
    }

    private func setPresentationCornerRadius(of sheet: CustomSheet, to radius: Double?) {
        if #available(iOS 15.0, *) {
            #if !os(tvOS) && !os(visionOS)
                if let sheetController = sheet.sheetPresentationController {
                    sheetController.preferredCornerRadius = radius.map { CGFloat($0) }
                }
            #endif
        } else {
            debugLogOnce(
                """
                your current OS version doesn't support variable sheet corner \
                radii; setting them only has an effect from iOS 15.0; tvOS and \
                visionOS do not support it at all
                """
            )
        }
    }

    private func setPresentationDragIndicatorVisibility(
        of sheet: Sheet,
        to visibility: Visibility,
        detents: [PresentationDetent]
    ) {
        if #available(iOS 15.0, *) {
            #if !os(tvOS) && !os(visionOS)
                if let sheetController = sheet.sheetPresentationController {
                    switch visibility {
                        case .visible:
                            sheetController.prefersGrabberVisible = true
                        case .hidden:
                            sheetController.prefersGrabberVisible = false
                        case .automatic:
                            sheetController.prefersGrabberVisible = detents.count > 1
                    }
                }
            #endif
        } else {
            debugLogOnce(
                """
                your current OS version doesn't support setting sheet drag \
                indicator visibility; setting this only has an effect from iOS \
                15.0; tvOS and visionOS do not support it at all
                """
            )
        }
    }
}

public final class CustomSheet: UIViewController {
    var onDismiss: (() -> Void)?
    private var wasDismissedProgrammatically = false

    var topConstraint: NSLayoutConstraint?
    var leadingConstraint: NSLayoutConstraint?

    func dismissProgrammatically() {
        let hasNestedPresentation = presentedViewController != nil
        if hasNestedPresentation {
            // This will dismiss all nested presentations
            dismiss(animated: false)
        }

        // When the controller doesn't have a nested presentation, which
        // we've guaranteed at this point, `dismiss` defers to the controller
        // that presented the current controller to `dismiss` the current
        // controller, which is what we want.
        wasDismissedProgrammatically = true
        dismiss(animated: true)
    }

    public override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        // Support escape-to-dismiss for iPadOS and Mac Catalyst
        var unhandledPresses: Set<UIPress> = []
        for press in presses {
            if let key = press.key, key.keyCode == .keyboardEscape {
                dismiss(animated: true)
            } else {
                unhandledPresses.insert(press)
            }
        }

        super.pressesBegan(unhandledPresses, with: event)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Only call onDismiss if the sheet was dismissed by user interaction
        // (swipe down, tap outside) not when dismissed programmatically via
        // the dismiss action.
        if !wasDismissedProgrammatically {
            onDismiss?()
        }
    }
}
