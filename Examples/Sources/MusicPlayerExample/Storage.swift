import Foundation
import MiniAudio
import SwiftCrossUI

/// A manager for a storage directory. Storage directories currently contain
/// a configuration file (``Storage/configFile``) and a directory of songs
/// (``Storage/songsDirectory``).
class Storage: SwiftCrossUI.ObservableObject {
    /// The root storage directory.
    let directory: URL

    /// The contents of the configuration file. Just contains the user's
    /// playlists for now.
    @SwiftCrossUI.Published
    var config = Config.default

    @SwiftCrossUI.Published
    var songStorage: SongStorage

    /// Our observation of the config property. Used to save the config to
    /// disk on changes.
    var configObservation: Cancellable?

    /// Whether the configuration has been loaded from disk yet. See ``loadFile()``.
    ///
    /// If you modify ``config`` while this property is `false`, then the user's
    /// current configuration will get overwritten.
    @SwiftCrossUI.Published
    var loaded = false

    /// The location of the configuration file.
    var configFile: URL {
        directory.appendingPathComponent("config.json")
    }

    /// The directory containing the user's songs. Song files must be named
    /// after the UUID of their respective song entry in the configuration
    /// file.
    var songsDirectory: URL {
        Self.songsDirectory(for: directory)
    }

    /// Creates a manager for a given storage directory.
    init(directory: URL, engine: Engine) {
        self.directory = directory
        songStorage = SongStorage(
            directory: Self.songsDirectory(for: directory),
            engine: engine
        )
    }

    /// The body of ``songsDirectory`` as a static function so that we can use
    /// it in ``init(directory:engine:)`` before all properties have been
    /// initialized.
    private static func songsDirectory(for directory: URL) -> URL {
        directory.appendingPathComponent("songs")
    }

    /// Loads the configuration file from disk.
    ///
    /// If the configuration file is invalid then we back up the existing
    /// configuration file and then reset it to its default values.
    ///
    /// Sets ``loaded`` to `true`.
    func load() throws {
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
        }

        if !FileManager.default.fileExists(atPath: songsDirectory.path) {
            try FileManager.default.createDirectory(
                at: songsDirectory,
                withIntermediateDirectories: true
            )
        }

        if FileManager.default.fileExists(atPath: configFile.path) {
            let data = try Data(contentsOf: configFile)
            do {
                config = try JSONDecoder().decode(Config.self, from: data)
            } catch {
                // TODO: Warn the user that their config file was invalid and has been backed up
                let backupFile = configFile.appendingPathExtension("\(UUID().uuidString).old")
                print(
                    """
                    Invalid config. Backing up to \(backupFile.path) and using \
                    defaults. Error: \(error.localizedDescription)
                    """
                )
                try FileManager.default.copyItem(
                    at: configFile,
                    to: backupFile
                )
                config = Config.default
                try saveConfig()
            }
        } else {
            config = Config.default
            try saveConfig()
        }

        configObservation = _config.didChange.observe {
            do {
                try self.saveConfig()
            } catch {
                // TODO: Relay this failure to the user in a toast somehow
                print("Failed to save config to disk: \(error.localizedDescription)")
            }
        }

        loaded = true
    }

    /// Saves the current ``config`` to ``configFile``.
    func saveConfig() throws {
        let data = try JSONEncoder().encode(config)
        try data.write(to: configFile)
    }
}
