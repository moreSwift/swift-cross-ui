import AndroidKit
import SwiftJava

/// A delegate that is notified of the activity's lifecycle changes.
///
/// Since it's (currently) not possible to use a custom subclass of `FragmentActivity` in
/// SwiftCrossUI apps, this allows you to act on lifecycle events instead. All methods have default
/// implementations that do nothing.
///
/// - Important: Due to the different mechanisms Jetpack provides for installing listeners, some of
/// these methods are called within the corresponding activity methods, while others are called
/// shortly after the corresponding activity methods.
///
/// Methods called during the corresponding activity method are:
/// - ``onCreate(of:env:)``
/// - ``onConfigurationChanged(for:to:env:)``
/// - ``onNewIntent(for:intent:env:)``
///
/// Methods called after the corresponding activity method are:
/// - ``onStart(of:env:)``
/// - ``onResume(of:env:)``
/// - ``onPause(of:env:)``
/// - ``onStop(of:env:)``
/// - ``onDestroy(of:env:)``
public protocol ActivityDelegate { // swiftlint:disable:this class_delegate_protocol
    func onCreate(of activity: FragmentActivity, env: JNIEnvironment?)
    func onStart(of activity: FragmentActivity, env: JNIEnvironment?)
    func onResume(of activity: FragmentActivity, env: JNIEnvironment?)
    func onPause(of activity: FragmentActivity, env: JNIEnvironment?)
    func onStop(of activity: FragmentActivity, env: JNIEnvironment?)
    func onDestroy(of activity: FragmentActivity, env: JNIEnvironment?)

    func onConfigurationChanged(
        for activity: FragmentActivity,
        to configuration: AndroidKit.Configuration,
        env: JNIEnvironment?
    )
    func onNewIntent(
        for activity: FragmentActivity,
        intent: AndroidKit.Intent,
        env: JNIEnvironment?
    )
}

extension ActivityDelegate {
    public func onCreate(of _: FragmentActivity, env _: JNIEnvironment?) {}
    public func onStart(of _: FragmentActivity, env _: JNIEnvironment?) {}
    public func onResume(of _: FragmentActivity, env _: JNIEnvironment?) {}
    public func onPause(of _: FragmentActivity, env _: JNIEnvironment?) {}
    public func onStop(of _: FragmentActivity, env _: JNIEnvironment?) {}
    public func onDestroy(of _: FragmentActivity, env _: JNIEnvironment?) {}

    public func onConfigurationChanged(
        for _: FragmentActivity,
        to _: AndroidKit.Configuration,
        env _: JNIEnvironment?
    ) {}
    public func onNewIntent(
        for _: FragmentActivity,
        intent _: AndroidKit.Intent,
        env _: JNIEnvironment?
    ) {}
}

@JavaClass("dev.swiftcrossui.androidbackend.ActivityListener")
class ActivityListener: JavaObject {
    @JavaMethod
    convenience init(
        _ activity: FragmentActivity?,
        _ delegate: SwiftObject?,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func getActivity() -> FragmentActivity!

    @JavaMethod
    func getDelegate() -> SwiftObject!
}

extension ActivityListener {
    func getCastedDelegate() -> any ActivityDelegate {
        getDelegate().value() as! any ActivityDelegate
    }
}

@JavaImplementation("dev.swiftcrossui.androidbackend.ActivityListener")
extension ActivityListener {
    @JavaMethod
    func onStart() {
        MainActor.assumeIsolated {
            getCastedDelegate().onStart(of: getActivity(), env: AndroidBackend.env)
        }
    }

    @JavaMethod
    func onResume() {
        MainActor.assumeIsolated {
            getCastedDelegate().onResume(of: getActivity(), env: AndroidBackend.env)
        }
    }

    @JavaMethod
    func onPause() {
        MainActor.assumeIsolated {
            getCastedDelegate().onPause(of: getActivity(), env: AndroidBackend.env)
        }
    }

    @JavaMethod
    func onStop() {
        MainActor.assumeIsolated {
            getCastedDelegate().onStop(of: getActivity(), env: AndroidBackend.env)
        }
    }

    @JavaMethod
    func onDestroy() {
        MainActor.assumeIsolated {
            getCastedDelegate().onDestroy(of: getActivity(), env: AndroidBackend.env)
        }
    }

    @JavaMethod
    func onNewIntent(_ intent: AndroidKit.Intent?) {
        MainActor.assumeIsolated {
            getCastedDelegate().onNewIntent(
                for: getActivity(),
                intent: intent!,
                env: AndroidBackend.env
            )
        }
    }

    @JavaMethod
    func onConfigurationChanged(_ configuration: AndroidKit.Configuration?) {
        MainActor.assumeIsolated {
            getCastedDelegate().onConfigurationChanged(
                for: getActivity(),
                to: configuration!,
                env: AndroidBackend.env
            )
        }
    }
}
