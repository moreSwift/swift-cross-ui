import SwiftCrossUI

struct SongRow: View {
    var index: Int
    var song: Song
    var songFile: SongStorage.SongFile?
    var mediaPlayer: MediaPlayer

    @State var errorMessage: String?

    var durationString: String {
        if let songFile {
            let minutes = Int(songFile.duration) / 60
            let seconds = Int(songFile.duration) - minutes * 60
            return "\(minutes):\(String(format: "%02d", seconds))"
        } else {
            return "--:--"
        }
    }

    var enabled: Bool {
        songFile != nil
    }

    var body: some View {
        HStack {
            Text("\(index + 1)")

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(song.name)
                    if let artist = song.artist {
                        Text("\(artist)")
                            .foregroundColor(.gray)
                    }
                }
                Text(durationString)
            }
            .padding(.leading, 10)
            .fixedSize()

            Spacer()

            MediaControlButton(isPlaying: mediaPlayer.isPlayingSong(id: song.id))
                .onTapGesture {
                    guard let songFile else {
                        return
                    }
                    let action = songFile.sound.isPlaying ? "stop" : "start"
                    do {
                        if mediaPlayer.isPlayingSong(id: song.id) {
                            try mediaPlayer.pause()
                        } else {
                            try mediaPlayer.play(songFile, id: song.id)
                        }
                    } catch {
                        errorMessage = "Failed to \(action) sound: \(error.localizedDescription)"
                    }
                }
        }
        .padding([.leading, .trailing], 20)
        .disabled(!enabled)
        .alert($errorMessage) {
            Button("Ok") {}
        }
    }
}
