import Foundation
import WinSDK
@_spi(Backends) import SwiftCrossUI

private func getLocaleInfoString(_ type: Int32, bufferSize: Int) -> String? {
    withUnsafeTemporaryAllocation(of: CWideChar.self, capacity: bufferSize) { ptr in
        // LOCALE_NAME_USER_DEFAULT is a #define for NULL. With no type context, Swift can't infer
        // the correct type. Pass nil directly instead.
        // The LOCALE_ constants are typed as Int32. LCTYPE is UInt32. So those have to be converted.
        let size = GetLocaleInfoEx(
            nil,
            LCTYPE(type),
            ptr.baseAddress,
            CInt(ptr.count)
        )

        if size == 0 {
            logger.warning("Error getting locale info: \(GetLastError())")
            return nil
        } else {
            let slice = ptr[..<Int(size)]
            return String(decoding: slice, as: UTF16.self)
        }
    }
}

private func getLocaleInfoInt(_ type: Int32) -> DWORD? {
    withUnsafeTemporaryAllocation(of: DWORD.self, capacity: 1) { ptr in
        let result = ptr.withMemoryRebound(to: CWideChar.self) {
            GetLocaleInfoEx(
                nil,
                LCTYPE(type | LOCALE_RETURN_NUMBER),
                $0.baseAddress,
                CInt($0.count)
            )
        }

        if result == 0 {
            logger.warning("Error getting locale info: \(GetLastError())")
            return nil
        } else {
            return ptr[0]
        }
    }
}

extension Foundation.Locale {
    static var windowsCurrent: Foundation.Locale {
        // The buffer size of 9 comes from the documentation: "The maximum number of characters
        // allowed for this string is nine, including a terminating null character."
        // https://learn.microsoft.com/en-us/windows/win32/intl/locale-siso-constants
        let languageCode =
            if let languageCodeStr = getLocaleInfoString(LOCALE_SISO639LANGNAME, bufferSize: 9) {
                LanguageCode(languageCodeStr)
            } else {
                nil as LanguageCode?
            }

        let region =
            if let regionStr = getLocaleInfoString(LOCALE_SISO3166CTRYNAME, bufferSize: 9) {
                Region(regionStr)
            } else {
                nil as Region?
            }

        // Windows supports multiple scripts in a single locale. Foundation doesn't. The buffer size
        // of 6 was chosen such that only one script name fits; if the locale has multiple scripts,
        // this returns nil.
        let script =
            if let scriptsStr = getLocaleInfoString(LOCALE_SSCRIPTS, bufferSize: 6) {
                Script(scriptsStr.trimmingCharacters(in: [";"]))
            } else {
                nil as Script?
            }

        var localeComponents = Foundation.Locale.Components(
            languageCode: languageCode,
            script: script,
            languageRegion: region
        )

        localeComponents.firstDayOfWeek =
            switch getLocaleInfoInt(LOCALE_IFIRSTDAYOFWEEK) {
                case 0: .monday
                case 1: .tuesday
                case 2: .wednesday
                case 3: .thursday
                case 4: .friday
                case 5: .saturday
                case 6: .sunday
                default: nil
            }

        localeComponents.measurementSystem =
            switch getLocaleInfoInt(LOCALE_IMEASURE) {
                case 0: .metric
                case 1: .us
                default: nil
            }

        localeComponents.timeZone = .current

        switch getLocaleInfoInt(LOCALE_ICALENDARTYPE) {
            case DWORD(CAL_GREGORIAN), DWORD(CAL_GREGORIAN_US), DWORD(CAL_GREGORIAN_ME_FRENCH),
                 DWORD(CAL_GREGORIAN_ARABIC), DWORD(CAL_GREGORIAN_XLIT_ENGLISH),
                 DWORD(CAL_GREGORIAN_XLIT_FRENCH):
                localeComponents.calendar = .gregorian
            case DWORD(CAL_JAPAN):
                localeComponents.calendar = .japanese
            case DWORD(CAL_TAIWAN):
                localeComponents.calendar = .republicOfChina
            case DWORD(CAL_HIJRI):
                localeComponents.calendar = .islamicTabular
            case DWORD(CAL_HEBREW):
                localeComponents.calendar = .hebrew
            case DWORD(CAL_UMALQURA):
                localeComponents.calendar = .islamicUmmAlQura
            case let id?:
                // Includes undeclared constants as well as CAL_KOREA and CAL_THAI
                logger.notice("Unsupported calendar type \(id).")
            default:
                // nil -- grabbing the calendar failed
                break
        }

        return Foundation.Locale(components: localeComponents)
    }
}
