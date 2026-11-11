import Foundation

struct Gtk3Error: LocalizedError {
    var code: Int
    var domain: Int
    var message: String

    var errorDescription: String? {
        "gerror: code=\(code), domain=\(domain), message=\(message)"
    }
}
