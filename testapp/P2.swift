import DefaultBackend
import SwiftCrossUI

// P2 Windows repro app:
// - #449 WinUIBackend Picker option updating code.
// - #471 WinUIBackend TextEditor has a thin border when not focused.
// - #401 Disable full screen button when window resizing is disabled.
// - #390 Disabled buttons do not appear disabled.
//
// Build this file as a standalone app target.

@main
@HotReloadable
struct P2ControlsAndStylingWinUIApp: App {
    @State var windowResizable = false

    var body: some Scene {
        WindowGroup("P2 WinUI controls and styling") {
            #hotReloadable {
                P2ControlsAndStylingView(windowResizable: $windowResizable)
                    .windowResizeBehavior(windowResizable ? .enabled : .disabled)
            }
        }
        .defaultSize(width: 620, height: 520)
    }
}

struct P2ControlsAndStylingView: View {
    @Binding var windowResizable: Bool

    @State var useExpandedPickerOptions = false
    @State var selectedFlavor: String? = "Vanilla"
    @State var pickerChangeCount = 0
    @State var text = """
        Click outside this TextEditor.
        On WinUI, the unfocused TextEditor should not show a thin border.
        """
    @State var enabled = false

    var pickerOptions: [String] {
        if useExpandedPickerOptions {
            return ["Vanilla", "Chocolate", "Strawberry", "Mint", "Coffee"]
        } else {
            return ["Vanilla", "Chocolate"]
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("P2: control updates and visual states")
                .font(.system(size: 18))

            VStack(alignment: .leading, spacing: 8) {
                Toggle("Use expanded Picker options", isOn: $useExpandedPickerOptions)

                HStack(spacing: 8) {
                    Text("Flavor")
                        .frame(width: 70, alignment: .leading)

                    Picker(of: pickerOptions, selection: $selectedFlavor)
                        .pickerStyle(.menu)
                        .frame(width: 220, height: 32)

                    Button("Reset") {
                        selectedFlavor = "Vanilla"
                        pickerChangeCount = 0
                    }
                }

                Text(
                    "Selected: \(selectedFlavor ?? "nil"), options: \(pickerOptions.count), changes: \(pickerChangeCount)"
                )
                Text("Expected: dropdown stays open, selected flavor changes, and options update after toggling.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onChange(of: selectedFlavor) {
                pickerChangeCount += 1
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("TextEditor border check")

                HStack {
                    Button("Set 12345") {
                        text = "12345"
                    }

                    Button("Clear") {
                        text = ""
                    }

                    Text("Length: \(text.count)")
                }

                TextEditor(text: $text)
                    .frame(width: 560, height: 150, alignment: .leading)
                Text("Expected: no thin border when unfocused, no missed keystrokes, caret remains usable.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                Toggle("Enable button row", isOn: $enabled)

                HStack {
                    Button("Disabled action") {}
                        .disabled(!enabled)

                    Button("Always enabled") {}

                    Toggle("Disabled toggle", isOn: $enabled)
                        .disabled(true)
                }

                Text("Expected: disabled controls should be visibly distinct.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                Toggle("Allow window resizing", isOn: $windowResizable)
                Text("Expected: disabled resizing should also disable the full screen button.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
    }
}
