import SwiftCrossUI

struct PlayButton: Shape {
    func path(in bounds: Path.Rect) -> Path {
        let inset: Double = 2
        return Path()
            .move(to: [inset, inset])
            .addLine(to: [bounds.maxX - inset, bounds.y + bounds.height / 2])
            .addLine(to: [inset, bounds.maxY - inset])
            .addLine(to: [inset, inset])
    }

    func size(fitting proposal: ProposedViewSize) -> ViewSize {
        ViewSize(17, 22)
    }
}
