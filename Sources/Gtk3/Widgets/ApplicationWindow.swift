//
//  Copyright © 2015 Tomas Linhart. All rights reserved.
//

import CGtk3

public class ApplicationWindow: Window {
    public convenience init(application: Application) {
        self.init(
            gtk_application_window_new(application.applicationPointer)
        )
        registerSignals()
    }

    public override func registerSignals() {
        super.registerSignals()

        let handler2:
            @convention(c) (
                UnsafeMutableRawPointer,
                gint,
                UnsafeMutableRawPointer
            ) -> Void = { _, value1, data in
                SignalBox1<gint>.run(data, value1)
            }
        addSignal(
            name: "notify::scale-factor",
            handler: gCallback(handler2)
        ) { [weak self] (scaleFactor: gint) in
            guard let self else { return }
            self.notifyScaleFactor?(Int(scaleFactor))
        }

        let handler3:
            @convention(c) (
                UnsafeMutableRawPointer,
                gboolean,
                UnsafeMutableRawPointer
            ) -> Void = { _, value1, data in
                SignalBox1<gboolean>.run(data, value1)
            }
        addSignal(
            name: "notify::is-active",
            handler: gCallback(handler3)
        ) { [weak self] (isActive: gboolean) in
            guard let self else { return }
            self.notifyIsActive?(isActive != 0)
        }
    }

    public var notifyScaleFactor: ((Int) -> Void)?
    public var notifyIsActive: ((Bool) -> Void)?

    @GObjectProperty(named: "show-menubar") public var showMenuBar: Bool
}
