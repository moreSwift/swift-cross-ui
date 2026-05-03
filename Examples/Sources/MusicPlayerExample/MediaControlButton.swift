import SwiftCrossUI

struct MediaControlButton: View {
    @Environment(\.isEnabled) var isEnabled

    var isPlaying: Bool

    var playbackButtonColor: Color {
        isEnabled ? .green : .gray
    }

    var body: some View {
        Group {
            if isPlaying {
                applyShapeStyle(PauseButton())
            } else {
                applyShapeStyle(PlayButton())
            }
        }
    }

    func applyShapeStyle<S: Shape>(_ shape: S) -> some StyledShape {
        shape.stroke(
            playbackButtonColor,
            style: StrokeStyle(width: 4, cap: .round, join: .round)
        ).fill(playbackButtonColor)
    }
}
