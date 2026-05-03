import SwiftCrossUI

struct PlaybackBar: View {
    var storage: Storage // observed by MusicPlayerApp
    var mediaPlayer: MediaPlayer // observed by MusicPlayerApp

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                if let currentSongId = mediaPlayer.currentSong,
                    let song = storage.config.song(withId: currentSongId)
                {
                    Text(song.name)
                    if let artist = song.artist {
                        Text(artist)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack {
                MediaControlButton(isPlaying: mediaPlayer.isPlaying)
                    .onTapGesture {
                        // TODO: Propagate errors from here
                        try? mediaPlayer.toggleCurrentSong()
                    }
                    .disabled(mediaPlayer.currentSong == nil)

                ProgressView(value: mediaPlayer.progress ?? 0)
                    .frame(maxWidth: 400)
            }.frame(maxWidth: .infinity)

            VStack {
                // TODO: Fix the underlying issue that caused this workaround to
                //   be required post-layout-system-refactor. This VStack should
                //   be able to just be a Spacer.
                Text("")
            }.frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
