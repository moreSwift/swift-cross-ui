/// Denotes a backend that implements a minimal subset of SwiftCrossUI
/// features.
///
/// This is the protocol your backend must conform to in order to be usable
/// with SwiftCrossUI APIs. It inherits all of ``BackendFeatures/Core`` as well
/// as many UI controls and containers.
///
/// ## Topics
///
/// ### Constituent Protocols
/// - ``BackendFeatures/Core``
/// - ``BackendFeatures/Containers``
/// - ``BackendFeatures/PassiveViews``
/// - ``BackendFeatures/Controls``
public typealias BaseAppBackend =
    BackendFeatures.Core
    & BackendFeatures.Containers
    & BackendFeatures.PassiveViews
    & BackendFeatures.Controls
