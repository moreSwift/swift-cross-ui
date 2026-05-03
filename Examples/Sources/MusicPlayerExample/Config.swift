import Foundation

/// The user's configuration. Just contains the user's playlists for now.
struct Config: Codable {
    /// The default configuration used when the configuration file is invalid
    /// or missing.
    static let `default` = Self(playlists: [], songs: [])

    /// The user's playlists.
    var playlists: [Playlist]

    /// The user's songs
    var songs: [Song]

    func song(withId id: UUID) -> Song? {
        songs.first { song in
            song.id == id
        }
    }
}
