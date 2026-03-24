import DefaultBackend
import Foundation
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct HoverExample: App {
    var body: some Scene {
        WindowGroup("Hover Example") {
            #hotReloadable {
                VStack(spacing: 0) {
                    ForEach(1...18, id: \.self) { _ in
                        HStack(spacing: 0) {
                            ForEach(1...30, id: \.self) { _ in
                                CellView()
                            }
                        }
                    }
                    .background(Color.black)
                }
            }
        }
        .defaultSize(width: 900, height: 540)
    }
}

struct CellView: View {
    @State var timer: Timer?
    @State var opacity: Double = 0.0

    var body: some View {
        Rectangle()
            .foregroundColor(Color.blue.opacity(opacity))
            .onHover { hovering in
                if !hovering {
                    timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                        DispatchQueue.main.async {
                            if opacity >= 0.05 {
                                opacity -= 0.05
                            } else {
                                opacity = 0.0
                                timer.invalidate()
                            }
                        }
                    }
                } else {
                    opacity = 1.0
                    timer?.invalidate()
                    timer = nil
                }
            }
    }
}
