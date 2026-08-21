import Foundation

// These types are already Equatable on non-Apple platforms
#if canImport(Darwin)
    extension Foundation.CGRect: Swift.Equatable {
        public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
            lhs.origin == rhs.origin && lhs.size == rhs.size
        }
    }

    extension Foundation.CGPoint: Swift.Equatable {
        public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
            lhs.x == rhs.x && lhs.y == rhs.y
        }
    }

    extension Foundation.CGSize: Swift.Equatable {
        public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
            lhs.width == rhs.width && lhs.height == rhs.height
        }
    }
#endif

extension ControlSize {
    public static var allCases: [ControlSize] {
        var cases: [ControlSize] = [.mini, .small, .regular]

        if #available(macOS 11.0, *) {
            cases.append(.large)
        }
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *) {
            cases.append(.extraLarge)
        }

        return cases
    }
}
