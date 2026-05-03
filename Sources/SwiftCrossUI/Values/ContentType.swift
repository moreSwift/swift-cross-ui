/// A content type corresponding to a specific file/data format.
public struct ContentType: Sendable {
    /// The HTML content type.
    public static let html = ContentType(
        name: "HTML",
        mimeTypes: ["text/html"],
        fileExtensions: ["html", "htm"]
    )

    /// The name of this content type.
    public var name: String
    /// An array of MIME types associated with this content type.
    public var mimeTypes: [String]
    /// An array of file extensions associated with this content type.
    public var fileExtensions: [String]

    /// Creates an instance of `ContentType`.
    ///
    /// - Parameters:
    ///   - name: The name of this content type.
    ///   - mimeTypes: An array of MIME types associated with this content type.
    ///   - fileExtensions: An array of file extensions associated with this
    ///     content type.
    public init(name: String, mimeTypes: [String], fileExtensions: [String]) {
        self.name = name
        self.mimeTypes = mimeTypes
        self.fileExtensions = fileExtensions
    }
}
