/// An ellipse.
public struct Ellipse: InsettableShape {
    /// Creates an ``Ellipse`` instance.
    public nonisolated init() {}

    public nonisolated func path(in bounds: Path.Rect) -> Path {
        Path()
            .addCircle(center: .zero, radius: bounds.width / 2.0)
            .applyTransform(
                AffineTransform(
                    linearTransform: SIMD4(
                        x: 1.0,
                        y: 0.0,
                        z: 0.0,
                        w: bounds.height / bounds.width
                    ),
                    translation: bounds.center
                )
            )
    }

    public nonisolated func inset(by amount: Double) -> some InsettableShape {
        InsettableShapeImpl(inset: amount, base: self)
    }
}
