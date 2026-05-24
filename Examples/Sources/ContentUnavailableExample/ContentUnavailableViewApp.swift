import DefaultBackend
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct ContentUnavailableViewApp: App {
    var body: some Scene {
        WindowGroup("Content Unavailable") {
            #hotReloadable {
                ContentUnavailableView(){
                    Color.blue
                        .frame(height: 200)
                    Text("Test")
                } description: {
                    Text("test")
                } actions: {
                    Button("Test") {}
                    Button("Test2") {}
                }
            }
        }
    }
}
