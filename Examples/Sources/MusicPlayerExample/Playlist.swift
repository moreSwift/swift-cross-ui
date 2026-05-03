import Foundation

/// A playlist's metadata
struct Playlist: Codable, Identifiable {
    /// The playlist's unique id.
    var id = UUID()
    /// The playlist's name.
    var name: String
    /// The playlist's description.
    var description: String
    /// The playlist's cover image.
    var image: URL?
    /// Metadata for each of the playlist's songs.
    var songs: [UUID]
}
