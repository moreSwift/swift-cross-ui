import DefaultBackend
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@HotReloadable
@main
struct GradientsApp: App {
    static let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]

    static let stops: [Gradient.Stop] = [
        Gradient.Stop(color: .red, location: 0),
        Gradient.Stop(color: .blue, location: 0.25),
        Gradient.Stop(color: .purple, location: 1),
    ]

    @State var gradientType: GradientType? = .linear

    var body: some Scene {
        WindowGroup("Gradients Example") {
            #if !canImport(UIKitBackend) && !canImport(AndroidBackend)
                NavigationSplitView {
                    // TODO: replace with List once bug described in #556 is fixed
                    ForEach(GradientType.allCases, id: \.rawValue) { type in
                        Button(type.rawValue) {
                            gradientType = type
                        }
                        .disabled(gradientType == type)
                    }
                } detail: {
                    scrollViewWithGradient()
                }
            #else
                VStack {
                    HStack {
                        ForEach(GradientType.allCases, id: \.rawValue) { type in
                            Button(type.rawValue) {
                                gradientType = type
                            }
                            .disabled(gradientType == type)
                        }
                    }
                    scrollViewWithGradient()
                }
            #endif
        }
    }

    func scrollViewWithGradient() -> some View {
        ScrollView {
            gradients()
        }
    }

    @ViewBuilder
    func gradients() -> some View {
        switch gradientType {
            case .linear:
                LinearGradientView()
            case .radial:
                RadialGradientView()
            case .angular:
                #if !canImport(WinUIBackend) && !canImport(GtkBackend)
                    ScrollView(.horizontal) {
                        AngularGradientView()
                    }
                #else
                    Text("Angular Gradients are not supported on \(App.Backend)")
                #endif
            case .none:
                Text("Please select a gradient type.")
        }
    }
}

enum GradientType: String, CaseIterable, Identifiable {
    var id: Self { self }
    case linear
    case radial
    case angular
}

struct LinearGradientView: View {
    var colors: [Color] { GradientsApp.colors }
    var stops: [Gradient.Stop] { GradientsApp.stops }

    var body: some View {
        VStack {
            HStack {
                LinearGradient(
                    colors: colors,
                    startPoint: .trailing,
                    endPoint: .leading
                )

                LinearGradient(
                    colors: colors,
                    startPoint: .top,
                    endPoint: .bottom
                )

                LinearGradient(
                    colors: colors,
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            }
            .frame(height: 100)

            HStack {
                LinearGradient(
                    colors: colors,
                    startPoint: .leading,
                    endPoint: .trailing
                )

                LinearGradient(
                    colors: colors,
                    startPoint: .bottom,
                    endPoint: .top
                )

                LinearGradient(
                    colors: colors,
                    startPoint: .bottomTrailing,
                    endPoint: .topLeading
                )
            }
            .frame(height: 100)
        }

        LinearGradient(stops: stops, startPoint: .leading, endPoint: .trailing)
            .frame(height: 100)
    }
}

struct RadialGradientView: View {
    var colors: [Color] { GradientsApp.colors }
    var stops: [Gradient.Stop] { GradientsApp.stops }

    var body: some View {
        VStack {
            HStack {
                RadialGradient(
                    colors: colors,
                    center: .center,
                    startRadius: 0,
                    endRadius: 150
                )

                RadialGradient(
                    colors: colors,
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 300
                )

                RadialGradient(
                    stops: stops,
                    center: .bottom,
                    startRadius: 0,
                    endRadius: 300
                )
            }
            .frame(height: 300)

            VStack {
                RadialGradient(
                    stops: [
                        .init(color: .red, location: 0),
                        .init(color: .blue, location: 0.25)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 300
                ).frame(width: 600)

                RadialGradient(
                    stops: [
                        .init(color: .red, location: 0),
                        .init(color: .blue, location: 0.25)
                    ],
                    center: .center,
                    startRadius: 300,
                    endRadius: 0
                ).frame(width: 600)
            }.frame(height: 300)
        }
    }
}

struct AngularGradientView: View {
    var colors: [Color] { GradientsApp.colors }
    var stops: [Gradient.Stop] { GradientsApp.stops }

    var specialStops: [Gradient.Stop] = [
        Gradient.Stop(color: .red, location: 1 / 12),
        Gradient.Stop(color: .orange, location: 3 / 12),
        Gradient.Stop(color: .yellow, location: 5 / 12),
        Gradient.Stop(color: .green, location: 7 / 12),
        Gradient.Stop(color: .blue, location: 9 / 12),
        Gradient.Stop(color: .purple, location: 11 / 12),
        Gradient.Stop(color: .red, location: 1),
    ]

    var body: some View {
        VStack {
            HStack {
                AngularGradient(
                    colors: colors,
                    center: .center,
                    angle: .degrees(90),
                )
                .frame(width: 300)

                AngularGradient(
                    stops: stops,
                    center: .center
                )
                .frame(width: 300)

                AngularGradient(colors: colors, center: .center)
                    .frame(width: 300)
            }
            .frame(height: 300)

            HStack {
                AngularGradient(
                    stops: specialStops,
                    center: .center,
                    startAngle: .degrees(260),
                    endAngle: .degrees(500)
                )
                .frame(width: 300)

                AngularGradient(
                    stops: specialStops,
                    center: .center,
                    startAngle: .degrees(260),
                    endAngle: .degrees(620)
                )
                .frame(width: 300)

                AngularGradient(
                    stops: [
                        Gradient.Stop(color: .white, location: 0),
                        Gradient.Stop(color: .black, location: 0.1),
                        Gradient.Stop(color: .white, location: 0.2),
                        Gradient.Stop(color: .white, location: 0.5),
                    ],
                    center: .center,
                    angle: .degrees(230)
                )
                .frame(width: 300)
            }.frame(height: 100)
        }
    }
}
