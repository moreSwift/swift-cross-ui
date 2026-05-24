import DefaultBackend
import Foundation
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct IconsApp: App {
    @State var iconSize = 20.0

    var body: some Scene {
        WindowGroup("IconsApp") {
            #hotReloadable {
                VStack(spacing: 30) {
                    VStack {
                        Text("Icons")
                        HStack {
                            Icon.share
                            Icon.plus
                                .foregroundColor(.green)
                            Icon.edit
                            Icon.back
                        }
                    }

                    VStack {
                        Text("Icon Resizing")
                        #if !canImport(AndroidBackend)
                            Slider(value: $iconSize, in: 10...100)
                        #endif
                        Icon.share
                            .font(.system(size: iconSize))
                    }
                }.padding()
            }
        }.defaultSize(width: 300, height: 300)
    }
}
