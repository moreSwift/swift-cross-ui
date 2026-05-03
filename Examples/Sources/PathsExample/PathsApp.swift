import DefaultBackend
import Foundation // for sin, cos
import SwiftCrossUI

struct ArcShape: StyledShape {
    var startAngle: Double
    var endAngle: Double
    var clockwise: Bool

    var strokeColor: Color? = Color.green
    let fillColor: Color? = nil
    let strokeStyle: StrokeStyle? = StrokeStyle(width: 5.0)

    func path(in bounds: Path.Rect) -> Path {
        Path()
            .addArc(
                center: bounds.center,
                radius: min(bounds.width, bounds.height) / 2.0 - 2.5,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: clockwise
            )
    }

    func size(fitting proposal: SIMD2<Int>) -> ViewSize {
        let diameter = Double(max(11, min(proposal.x, proposal.y)))
        return ViewSize(diameter, diameter)
    }
}

struct TestCurveShape: StyledShape {
    var strokeColor: Color? = Color.purple
    let fillColor: Color? = nil
    let strokeStyle: StrokeStyle? = StrokeStyle(width: 3.0, cap: .round)

    func path(in bounds: Path.Rect) -> Path {
        Path()
            .move(to: SIMD2(x: bounds.x + 1.5, y: bounds.y + 1.5))
            .addCubicCurve(
                control1: SIMD2(x: bounds.maxX, y: bounds.center.y),
                control2: SIMD2(x: bounds.x, y: bounds.center.y),
                to: SIMD2(x: bounds.maxX - 1.5, y: bounds.maxY - 1.5)
            )
            .addSubpath(
                RoundedRectangle(cornerRadius: 12.0)
                    .path(
                        in: Path.Rect(
                            x: bounds.x + (1.0 - 0.5.squareRoot()) * bounds.width / 2.0,
                            y: bounds.y + (1.0 - 0.5.squareRoot()) * bounds.height / 2.0,
                            width: bounds.width * 0.5.squareRoot(),
                            height: bounds.height * 0.5.squareRoot()
                        )
                    )
                    .applyTransform(.rotation(degrees: 60.0, center: bounds.center))
            )
            .applyTransform(.rotation(degrees: -15.0, center: bounds.center))
    }
}

@main
struct PathsApp: App {
    var body: some Scene {
        WindowGroup("PathsApp") {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .inset(by: 2)
                        .stroke(.red, style: .init(width: 4))
                        .fill(.gray)

                    HStack {
                        VStack {
                            Text("Clockwise")

                            HStack {
                                ArcShape(
                                    startAngle: .pi * 2.0 / 3.0,
                                    endAngle: .pi * 1.5,
                                    clockwise: true
                                )

                                ArcShape(
                                    startAngle: .pi * 1.5,
                                    endAngle: .pi * 1.0 / 3.0,
                                    clockwise: true
                                )
                            }

                            HStack {
                                ArcShape(
                                    startAngle: .pi * 1.5,
                                    endAngle: .pi * 2.0 / 3.0,
                                    clockwise: true
                                )

                                ArcShape(
                                    startAngle: .pi * 1.0 / 3.0,
                                    endAngle: .pi * 1.5,
                                    clockwise: true
                                )
                            }
                        }

                        VStack {
                            Text("Counter-clockwise")

                            HStack {
                                ArcShape(
                                    startAngle: .pi * 1.5,
                                    endAngle: .pi * 2.0 / 3.0,
                                    clockwise: false
                                )

                                ArcShape(
                                    startAngle: .pi * 1.0 / 3.0,
                                    endAngle: .pi * 1.5,
                                    clockwise: false
                                )
                            }

                            HStack {
                                ArcShape(
                                    startAngle: .pi * 2.0 / 3.0,
                                    endAngle: .pi * 1.5,
                                    clockwise: false
                                )

                                ArcShape(
                                    startAngle: .pi * 1.5,
                                    endAngle: .pi * 1.0 / 3.0,
                                    clockwise: false
                                )
                            }
                        }
                    }.padding()
                }
                .padding()

                TestCurveShape()
                    .padding()
            }
        }
    }
}
