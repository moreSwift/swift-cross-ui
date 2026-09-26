import Foundation
import WinSDK

#if canImport(CRT)
    import CRT
#endif

extension WinUIBackend {
    /// Attaches the app's standard IO streams to the parent's console.
    ///
    /// This allows the stdout/stderr of SwiftCrossUI GUI apps to be
    /// viewed by starting them from the command line, even when they're
    /// built and linked as /SUBSYSTEM:WINDOWS apps (GUI apps). Without
    /// this fix the output of GUI apps is basically impossible to access.
    ///
    /// Adapted from: https://stackoverflow.com/a/55875595/8268001
    static func attachToParentConsole() throws {
        try Self.releaseConsole()
        // -1 attaches to parent's console
        if AttachConsole(DWORD(bitPattern: -1)) {
            try Self.adjustConsoleBuffer(1024)
            try Self.redirectConsoleIO()
        }
    }

    /// Releases existing files associated with the app's standard IO streams.
    private static func releaseConsole() throws {
        var fp = UnsafeMutablePointer<FILE>?.none
        guard
            freopen_s(&fp, "NUL:", "r", stdin) == 0,
            freopen_s(&fp, "NUL:", "w", stdout) == 0,
            freopen_s(&fp, "NUL:", "w", stderr) == 0,
            FreeConsole()
        else {
            throw Error(message: "Failed to release existing console")
        }
    }

    /// Redirect the application's standard IO streams to the current console.
    private static func redirectConsoleIO() throws {
        var fp = UnsafeMutablePointer<FILE>?.none
        guard
            freopen_s(&fp, "CONIN$", "r", stdin) == 0,
            freopen_s(&fp, "CONOUT$", "w", stderr) == 0
        else {
            throw Error(message: "Failed to redirect console IO")
        }
        try redirectFilteredStandardOutput()
    }

    /// Redirects stdout into a pipe drained by a background thread that
    /// filters out noise before writing to the console.
    ///
    /// Microsoft.UI.Xaml.dll from WindowsAppSDK 1.5 preview prints backdrop
    /// debugging messages (BVI-*, rcBackdropLocal=, and bare matrix/rect
    /// value lines) straight to stdout whenever an acrylic backdrop
    /// re-renders, and apps have no switch to turn them off. stderr is left
    /// attached directly to the console so that crash output can't get lost
    /// in the pipe. Remove this filter once we're on a stable WindowsAppSDK
    /// (#204).
    private static func redirectFilteredStandardOutput() throws {
        var pipeEnds = [CInt](repeating: 0, count: 2)
        guard _pipe(&pipeEnds, 65536, _O_BINARY) == 0 else {
            throw Error(message: "Failed to create console filter pipe")
        }
        let readEnd = pipeEnds[0]
        let writeEnd = pipeEnds[1]

        guard _dup2(writeEnd, _fileno(stdout)) == 0 else {
            throw Error(message: "Failed to redirect stdout to console filter pipe")
        }
        // The pipe isn't a console, so the CRT switches stdout to full
        // buffering; disable buffering so output flows through immediately.
        setvbuf(stdout, nil, _IONBF, 0)

        // Cover code that writes directly to GetStdHandle(STD_OUTPUT_HANDLE)
        // as well.
        SetStdHandle(
            STD_OUTPUT_HANDLE,
            UnsafeMutableRawPointer(bitPattern: _get_osfhandle(writeEnd))
        )

        var consoleFile = UnsafeMutablePointer<FILE>?.none
        guard fopen_s(&consoleFile, "CONOUT$", "w") == 0, let console = consoleFile else {
            throw Error(message: "Failed to open console for filtered output")
        }
        let consoleAddress = UInt(bitPattern: console)

        Thread.detachNewThread {
            let console = UnsafeMutablePointer<FILE>(bitPattern: consoleAddress)!
            var buffer = [UInt8](repeating: 0, count: 4096)
            var pending = ""
            var lastLineWasNoise = false
            while true {
                let count = _read(readEnd, &buffer, UInt32(buffer.count))
                guard count > 0 else { break }
                pending += String(decoding: buffer[0..<Int(count)], as: UTF8.self)
                while let newlineIndex = pending.firstIndex(of: "\n") {
                    var line = String(pending[..<newlineIndex])
                    pending = String(pending[pending.index(after: newlineIndex)...])
                    if line.hasSuffix("\r") {
                        line.removeLast()
                    }
                    if isBackdropDebugNoise(line, afterNoiseLine: lastLineWasNoise) {
                        lastLineWasNoise = true
                        continue
                    }
                    lastLineWasNoise = false
                    fputs(line + "\n", console)
                    fflush(console)
                }
            }

            if !pending.isEmpty {
                if pending.hasSuffix("\r") {
                    pending.removeLast()
                }
                if !isBackdropDebugNoise(pending, afterNoiseLine: lastLineWasNoise) {
                    fputs(pending, console)
                    fflush(console)
                }
            }
        }
    }

    /// Decides whether a single output line is WinUI backdrop debugging noise.
    private nonisolated static func isBackdropDebugNoise(
        _ line: String,
        afterNoiseLine: Bool
    ) -> Bool {
        // The noise blocks are interleaved with blank lines; drop blank lines
        // that directly follow a noise line.
        if line.isEmpty {
            return afterNoiseLine
        }
        if line.hasPrefix("BVI-") || line.hasPrefix("rcBackdropLocal=") {
            return true
        }
        // Bare matrix/rect value lines contain only digits and light
        // punctuation, e.g. "(1.25, 0.00, 0.00, 0.00), ..." or
        // "0.00, 0.00, 12.00, 339.20 (12.00 x 339.20)". Only filter them
        // after an explicit backdrop noise prefix so normal numeric stdout
        // such as "12345" still reaches the console.
        return afterNoiseLine && line.allSatisfy { "0123456789.,-() x".contains($0) }
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
}
