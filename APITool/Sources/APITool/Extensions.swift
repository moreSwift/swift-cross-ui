import Foundation

extension URL {
    static func / (_ lhs: Self, _ rhs: String) -> Self {
        lhs.appendingPathComponent(rhs)
    }

    func exists() -> Bool {
        FileManager.default.fileExists(atPath: path)
    }

    static var currentDirectory: URL {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
