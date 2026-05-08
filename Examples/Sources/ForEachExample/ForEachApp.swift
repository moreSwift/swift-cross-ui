import DefaultBackend
import Foundation
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct ForEachApp: App {
    @State var items = (0..<20).map { Item("\($0)") }
    @State var biggestValue = 19
    @State var insertionPosition = 10

    var body: some Scene {
        WindowGroup("ForEach") {
            #hotReloadable {
                VStack {
                    VStack {
                        Button("Append") {
                            biggestValue += 1
                            items.append(.init("\(biggestValue)"))
                        }

                        #if !os(tvOS)
                            Button(
                                "Insert before item at position \(insertionPosition)"
                            ) {
                                biggestValue += 1
                                items.insert(.init("\(biggestValue)"), at: insertionPosition)
                            }

                            Slider(value: $insertionPosition, in: 0...(items.count - 1))
                                .onChange(of: items.count) {
                                    let upperLimit = max(items.count - 1, 0)
                                    insertionPosition = min(insertionPosition, upperLimit)
                                }
                                .frame(maxWidth: 200)
                        #endif
                    }
                    .padding(10)

                    ScrollView {
                        VStack(alignment: .trailing) {
                            ForEach(Array(items.enumerated()), id: \.element.id) { (index, _) in
                                ItemRow(
                                    item: $items[index],
                                    isFirst: index == 0,
                                    isLast: index == items.count - 1
                                ) {
                                    items.remove(at: index)
                                } moveUp: {
                                    guard index != items.startIndex else { return }
                                    items.swapAt(index, index - 1)
                                } moveDown: {
                                    guard index != items.endIndex else { return }
                                    items.swapAt(index, index + 1)
                                }
                            }
                        }
                    }.padding()
                }
            }
        }
        .defaultSize(width: 400, height: 800)
    }
}

struct ItemRow: View {
    @Binding var item: Item

    @State var isEditing = false
    @State var value = ""

    let isFirst: Bool
    let isLast: Bool
    var remove: () -> Void
    var moveUp: () -> Void
    var moveDown: () -> Void

    var body: some View {
        HStack {
            if isEditing {
                TextField("Value", text: $value)
                    .frame(width: 100)
                Spacer()
                Button("Save") {
                    item.value = value
                    isEditing = false
                }
                Button("Cancel") {
                    isEditing = false
                }
            } else {
                Text(item.value)
                    .frame(width: 100, alignment: .leading)
                Spacer()
                Button("Edit") {
                    isEditing = true
                    value = item.value
                }
            }
            Button("Delete") { remove() }
            Button("⌃") { moveUp() }
                .disabled(isFirst)
            Button("⌄") { moveDown() }
                .disabled(isLast)
        }
    }
}

struct Item: Identifiable {
    let id = UUID()
    var value: String

    init(_ value: String) {
        self.value = value
    }
}
