import Foundation

/// A song's metadata.
struct Song: Codable, Identifiable {
    /// The song's unique id.
    var id = UUID()
    /// The song's name.
    var name: String
    /// The song's album, if given.
    var album: String?
    /// The song's artist, if given.
    var artist: String?
}
