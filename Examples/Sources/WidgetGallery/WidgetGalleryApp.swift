import DefaultBackend
import Foundation
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct WidgetGalleryApp: App {

    var body: some Scene {
        WindowGroup("Widget Gallery") {
            #hotReloadable {
                ContentView()
                    .environment(\.colorScheme, .dark)
            }
        }
        .defaultSize(width: 400, height: 200)
    }
}

struct ContentView: View {
    @State var data = ContentViewModel()
    @FocusState var focus: Widget?
    @State var currentWidgetFocusIndex = 0

    var widgetToFocus: Widget {
        Widget.allCases[currentWidgetFocusIndex]
    }

    var body: some View {
        Text("Focused widget: \(focus?.rawValue ?? "nil")")
            .frame(width: 200)

        Button(widgetToFocus.rawValue) {
            focus = widgetToFocus
            if currentWidgetFocusIndex < Widget.allCases.count - 1 {
                currentWidgetFocusIndex += 1
            } else {
                currentWidgetFocusIndex = 0
            }
        }
        Button("Resign focus") {
            focus = nil
        }
        ScrollView {
            Button("Print something") { print("something") }
                .focused($focus, equals: .button)
            TextField(text: data.$textField)
                .focused($focus, equals: .textField)
            TextEditor(text: data.$textEditor)
                .focused($focus, equals: .textEditor)
            Slider(value: data.$slider, in: -10...10)
                .focused($focus, equals: .slider)
            Toggle("Toggle Switch", isOn: data.$toggleSwitch)
                .toggleStyle(.switch)
                .focused($focus, equals: .toggleSwitch)
            #if !canImport(UIKitBackend)
                Toggle("Checkbox", isOn: data.$checkbox)
                    .toggleStyle(.checkbox)
                    .focused($focus, equals: .checkbox)
                Toggle("Toggle Button", isOn: data.$toggleButton)
                    .toggleStyle(.button)
                    .focused($focus, equals: .toggleButton)
            #endif
            #if !canImport(Gtk3Backend)
                Picker(of: Widget.allCases, selection: data.$picker)
                    .focused($focus, equals: .picker)
                #if !os(tvOS)
                    DatePicker("", selection: data.$datePicker)
                        .focused($focus, equals: .datePicker)
                #endif
            #endif
            NavigationLink("Nav link", value: "destination", path: data.$navigationLink)
                .focused($focus, equals: .navigationLink)
            Menu("Menu") {
                Button("Test Button") {}
            }
            .focused($focus, equals: .menu)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                focus = nil
            }
        }
    }
}

@ObservableObject
class ContentViewModel {
    var textField = "TextField"
    var textEditor = "TextEditor"
    var slider: Double = 0.0
    var toggleSwitch = false
    var checkbox = false
    var toggleButton = false
    var picker: Widget? = nil
    var datePicker = Date()
    var navigationLink = NavigationPath()
}

@MainActor
enum Widget: String, CaseIterable {
    case button
    case textField
    case textEditor
    case slider
    case toggleSwitch
    case checkbox
    case toggleButton
    case picker
    case datePicker
    case navigationLink
    case menu
}
