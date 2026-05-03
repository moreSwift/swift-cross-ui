import Foundation

struct MusicPlayerError: LocalizedError {
    var message: String

    var errorDescription: String? {
        message
    }
}
