import DefaultBackend
import Foundation
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct ControlsApp: App {
    @AppStorage("count") var count = 0
    @State var exampleButtonState = false
    @State var exampleSwitchState = false
    @State var exampleCheckboxState = false
    @State var sliderValue = 5.0
    @State var text = ""
    @State var flavor: String? = nil
    @State var enabled = true
    @State var date = Date()
    @State var datePickerStyle: DatePickerStyle? = .automatic
    @State var menuToggleState = false
    @State var progressViewSize: Int = 10
    @State var isProgressViewResizable = true

    @Environment(\.supportedDatePickerStyles) var supportedDatePickerStyles

    var body: some Scene {
        WindowGroup("ControlsApp") {
            #hotReloadable {
                ScrollView {
                    VStack(spacing: 30) {
                        VStack {
                            Text("Button (persisted)")
                            Button("Click me!") {
                                count += 1
                            }
                            Text("Count: \(count)")
                        }

                        VStack {
                            Text("Menu button")
                            Menu("Menu") {
                                Button("Button item") {
                                    print("Button item clicked")
                                }
                                Toggle("Toggle item", isOn: $menuToggleState)
                                Menu("Submenu") {
                                    Text("Text item 1")
                                    Text("Text item 2")
                                }
                            }
                        }

                        #if !canImport(UIKitBackend)
                            VStack {
                                Text("Toggle button")
                                Toggle("Toggle me!", isOn: $exampleButtonState)
                                    .toggleStyle(.button)
                                Text("Currently enabled: \(exampleButtonState)")
                            }
                        #endif

                        VStack {
                            Text("Toggle switch")
                            Toggle("Toggle me:", isOn: $exampleSwitchState)
                                .toggleStyle(.switch)
                            Text("Currently enabled: \(exampleSwitchState)")
                        }

                        #if !canImport(UIKitBackend)
                            VStack {
                                Text("Checkbox")
                                Toggle("Toggle me:", isOn: $exampleCheckboxState)
                                    .toggleStyle(.checkbox)
                                Text("Currently enabled: \(exampleCheckboxState)")
                            }
                        #endif

                        VStack {
                            Text("Slider")
                            Slider(value: $sliderValue, in: 0...10)
                                .frame(maxWidth: 200)
                            Text("Value: \(String(format: "%.02f", sliderValue))")
                        }

                        VStack {
                            Text("Text field")
                            TextField("Text field", text: $text)
                            Text("Value: \(text)")
                        }

                        VStack {
                            Toggle(
                                "Enable ProgressView resizability", isOn: $isProgressViewResizable)
                            Slider(value: $progressViewSize, in: 10...100)
                            ProgressView()
                                .resizable(isProgressViewResizable)
                                .frame(width: progressViewSize, height: progressViewSize)
                        }

                        #if !canImport(Gtk3Backend)
                            VStack {
                                Text("Drop down")
                                HStack {
                                    Text("Flavor: ")
                                    Picker(
                                        of: ["Vanilla", "Chocolate", "Strawberry"],
                                        selection: $flavor
                                    )
                                }
                                Text("You chose: \(flavor ?? "Nothing yet!")")
                            }

                            #if !os(tvOS)
                                VStack {
                                    Text("Selected date: \(date)")

                                    HStack {
                                        Text("Date picker style: ")
                                        Picker(
                                            of: supportedDatePickerStyles,
                                            selection: $datePickerStyle
                                        )
                                    }

                                    DatePicker(selection: $date) {}
                                        .datePickerStyle(datePickerStyle ?? .automatic)

                                    Button("Reset date to now") {
                                        date = Date()
                                    }
                                }
                            #endif
                        #endif
                    }.padding().disabled(!enabled)

                    Toggle(enabled ? "Disable all" : "Enable all", isOn: $enabled)
                        .padding()
                }
            }
        }.defaultSize(width: 400, height: 600)
    }
}
