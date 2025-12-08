//
//  Copyright © 2016 Tomas Linhart. All rights reserved.
//

public struct Size: Sendable {
    static let zero = Size(width: 0, height: 0)

    public var width: Int
    public var height: Int

    public init(width: Int = 0, height: Int = 0) {
        self.width = width
        self.height = height
    }
}

extension Size: CustomStringConvertible {
    public var description: String {
        return "(\(width), \(height))"
    }
}

extension Size: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}
