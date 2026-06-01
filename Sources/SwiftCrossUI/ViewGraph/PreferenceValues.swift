import Foundation

public struct PreferenceValues: Sendable {
    public static let `default` = PreferenceValues(
        onOpenURL: nil
    )

    public var onOpenURL: (@Sendable @MainActor (URL) -> Void)?

    public init(onOpenURL: (@Sendable @MainActor (URL) -> Void)?) {
        self.onOpenURL = onOpenURL
    }

    public init(merging children: [PreferenceValues]) {
        // Extract all non-nil handlers from children
        let handlers: [(URL) -> Void] = children.compactMap { $0.onOpenURL }

        // Assign a closure that safely calls each handler
        onOpenURL = { url in
            for handler in handlers {
                // Wrap each call in a do/catch to prevent crashes from unexpected errors
                // or weak captures inside handlers
                do {
                    handler(url)
                } catch {
                    // Optionally log the error, but prevent crash
                    print("Warning: onOpenURL handler threw an error: \(error)")
                }
            }
        }
    }

}
