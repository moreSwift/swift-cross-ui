import DefaultBackend
import Foundation
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

enum BuiltInPickerStyle: CaseIterable, Equatable {
    case automatic
    case inline
    case menu
    case radioGroup
    case segmented
    case wheel

    var asPickerStyle: any PickerStyle {
        switch self {
            case .automatic: .automatic
            case .inline: .inline
            case .menu: .menu
            case .radioGroup: .radioGroup
            case .segmented: .segmented
            case .wheel: .wheel
        }
    }
}

@main
@HotReloadable
struct ControlsApp: App {
    @State var count = 0
    @State var exampleButtonState = false
    @State var exampleSwitchState = false
    @State var exampleCheckboxState = false
    @State var sliderValue = 5.0
    @State var text = ""
    @State var secureText = ""
    @State var flavor: String? = nil
    @State var enabled = true
    @State var date = Date()
    @State var datePickerStyle: DatePickerStyle? = .automatic
    @State var menuToggleState = false
    @State var progressViewSize: Double = 10
    @State var isProgressViewResizable = true
    @State var pickerStyle: BuiltInPickerStyle? = .automatic

    @State var isButtonFocusable = true
    @State var isMenuFocusable = true
    @State var isToggleButtonFocusable = true
    @State var isToggleSwitchFocusable = true
    @State var isCheckboxFocusable = true
    @State var isSliderFocusable = true
    @State var isProgressSliderFocusable = true
    @State var isTextFieldFocusable = true
    @State var isSecureTextFieldFocusable = true
    @State var isPickerStyleFocusable = true
    @State var isFlavorPickerFocusable = true
    @State var isDatePickerStyleFocusable = true
    @State var isDatePickerFocusable = true

    @FocusState var focused: Int?

    @Environment(\.supportedDatePickerStyles) var supportedDatePickerStyles
    @Environment(\.isPickerStyleSupported) var isPickerStyleSupported

    var body: some Scene {
        WindowGroup("ControlsApp focused: \(focused ?? -1)") {
            #hotReloadable {
                ScrollView {
                    VStack(spacing: 30) {
                        Button("randomize focus") {
                            focused = Int.random(in: 1...13)
                        }
                        .padding(.bottom, 20)

                        HStack {
                            VStack {
                                Text("Button (persisted)")
                                Button("Click me!") {
                                    count += 1
                                }
                                .focusableIfSupported(isButtonFocusable)
                                .focused($focused, equals: 1)
                                .focusEffectDisabled()

                                Text("Count: \(count)")
                            }
                            Toggle("focusable", isOn: $isButtonFocusable)
                                .focusableIfSupported(false)
                        }
                        .padding(.bottom, 20)

                        HStack {
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
                                .focusableIfSupported(isMenuFocusable)
                                .focused($focused, equals: 2)
                            }
                            Toggle("focusable", isOn: $isMenuFocusable)
                                .focusableIfSupported(false)
                        }

                        #if !canImport(UIKitBackend)
                            HStack {
                                VStack {
                                    Text("Toggle button")
                                    Toggle("Toggle me!", isOn: $exampleButtonState)
                                        .toggleStyle(.button)
                                        .focusableIfSupported(isToggleButtonFocusable)
                                        .focused($focused, equals: 3)
                                    Text("Currently enabled: \(exampleButtonState)")
                                }
                                Toggle("focusable", isOn: $isToggleButtonFocusable)
                                    .focusableIfSupported(false)
                            }
                            .padding(.bottom, 20)
                        #endif

                        HStack {
                            VStack {
                                Text("Toggle switch")
                                Toggle("Toggle me:", isOn: $exampleSwitchState)
                                    .toggleStyle(.switch)
                                    .focusableIfSupported(isToggleSwitchFocusable)
                                    .focused($focused, equals: 4)
                                Text("Currently enabled: \(exampleSwitchState)")
                            }
                            Toggle("focusable", isOn: $isToggleSwitchFocusable)
                                .focusableIfSupported(false)
                        }

                        HStack {
                            VStack {
                                Text("Checkbox")
                                Toggle("Toggle me:", isOn: $exampleCheckboxState)
                                    .toggleStyle(.checkbox)
                                    .focusableIfSupported(isCheckboxFocusable)
                                    .focused($focused, equals: 5)
                                Text("Currently enabled: \(exampleCheckboxState)")
                            }
                            Toggle("focusable", isOn: $isCheckboxFocusable)
                                .focusableIfSupported(false)
                        }

                        #if !os(tvOS)
                            HStack {
                                VStack {
                                    Text("Slider")
                                    Slider(value: $sliderValue, in: 0...10)
                                        .frame(maxWidth: 200)
                                        .focusableIfSupported(isSliderFocusable)
                                        .focused($focused, equals: 6)
                                    Text("Value: \(String(format: "%.02f", sliderValue))")
                                }
                                Toggle("focusable", isOn: $isSliderFocusable)
                                    .focusableIfSupported(false)
                            }
                        #endif

                        HStack {
                            VStack {
                                Text("Text field")
                                TextField("Text field", text: $text)
                                    .focusableIfSupported(isTextFieldFocusable)
                                    .focused($focused, equals: 7)
                                Text("Value: \(text)")
                            }
                            Toggle("focusable", isOn: $isTextFieldFocusable)
                                .focusableIfSupported(false)
                        }

                        HStack {
                            VStack {
                                Text("Secure text field")
                                SecureField("Secure text field", text: $secureText)
                                    .focusableIfSupported(isSecureTextFieldFocusable)
                                    .focused($focused, equals: 8)
                                Text("Value: \(secureText)")
                            }
                            Toggle("focusable", isOn: $isSecureTextFieldFocusable)
                                .focusableIfSupported(false)
                        }

                        #if !os(tvOS)
                            HStack {
                                VStack {
                                    Toggle(
                                        "Enable ProgressView resizability",
                                        isOn: $isProgressViewResizable
                                    )
                                    .focusableIfSupported(false)
                                    Slider(value: $progressViewSize, in: 10...100)
                                        .focusableIfSupported(isProgressSliderFocusable)
                                        .focused($focused, equals: 9)
                                    ProgressView()
                                        .resizable(isProgressViewResizable)
                                        .frame(
                                            width: progressViewSize,
                                            height: progressViewSize
                                        )
                                }
                                Toggle("focusable", isOn: $isProgressSliderFocusable)
                                    .focusableIfSupported(false)
                            }
                        #endif

                        #if !canImport(Gtk3Backend)
                            VStack {
                                Text("Picker")

                                HStack {
                                    Text("Picker Style:")
                                    Picker(
                                        of: BuiltInPickerStyle.allCases.filter {
                                            isPickerStyleSupported($0.asPickerStyle)
                                        },
                                        selection: $pickerStyle
                                    )
                                    .focusableIfSupported(isPickerStyleFocusable)
                                    .focused($focused, equals: 10)
                                    Toggle("focusable", isOn: $isPickerStyleFocusable)
                                        .focusableIfSupported(false)
                                }

                                HStack {
                                    Text("Flavor: ")
                                    Picker(
                                        of: ["Vanilla", "Chocolate", "Strawberry"],
                                        selection: $flavor
                                    )
                                    .pickerStyle(
                                        pickerStyle?.asPickerStyle ?? DefaultPickerStyle()
                                    )
                                    .focusableIfSupported(isFlavorPickerFocusable)
                                    .focused($focused, equals: 11)
                                    Toggle("focusable", isOn: $isFlavorPickerFocusable)
                                        .focusableIfSupported(false)
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
                                        .focusableIfSupported(isDatePickerStyleFocusable)
                                        .focused($focused, equals: 12)
                                        Toggle("focusable", isOn: $isDatePickerStyleFocusable)
                                            .focusableIfSupported(false)
                                    }

                                    HStack {
                                        DatePicker(selection: $date) {}
                                            .datePickerStyle(datePickerStyle ?? .automatic)
                                            .focusableIfSupported(isDatePickerFocusable)
                                            .focused($focused, equals: 13)
                                        Toggle("focusable", isOn: $isDatePickerFocusable)
                                            .focusableIfSupported(false)
                                    }

                                    Button("Reset date to now") {
                                        date = Date()
                                    }
                                    .focusableIfSupported(false)
                                }
                            #endif
                        #endif
                    }.padding().disabled(!enabled)

                    Toggle(enabled ? "Disable all" : "Enable all", isOn: $enabled)
                        .padding()
                        .focusableIfSupported(false)
                }
            }
            Text("Test")
        }.defaultSize(width: 400, height: 600)
    }
}

extension AppStorageValues {
    @Entry var count: Int = 0
}

extension View {
    func focusableIfSupported(_ disabled: Bool) -> some View {
        #if canImport(AppKitBackend) || canImport(GtkBackend)
            self
                .focusable(disabled ? .unmodified : .disabled)
        #else
            self
        #endif
    }
}
