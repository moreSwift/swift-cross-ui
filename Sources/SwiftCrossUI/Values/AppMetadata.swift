/// Metadata loaded at app start up.
public struct AppMetadata {
    /// The app's reverse domain name identifier.
    public var identifier: String
    /// The app's version (generally a semantic version string).
    public var version: String
    /// The app's declared URL schemes.
    public var urlSchemes: [URLScheme]?
    /// Additional developer-defined metadata.
    public var additionalMetadata: [String: Any]

    /// A URL scheme registered by an app.
    public struct URLScheme {
        public var scheme: String
    }

    /// Creates an ``AppMetadata`` instance.
    ///
    /// - Parameters:
    ///   - identifier: The app's reverse domain name identifier.
    ///   - version: The app's version (generally a semantic version string).
    ///   - urlSchemes: The app's URL schemes.
    ///   - additionalMetadata: Additional developer-defined metadata.
    public init(
        identifier: String,
        version: String,
        urlSchemes: [URLScheme]? = nil,
        additionalMetadata: [String: Any]
    ) {
        self.identifier = identifier
        self.version = version
        self.urlSchemes = urlSchemes
        self.additionalMetadata = additionalMetadata
    }
}
