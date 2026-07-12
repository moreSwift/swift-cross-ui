import DefaultBackend
import Foundation
import SwiftCrossUI

// P1 Windows repro app:
// - #523 Windows File Open/Save dialog slow to appear.
// - #659 WinUIBackend: nested sheets not supported.
// - #660 WinUIBackend: sheets have default padding.
//
// Build this file as a standalone app target.

@main
@HotReloadable
struct P1DialogsAndSheetsWinUIApp: App {
    var body: some Scene {
        WindowGroup("P1 WinUI dialogs and sheets") {
            #hotReloadable {
                P1DialogsAndSheetsView()
            }
        }
        .defaultSize(width: 620, height: 520)
    }
}

struct P1DialogsAndSheetsView: View {
    @State var openResult = "No open result yet"
    @State var folderResult = "No folder result yet"
    @State var saveResult = "No save result yet"
    @State var lastTiming = "No timings yet"
    @State var rootSheetPresented = false

    @Environment(\.chooseFile) var chooseFile
    @Environment(\.chooseFileSaveDestination) var chooseFileSaveDestination

    var body: some View {
        VStack(spacing: 14) {
            Text("P1: dialogs, nested sheets, and sheet padding")
                .font(.system(size: 18))

            Button("Open file dialog") {
                Task {
                    let startedAt = Date()
                    let result = await chooseFile(
                        title: "P1 open file",
                        defaultButtonLabel: "Open",
                        allowSelectingFiles: true,
                        allowSelectingDirectories: false
                    )
                    lastTiming = elapsedMessage("Open file", since: startedAt)
                    openResult = result?.path ?? "Cancelled"
                }
            }

            Button("Open folder dialog") {
                Task {
                    let startedAt = Date()
                    let result = await chooseFile(
                        title: "P1 choose folder",
                        defaultButtonLabel: "Choose",
                        allowSelectingFiles: false,
                        allowSelectingDirectories: true
                    )
                    lastTiming = elapsedMessage("Open folder", since: startedAt)
                    folderResult = result?.path ?? "Cancelled"
                }
            }

            Button("Save file dialog") {
                Task {
                    let startedAt = Date()
                    let result = await chooseFileSaveDestination(
                        title: "P1 save file",
                        defaultButtonLabel: "Save",
                        defaultFileName: "p1-output.txt"
                    )
                    lastTiming = elapsedMessage("Save file", since: startedAt)
                    saveResult = result?.path ?? "Cancelled"
                }
            }

            Button("Open root sheet") {
                rootSheetPresented = true
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(lastTiming)
                Text("Open: \(openResult)")
                Text("Folder: \(folderResult)")
                Text("Save: \(saveResult)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .sheet(isPresented: $rootSheetPresented) {
            print("P1 root sheet dismissed")
        } content: {
            P1RootSheet()
                .presentationBackground(.green)
        }
    }

    func elapsedMessage(_ label: String, since startedAt: Date) -> String {
        let seconds = Date().timeIntervalSince(startedAt)
        return "\(label) dialog returned after \(String(format: "%.2f", seconds))s"
    }
}

struct P1RootSheet: View {
    @State var nestedSheetPresented = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 12) {
            Color.red
                .frame(width: 160, height: 20)

            Text("Root sheet")

            Text("The red bar should touch the sheet content edge if padding was removed.")
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Open nested sheet") {
                nestedSheetPresented = true
            }

            Button("Dismiss root sheet") {
                dismiss()
            }
        }
        .padding(0)
        .sheet(isPresented: $nestedSheetPresented) {
            print("P1 nested sheet dismissed")
        } content: {
            P1NestedSheet()
        }
    }
}

struct P1NestedSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 12) {
            Text("Nested sheet")
            Text("If this appears reliably, nested sheet handling is working.")
            Button("Dismiss nested sheet") {
                dismiss()
            }
        }
        .padding(16)
    }
}
