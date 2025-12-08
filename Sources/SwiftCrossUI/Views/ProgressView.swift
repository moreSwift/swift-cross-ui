import Foundation

/// A progress indicator; either a bar or a spinner.
public struct ProgressView<Label: View>: View {
    /// The label for this progress view.
    private var label: Label
    /// The current progress, if this is a progress bar.
    private var progress: Double?
    private var kind: Kind
    private var isSpinnerResizable: Bool = false

    private enum Kind {
        case spinner
        case bar
    }

    public var body: some View {
        if label as? EmptyView == nil {
            progressIndicator
            label
        } else {
            progressIndicator
        }
    }

    @ViewBuilder
    private var progressIndicator: some View {
        switch kind {
            case .spinner:
                ProgressSpinnerView(isResizable: isSpinnerResizable)
            case .bar:
                ProgressBarView(value: progress)
        }
    }

    /// Creates an indeterminate progress view (a spinner).
    ///
    /// - Parameter label: The label for this progress view.
    public init(_ label: Label) {
        self.label = label
        self.kind = .spinner
    }

    /// Creates a progress bar.
    ///
    /// - Parameters:
    ///   - label: The label for this progress view.
    ///   - progress: The current progress.
    public init(_ label: Label, _ progress: Progress) {
        self.label = label
        self.kind = .bar

        if !progress.isIndeterminate {
            self.progress = progress.fractionCompleted
        }
    }

    /// Creates a progress bar.
    ///
    /// - Parameters:
    ///   - label: The label for this progress view.
    ///   - value: The current progress. If `nil`, an indeterminate progress bar
    ///     will be shown.
    public init<Value: BinaryFloatingPoint>(_ label: Label, value: Value?) {
        self.label = label
        self.kind = .bar
        self.progress = value.map { Double($0) }
    }

    /// Makes the `ProgressView` resize to fit the available space.
    ///
    /// This only affects spinners.
    public func resizable(_ isResizable: Bool = true) -> Self {
        var progressView = self
        progressView.isSpinnerResizable = isResizable
        return progressView
    }
}

extension ProgressView where Label == EmptyView {
    /// Creates an indeterminate progress view (a spinner).
    public init() {
        self.label = EmptyView()
        self.kind = .spinner
    }

    /// Creates a progress bar.
    ///
    /// - Parameters:
    ///   - progress: The current progress.
    public init(_ progress: Progress) {
        self.label = EmptyView()
        self.kind = .bar

        if !progress.isIndeterminate {
            self.progress = progress.fractionCompleted
        }
    }

    /// Creates a progress bar.
    ///
    /// - Parameters:
    ///   - value: The current progress. If `nil`, an indeterminate progress bar
    ///     will be shown.
    public init<Value: BinaryFloatingPoint>(value: Value?) {
        self.label = EmptyView()
        self.kind = .bar
        self.progress = value.map { Double($0) }
    }
}

extension ProgressView where Label == Text {
    /// Creates an indeterminate progress view (a spinner).
    ///
    /// - Parameter label: The label for this progress view.
    public init(_ label: String) {
        self.label = Text(label)
        self.kind = .spinner
    }

    /// Creates a progress bar.
    ///
    /// - Parameters:
    ///   - label: The label for this progress view.
    ///   - progress: The current progress.
    public init(_ label: String, _ progress: Progress) {
        self.label = Text(label)
        self.kind = .bar

        if !progress.isIndeterminate {
            self.progress = progress.fractionCompleted
        }
    }

    /// Creates a progress bar.
    ///
    /// - Parameters:
    ///   - label: The label for this progress view.
    ///   - value: The current progress. If `nil`, an indeterminate progress bar
    ///     will be shown.
    public init<Value: BinaryFloatingPoint>(_ label: String, value: Value?) {
        self.label = Text(label)
        self.kind = .bar
        self.progress = value.map { Double($0) }
    }
}

struct ProgressSpinnerView: ElementaryView {
    let isResizable: Bool

    init(isResizable: Bool = false) {
        self.isResizable = isResizable
    }

    func asWidget<Backend: AppBackend>(backend: Backend) -> Backend.Widget {
        backend.createProgressSpinner()
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let naturalSize = backend.naturalSize(of: widget)

        guard isResizable else {
            return ViewLayoutResult.leafView(size: ViewSize(naturalSize))
        }

        let dimension: Double

        if let proposedWidth = proposedSize.width, let proposedHeight = proposedSize.height {
            dimension = min(proposedWidth, proposedHeight)
        } else if let proposedWidth = proposedSize.width {
            dimension = proposedWidth
        } else if let proposedHeight = proposedSize.height {
            dimension = proposedHeight
        } else {
            dimension = Double(min(naturalSize.x, naturalSize.y))
        }

        return ViewLayoutResult.leafView(
            size: ViewSize(dimension, dimension)
        )
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        // Doesn't change the rendered size of ProgressSpinner
        // on UIKitBackend, but still sets container size to
        // (width: n, height: n) n = min(proposedSize.x, proposedSize.y)
        backend.setSize(ofProgressSpinner: widget, to: layout.size.vector)
    }
}

struct ProgressBarView: ElementaryView {
    /// The ideal width of a ProgressBarView.
    static let idealWidth: Double = 100

    var value: Double?

    init(value: Double?) {
        self.value = value
    }

    func asWidget<Backend: AppBackend>(backend: Backend) -> Backend.Widget {
        backend.createProgressBar()
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let height = backend.naturalSize(of: widget).y
        let size = ViewSize(
            proposedSize.width ?? Self.idealWidth,
            Double(height)
        )

        return ViewLayoutResult.leafView(size: size)
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.updateProgressBar(widget, progressFraction: value, environment: environment)
        backend.setSize(of: widget, to: layout.size.vector)
    }
}
