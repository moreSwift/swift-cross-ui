import DefaultBackend
import Foundation
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@available(tvOS, unavailable)
struct FileDialogDemo: View {
    @State var selectedFile: URL? = nil
    @State var saveDestination: URL? = nil

    @Environment(\.chooseFile) var chooseFile
    @Environment(\.chooseFileSaveDestination) var chooseFileSaveDestination

    var body: some View {
        Text("File dialog demo")
            .font(.system(size: 18))

        if let selectedFile {
            Text("Selected file: \(selectedFile.path)")
        } else {
            Text("No file selected")
        }

        if let saveDestination {
            Text("Save destination: \(saveDestination.path)")
        }

        HStack {
            Button("Open") {
                Task {
                    guard let file = await chooseFile() else {
                        return
                    }
                    selectedFile = file
                }
            }

            Button("Save") {
                Task {
                    guard let file = await chooseFileSaveDestination() else {
                        return
                    }
                    saveDestination = file
                }
            }
        }
    }
}

struct AlertDemo: View {
    @Environment(\.presentAlert) var presentAlert

    var body: some View {
        Text("Alert demo")
            .font(.system(size: 18))

        Button("Present error") {
            Task {
                await presentAlert("Failed to succeed") {}
            }
        }
    }
}

// A demo displaying SwiftCrossUI's `View.sheet` modifier.
struct SheetDemo: View {
    @State var isPresented = false
    @State var isEphemeralSheetPresented = false
    @State var ephemeralSheetDismissalTask: Task<Void, Never>?

    var body: some View {
        Button("Open Sheet") {
            isPresented = true
        }
        Button("Show Sheet for 5s") {
            isEphemeralSheetPresented = true
            ephemeralSheetDismissalTask = Task {
                do {
                    try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                    isEphemeralSheetPresented = false
                } catch {}
            }
        }
        .sheet(isPresented: $isPresented) {
            print("Root sheet dismissed")
        } content: {
            SheetBody()
                .presentationDetents([.height(250), .medium, .large])
                .presentationBackground(.green)
        }
        .sheet(isPresented: $isEphemeralSheetPresented) {
            ephemeralSheetDismissalTask?.cancel()
        } content: {
            Text("I'm only here for 5s")
                .padding(20)
                .presentationDetents([.medium])
                .presentationCornerRadius(10)
                .presentationBackground(.red)
        }
    }

    struct SheetBody: View {
        @State var isNestedSheetPresented = false
        @Environment(\.dismiss) var dismiss

        var body: some View {
            VStack {
                Text("Root sheet")
                Button("Present a nested sheet") {
                    isNestedSheetPresented = true
                }
                Button("Dismiss") {
                    dismiss()
                }
            }
            .padding()
            .sheet(isPresented: $isNestedSheetPresented) {
                print("Nested sheet dismissed")
            } content: {
                NestedSheetBody(dismissRoot: { dismiss() })
                    .presentationDetents([.height(250), .medium, .large])
            }
        }
    }

    struct NestedSheetBody: View {
        var dismissRoot: () -> Void

        @Environment(\.dismiss) var dismiss
        @State var showNextChild = false

        var body: some View {
            VStack {
                Text("Nested sheet")

                Button("Present another sheet") {
                    showNextChild = true
                }
                Button("Dismiss root sheet") {
                    dismissRoot()
                }
                Button("Dismiss") {
                    dismiss()
                }
            }
            .padding()
            .sheet(isPresented: $showNextChild) {
                print("Nested sheet dismissed")
            } content: {
                NestedSheetBody(dismissRoot: dismissRoot)
                    .presentationDetents([.height(250), .medium, .large])
            }
        }
    }
}

struct OpenWindowDemo: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows

    var body: some View {
        Text("Backend supports multi-window: \(supportsMultipleWindows)")

        Button("Open singleton window") {
            openWindow(id: "singleton-window")
        }
        Button("Open new tertiary window instance") {
            openWindow(id: "tertiary-window")
        }
    }
}

struct TertiaryWindowView: View {
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack {
            Text("This a tertiary window!")

            Button("Close window") {
                dismissWindow()
            }
            Button("Open new instance") {
                openWindow(id: "tertiary-window")
            }
        }
        .padding()
    }
}

struct SingletonWindowView: View {
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        VStack {
            Text("This a singleton window!")

            Button("Close window") {
                dismissWindow()
            }
        }
        .padding()
    }
}

@main
@HotReloadable
struct WindowingApp: App {
    @State var title = "My window"
    @State var resizable = true
    @State var isAlertSceneShown = false
    @State var toggle = false
    @State var enforceMaxSize = true
    @State var closable = true
    @State var minimizable = true

    var body: some Scene {
        WindowGroup(title) {
            #hotReloadable {
                VStack {
                    HStack {
                        Text("Window title:")
                        TextField("My window", text: $title)
                    }

                    Toggle("Enable resizing", isOn: $resizable)
                        .windowResizeBehavior(resizable ? .enabled : .disabled)
                    Toggle("Enable closing", isOn: $closable)
                        .windowDismissBehavior(closable ? .enabled : .disabled)
                    Toggle("Enable minimizing", isOn: $minimizable)
                        .preferredWindowMinimizeBehavior(minimizable ? .enabled : .disabled)

                    Image(Bundle.module.bundleURL.appendingPathComponent("Banner.png"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                    Divider()

                    #if !os(tvOS)
                        FileDialogDemo()

                        Divider()
                    #endif

                    AlertDemo()
                    Button("Show alert scene") {
                        isAlertSceneShown = true
                    }

                    Divider()

                    SheetDemo()

                    Divider()

                    OpenWindowDemo()
                        .padding(.bottom, 20)
                }
                .padding(20)
            }
        }
        .defaultSize(width: 500, height: 500)
        .commands {
            CommandMenu("Demo menu") {
                Button("Menu item") {}
                Toggle("Toggle", active: $toggle)

                Divider()

                Menu("Submenu") {
                    Button("Item 1") {}
                    Button("Item 2") {}
                }
            }
        }

        AlertScene("Alert scene", isPresented: $isAlertSceneShown) {}

        #if !(os(iOS) || os(tvOS))
            WindowGroup("Secondary window", id: "secondary-window") {
                #hotReloadable {
                    VStack {
                        Text("This a secondary window!")

                        Toggle("Enforce max size", isOn: $enforceMaxSize)
                            .toggleStyle(.checkbox)
                    }
                    .padding(10)
                }
            }
            .defaultSize(width: 200, height: 200)
            .windowResizability(enforceMaxSize ? .contentSize : .contentMinSize)
            #if os(Windows)
                .defaultLaunchBehavior(.suppressed)
            #endif

            WindowGroup("Tertiary window (hidden)", id: "tertiary-window") {
                #hotReloadable {
                    TertiaryWindowView()
                }
            }
            .defaultSize(width: 200, height: 200)
            .defaultLaunchBehavior(.suppressed)
            .windowResizability(.contentMinSize)

            Window("Singleton window", id: "singleton-window") {
                #hotReloadable {
                    SingletonWindowView()
                }
            }
            .defaultSize(width: 200, height: 200)
            #if os(Windows)
                .defaultLaunchBehavior(.suppressed)
            #endif
        #endif
    }
}
