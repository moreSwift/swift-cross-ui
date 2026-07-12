import DefaultBackend
import SwiftCrossUI

#if canImport(WinUIBackend)
    import UWP
    import WinUI
    import WinUIBackend
#endif

// P4 Windows exploration app:
// - #190 Store callbacks in subclasses instead of global hashmaps.
// - #156 Needs for WinUI / WinUI-specific escape hatches.
// - #204 Update to latest stable WinUI.
// - #470 Regenerate WinUI bindings with latest swift-winrt.
//
// Build this file as a standalone app target.

@main
@HotReloadable
struct P4WinUISpecificAndStressApp: App {
    @State var rowCount = 80
    @State var updateTick = 0

    var body: some Scene {
        WindowGroup("P4 WinUI native and callback stress") {
            #hotReloadable {
                P4WinUISpecificAndStressView(rowCount: $rowCount, updateTick: $updateTick)
            }
        }
        .defaultSize(width: 840, height: 760)
    }
}

struct P4WinUISpecificAndStressView: View {
    @SwiftCrossUI.Binding var rowCount: Int
    @SwiftCrossUI.Binding var updateTick: Int

    @State var selectedRow: Int? = nil
    @State var callbackCount = 0
    @State var text = "Native WinUI inspection should be visible on Windows."
    @State var windowStart = 0

    var batchSize: Int { 25 }
    var windowSize: Int { 50 }
    var windowEnd: Int { min(rowCount, windowStart + windowSize) }

    var body: some View {
        VStack(spacing: 14) {
            Text("P4: WinUI-specific APIs and callback stress")
                .font(.system(size: 18))

            HStack {
                Button("Fewer rows") {
                    rowCount = max(10, rowCount - 25)
                    windowStart = min(windowStart, max(0, rowCount - windowSize))
                    updateTick += 1
                }

                Button("More rows") {
                    rowCount += 25
                    updateTick += 1
                }

                Button("Force update") {
                    updateTick += 1
                }

                Button("Run last") {
                    selectedRow = max(0, rowCount - 1)
                    callbackCount += 1
                    windowStart = max(0, rowCount - windowSize)
                }

                Button("Rows 250") {
                    rowCount = 250
                    windowStart = min(windowStart, max(0, 250 - windowSize))
                    updateTick += 1
                }
            }

            Text(
                "Rows: \(rowCount), rows \(windowStart)-\(max(windowStart, windowEnd - 1)), update tick: \(updateTick), callbacks: \(callbackCount)"
            )

            #if canImport(WinUIBackend)
                P4NativeWinUIBanner(text: text, tick: updateTick)
                    .frame(height: 60)
            #else
                Text("WinUI native banner only appears when WinUIBackend is available.")
                    .frame(height: 60)
            #endif

            TextField("Native inspection text", text: $text)
                .inspect(.afterUpdate) { textField in
                    #if canImport(WinUIBackend)
                        let brush = WinUI.SolidColorBrush()
                        brush.color = UWP.Color(a: 255, r: 20, g: 70, b: 120)
                        textField.borderBrush = brush
                    #endif
                }

            HStack {
                Button("Load next rows") {
                    windowStart = min(max(0, rowCount - windowSize), windowStart + batchSize)
                }

                Text("Scrolling near the bottom or top slides the row window on Windows.")
            }

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(Array(windowStart..<windowEnd), id: \.self) { row in
                        HStack {
                            Button("Run \(row)") {
                                selectedRow = row
                                callbackCount += 1
                            }

                            Text("Callback row \(row)")

                            Spacer()
                        }
                        .padding(4)
                    }
                }
                .padding(8)
            }
            #if canImport(WinUIBackend)
                .inspect(.afterUpdate) { scrollViewer in
                    hookScrollAutoLoad(scrollViewer)
                }
            #endif
            .frame(height: 340)

            Text("Selected row: \(selectedRow.map(String.init) ?? "none")")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(
                "Expected: banner updates with tick/text, scrolling slides the row window, and row callbacks respond quickly even when row count is large."
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .inspectWindow { window in
            #if canImport(WinUIBackend)
                window.appWindow.titleBar.backgroundColor = UWP.Color(
                    a: 255,
                    r: 30,
                    g: 90,
                    b: 120
                )
            #endif
        }
    }

    #if canImport(WinUIBackend)
        // Hooks viewChanged once per ScrollViewer: scrolling near the bottom or
        // top slides the row window, and changeView compensates the scroll
        // offset so the content stays visually continuous.
        func hookScrollAutoLoad(_ scrollViewer: WinUI.ScrollViewer) {
            let identifier = ObjectIdentifier(scrollViewer)
            P4ScrollAutoLoad.hookedScrollViewers = P4ScrollAutoLoad.hookedScrollViewers
                .filter { $0.value.scrollViewer != nil }

            guard P4ScrollAutoLoad.hookedScrollViewers[identifier] == nil else {
                return
            }
            P4ScrollAutoLoad.hookedScrollViewers[identifier] = P4WeakScrollViewer(scrollViewer)

            scrollViewer.viewChanged.addHandler { [weak scrollViewer] _, _ in
                guard let scrollViewer else { return }
                let offset = scrollViewer.verticalOffset
                let viewport = scrollViewer.viewportHeight
                let extent = scrollViewer.extentHeight
                let renderedCount = windowEnd - windowStart
                guard renderedCount > 0, extent > 0 else { return }

                // Rows have uniform height, so estimate it from the total
                // extent and use it to compensate the scroll offset by the
                // amount the window slides.
                let rowHeight = extent / Double(renderedCount)
                let remainingBelow = extent - (offset + viewport)

                if remainingBelow < 60, windowEnd < rowCount {
                    let advance = min(batchSize, rowCount - windowEnd)
                    windowStart += advance
                    _ = try? scrollViewer.changeView(
                        nil,
                        max(0, offset - Double(advance) * rowHeight),
                        nil,
                        true
                    )
                } else if offset < 60, windowStart > 0 {
                    let retreat = min(batchSize, windowStart)
                    windowStart -= retreat
                    _ = try? scrollViewer.changeView(
                        nil,
                        offset + Double(retreat) * rowHeight,
                        nil,
                        true
                    )
                }
            }
        }
    #endif
}

#if canImport(WinUIBackend)
    final class P4WeakScrollViewer {
        weak var scrollViewer: WinUI.ScrollViewer?

        init(_ scrollViewer: WinUI.ScrollViewer) {
            self.scrollViewer = scrollViewer
        }
    }

    enum P4ScrollAutoLoad {
        nonisolated(unsafe) static var hookedScrollViewers: [ObjectIdentifier: P4WeakScrollViewer] = [:]
    }
#endif

#if canImport(WinUIBackend)
    struct P4NativeWinUIBanner: WinUIElementRepresentable {
        var text: String
        var tick: Int

        func makeWinUIElement(context: Context) -> WinUI.Border {
            let border = WinUI.Border()
            border.cornerRadius = .init(topLeft: 6, topRight: 6, bottomRight: 6, bottomLeft: 6)
            border.padding = .init(left: 12, top: 8, right: 12, bottom: 8)
            return border
        }

        func updateWinUIElement(_ border: WinUI.Border, context: Context) {
            let block = WinUI.TextBlock()
            block.text = "\(text) Tick \(tick)"
            block.textWrapping = .wrap

            let foreground = WinUI.SolidColorBrush()
            foreground.color = UWP.Color(a: 255, r: 10, g: 35, b: 65)
            block.foreground = foreground

            let background = WinUI.SolidColorBrush()
            background.color = UWP.Color(a: 255, r: 230, g: 242, b: 255)
            border.background = background

            let borderBrush = WinUI.SolidColorBrush()
            borderBrush.color = UWP.Color(a: 255, r: 45, g: 95, b: 150)
            border.borderBrush = borderBrush
            border.borderThickness = .init(left: 1, top: 1, right: 1, bottom: 1)
            border.child = block
        }
    }
#endif
