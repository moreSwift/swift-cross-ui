import Foundation
import SwiftCrossUI

struct PlaylistView: View {
    @Environment(\.chooseFile) var chooseFile

    @State var isEditing = false
    @State var newSong: Song?

    @Binding var config: Config
    @Binding var playlist: Playlist

    var songStorage: SongStorage // observed by MusicPlayerApp
    var mediaPlayer: MediaPlayer // observed by MusicPlayerApp

    var body: some View {
        VStack(alignment: .leading) {
            header

            Divider()

            if let newSong = Binding($newSong) {
                SongEditor(song: newSong, songStorage: songStorage)
                    .onSave {
                        let newSong = newSong.wrappedValue
                        config.songs.append(newSong)
                        playlist.songs.append(newSong.id)
                        self.newSong = nil
                    }
                    .onCancel {
                        self.newSong = nil
                    }
            } else {
                ForEach(Array(playlist.songs.enumerated()), id: \.element) { (index, songId) in 
                    if let song = config.song(withId: songId) {
                        if let songFile = songStorage.loadCachedSong(id: song.id) {
                            SongRow(
                                index: index,
                                song: song,
                                songFile: songFile,
                                mediaPlayer: mediaPlayer
                            )
                        } else {
                            SongRow(
                                index: index,
                                song: song,
                                songFile: nil,
                                mediaPlayer: mediaPlayer
                            ).task {
                                do {
                                    _ = try songStorage.loadSong(id: song.id)
                                } catch {
                                    // TODO: Wire this up to some sort of visual indication
                                    // on the song. Maybe store results in the song storage
                                    // cache instead of song files. Actually yeah that'd probably
                                    // be best cause it'd avoid us loading failed songs again
                                    // and again.
                                    print("Failed to load song: \(error.localizedDescription)")
                                }
                            }
                        }
                    } else {
                        SongRow(
                            index: index,
                            song: Song(name: songId.uuidString),
                            songFile: nil,
                            mediaPlayer: mediaPlayer
                        )
                    }

                    Divider()
                }
            }
        }
    }

    var header: some View {
        HStack {
            PlaylistCover(image: playlist.image, dimension: 100, cornerRadius: 0)
                .if(isEditing) { cover in
                    cover.overlay {
                        Color.black.opacity(0.5)
                    }.overlay {
                        Text("Edit").font(.system(size: 12))
                    }.onTapGesture {
                        Task {
                            let result = await chooseFile(
                                title: "Choose playlist cover",
                                defaultButtonLabel: "Choose",
                                initialDirectory: nil,
                                showHiddenFiles: false,
                                allowSelectingFiles: true,
                                allowSelectingDirectories: false
                            )
                            if let result {
                                playlist.image = result
                            }
                        }
                    }
                }
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 5) {
                if isEditing {
                    TextField("Name", text: $playlist.name)
                    TextField("Description", text: $playlist.description)

                    Button("Save") {
                        isEditing = false
                    }
                } else {
                    Text(playlist.name)
                        .font(.system(size: 24))
                    Text(playlist.description)

                    HStack {
                        Button("Edit") {
                            isEditing = true
                        }

                        Button("Add song") {
                            newSong = Song.init(name: "")
                        }.disabled(newSong != nil)
                    }.padding(.top, 5)
                }
            }
        }.onAppear {
            if playlist.name == "" {
                isEditing = true
            }
        }
    }
}
