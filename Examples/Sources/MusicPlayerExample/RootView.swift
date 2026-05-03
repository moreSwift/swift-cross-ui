import SwiftCrossUI
import Foundation

struct RootView: View {
    var storage: Storage // observed by MusicPlayerApp
    var mediaPlayer: MediaPlayer // observed by MusicPlayerApp

    @State var selectedPlaylistId: UUID?

    var selectedPlaylist: Binding<Playlist>? {
        guard
            let selectedPlaylistId,
            let index = storage.config.playlists.firstIndex(
                where: { $0.id == selectedPlaylistId }
            )
        else {
            return nil
        }
        return storage.$config.playlists[index]
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationSplitView {
                VStack {
                    ScrollView {
                        List(storage.config.playlists, selection: $selectedPlaylistId) { playlist in
                            PlaylistListItem(playlist: playlist)
                        }.padding()
                    }

                    Group {
                        Button("New playlist") {
                            let playlist = Playlist(
                                name: "",
                                description: "",
                                image: nil,
                                songs: []
                            )
                            storage.config.playlists.append(playlist)
                            selectedPlaylistId = playlist.id
                        }
                    }.padding()
                }
                .frame(minWidth: 300)
            } detail: {
                ScrollView {
                    VStack {
                        if let selectedPlaylist {
                            PlaylistView(
                                config: storage.$config,
                                playlist: selectedPlaylist,
                                songStorage: storage.songStorage,
                                mediaPlayer: mediaPlayer
                            )
                        }
                    }.padding()
                }
            }

            Divider()

            PlaybackBar(storage: storage, mediaPlayer: mediaPlayer)
        }
    }
}
