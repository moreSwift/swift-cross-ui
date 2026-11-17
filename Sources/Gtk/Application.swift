//
//  Copyright © 2015 Tomas Linhart. All rights reserved.
//

import CGtk
import Foundation

public class Application: GObject, GActionMap {
    var applicationPointer: UnsafeMutablePointer<GtkApplication> {
        UnsafeMutablePointer(OpaquePointer(gobjectPointer))
    }

    private var windowCallback: ((ApplicationWindow) -> Void)?
    private var hasActivated = false

    public var actionMapPointer: OpaquePointer {
        OpaquePointer(applicationPointer)
    }

    private var _menuBarModel: GMenu?
    public var menuBarModel: GMenu? {
        get {
            _menuBarModel
        }
        set {
            gtk_application_set_menubar(
                applicationPointer,
                (newValue?.pointer).map(UnsafeMutablePointer.init)
            )
            _menuBarModel = newValue
        }
    }

    @GObjectProperty(named: "register-session") public var registerSession: Bool

    public init(applicationId: String, flags: GApplicationFlags = .init(rawValue: 0)) {
        super.init(
            gtk_application_new(applicationId, flags)
        )
        registerSignals()
    }

    public override func registerSignals() {
        let handler0: @convention(c) (
            UnsafeMutableRawPointer, UnsafeMutableRawPointer
        ) -> Void = { _, data in
            SignalBox0<Void>.run(data)
        }
        
        addSignal(
            name: "activate",
            handler: gCallback(handler0)
        ) { [weak self] in
            guard let self else { return }
            self.activate()
        }

        let handler1:
            @convention(c) (
                UnsafeMutableRawPointer,
                UnsafeMutablePointer<OpaquePointer>,
                gint,
                UnsafeMutableRawPointer,
                UnsafeMutableRawPointer
            ) -> Void = { _, files, nFiles, _, data in
                SignalBox2<UnsafeMutablePointer<OpaquePointer>, Int, Void>.run(data, files, Int(nFiles))
            }

        addSignal(name: "open", handler: gCallback(handler1)) {
            [weak self] (files: UnsafeMutablePointer<OpaquePointer>, nFiles: Int) in
            guard let self else { return }
            var uris: [URL] = []
            for i in 0..<nFiles {
                uris.append(
                    GFile(files[i]).uri
                )
            }
            self.onOpen?(uris)
        }
    }

    @discardableResult
    public func run(_ windowCallback: @escaping (ApplicationWindow) -> Void) -> Int {
        self.windowCallback = windowCallback

        let status = g_application_run(applicationPointer.cast(), 0, nil)
        g_object_unref(applicationPointer)
        return Int(status)
    }

    private func activate() {
        // When set up as a DBusActivatable application on Linux and launched
        // the GNOME app launcher, the activate signal triggers twice, causing
        // two instances of the application's main window unless we ignore the
        // second activation.
        guard !hasActivated else {
            return
        }

        hasActivated = true
        let window = ApplicationWindow(application: self)
        windowCallback?(window)
    }

    public var onOpen: (([URL]) -> Void)?
}
