import Foundation
import WinSDK

extension WinUIBackend {
    /// Attaches the app's standard IO streams to the parent's console.
    ///
    /// This allows the stdout/stderr of SwiftCrossUI GUI apps to be
    /// viewed by starting them from the command line, even when they're
    /// built and linked as /SUBSYSTEM:WINDOWS apps (GUI apps). Without
    /// this fix the output of GUI apps is basically impossible to access.
    ///
    /// Streams that the caller has redirected (to a file, a pipe or a
    /// non-console device such as `NUL`) are left alone, stream by stream,
    /// so that e.g. `app.exe > out.txt` still writes stdout to `out.txt`
    /// while stderr goes to the console.
    ///
    /// Adapted from: https://stackoverflow.com/a/55875595/8268001
    static func attachToParentConsole() throws {
        let redirected = StandardStream.allCases.filter(\.isRedirected)
        let consoleStreams = StandardStream.allCases.filter { !redirected.contains($0) }
        guard !consoleStreams.isEmpty else {
            return
        }
        let redirectedHandles = redirected.map { ($0.handleID, GetStdHandle($0.handleID)) }
        try Self.releaseConsole(consoleStreams)
        // -1 attaches to parent's console
        if AttachConsole(DWORD(bitPattern: -1)) {
            // AttachConsole points the standard handles at the console unless
            // the process was started with STARTF_USESTDHANDLES, which cmd.exe
            // doesn't use for its own redirections (`app.exe > out.txt`), so
            // put the redirected ones back. Best-effort: the C streams keep
            // their own descriptors regardless, so a failure only leaves
            // GetStdHandle (FileHandle, child processes) on the console.
            for (handleID, handle) in redirectedHandles {
                _ = SetStdHandle(handleID, handle)
            }
            try Self.redirectConsoleIO(consoleStreams)
            // Only after the redirection: releasing stdout onto NUL can leave
            // STD_OUTPUT_HANDLE pointing at NUL (the CRT updates it for console
            // apps). A bigger buffer is cosmetic, so failing to get one isn't
            // an error.
            if consoleStreams.contains(.output) {
                try? Self.adjustConsoleBuffer(1024)
            }
        }
    }

    /// Releases existing files associated with the given standard IO streams.
    private static func releaseConsole(_ streams: [StandardStream]) throws {
        var fp = UnsafeMutablePointer<FILE>?.none
        for stream in streams {
            guard freopen_s(&fp, "NUL:", stream.mode, stream.file) == 0 else {
                throw Error(message: "Failed to release existing console")
            }
        }
        guard FreeConsole() else {
            throw Error(message: "Failed to release existing console")
        }
    }

    /// Redirect the given standard IO streams to the current console.
    private static func redirectConsoleIO(_ streams: [StandardStream]) throws {
        var fp = UnsafeMutablePointer<FILE>?.none
        for stream in streams {
            guard freopen_s(&fp, stream.consoleName, stream.mode, stream.file) == 0 else {
                throw Error(message: "Failed to redirect console IO")
            }
        }
    }

    /// Adjusts the size of the app's console output buffer.
    private static func adjustConsoleBuffer(_ minLength: SHORT) throws {
        let handle = GetStdHandle(STD_OUTPUT_HANDLE)
        var consoleInfo = CONSOLE_SCREEN_BUFFER_INFO()
        guard GetConsoleScreenBufferInfo(handle, &consoleInfo) else {
            throw Error(message: "Failed to get console screen buffer info")
        }
        if consoleInfo.dwSize.Y < minLength {
            consoleInfo.dwSize.Y = minLength
        }
        guard SetConsoleScreenBufferSize(handle, consoleInfo.dwSize) else {
            throw Error(message: "Failed to set console screen buffer size")
        }
    }

    /// One of the app's standard IO streams.
    private enum StandardStream: CaseIterable {
        case input
        case output
        case error

        var file: UnsafeMutablePointer<FILE> {
            switch self {
                case .input: stdin
                case .output: stdout
                case .error: stderr
            }
        }

        var mode: String {
            self == .input ? "r" : "w"
        }

        var consoleName: String {
            self == .input ? "CONIN$" : "CONOUT$"
        }

        var handleID: DWORD {
            switch self {
                case .input: STD_INPUT_HANDLE
                case .output: STD_OUTPUT_HANDLE
                case .error: STD_ERROR_HANDLE
            }
        }

        /// Whether the caller redirected this stream away from the console:
        /// its handle is a file, a pipe or a character device that isn't a
        /// console (`NUL`, a serial port). A console handle (e.g. one
        /// inherited from the parent) is not a redirection; it gets released
        /// and reattached to the parent's console like a missing handle.
        var isRedirected: Bool {
            guard let handle = GetStdHandle(handleID) else {
                return false
            }
            switch GetFileType(handle) {
                case DWORD(FILE_TYPE_DISK), DWORD(FILE_TYPE_PIPE):
                    return true
                case DWORD(FILE_TYPE_CHAR):
                    var consoleMode: DWORD = 0
                    return !GetConsoleMode(handle, &consoleMode)
                default:
                    // FILE_TYPE_UNKNOWN, including INVALID_HANDLE_VALUE
                    return false
            }
        }
    }
}
