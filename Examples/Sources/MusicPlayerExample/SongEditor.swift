import SwiftCrossUI
import Foundation

struct SongEditor: View {
    @Environment(\.chooseFile) var chooseFile

    @Binding var song: Song
    var songStorage: SongStorage

    var save: (() -> Void)? = nil
    var cancel: (() -> Void)? = nil

    @State var file: URL?
    @State var errorMessage: String?

    func onSave(perform action: @escaping () -> Void) -> Self {
        var editor = self
        editor.save = action
        return editor
    }

    func onCancel(perform action: @escaping () -> Void) -> Self {
        var editor = self
        editor.cancel = action
        return editor
    }

    var albumBinding: Binding<String> {
        Binding {
            song.album ?? ""
        } set: { newValue in
            song.album = newValue == "" ? nil : newValue
        }
    }

    var artistBinding: Binding<String> {
        Binding {
            song.artist ?? ""
        } set: { newValue in
            song.artist = newValue == "" ? nil : newValue
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Name", text: $song.name)
            TextField("Album (optional)", text: albumBinding)
            TextField("Artist (optional)", text: artistBinding)

            Spacer().frame(height: 10)

            Text("File: \(file?.lastPathComponent ?? "not chosen")")
            Button("Choose file") {
                Task {
                    let result = await chooseFile(
                        title: "Choose song",
                        defaultButtonLabel: "Choose",
                        initialDirectory: nil,
                        showHiddenFiles: false,
                        allowSelectingFiles: true,
                        allowSelectingDirectories: false
                    )
                    if let result {
                        file = result
                    }
                }
            }

            Spacer().frame(height: 10)

            HStack {
                Button("Cancel") {
                    cancel?()
                }

                Button("Save") {
                    guard let file else {
                        return
                    }

                    Task {
                        do {
                            try songStorage.insertSong(file, id: song.id)
                        } catch {
                            self.errorMessage =
                                "Failed to insert song: \(error.localizedDescription)"
                            return
                        }

                        save?()
                    }
                }.disabled(file == nil)
            }
        }.alert($errorMessage) {
            Button("Ok") {}
        }
    }
}
