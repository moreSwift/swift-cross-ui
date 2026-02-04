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
    }

    public var notifyScaleFactor: ((Int) -> Void)?

    @GObjectProperty(named: "show-menubar") public var showMenuBar: Bool
}
