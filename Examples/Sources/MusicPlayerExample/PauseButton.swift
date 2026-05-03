import SwiftCrossUI

struct PauseButton: Shape {
    func path(in bounds: Path.Rect) -> Path {
        let yInset: Double = 2
        let xInset: Double = 4
        return Path()
            .move(to: [xInset, yInset])
            .addLine(to: [xInset, bounds.maxY - yInset])
            .move(to: [bounds.maxX - xInset, yInset])
            .addLine(to: [bounds.maxX - xInset, bounds.maxY - yInset])
    }

    func size(fitting proposal: ProposedViewSize) -> ViewSize {
        ViewSize(17, 22)
    }
}
