/// A rectangle.
public struct Rectangle: InsettableShape {
    /// Creates a ``Rectangle`` instance.
    public nonisolated init() {}

    public nonisolated func path(in bounds: Path.Rect) -> Path {
        Path().addRectangle(bounds)
    }

    public nonisolated func inset(by amount: Double) -> some InsettableShape {
        InsettableShapeImpl(inset: amount, base: self)
    }
}
