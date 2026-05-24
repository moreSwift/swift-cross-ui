import DefaultBackend
import Foundation
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct IconsApp: App {
    var body: some Scene {
        WindowGroup("IconsApp") {
            #hotReloadable {
                VStack(spacing: 30) {
                    VStack {
                        Text("Icons")
                        HStack {
                            Icon.share
                            Icon.plus
                            Icon.edit
                            Icon.back
                        }
                    }

//                    VStack {
//                        Text("Bigger Icons")
//                        Icon.share
//                            .frame(width: 50, height: 50)
//                    }
                }.padding()
            }
        }.defaultSize(width: 300, height: 300)
    }
}
