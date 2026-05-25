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
    @State var showForegroundColors = false

    let weights: [Font.Weight] = [
        .ultraLight,
        .thin,
        .light,
        .regular,
        .medium,
        .semibold,
        .bold,
        .heavy,
        .black,
    ]

    var body: some Scene {
        WindowGroup("IconsApp") {
            #hotReloadable {
                VStack {
                    VStack {
                        Text("Icon Weights")
                        ForEach(weights, id: \.self) { weight in
                            HStack {
                                Text("\(weight)")
                                Spacer()

                                Icon.share
                                Icon.plus
                                    .foregroundColor(.green)
                                Icon.back
                                Icon.cut
                                Icon.copy
                                Icon.paste
                            }
                            .fontWeight(weight)
                        }
                    }

                    #if !canImport(AndroidBackend)
                        Divider()

                        VStack {
                            Text("Icon Resizing")
                            Slider(value: $iconSize, in: 10...100)
                            HStack {
                                Icon.copy
                                Text("Some text for scale")
                            }
                            .font(.system(size: iconSize))
                        }
                    #endif
                }
                .padding()
            }
        }
        .defaultSize(width: 300, height: 300)
        .windowResizability(.contentSize)
        .commands {
            CommandMenu("Icons") {
                Toggle("Show foreground colors", isOn: $showForegroundColors)
            }
        }
    }
}
