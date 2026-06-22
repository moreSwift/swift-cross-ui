import DefaultBackend
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct CounterApp: App {
    @State var count = 0

    var body: some Scene {
        WindowGroup("CounterExample: \(count)") {
            #hotReloadable {
                HStack(spacing: 20) {
                    Button {
                        count -= 1
                    } label: {
                        Text("-")
                            .background(Color.green)
                    }.background(Color.blue)
                    
                    Text("Count: \(count)")
                    Button {
                        count += 1
                    } label: {
                        Text("+")
                            .background(Color.green)
                    }
                    .background(Color.blue)
                }
                .background(Color.red)
                .padding()
            }
        }
        .defaultSize(width: 400, height: 200)
    }
}
