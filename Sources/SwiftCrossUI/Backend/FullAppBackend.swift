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
    *, deprecated, renamed: "FullAppBackend",
     message: "this is now a composition of many smaller protocols; see SwiftCrossUI PR #513 for details"
)
public typealias AppBackend = FullAppBackend
