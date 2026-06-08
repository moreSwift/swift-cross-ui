import AndroidBackendShim
import AndroidKit
import Foundation
import JavaLang
import JavaLangIO
import SwiftJava

// AndroidKit.Calendar is java.util.Calendar, which doesn't have getType()
@JavaClass(
    "android.icu.util.Calendar",
    implements: Cloneable.self,
    JavaLang.Comparable.self,
    JavaLangIO.Serializable.self
)
class AndroidCalendar: JavaObject {
    @JavaMethod
    func getFirstDayOfWeek() -> Int32

    @JavaMethod
    func getMinimalDaysInFirstWeek() -> Int32

    @JavaMethod
    func getType() -> String
}

extension JavaClass where JavaClass_T == AndroidCalendar {
    @JavaStaticMethod
    func getInstance() -> AndroidCalendar?
}

extension String {
    func ifNotEmpty<T>(_ cb: (String) -> T) -> T? {
        isEmpty ? nil : cb(self)
    }
}

// swiftlint:disable force_try
extension AndroidBackend {
    func getCurrentCalendar(timeZone: Foundation.TimeZone?) -> Foundation.Calendar {
        let androidCalendar = try! JavaClass<AndroidCalendar>().getInstance()!

        var identifier: Foundation.Calendar.Identifier
        switch androidCalendar.getType() {
            case "buddhist":
                identifier = .buddhist
            case "chinese":
                identifier = .chinese
            case "coptic":
                identifier = .coptic
            case "ethiopic":
                identifier = .ethiopicAmeteMihret
            // The documentation gives a fixed list of strings, which includes "gregorian". It
            // then links to documentation on unicode.org, which instead lists "gregory". Be
            // prepared for both, just in case.
            case "gregorian", "gregory":
                identifier = .gregorian
            case "hebrew":
                identifier = .hebrew
            case "islamic":
                identifier = .islamic
            case "islamic-civil":
                identifier = .islamicCivil
            case "japanese":
                identifier = .japanese
            case "roc":
                identifier = .republicOfChina
            case let type:
                android_log(
                    Int32(ANDROID_LOG_WARN.rawValue),
                    "Swift",
                    "Unexpected calendar type \(type). Falling back to Gregorian."
                )
                identifier = .gregorian
        }

        let androidLocale = try! JavaClass<AndroidKit.Locale>().getDefault()!
        let languageCode = androidLocale.getLanguage().ifNotEmpty(
            Foundation.Locale.LanguageCode.init(_:)
        )
        let script = androidLocale.getScript().ifNotEmpty(Foundation.Locale.Script.init(_:))
        let region = androidLocale.getCountry().ifNotEmpty(Foundation.Locale.Region.init(_:))

        var localeComponents = Foundation.Locale.Components(
            languageCode: languageCode,
            script: script,
            languageRegion: region
        )
        localeComponents.calendar = identifier
        localeComponents.timeZone = timeZone
        localeComponents.variant = androidLocale.getVariant().ifNotEmpty(
            Foundation.Locale.Variant.init(_:)
        )
        localeComponents.firstDayOfWeek =
            switch androidCalendar.getFirstDayOfWeek() {
                case 1: .sunday
                case 2: .monday
                case 3: .tuesday
                case 4: .wednesday
                case 5: .thursday
                case 6: .friday
                case 7: .saturday
                default: nil
            }

        let locale = Locale(components: localeComponents)

        var result = locale.calendar
        result.minimumDaysInFirstWeek = Int(androidCalendar.getMinimalDaysInFirstWeek())
        return result
    }
}
