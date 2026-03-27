import DefaultBackend
import Foundation
import SwiftCrossUI

#if canImport(WinUIBackend)
    import WinUI
    import UWP
#endif

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct CounterApp: App {
    @State var count = 0
    @State var value = 0.0
    @State var color: String? = nil
    @State var name = ""

    var body: some Scene {
        WindowGroup("Inspect modifier and custom native views") {
            #hotReloadable {
                ScrollView {
                    CustomNativeButton(label: "Custom native button")

                    #if canImport(UIKitBackend)
                        CustomNativeViewControllerButton(label: "Custom UIViewController button")
                    #endif

                    HStack(spacing: 20) {
                        Button("-") {
                            count -= 1
                        }

                        Text("Count: \(count)")
                            .inspect { text in
                                #if canImport(AppKitBackend)
                                    text.isSelectable = true
                                #elseif canImport(UIKitBackend)
                                    text.isUserInteractionEnabled = true
                                #elseif canImport(WinUIBackend)
                                    text.isTextSelectionEnabled = true
                                #elseif canImport(GtkBackend)
                                    text.selectable = true
                                #elseif canImport(Gtk3Backend)
                                    text.selectable = true
                                #endif
                            }

                        Button("+") {
                            count += 1
                        }.inspect(.afterUpdate) { button in
                            #if canImport(AppKitBackend)
                                // Button is an NSButton on macOS
                                button.bezelColor = .red
                            #elseif canImport(UIKitBackend)
                                if #available(iOS 15.0, tvOS 15.0, *) {
                                    button.configuration = .bordered()
                                }
                            #elseif canImport(WinUIBackend)
                                button.cornerRadius.topLeft = 10
                                let brush = WinUI.SolidColorBrush()
                                brush.color = .init(a: 255, r: 255, g: 0, b: 0)
                                button.background = brush
                            #elseif canImport(GtkBackend)
                                button.css.set(property: .backgroundColor(.init(1, 0, 0)))
                            #elseif canImport(Gtk3Backend)
                                button.css.set(property: .backgroundColor(.init(1, 0, 0)))
                            #endif
                        }
                    }

                    #if !os(tvOS)
                        Slider(value: $value, in: 0...10)
                            .inspect { slider in
                                #if canImport(AppKitBackend)
                                    slider.numberOfTickMarks = 10
                                #elseif canImport(UIKitBackend)
                                    slider.thumbTintColor = .blue
                                #elseif canImport(WinUIBackend)
                                    slider.isThumbToolTipEnabled = true
                                #elseif canImport(GtkBackend)
                                    slider.drawValue = true
                                #elseif canImport(Gtk3Backend)
                                    slider.drawValue = true
                                #endif
                            }
                    #endif

                    // TODO(stackotter): Repair Picker.inspect implementations post
                    //   PickerStyle refactor
                    // #if !canImport(Gtk3Backend)
                    //     Picker(of: ["Red", "Green", "Blue"], selection: $color)
                    //         .inspect(.afterUpdate) { picker in
                    //             #if canImport(AppKitBackend)
                    //                 picker.preferredEdge = .maxX
                    //             #elseif canImport(UIKitBackend) && os(iOS)
                    //                 // Can't think of something to do to the
                    //                 // UIPickerView, but the point is that you
                    //                 // could do something if you needed to!
                    //                 // This would be a UITableView on tvOS.
                    //                 // And could be either a UITableView or a
                    //                 // UIPickerView on Mac Catalyst depending
                    //                 // on Mac Catalyst version and interface
                    //                 // idiom.
                    //             #elseif canImport(WinUIBackend)
                    //                 let brush = WinUI.SolidColorBrush()
                    //                 brush.color = .init(a: 255, r: 255, g: 0, b: 0)
                    //                 picker.background = brush
                    //             #elseif canImport(GtkBackend)
                    //                 picker.enableSearch = true
                    //             #endif
                    //         }
                    // #endif

                    TextField("Name", text: $name)
                        .inspect(.afterUpdate) { textField in
                            #if canImport(AppKitBackend)
                                textField.backgroundColor = .blue
                            #elseif canImport(UIKitBackend)
                                textField.borderStyle = .bezel
                            #elseif canImport(WinUIBackend)
                                textField.selectionHighlightColor.color = .init(
                                    a: 255, r: 0, g: 255, b: 0)
                                let brush = WinUI.SolidColorBrush()
                                brush.color = .init(a: 255, r: 0, g: 0, b: 255)
                                textField.background = brush
                            #elseif canImport(GtkBackend)
                                textField.xalign = 1
                                textField.css.set(property: .backgroundColor(.init(0, 0, 1)))
                            #elseif canImport(Gtk3Backend)
                                textField.hasFrame = false
                                textField.css.set(property: .backgroundColor(.init(0, 0, 1)))
                            #endif
                        }

                    ScrollView {
                        ForEach(Array(1...50), id: \.self) { number in
                            Text("Line \(number)")
                        }.padding()
                    }.inspect(.afterUpdate) { scrollView in
                        #if canImport(AppKitBackend)
                            scrollView.borderType = .grooveBorder
                        #elseif canImport(UIKitBackend)
                            scrollView.alwaysBounceHorizontal = true
                        #elseif canImport(WinUIBackend)
                            let brush = WinUI.SolidColorBrush()
                            brush.color = .init(a: 255, r: 0, g: 255, b: 0)
                            scrollView.borderBrush = brush
                            scrollView.borderThickness = .init(
                                left: 1, top: 1, right: 1, bottom: 1
                            )
                        #elseif canImport(GtkBackend)
                            scrollView.css.set(property: .border(color: .init(1, 0, 0), width: 2))
                        #elseif canImport(Gtk3Backend)
                            scrollView.css.set(property: .border(color: .init(1, 0, 0), width: 2))
                        #endif
                    }.frame(height: 200)

                    List(["Red", "Green", "Blue"], id: \.self, selection: $color) { color in
                        Text(color)
                    }.inspect(.afterUpdate) { table in
                        #if canImport(AppKitBackend)
                            table.usesAlternatingRowBackgroundColors = true
                        #elseif canImport(UIKitBackend)
                            table.isEditing = true
                        #elseif canImport(WinUIBackend)
                            let brush = WinUI.SolidColorBrush()
                            brush.color = .init(a: 255, r: 255, g: 0, b: 255)
                            table.borderBrush = brush
                            table.borderThickness = .init(
                                left: 1, top: 1, right: 1, bottom: 1
                            )
                        #elseif canImport(GtkBackend)
                            table.showSeparators = true
                        #elseif canImport(Gtk3Backend)
                            table.selectionMode = .multiple
                        #endif
                    }

                    Image(Bundle.module.bundleURL.appendingPathComponent("Banner.png"))
                        .resizable()
                        .inspect(.afterUpdate) { image in
                            #if canImport(AppKitBackend)
                                image.isEditable = true
                            #elseif canImport(UIKitBackend)
                                image.layer.borderWidth = 1
                                image.layer.borderColor = .init(red: 0, green: 1, blue: 0, alpha: 1)
                            #elseif canImport(WinUIBackend)
                                // Couldn't find anything visually interesting
                                // to do to the WinUI.Image, but the point is
                                // that you could do something if you wanted to.
                            #elseif canImport(GtkBackend)
                                image.css.set(property: .border(color: .init(0, 1, 0), width: 2))
                            #elseif canImport(Gtk3Backend)
                                image.css.set(property: .border(color: .init(0, 1, 0), width: 2))
                            #endif
                        }
                        .aspectRatio(contentMode: .fit)
                }
                .padding()
                .inspectWindow { window in
                    #if canImport(AppKitBackend)
                        window.backgroundColor = .black
                    #elseif canImport(GtkBackend) || canImport(Gtk3Backend)
                        window.title = "Overridden title"
                    #elseif canImport(WinUIBackend)
                        // Only works on Windows 11+
                        window.appWindow.titleBar.backgroundColor = UWP.Color(a: 255, r: 0, g: 255, b: 255)
                    #elseif canImport(UIKitBackend)
                        window.backgroundColor = .darkGray
                    #endif
                }
            }
        }
        .defaultSize(width: 400, height: 200)
    }
}
