import DefaultBackend
import Foundation
import SwiftCrossUI
import MiniAudio

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct MusicPlayerApp: App {
    @Environment(\.presentAlert) var presentAlert

    @State var storage: Storage?
    @State var initializationError: String?
    @State var mediaPlayer = MediaPlayer()
    var engine: Engine?

    init() {
        let identifier = Self.metadata?.identifier ?? "com.example.MusicPlayerExample"

        let engine: Engine
        do {
            engine = try Engine()
        } catch {
            initializationError = "Failed to load MiniAudio engine: \(error.localizedDescription)"
            return
        }
        self.engine = engine

        let applicationSupport: URL
        do {
            applicationSupport = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
        } catch {
            initializationError = """
                Failed to get application support directory: \(error.localizedDescription)
                """
            return
        }

        let directory = applicationSupport.appendingPathComponent(identifier)
        let storage = Storage(directory: directory, engine: engine)
        _storage = State(wrappedValue: storage)
    }

    var body: some Scene {
        WindowGroup("Music Player") {
            #hotReloadable {
                content
            }
        }
    }

    var content: some View {
        VStack {
            if let initializationError {
                Text(initializationError)
                    .frame(maxWidth: 400)
                    .font(.system(size: 20, weight: nil, design: nil))

                Button("Exit app") {
                    Foundation.exit(1)
                }
            } else if let storage, storage.loaded {
                RootView(storage: storage, mediaPlayer: mediaPlayer)
            } else {
                ProgressView("Loading")
            }
        }.task {
            guard let storage else {
                initializationError = "Failed to load storage: unknown reason"
                return
            }

            do {
                try storage.load()
            } catch {
                initializationError = "Failed to load config: \(error.localizedDescription)"
            }
        }
    }
}
