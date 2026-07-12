import DefaultBackend
import Foundation
import ImageFormats
import SwiftCrossUI

// P3 Windows repro app:
// - #389 Images are not clipped on GTK/WinUI.
// - #160 WinUIBackend NavigationSplitView initial layout is wrong until resize/update.
//
// Build this file as a standalone app target.

enum P3SidebarItem: String, CaseIterable, Identifiable {
    case clipping = "Image clipping"
    case split = "Split layout"
    case details = "Details"

    var id: Self { self }
}

@main
@HotReloadable
struct P3LayoutAndClippingWinUIApp: App {
    var body: some Scene {
        WindowGroup("P3 WinUI layout and clipping") {
            #hotReloadable {
                P3LayoutAndClippingView()
            }
        }
        .defaultSize(width: 960, height: 600)
    }
}

struct P3LayoutAndClippingView: View {
    @State var selectedItem: P3SidebarItem? = .clipping
    @State var selectedDetail: String? = "A"
    @State var imageSize = P3ImageSize.large
    @State var forceLayoutTick = false

    let testImage = P3LayoutAndClippingView.makeTestImage()

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 12) {
                Text("P3 sidebar")
                    .font(.system(size: 18))

                List(P3SidebarItem.allCases, selection: $selectedItem) { item in
                    Text(item.rawValue)
                }

                Button("Force state update") {
                    forceLayoutTick.toggle()
                }
            }
            .padding(12)
            .frame(width: 220)
            .frame(maxHeight: .infinity)
            .background(Color.black)

            VStack(spacing: 12) {
                Text("Middle column")
                    .font(.system(size: 18))

                List(["A", "B", "C"], id: \.self, selection: $selectedDetail) { value in
                    Text("Detail \(value)")
                }

                Text("Tick: \(forceLayoutTick ? "on" : "off")")
            }
            .padding(12)
            .frame(width: 220)
            .frame(maxHeight: .infinity)
            .background(Color.black)

            ScrollView {
                VStack(spacing: 14) {
                    Text(selectedItem?.rawValue ?? "No selection")
                        .font(.system(size: 18))

                    Text("Expected: the three columns are visible immediately after launch.")
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Expected: the oversized image is clipped to the 220x140 black frame.")
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ZStack(alignment: .center) {
                        Color.black
                            .frame(width: 220, height: 140)

                        Image(testImage)
                            .resizable()
                            .frame(
                                width: 220.0 * imageSize.scale,
                                height: 140.0 * imageSize.scale
                            )
                    }
                    .frame(width: 220, height: 140, alignment: .center)
                    .cornerRadius(0)

                    HStack {
                        Button("Small") {
                            imageSize = .small
                        }

                        Button("Medium") {
                            imageSize = .medium
                        }

                        Button("Large") {
                            imageSize = .large
                        }
                    }

                    Text("Image size: \(imageSize.rawValue), scale: \(imageSize.scaleText)")
                    Text("Selected detail: \(selectedDetail ?? "nil")")
                }
                .padding(18)
                .frame(minWidth: 360, maxWidth: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
    }

    static func makeTestImage() -> ImageFormats.Image<RGBA> {
        let width = 160
        let height = 100
        var pixels: [RGBA] = []
        pixels.reserveCapacity(width * height)

        for y in 0..<height {
            for x in 0..<width {
                let red = UInt8((x * 255) / max(1, width - 1))
                let green = UInt8((y * 255) / max(1, height - 1))
                let blue: UInt8 = (x / 10 + y / 10).isMultiple(of: 2) ? 230 : 40
                pixels.append(RGBA(red, green, blue, 255))
            }
        }

        return ImageFormats.Image(width: width, height: height, pixels: pixels)
    }
}

enum P3ImageSize: String {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"

    var scale: Double {
        switch self {
            case .small:
                1.0
            case .medium:
                1.6
            case .large:
                2.4
        }
    }

    var scaleText: String {
        switch self {
            case .small:
                "1.0x"
            case .medium:
                "1.6x"
            case .large:
                "2.4x"
        }
    }
}
