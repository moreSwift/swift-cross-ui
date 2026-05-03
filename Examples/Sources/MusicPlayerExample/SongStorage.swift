import Foundation
import MiniAudio
import SwiftCrossUI

class SongStorage: SwiftCrossUI.ObservableObject {
    var engine: Engine
    var directory: URL

    @SwiftCrossUI.Published
    var cache: [UUID: SongFile] = [:]

    struct SongFile {
        var file: URL
        var duration: Double
        var sound: Sound
    }

    init(directory: URL, engine: Engine) {
        self.directory = directory
        self.engine = engine
    }

    func loadCachedSong(id: UUID) -> SongFile? {
        cache[id]
    }

    func loadSong(id: UUID) throws -> SongFile {
        if let song = cache[id] {
            return song
        }

        let contents = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        )

        guard
            let file = contents.filter({ file in
                file.deletingPathExtension().lastPathComponent == id.uuidString
            }).first
        else {
            throw MusicPlayerError(message: "File not found for song '\(id.uuidString)'")
        }

        let sound = try engine.loadSound(file)
        let duration = try sound.duration

        let songFile = SongFile(
            file: file,
            duration: duration,
            sound: sound
        )
        cache[id] = songFile
        return songFile
    }

    func insertSong(_ file: URL, id: UUID) throws {
        let destination = directory.appendingPathComponent(id.uuidString)
            .appendingPathExtension(file.pathExtension)

        try FileManager.default.copyItem(
            at: file,
            to: destination
        )

        // Make sure that the sound loads and add it to the cache pre-emptively.
        let sound = try engine.loadSound(destination)
        let duration = try sound.duration

        let songFile = SongFile(
            file: file,
            duration: duration,
            sound: sound
        )
        cache[id] = songFile
    }
}
