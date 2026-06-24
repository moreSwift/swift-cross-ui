import Foundation
import SwiftCrossUI

struct Note: Codable, Equatable, Identifiable {
    var id = UUID()
    var title: String
    var content: String

    var truncatedDescription: String {
        let firstLine = content.split(separator: "\n").first ?? []
        let words = firstLine.split(separator: " ", omittingEmptySubsequences: false)
        let limit = 20
        var output = ""
        for (index, word) in words.enumerated() {
            let addition = (index == 0 ? "" : " ") + word
            guard output.count + addition.count <= limit else {
                if index == 0 {
                    // We should at least output a little snippet
                    output += word.prefix(limit)
                }
                break
            }
            output += addition
        }
        if content.isEmpty {
            output = "No content"
        } else if output.count < content.count {
            output += "..."
        }
        return output
    }
}

extension AppStorageValues {
    @Entry var previewLines = 1
}

struct ContentView: View {
    let notesFile = URL(fileURLWithPath: "notes.json")

    @State var notes: [Note] = [
        Note(title: "Hello, world!", content: "Welcome SwiftCrossNotes!"),
        Note(
            title: "Shopping list",
            content: "Carrots, mushrooms, and party pies"
        ),
    ]

    @State var selectedNoteId: UUID?

    @State var error: String?

    @AppStorage(\.previewLines) var previewLines

    var selectedNote: Binding<Note>? {
        guard let id = selectedNoteId else {
            return nil
        }

        guard
            let index = notes.firstIndex(where: { note in
                note.id == id
            })
        else {
            return nil
        }

        // TODO: This is unsafe, index could change/not exist anymore
        return Binding(
            get: {
                notes[index]
            },
            set: { newValue in
                notes[index] = newValue
            }
        )
    }

    var body: some View {
        NavigationSplitView {
            VStack {
                ScrollView {
                    List(notes, selection: $selectedNoteId) { note in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(note.title.isEmpty ? "Untitled" : note.title)
                            Text(note.content)
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                                .lineLimit(previewLines)
                        }
                    }
                    .padding()
                }
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                }

                VStack {
                    Button("New note") {
                        let note = Note(title: "", content: "")
                        notes.append(note)
                        selectedNoteId = note.id
                    }
                    Divider()

                    VStack(alignment: .leading) {
                        Text("Max preview lines: \(previewLines)")
                        Slider(value: $previewLines, in: 1...4)
                    }.padding([.leading, .trailing])
                }
                .padding([.top, .bottom])
            }
            .onChange(of: notes) {
                do {
                    let data = try JSONEncoder().encode(notes)
                    try data.write(to: notesFile)
                } catch {
                    print("Error: \(error)")
                    self.error = "Failed to save notes"
                }
            }
            .onAppear {
                guard FileManager.default.fileExists(atPath: notesFile.path) else {
                    return
                }

                do {
                    let data = try Data(contentsOf: notesFile)
                    notes = try JSONDecoder().decode([Note].self, from: data)
                } catch {
                    print("Error: \(error)")
                    self.error = "Failed to load notes"
                }
            }
            .frame(minWidth: 200)
        } detail: {
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .center) {
                        if let selectedNote = selectedNote {
                            HStack(spacing: 4) {
                                Text("Title")
                                TextField("Title", text: selectedNote.title)

                                Button("Delete note") {
                                    guard
                                        let index = notes.firstIndex(of: selectedNote.wrappedValue)
                                    else {
                                        return
                                    }
                                    notes.remove(at: index)
                                    if notes.count == 0 {
                                        selectedNoteId = nil
                                    } else {
                                        let newIndex = max(index - 1, 0)
                                        selectedNoteId = notes[newIndex].id
                                    }
                                }
                            }

                            TextEditor(text: selectedNote.content)
                                .padding()
                                .background(
                                    Color.adaptive(
                                        light: Color(white: 0.8),
                                        dark: Color(white: 0.18)
                                    )
                                )
                                .cornerRadius(4)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    .padding()
                    .frame(minHeight: proxy.size.height)
                }
            }
        }
    }
}
