import DefaultBackend
import Foundation
import SwiftCrossUI

// P0 Windows repro app:
// - #493 WinUIBackend: crashes if an environment action is called too early.
// - #548 @AppStorage crashes on Windows.
//
// Build this file as a standalone app target; do not compile P0...P4 together
// because each file intentionally declares its own @main app.

@main
@HotReloadable
struct P0CriticalWinUIApp: App {
    @AppStorage(\.p0LaunchCount) var launchCount
    @State var showAlertScene = false

    var body: some Scene {
        WindowGroup("P0 WinUI critical checks") {
            #hotReloadable {
                P0CriticalView(launchCount: $launchCount, showAlertScene: $showAlertScene)
            }
        }
        .defaultSize(width: 520, height: 360)

        AlertScene("P0 launch AlertScene", isPresented: $showAlertScene) {
            Button("OK") {
                showAlertScene = false
            }
        }
    }
}

struct P0CriticalView: View {
    @Binding var launchCount: Int
    @Binding var showAlertScene: Bool
    @State var eventLog = "Ready. Use the buttons to run one check at a time."

    @Environment(\.presentAlert) var presentAlert

    var body: some View {
        VStack(spacing: 12) {
            Text("P0: launch-time alert + AppStorage")
                .font(.system(size: 18))

            Text("This app no longer auto-presents alerts on launch, so it can open before you trigger the crash repro.")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Launch count stored in @AppStorage: \(launchCount)")

            HStack {
                Button("Increment @AppStorage") {
                    launchCount += 1
                    eventLog = "Incremented @AppStorage to \(launchCount)"
                }

                Button("Reset") {
                    launchCount = 0
                    eventLog = "Reset @AppStorage"
                }
            }

            Button("Show AlertScene") {
                eventLog = "Showing AlertScene..."
                showAlertScene = true
            }

            Button("Present environment alert now") {
                Task {
                    P0DebugLog.write("immediate alert button clicked")
                    eventLog = "Presenting manual environment alert..."
                    await presentAlert("Manual P0 alert") {
                        Button("OK") {
                            P0DebugLog.write("immediate alert OK clicked")
                            eventLog = "Manual alert dismissed"
                        }
                    }
                    P0DebugLog.write("immediate presentAlert returned")
                }
            }

            Button("Present environment alert after 1 second") {
                Task {
                    P0DebugLog.write("delayed alert button clicked")
                    eventLog = "Waiting 1 second before presenting alert..."
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    P0DebugLog.write("delayed alert sleep finished")
                    eventLog = "Presenting delayed environment alert..."
                    await presentAlert("Delayed P0 alert") {
                        Button("OK") {
                            P0DebugLog.write("delayed alert OK clicked")
                            eventLog = "Delayed alert dismissed"
                        }
                    }
                    P0DebugLog.write("delayed presentAlert returned")
                }
            }

            Text(eventLog)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .onAppear {
            launchCount += 1
            eventLog = "Window appeared. Incremented @AppStorage to \(launchCount)."
        }
    }
}

extension AppStorageValues {
    @Entry var p0LaunchCount: Int = 0
}

enum P0DebugLog {
    static func write(_ message: String) {
        let line = "\(Date()) \(message)\n"
        let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("p0-debug-events.log")

        if let data = line.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: path.path),
               let handle = try? FileHandle(forWritingTo: path)
            {
                try? handle.seekToEnd()
                try? handle.write(contentsOf: data)
                try? handle.close()
            } else {
                try? data.write(to: path)
            }
        }
    }
}
