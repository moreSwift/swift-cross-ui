import Foundation

public struct PreferenceValues: Sendable {
    /// The default preferences.
    public static let `default` = PreferenceValues(
        onOpenURL: nil,
        presentationDetents: nil,
        presentationCornerRadius: nil,
        presentationDragIndicatorVisibility: nil,
        presentationBackground: nil,
        interactiveDismissDisabled: nil,
        windowDismissBehavior: nil,
        preferredWindowMinimizeBehavior: nil,
        windowResizeBehavior: nil
    )

    public var onOpenURL: (@Sendable @MainActor (URL) -> Void)?

    /// The available detents for a sheet presentation. Applies to enclosing sheets.
    public var presentationDetents: [PresentationDetent]?

    /// The corner radius for a sheet presentation. Applies to enclosing sheets.
    public var presentationCornerRadius: Double?

    /// The drag indicator visibility for a sheet presentation. Applies to enclosing sheets.
    public var presentationDragIndicatorVisibility: Visibility?

    /// The background color for enclosing sheets.
    public var presentationBackground: Color?

    /// Controls whether the user can interactively dismiss enclosing sheets.
    public var interactiveDismissDisabled: Bool?

    /// Controls whether the user can close the enclosing window.
    public var windowDismissBehavior: WindowInteractionBehavior?

    /// Controls whether the user can minimize the enclosing window.
    public var preferredWindowMinimizeBehavior: WindowInteractionBehavior?

    /// Controls whether the user can resize the enclosing window.
    public var windowResizeBehavior: WindowInteractionBehavior?
}

extension PreferenceValues {
    init(merging children: [PreferenceValues]) {
        let handlers = children.compactMap(\.onOpenURL)

        if !handlers.isEmpty {
            onOpenURL = { url in
                for handler in handlers {
                    handler(url)
                }
            }
        }

        // For presentation modifiers, take the outer-most value (using child ordering to break ties).
        presentationDetents = children.compactMap(\.presentationDetents).first
        presentationCornerRadius = children.compactMap(\.presentationCornerRadius).first
        presentationDragIndicatorVisibility =
            children.compactMap(\.presentationDragIndicatorVisibility).first
        presentationBackground = children.compactMap(\.presentationBackground).first
        interactiveDismissDisabled = children.compactMap(\.interactiveDismissDisabled).first

        windowDismissBehavior = children.compactMap(\.windowDismissBehavior).first
        preferredWindowMinimizeBehavior =
            children.compactMap(\.preferredWindowMinimizeBehavior).first
        windowResizeBehavior = children.compactMap(\.windowResizeBehavior).first
    }
}
