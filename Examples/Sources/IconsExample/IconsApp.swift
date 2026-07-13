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

    var body: some Scene {
        WindowGroup("IconsApp") {
            #hotReloadable {
                VStack {
                    IconWeightsView(showForegroundColors: $showForegroundColors)

                    Divider()

                    VStack {
                        Text("Icon Resizing")
                        Slider(value: $iconSize, in: 10...100)
                        HStack {
                            Icon.system(.copy)
                            Text("Some text for scale")
                        }
                        .font(.system(size: iconSize))
                    }
                }
                .padding()
            }
        }
        .defaultSize(width: 300, height: 300)
        .windowResizability(.contentSize)
        .commands {
            CommandMenu("Icons") {
                Toggle("Show Foreground Colors", isOn: $showForegroundColors)
            }
        }
    }
}

struct IconWeightsView: View {
    @Binding var showForegroundColors: Bool

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
    let icons: [Icon.SystemIcon] = [
        .share,
        .plus,
        .back,
        .cut,
        .copy,
        .paste,
        .search,
    ]

    var body: some View {
        VStack {
            Text("Icon Weights")
            ForEach(weights, id: \.self) { weight in
                HStack {
                    Text("\(weight)")
                    Spacer()

                    ForEach(icons, id: \.self) { icon in
                        Icon.system(icon)
                    }
                    .if(showForegroundColors) {
                        $0.foregroundColor(.green)
                    }
                }
                .fontWeight(weight)
            }
        }
    }
}
