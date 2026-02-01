import DefaultBackend
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct ColorsApp: App {
    @State private var isShowingSystemColors = false

    var colors: [Color] {
        if isShowingSystemColors {
            [
                .system(.blue), .system(.brown),
                .system(.gray), .system(.green),
                .system(.orange), .system(.purple),
                .system(.red), .system(.yellow),
            ]
        } else {
            [
                .blue, .brown, .gray, .green,
                .orange, .purple, .red, .yellow,

                // Add the SCUI-exclusive colors to the end so as
                // to make comparing the non-exclusive colors easier.
                .cyan, .indigo, .mint, .pink, .teal,
            ]
        }
    }

    @ViewBuilder var colorStack: some View {
        HStack(spacing: 5) {
            ForEach(colors, id: \.self) { color in
                VStack {
                    color.aspectRatio(1, contentMode: .fill)

                    #if os(tvOS)
                        // Add something focusable so we can scroll on tvOS.
                        Button("focus this") {}
                    #endif
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup("ColorsExample") {
            #hotReloadable {
                VStack {
                    Toggle("Show system colors", isOn: $isShowingSystemColors)
                    Text("First row is .dark, second row is .light, third row is the system scheme")
                    Text(
                        """
                        If "Show system colors" is on, platform-specific colors will be used; \
                        otherwise SCUI's built-in colors will be shown
                        """
                    )

                    ScrollView(.horizontal) {
                        VStack(spacing: 5) {
                            colorStack.colorScheme(.dark)
                            colorStack.colorScheme(.light)
                            colorStack
                        }
                    }
                }
                .padding()
            }
        }
    }
}
