import Testing
@testable import SwiftCrossUI

@Suite("Test Gradients")
@MainActor
struct GradientTests {
    @Test("Automatic equal distribution of color")
    func testAutomaticColorDistribution() async throws {
        let gradient = Gradient(colors: .init(repeating: .red, count: 12))
        
        checkExpectations(gradient: gradient)
        
        func checkExpectations(gradient: Gradient) {
            let count = Double(gradient.stops.count) - 1
    
            for (i, stop) in gradient.stops.enumerated() {
                #expect(stop.location ~= (Double(i) / count))
            }
        }
    }
    
    @Test("Empty array creates transparent stops")
    func testEmptyArrayCreatesTransparentStops() async throws {
        let gradient = Gradient(colors: [])
        
        #expect(gradient.stops.count == 2)
        #expect(gradient.stops.first!.color.opacityMultiplier == 0)
        #expect(gradient.stops.first!.location == 0)
        #expect(gradient.stops.last!.color.opacityMultiplier == 0)
        #expect(gradient.stops.last!.location == 1)
    }
    
    @Test("Single color array creates 2 stops of color")
    func testSingleColorArrayCreates2Stops() async throws {
        let gradient = Gradient(colors: [.red])
        
        #expect(gradient.stops.count == 2)
        #expect(gradient.stops.first!.color == .red)
        #expect(gradient.stops.first!.location == 0)
        #expect(gradient.stops.last!.color == .red)
        #expect(gradient.stops.last!.location == 1)
    }
    
    @Test("Color order stays the same")
    func testColorOrderStays() async throws {
        let colors: [Color] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple
        ]
        
        let gradient = Gradient(colors: colors)
        
        for (i, stop) in gradient.stops.enumerated() {
            #expect(colors[i] == stop.color)
        }
    }
    
    @Test("Angular: Unspecified end angle returns original stops")
    func nilEndAngleReturnsOriginalStops() async throws {
        let gradient = AngularGradient(
            stops: [
                .init(color: .red, location: 0),
                .init(color: .blue, location: 1)
            ],
            center: .center,
            angle: .degrees(45)
        )
        
        let result = gradient.adjustedStops
        
        #expect(gradient.endAngle == nil)
        #expect(result == gradient.gradient.stops)
    }
    
    @Test("Angular: Positive range scales correctly")
    func positiveRangeScalesCorrectly() async throws {
        let gradient = AngularGradient(
            stops: [
                .init(color: .red, location: 0),
                .init(color: .blue, location: 0.5),
                .init(color: .green, location: 1)
            ],
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(180)
        )
        
        let result = gradient.adjustedStops
        
        #expect(result[0].location == 0)
        #expect(result[1].location ~= 0.25)
        #expect(result[2].location ~= 0.5)
    }
    
    @Test("Angular: Negative range inverts locations")
    func negativeRangeReversesAndInverts() async throws {
        let gradient = AngularGradient(
            stops: [
                .init(color: .red, location: 0),
                .init(color: .blue, location: 0.5),
                .init(color: .green, location: 1)
            ],
            center: .center,
            startAngle: .degrees(180),
            endAngle: .degrees(0)
        )
        
        let result = gradient.adjustedStops
        
        #expect(result[0].color == .green)
        #expect(result[0].location ~= 0)
        #expect(result[1].location ~= 0.25)
        #expect(result[2].location ~= 0.5)
    }
    
    @Test("Angular: Full circle range")
    func fullCircleRange() async throws {
        let gradient = AngularGradient(
            stops: [
                .init(color: .red, location: 0),
                .init(color: .blue, location: 1)
            ],
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
        
        let result = gradient.adjustedStops
        
        #expect(result[0].location == 0)
        #expect(result[1].location ~= 1.0)
    }
    
    @Test("Radial: negative range returns inverted stops")
    func radialNegativeRangeReturnsInvertedStops() async throws {
        let gradient = RadialGradient(
            stops: [
                .init(color: .red, location: 0.25),
                .init(color: .blue, location: 1)
            ],
            center: .center,
            startRadius: 300,
            endRadius: 0
        )
        
        let result = gradient.adjustedStops
        let expectedResult: [Gradient.Stop] = [
            .init(color: .blue, location: 0),
            .init(color: .red, location: 0.75)
        ]
        
        #expect(result == expectedResult)
    }
    
    @Test("Radial: starting at 0 returns original stops")
    func radialStartingAtZeroReturnsOriginalStops() async throws {
        let gradient = RadialGradient(
            stops: [
                .init(color: .red, location: 0),
                .init(color: .blue, location: 1)
            ],
            center: .center,
            startRadius: 0,
            endRadius: 300
        )
        
        let result = gradient.adjustedStops
        
        #expect(result == gradient.gradient.stops)
    }
    
    @Test("Radial: stops location gets adjusted correctly")
    func radialStopsLocationAdjustedCorrectly() async throws {
        let gradient = RadialGradient(
            stops: [
                .init(color: .red, location: 0),
                .init(color: .green, location: 0.5),
                .init(color: .blue, location: 1)
            ],
            center: .center,
            startRadius: 100,
            endRadius: 200
        )
        
        let result = gradient.adjustedStops
        
        #expect(result[0].location ~= 0.5)
        #expect(result[1].location ~= 0.75)
        #expect(result[2].location ~= 1)
    }
}

fileprivate extension Double {
    static func ~= (lhs: Self, rhs: Self) -> Bool {
        abs(lhs - rhs) < 1e-6
    }
}
