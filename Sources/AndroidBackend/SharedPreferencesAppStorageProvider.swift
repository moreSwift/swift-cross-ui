import SwiftCrossUI
import AndroidKit
import SwiftJava
import Foundation

extension AndroidKit.SharedPreferences {
    // The generated binding isn't marked `throws` and doesn't have the correct optionality.
    @JavaMethod
    func getString(key: String, defaultValue: JavaString?) throws -> JavaString?
}

// swiftlint:disable force_try
public struct SharedPreferencesAppStorageProvider: AppStorageProvider {
    private let sharedPreferences: AndroidKit.SharedPreferences
    private let encoder = Foundation.JSONEncoder()
    private let decoder = Foundation.JSONDecoder()

    init(activity: AndroidKit.Activity) {
        let contextClass = try! JavaClass<AndroidKit.Context>()
        sharedPreferences = activity.getSharedPreferences("AppStorage", contextClass.MODE_PRIVATE)!
    }

    public func persistValue<Value: Codable>(_ value: Value, forKey key: String) throws {
        let data = try encoder.encode(value)
        let jsonString = String(data: data, encoding: .utf8)

        let editor = sharedPreferences.edit()!
        // Some methods on Editor return the editor again, so that you can
        // chain multiple put* or remove calls. We don't need that, and the
        // Swift bindings aren't marked @discardableResult.
        if let jsonString {
            _ = editor.putString(key, jsonString)
        } else {
            _ = editor.remove(key)
        }
        editor.apply()
    }

    public func retrieveValue<Value: Codable>(
        ofType type: Value.Type,
        forKey key: String
    ) -> Value? {
        var jsonString: String
        do {
            guard
                let javaString = try sharedPreferences.getString(key: key, defaultValue: nil)
            else {
                return nil
            }
            jsonString = javaString.toString()
        } catch {
            log("Exception thrown by sharedPreferences.getString: \(error)")
            return nil
        }

        let data = Data(jsonString.utf8)

        return try? decoder.decode(type, from: data)
    }
}
