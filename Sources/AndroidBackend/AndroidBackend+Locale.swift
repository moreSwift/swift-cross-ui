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
    func getCurrentCalendarAndLocale(
        timeZone: Foundation.TimeZone?
    ) -> (Foundation.Calendar, Foundation.Locale) {
        let androidCalendar = try! JavaClass<AndroidCalendar>().getInstance()!
        let androidLocale = try! JavaClass<AndroidKit.Locale>().getDefault()!

        let locale: Foundation.Locale
        if let index = localeCache.firstIndex(where: { androidLocale.equals($0.1) }) {
            locale = localeCache[index].0
        } else {
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

            locale = Locale(components: localeComponents)
            addLocaleToCache(foundationLocale: locale, javaLocale: androidLocale)
        }

        var calendar = locale.calendar
        calendar.minimumDaysInFirstWeek = Int(androidCalendar.getMinimalDaysInFirstWeek())
        return (calendar, locale)
    }

    private func addLocaleToCache(
        foundationLocale: Foundation.Locale,
        javaLocale: AndroidKit.Locale
    ) {
        localeCache.append((foundationLocale, javaLocale))
        if localeCache.count > Self.maxLocaleCacheSize {
            localeCache.removeFirst()
        }
    }

    private func makeJavaLocale(for foundationLocale: Foundation.Locale) -> AndroidKit.Locale {
        var builder = AndroidKit.Locale.Builder()
            .setUnicodeLocaleKeyword("nu", foundationLocale.numberingSystem.identifier)!

        if let languageCode = foundationLocale.language.languageCode {
            builder = builder.setLanguage(languageCode.identifier)
        }
        if let region = foundationLocale.region {
            builder = builder.setRegion(region.identifier)
        }
        if let script = foundationLocale.language.script {
            builder = builder.setScript(script.identifier)
        }
        if let variant = foundationLocale.variant {
            builder = builder.setVariant(variant.identifier)
        }
        if let currency = foundationLocale.currency {
            builder = builder.setUnicodeLocaleKeyword("cu", currency.identifier)
        }
        if let timeZone = foundationLocale.timeZone {
            builder = builder.setUnicodeLocaleKeyword("tz", timeZone.identifier)
        }

        switch foundationLocale.calendar.identifier {
            case .gregorian, .iso8601:
                builder = builder.setUnicodeLocaleKeyword("ca", "gregory")
            case .buddhist:
                builder = builder.setUnicodeLocaleKeyword("ca", "buddhist")
            case .chinese:
                builder = builder.setUnicodeLocaleKeyword("ca", "chinese")
            case .coptic:
                builder = builder.setUnicodeLocaleKeyword("ca", "coptic")
            case .ethiopicAmeteMihret:
                builder = builder.setUnicodeLocaleKeyword("ca", "ethiopic")
            case .hebrew:
                builder = builder.setUnicodeLocaleKeyword("ca", "hebrew")
            case .islamic:
                builder = builder.setUnicodeLocaleKeyword("ca", "islamic")
            case .islamicCivil:
                builder = builder.setUnicodeLocaleKeyword("ca", "islamic-civil")
            case .japanese:
                builder = builder.setUnicodeLocaleKeyword("ca", "japanese")
            case .republicOfChina:
                builder = builder.setUnicodeLocaleKeyword("ca", "roc")
            case let x:
                // all unsupported calendar types
                android_log(
                    Int32(ANDROID_LOG_WARN.rawValue),
                    "Swift",
                    "Unsupported calendar type \(x)."
                )
        }

        return builder.build()
    }

    func getJavaLocale(for foundationLocale: Foundation.Locale) -> AndroidKit.Locale {
        if let index = localeCache.firstIndex(where: { $0.0 == foundationLocale }) {
            return localeCache[index].1
        }

        let javaLocale = makeJavaLocale(for: foundationLocale)
        addLocaleToCache(foundationLocale: foundationLocale, javaLocale: javaLocale)
        return javaLocale
    }
}
