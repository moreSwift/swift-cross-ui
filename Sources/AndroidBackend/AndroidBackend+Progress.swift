import AndroidKit
import SwiftCrossUI
import SwiftJava

// swiftlint:disable force_try

// implements BackendFeatures.ProgressBars & BackendFeatures.ProgressSpinners
extension AndroidBackend {
    public func createProgressBar() -> Widget {
        let Rstyle = try! JavaClass<AndroidKit.R.style>()

        let widget = AndroidKit.ProgressBar(
            Self.activity,
            nil,
            0,
            Rstyle.Widget_ProgressBar_Horizontal,
            environment: Self.env
        )

        widget.setMin(0)
        widget.setMax(10_000)

        return widget.as(AndroidKit.View.self)!
    }

    public func updateProgressBar(
        _ widget: Widget,
        progressFraction: Double?,
        environment: EnvironmentValues
    ) {
        let progressBar = widget.as(AndroidKit.ProgressBar.self)!

        if let progressFraction {
            progressBar.setProgress(Int32(progressFraction * 10_000))
            progressBar.setIndeterminate(false)
        } else {
            progressBar.setIndeterminate(true)
        }
    }

    public func createProgressSpinner() -> Widget {
        let Rstyle = try! JavaClass<AndroidKit.R.style>()

        let widget = AndroidKit.ProgressBar(
            Self.activity,
            nil,
            0,
            Rstyle.Widget_ProgressBar_Small,
            environment: Self.env
        )

        widget.setIndeterminate(true)

        return widget.as(AndroidKit.View.self)!
    }

    public func setSize(ofProgressSpinner widget: Widget, to size: SIMD2<Int>) {
        setSize(of: widget, to: size)
    }
}
