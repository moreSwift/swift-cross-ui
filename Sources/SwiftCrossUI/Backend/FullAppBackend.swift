/// Denotes a fully-featured backend that implements all features of
/// SwiftCrossUI.
///
/// ## Topics
///
/// ### Constituent Protocols
/// - ``BaseAppBackend``
/// - ``BackendFeatures/MenuButtons``
/// - ``BackendFeatures/Paths``
/// - ``BackendFeatures/Alerts``
/// - ``BackendFeatures/Sheets``
/// - ``BackendFeatures/IncomingURLs``
/// - ``BackendFeatures/ExternalURLs``
/// - ``BackendFeatures/RevealFiles``
/// - ``BackendFeatures/ApplicationMenus``
/// - ``BackendFeatures/FileDialogs``
/// - ``BackendFeatures/CornerRadius``
/// - ``BackendFeatures/WebViews``
/// - ``BackendFeatures/Tables``
/// - ``BackendFeatures/Gestures``
/// - ``BackendFeatures/Tooltips``
/// - ``BackendFeatures/Colors``
/// - ``BackendFeatures/DatePickers``
/// - ``BackendFeatures/Windowing``
/// - ``BackendFeatures/Gradients``
/// - ``BackendFeatures/FocusHandling``
/// - ``BackendFeatures/FocusDisabling``
/// - ``BackendFeatures/ColorPickers``
public typealias FullAppBackend =
    BaseAppBackend
        & BackendFeatures.MenuButtons
        & BackendFeatures.Paths
        & BackendFeatures.Alerts
        & BackendFeatures.Sheets
        & BackendFeatures.IncomingURLs
        & BackendFeatures.ExternalURLs
        & BackendFeatures.RevealFiles
        & BackendFeatures.ApplicationMenus
        & BackendFeatures.FileDialogs
        & BackendFeatures.CornerRadius
        & BackendFeatures.WebViews
        & BackendFeatures.Tables
        & BackendFeatures.Gestures
        & BackendFeatures.Tooltips
        & BackendFeatures.Colors
        & BackendFeatures.DatePickers
        & BackendFeatures.Windowing
        & BackendFeatures.Gradients
        & BackendFeatures.FocusHandling
        & BackendFeatures.FocusDisabling
        & BackendFeatures.ColorPickers

/// A typealias for ``FullAppBackend``.
///
/// Long story short, [SwiftCrossUI PR #513](https://github.com/moreSwift/swift-cross-ui/pull/513)
/// completely refactored the monolithic `AppBackend` protocol, splitting it out
/// into around three dozen smaller protocols. This typealias now refers to
/// another typealias that composes all of these protocols together, meaning
/// it should behave just as it used to.
///
/// After SwiftCrossUI 1.0.0, this typealias will be removed and we may choose
/// to reuse the name `AppBackend`.
@available(
    *,
    deprecated,
    renamed: "FullAppBackend",
    message: """
        This is now a composition of many smaller protocols; see SwiftCrossUI \
        PR #513 for details
        """
)
public typealias AppBackend = FullAppBackend

/// This utility function purely exists as a way to get the type checker to enforce
/// FullAppBackend conformance on the passed value at compile time. We use this
/// approach to ensure that backends such as AppKitBackend conform to FullAppBackend
/// so that we can implement the backend's features across multiple files with explicit
/// conformances to each constituent protocol of FullAppBackend.
@_spi(Backends)
public func ensureFullAppBackendConformance<Backend: FullAppBackend>(_ backend: Backend) {}
