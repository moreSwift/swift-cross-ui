/// Metadata loaded at app start up.
public struct AppMetadata {
    /// The app's reverse domain name identifier.
    public var identifier: String
    /// The app's version (generally a semantic version string).
    public var version: String
    /// Additional developer-defined metadata.
    public var additionalMetadata: [String: Any]

    /// Creates an ``AppMetadata`` instance.
    ///
    /// - Parameters:
    ///   - identifier: The app's reverse domain name identifier.
    ///   - version: The app's version (generally a semantic version string).
    ///   - additionalMetadata: Additional developer-defined metadata.
    public init(
        identifier: String,
        version: String,
        additionalMetadata: [String: Any]
    ) {
        self.identifier = identifier
        self.version = version
        self.additionalMetadata = additionalMetadata
    }
}
