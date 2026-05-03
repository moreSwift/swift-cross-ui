/// A shape type that is able to inset itself to produce another shape.
public protocol InsettableShape: Shape {
    /// The type of the inset shape.
    associatedtype InsetShape: InsettableShape

    /// Returns `self` inset by `amount`.
    nonisolated func inset(by amount: Double) -> InsetShape
}

/// The `InsetShape` implementation used by ``Rectangle``, ``Ellipse``, ``Circle``, and ``Capsule``.
///
/// This implementation only works for convex shapes where insetting the shape is equivalent to
/// making the shape smaller.
struct InsettableShapeImpl<Base: Shape>: InsettableShape {
    var inset: Double
    var base: Base

    nonisolated func path(in bounds: Path.Rect) -> Path {
        base.path(
            in: .init(
                x: bounds.x + inset,
                y: bounds.y + inset,
                width: bounds.width - 2 * inset,
                height: bounds.height - 2 * inset
            )
        )
    }

    nonisolated func size(fitting proposal: ProposedViewSize) -> ViewSize {
        let innerProposal = ProposedViewSize(
            proposal.width.map { max(0, $0 - 2 * inset) },
            proposal.height.map { max(0, $0 - 2 * inset) }
        )

        let innerSize = base.size(fitting: innerProposal)

        return ViewSize(
            innerSize.width + 2 * inset,
            innerSize.height + 2 * inset
        )
    }

    func inset(by amount: Double) -> InsettableShapeImpl<Base> {
        .init(inset: inset + amount, base: base)
    }
}
