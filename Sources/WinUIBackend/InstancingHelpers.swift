import Foundation
import WinSDK
import WinSDK.PSAPI

enum InstancingHelpers {
    enum Error: LocalizedError {
        case failedToEnumerateProcesses
        case failedToEnumerateWindowsForProcess(processId: Int)
        case failedToGetProcessInfo(processId: Int)
        case failedToGetProcessName(processId: Int)
        case failedToLocateWindowForProcess(name: String)
        case failedToLocateWindowForProcessWithId(id: Int)
        case failedToBringWindowToForeground

        var errorDescription: String? {
            switch self {
                case .failedToEnumerateProcesses:
                    return "Failed to enumerate processes"
                case .failedToEnumerateWindowsForProcess(let processId):
                    return "Failed to enumerate windows for process with id \(processId)"
                case .failedToGetProcessInfo(let processId):
                    return "Failed to get process info for process with id \(processId)"
                case .failedToGetProcessName(let processId):
                    return "Failed to get name of process with id \(processId)"
                case .failedToLocateWindowForProcess(let name):
                    return "Failed to locate window for process with name \(name)"
                case .failedToLocateWindowForProcessWithId(let id):
                    return "Failed to locate window for process with id \(id)"
                case .failedToBringWindowToForeground:
                    return "Failed to bring window to foreground"
            }
        }
    }

    static func activateProcess(withName name: String) throws {
        let processes = try enumerateProcesses(withName: name)
        let windows = try processes.flatMap { id in
            try enumerateWindows(processId: id)
        }

        guard let firstWindow = windows.first else {
            throw Error.failedToLocateWindowForProcess(name: name)
        }

        guard SetForegroundWindow(firstWindow) else {
            throw Error.failedToBringWindowToForeground
        }
    }

    static func activateProcess(withId processId: Int) throws {
        let windows = try enumerateWindows(processId: processId)

        guard let firstWindow = windows.first else {
            throw Error.failedToLocateWindowForProcessWithId(id: processId)
        }

        guard SetForegroundWindow(firstWindow) else {
            throw Error.failedToBringWindowToForeground
        }
    }

    static func enumerateProcesses() throws -> [Int] {
        var processes: [DWORD] = []
        var capacity = 1024
        while true {
            processes = try Array<DWORD>(unsafeUninitializedCapacity: capacity) { buffer, count in
                var dwordCount: DWORD = 0
                if !K32EnumProcesses(
                    buffer.baseAddress,
                    DWORD(capacity * MemoryLayout<DWORD>.stride),
                    &dwordCount
                ) {
                    throw Error.failedToEnumerateProcesses
                }
                count = Int(dwordCount) / MemoryLayout<DWORD>.stride
            }

            if processes.count < capacity {
                break
            }

            capacity *= 2
        }

        return processes.map(Int.init(_:)).filter { id in
            // We skip the special system process with id 0 (because it acts
            // special, and can't be opened with OpenProcess)
            id != 0
        }
    }

    static func enumerateProcesses(withName name: String) throws -> [Int] {
        let processes = try enumerateProcesses()
        return try processes.filter { id in
            let processName = try nameOfProcess(withId: id)
            return processName == name
        }
    }

    static func nameOfProcess(withId processId: Int) throws -> String? {
        guard let handle = OpenProcess(
            DWORD(PROCESS_QUERY_INFORMATION),
            false,
            DWORD(processId)
        ) else {
            if GetLastError() == ERROR_ACCESS_DENIED {
                return nil
            }
            throw Error.failedToGetProcessInfo(processId: processId)
        }

        var buffer = Array<TCHAR>(repeating: 0, count: Int(MAX_PATH))
        guard K32GetModuleFileNameExA(handle, nil, &buffer, DWORD(buffer.count)) != 0 else {
            throw Error.failedToGetProcessName(processId: processId)
        }

        return String(cString: &buffer)
    }

    class Box<T> {
        var value: T

        init(value: T) {
            self.value = value
        }
    }

    static func enumerateWindows(processId: Int) throws -> [HWND] {
        struct State {
            let processId: Int
            var windows: [HWND]
        }

        let state = Box(
            value: State(processId: processId, windows: [])
        )
        let result = EnumWindows(
            { hwnd, statePointer in
                let state = Unmanaged<Box<State>>.fromOpaque(
                    UnsafeMutableRawPointer(bitPattern: Int(statePointer))!
                ).takeUnretainedValue()
                var windowProcessId: DWORD = 0
                GetWindowThreadProcessId(hwnd, &windowProcessId)
                if state.value.processId == Int(windowProcessId) {
                    state.value.windows.append(hwnd!)
                }
                return true
            },
            LPARAM(Int(bitPattern: Unmanaged.passUnretained(state).toOpaque()))
        )
        if !result {
            throw Error.failedToEnumerateWindowsForProcess(processId: processId)
        }
        return state.value.windows
    }
}
