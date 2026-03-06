/// Configuration for text height limits, propagated via ``EnvironmentValues/lineLimitSettings``.
public struct LineLimit: Sendable, Hashable {
    /// The maximum number of lines text may occupy.
    public var limit: Int
    /// A Boolean value indicating whether the view should reserve the full height
    /// required by the line limit, regardless of the content's length.
    public var reservesSpace: Bool
}
