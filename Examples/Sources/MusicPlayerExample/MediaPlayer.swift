import Foundation
import SwiftCrossUI

class MediaPlayer: SwiftCrossUI.ObservableObject {
    @SwiftCrossUI.Published
    var currentSong: UUID?

    /// The cursor of the current song in seconds.
    @SwiftCrossUI.Published
    var cursor: Double = 0

    var progress: Double? {
        if let duration = songFile?.duration, duration != 0 {
            cursor / duration
        } else {
            nil
        }
    }

    @SwiftCrossUI.Published
    var isPlaying = false

    private var songFile: SongStorage.SongFile?
    private var progressTask: Task<Void, Never>?

    func isPlayingSong(id: UUID) -> Bool {
        id == currentSong && isPlaying
    }

    func play(_ songFile: SongStorage.SongFile, id: UUID) throws {
        if id != currentSong {
            // Rewind new song to the start if it's not the current song.
            try songFile.sound.seek(toSecond: 0)

            if let currentSongFile = self.songFile {
                // Stop current song if the new song is different.
                try currentSongFile.sound.stop()
            }
        }

        cursor = try songFile.sound.cursor

        // Make sure that the last fallible step is starting the song, otherwise
        // errors could be kinda annoying.
        try songFile.sound.start()

        progressTask?.cancel()
        progressTask = createProgressTask(for: songFile)

        isPlaying = true
        self.currentSong = id
        self.songFile = songFile
    }

    func pause() throws {
        if isPlaying, let songFile {
            try songFile.sound.stop()
            progressTask?.cancel()
            isPlaying = false
        }
    }

    func resume() throws {
        if !isPlaying, let songFile {
            try songFile.sound.start()
            progressTask = createProgressTask(for: songFile)
            isPlaying = true
        }
    }

    /// If the current song is playing, pauses it, otherwise resumes it.
    func toggleCurrentSong() throws {
        if isPlaying {
            try pause()
        } else {
            try resume()
        }
    }

    /// Creates a task which updates the current song's progress at a given
    /// frequency (updates per second).
    private func createProgressTask(
        for songFile: SongStorage.SongFile,
        frequency: Double = 30
    ) -> Task<Void, Never> {
        Task {
            while true {
                do {
                    try await Task.sleep(nanoseconds: UInt64(1 / frequency * 1_000_000_000))
                } catch {
                    break
                }

                do {
                    let cursor = try songFile.sound.cursor
                    // TODO: Is this needed? If so, can SwiftCrossUI enforce it?
                    Task { @MainActor in
                        self.cursor = cursor
                    }
                } catch {
                    // TODO: Propagate this warning to the user
                    print("warning: Failed to update song cursor")
                    break
                }
            }
        }
    }
}
