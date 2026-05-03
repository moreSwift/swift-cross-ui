import SwiftCrossUI

struct PlaylistListItem: View {
    var playlist: Playlist

    var displayName: String {
        if playlist.name.trimmingCharacters(in: .whitespaces).isEmpty {
            "Untitled"
        } else {
            playlist.name
        }
    }

    var body: some View {
        HStack {
            PlaylistCover(image: playlist.image, dimension: 40, cornerRadius: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                Text("\(playlist.songs.count) songs")
                    .foregroundColor(.gray)
            }
        }
    }
}
