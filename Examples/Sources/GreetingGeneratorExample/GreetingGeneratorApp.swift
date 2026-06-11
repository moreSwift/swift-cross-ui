import DefaultBackend
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct GreetingGeneratorApp: App {
    @State var name = ""
    @State var greetings: [String] = []
    @State var isGreetingSelectable = false

    var body: some Scene {
        WindowGroup("Greeting Generator") {
            #hotReloadable {
                VStack {
                    TextField("Name", text: $name)
                    HStack {
                        Button("Generate") {
                            greetings.append("Hello, \(name)!")
                        }
                        Button("Reset") {
                            greetings = []
                            name = ""
                        }
                    }

                    Toggle("Selectable Greeting", isOn: $isGreetingSelectable)
                    if let latest = greetings.last {
                        LatestGreetingDisplay()
                            .environment(\.latestGreeting, latest)
                            .padding(.top, 5)
                            .textSelectionEnabled(isGreetingSelectable)

                        if greetings.count > 1 {
                            Text("History:")
                                .padding(.top, 20)

                            ScrollView {
                                ForEach(greetings.reversed()[1...], id: \.self) { greeting in
                                    Text(greeting)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                .padding(10)
            }
        }
    }
}

/// This intermediate view exists to show the usage of custom environment keys.
/// In reality it is not necessary.
struct LatestGreetingDisplay: View {
    @Environment(\.latestGreeting) var value: String?

    var body: some View {
        Text(value ?? "nil")
    }
}

extension EnvironmentValues {
    @Entry
    var latestGreeting: String? = nil
}
