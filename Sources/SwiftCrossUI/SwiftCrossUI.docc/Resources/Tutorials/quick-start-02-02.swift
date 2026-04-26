import SwiftCrossUI
import DefaultBackend

@main
struct HelloWorldApp: App {
    var body: some Scene {
        WindowGroup("HelloWorld") {
            Text("Hello, World!")
                .padding()
        }
    }
}
