// AndroidComposeBackendBridge.swift
//
// Low-level JNI wrapper around ComposeBackendHost's @JvmStatic methods.
// This is what jextract would normally generate for you; we write it by hand
// because the Kotlin side isn't compiled yet when you're building the Swift module.
//
// Once your Kotlin jar is built, replace this with:
//   jextract --module-name AndroidComposeBackendBridge \
//            --output Sources/AndroidComposeBackendBridge \
//            build/intermediates/aar_main_jar/release/classes.jar
//
// Requirements: Swift 6.3+, Swift Android SDK, swift-java package dependency.

import Foundation
import SwiftJava
import AndroidKit

/// Wraps dev.swiftcrossui.compose.AndroidComposeBackendHost for direct Swift calls.
///
/// All methods are static on the Kotlin side, so we only ever need one
/// instance of this wrapper (the class object itself).
@JavaClass("dev.swiftcrossui.compose.AndroidComposeBackendHost")
struct AndroidComposeBackendHostClass: AnyJavaObject {  
  
    // Node tree mutations

    @JavaMethod
    func createNode(_ id: Int32, _ type: String) throws

    @JavaMethod
    func setProperty(_ id: Int32, _ key: String, _ value: String) throws

    @JavaMethod
    func setChildren(_ parentId: Int32, _ childIds: [Int32]) throws

    @JavaMethod
    func setPosition(_ containerId: Int32, _ index: Int32, _ x: Int32, _ y: Int32) throws

    @JavaMethod
    func setRootNode(_ id: Int32) throws

    @JavaMethod
    func removeNode(_ id: Int32) throws

    @JavaMethod
    func clearAll() throws

    // Event queue

    @JavaMethod
    func pollEvent() throws -> JavaString?

    @JavaMethod
    func pendingEventCount() throws -> Int32
  
    @JavaMethod
    func measureText(_ text: String, _ fontSizeSp: Float, _ maxWidthDp: Int32) throws -> JavaString?
  
    @JavaMethod
    func measureWidget(_ id: Int32) throws -> JavaString?

    @JavaMethod
    func getTextFieldValue(_ id: Int32) throws -> JavaString?
  
    @JavaMethod
    func getWindowInsets() throws -> JavaString?
}

/// Thin Swift facade that converts Swift String/Int/Bool to Java types and
/// surfaces errors as Swift throws rather than Java exceptions.
public final class AndroidComposeBackendBridge {
  
    private let hostClass: AndroidComposeBackendHostClass

    public init(javaHolder: JavaObjectHolder) {
      // Obtain the already-running JVM (Android boots one before Swift code runs).
      self.hostClass = AndroidComposeBackendHostClass(javaHolder: javaHolder)
    }

    public func createNode(id: Int32, type: String) throws {
        try hostClass.createNode(id, type)
    }

    public func setProperty(id: Int32, key: String, value: String) throws {
        try hostClass.setProperty(id, key, value)
    }

    public func setChildren(parentId: Int32, childIds: [Int32]) throws {
        try hostClass.setChildren(parentId, childIds)
    }

    public func setPosition(containerId: Int32, index: Int32, x: Int32, y: Int32) throws {
        try hostClass.setPosition(containerId, index, x, y)
    }

    public func setRootNode(id: Int32) throws {
        try hostClass.setRootNode(id)
    }

    public func removeNode(id: Int32) throws {
        try hostClass.removeNode(id)
    }

    public func clearAll() throws {
        try hostClass.clearAll()
    }

    /// Returns nil when the queue is empty.
    public func pollEvent() throws -> String? {
        guard let jStr = try hostClass.pollEvent() else { return nil }
      return jStr.toString()
    }

    public func pendingEventCount() throws -> Int {
        return Int(try hostClass.pendingEventCount())
    }
  
    public func measureText(text: String, fontSizeSp: Float, maxWidthDp: Int32) throws -> [Int] {
        guard let jStr = try hostClass.measureText(text, fontSizeSp, maxWidthDp),
              let str = Optional(jStr.toString()) else { return [] }
        let parts = str.split(separator: ",").compactMap { Int($0) }
        return parts
    }
  
    public func measureWidget(id: Int32) throws -> [Int] {
        guard let jStr = try hostClass.measureWidget(id),
              let str = Optional(jStr.toString()) else { return [] }
        let parts = str.split(separator: ",").compactMap { Int($0) }
        return parts
    }
  
    public func getTextFieldValue(id: Int32) throws -> String {
        guard let jStr = try hostClass.getTextFieldValue(id) else { return "" }
        return jStr.toString()
    }
  
    public func getWindowInsets() throws -> (statusBar: Int, navBar: Int) {
        guard let jStr = try hostClass.getWindowInsets(),
              let str = Optional(jStr.toString()) else { return (0, 0) }
        let parts = str.split(separator: ",").compactMap { Int($0) }
        guard parts.count >= 2 else { return (0, 0) }
        return (parts[0], parts[1])
    }
}
