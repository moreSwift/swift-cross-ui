import Foundation

extension BackendFeatures {
    /// A protocol that provides default implementations of all methods in
    /// ``BaseAppBackend`` so as to enable rapid iteration on custom backends.
    ///
    /// - Warning: **This protocol is _not_ intended to be used by
    ///   production-ready backends!** Every default implementation that it
    ///   provides will crash the user's app when called. This protocol is
    ///   solely intended to make the compiler shut up when you're in the middle
    ///   of implementing a brand-new backend.
    ///
    /// If you are unable to write a required backend method because your
    /// underlying UI framework doesn't properly support the associated
    /// functionality, you can call `fatalError` in your own implementation
    /// of the method. That way you'll still get notified by the compiler if
    /// we add new methods in future SwiftCrossUI versions.
    ///
    /// ## Workflow
    ///
    /// A typical workflow for implementing a new backend might go something
    /// like this:
    ///
    /// 1. Declare a type (usually a `class`, but there's no technical reason
    ///    it can't be a `struct`) that conforms to `BaseStubs`.
    /// 2. Write a small example app using that type as its backend.
    /// 3. Implement enough of ``Core`` to get the example app to launch and
    ///    show an empty window.
    /// 4. Switch the conformance over to ``BaseAppBackend``, and examine the
    ///    compiler errors for suitable methods to implement.
    /// 5. Copy their declarations into the type, then switch back over to
    ///    `BaseStubs` so the backend compiles again.
    /// 6. Iterate on the method implementations until they work properly.
    /// 7. Repeat steps 4 through 6 until you have a more-or-less complete
    ///    backend.
    ///
    /// Of course, you can use whatever workflow works best for you; this
    /// protocol just serves as a tool to keep you from having to implement the
    /// entire backend in one go.
    #if !DEBUG
        @available(
            *, deprecated,
            message: """
            'BaseStubs' should not be used in release builds, conform to 'BaseAppBackend' instead
            """
        )
    #endif
    public protocol BaseStubs: BaseAppBackend {}
}

// This type isn't actually used anywhere, so keep it out of release builds.
#if DEBUG
/// A backend "implementation" solely for testing whether
/// ``BackendFeatures/BaseStubs`` has default implementations for all required
/// backend features.
///
/// Aside from empty nested structs to satisfy associated type requirements,
/// **this struct must remain empty** -- all backend methods and properties
/// should have default implementations provided by `BaseStubs`. If any errors
/// show up here, and you've added empty structs for all associated types,
/// you're missing some default implementations.
///
///   1. Accept all fix-mes for the errors in question.
///   2. Move the compiler-generated declarations out of this type and into the
///      `BaseStubs` extension just below this type in the
///      `BackendFeatures+BaseStubs` file. (Precisely _where_ you move them is
///      unimportant, just try to keep some semblance of a logical order.)
///   3. **Make all declarations `public`.** This is important, and the
///      compiler likely won't help you here because this struct is `private`.
///   4. Write `todo()` in the bodies of every method and property.
private struct BaseStubsTest: BackendFeatures.BaseStubs {
    struct Window {}
    struct Widget {}
}
#endif

#if !DEBUG
    @available(*, deprecated)
#endif
extension BackendFeatures.BaseStubs {
    fileprivate func todo(function: String = #function) -> Never {
        fatalError("\(Self.self): \(function) not implemented")
    }
}

#if !DEBUG
    @available(*, deprecated)
#endif
extension BackendFeatures.BaseStubs {
    public func createScrollContainer(for child: Widget) -> Widget {
        todo()
    }

    public func updateScrollContainer(
        _ scrollView: Widget,
        environment: EnvironmentValues,
        bounceHorizontally: Bool,
        bounceVertically: Bool,
        hasHorizontalScrollBar: Bool,
        hasVerticalScrollBar: Bool
    ) {
        todo()
    }

    public func createSelectableListView() -> Widget {
        todo()
    }

    public func updateSelectableListView(
        _ selectableListView: Widget,
        environment: EnvironmentValues
    ) {
        todo()
    }

    public func baseItemPadding(ofSelectableListView listView: Widget) -> EdgeInsets {
        todo()
    }

    public func minimumRowSize(ofSelectableListView listView: Widget) -> SIMD2<Int> {
        todo()
    }

    public func setItems(
        ofSelectableListView listView: Widget,
        to items: [Widget],
        withRowHeights rowHeights: [Int]
    ) {
        todo()
    }

    public func setSelectionHandler(
        forSelectableListView listView: Widget,
        to action: @escaping (Int) -> Void
    ) {
        todo()
    }

    public func setSelectedItem(
        ofSelectableListView listView: Widget,
        toItemAt index: Int?
    ) {
        todo()
    }

    public func createSplitView(leadingChild: Widget, trailingChild: Widget) -> Widget {
        todo()
    }

    public func setResizeHandler(
        ofSplitView splitView: Widget,
        to action: @escaping () -> Void
    ) {
        todo()
    }

    public func sidebarWidth(ofSplitView splitView: Widget) -> Int {
        todo()
    }

    public func setSidebarWidthBounds(
        ofSplitView splitView: Widget,
        minimum minimumWidth: Int,
        maximum maximumWidth: Int
    ) {
        todo()
    }

    public func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedWidth: Int?,
        proposedHeight: Int?,
        environment: EnvironmentValues
    ) -> SIMD2<Int> {
        todo()
    }

    public func createTextView() -> Widget {
        todo()
    }

    public func updateTextView(
        _ textView: Widget,
        content: String,
        environment: EnvironmentValues
    ) {
        todo()
    }

    public func createImageView() -> Widget {
        todo()
    }

    public func updateImageView(
        _ imageView: Widget,
        rgbaData: [UInt8],
        width: Int,
        height: Int,
        targetWidth: Int,
        targetHeight: Int,
        dataHasChanged: Bool,
        environment: EnvironmentValues
    ) {
        todo()
    }

    public func createButton() -> Widget {
        todo()
    }

    public func updateButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        todo()
    }

    public func createToggle() -> Widget {
        todo()
    }

    public func updateToggle(
        _ toggle: Widget,
        label: String,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        todo()
    }

    public func setState(ofToggle toggle: Widget, to state: Bool) {
        todo()
    }

    public func createSwitch() -> Widget {
        todo()
    }

    public func updateSwitch(
        _ switchWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        todo()
    }

    public func setState(ofSwitch switchWidget: Widget, to state: Bool) {
        todo()
    }

    public func createCheckbox() -> Widget {
        todo()
    }

    public func updateCheckbox(
        _ checkboxWidget: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (Bool) -> Void
    ) {
        todo()
    }

    public func setState(ofCheckbox checkboxWidget: Widget, to state: Bool) {
        todo()
    }

    public func createSlider() -> Widget {
        todo()
    }

    public func updateSlider(
        _ slider: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces: Int,
        environment: EnvironmentValues,
        onChange: @escaping (Double) -> Void
    ) {
        todo()
    }

    public func setValue(ofSlider slider: Widget, to value: Double) {
        todo()
    }

    public func createTextField() -> Widget {
        todo()
    }

    public func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        todo()
    }

    public func setContent(ofTextField textField: Widget, to content: String) {
        todo()
    }

    public func getContent(ofTextField textField: Widget) -> String {
        todo()
    }

    public func setContent(ofSecureField secureField: Widget, to content: String) {
        todo()
    }

    public func getContent(ofSecureField secureField: Widget) -> String {
        todo()
    }

    public func createTextEditor() -> Widget {
        todo()
    }

    public func updateTextEditor(
        _ textEditor: Widget,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void
    ) {
        todo()
    }

    public func setContent(ofTextEditor textEditor: Widget, to content: String) {
        todo()
    }

    public func getContent(ofTextEditor textEditor: Widget) -> String {
        todo()
    }

    public func createPicker(style: BackendPickerStyle) -> Widget {
        todo()
    }

    public func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping (Int?) -> Void
    ) {
        todo()
    }

    public func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?) {
        todo()
    }

    public func createProgressSpinner() -> Widget {
        todo()
    }

    public func createProgressBar() -> Widget {
        todo()
    }

    public func updateProgressBar(
        _ widget: Widget,
        progressFraction: Double?,
        environment: EnvironmentValues
    ) {
        todo()
    }

    public var deviceClass: DeviceClass {
        todo()
    }

    public func runMainLoop(_ callback: @escaping @MainActor () -> Void) {
        todo()
    }

    public func runInMainThread(action: @escaping @MainActor () -> Void) {
        todo()
    }

    public func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues {
        todo()
    }

    public func setRootEnvironmentChangeHandler(to action: @escaping @Sendable @MainActor () -> Void) {
        todo()
    }

    public var defaultPaddingAmount: Int {
        todo()
    }

    public func show(widget: Widget) {
        todo()
    }

    public func naturalSize(of widget: Widget) -> SIMD2<Int> {
        todo()
    }

    public func setSize(of widget: Widget, to size: SIMD2<Int>) {
        todo()
    }

    public var supportsMultipleWindows: Bool {
        todo()
    }

    public var canOverrideWindowColorScheme: Bool {
        todo()
    }

    public func createWindow(withDefaultSize defaultSize: SIMD2<Int>?) -> Window {
        todo()
    }

    public func updateWindow(_ window: Window, environment: EnvironmentValues) {
        todo()
    }

    public func setTitle(ofWindow window: Window, to title: String) {
        todo()
    }
    
    public func setChild(ofWindow window: Window, to child: Widget) {
        todo()
    }

    public func size(ofWindow window: Window) -> SIMD2<Int> {
        todo()
    }

    public func isWindowProgrammaticallyResizable(_ window: Window) -> Bool {
        todo()
    }

    public func setSize(ofWindow window: Window, to newSize: SIMD2<Int>) {
        todo()
    }

    public func setSizeLimits(
        ofWindow window: Window,
        minimum minimumSize: SIMD2<Int>,
        maximum maximumSize: SIMD2<Int>?
    ) {
        todo()
    }

    public func setResizeHandler(
        ofWindow window: Window,
        to action: @escaping (SIMD2<Int>) -> Void
    ) {
        todo()
    }

    public func show(window: Window) {
        todo()
    }

    public func activate(window: Window) {
        todo()
    }

    public func computeWindowEnvironment(window: Window, rootEnvironment: EnvironmentValues) -> EnvironmentValues {
        todo()
    }

    public func setWindowEnvironmentChangeHandler(
        of window: Window,
        to action: @escaping @Sendable @MainActor () -> Void
    ) {
        todo()
    }

    public func createContainer() -> Widget {
        todo()
    }

    public func removeAllChildren(of container: Widget) {
        todo()
    }

    public func insert(_ child: Widget, into container: Widget, at index: Int) {
        todo()
    }

    public func swap(
        childAt firstIndex: Int,
        withChildAt secondIndex: Int,
        in container: Widget
    ) {
        todo()
    }

    public func setPosition(
        ofChildAt index: Int,
        in container: Widget,
        to position: SIMD2<Int>
    ) {
        todo()
    }

    public func remove(childAt index: Int, from container: Widget) {
        todo()
    }

    public var scrollBarWidth: Int {
        todo()
    }

    public var requiresImageUpdateOnScaleFactorChange: Bool {
        todo()
    }

    public var requiresToggleSwitchSpacer: Bool {
        todo()
    }

    public func createSecureField() -> Widget {
        todo()
    }

    public func updateSecureField(
        _ secureField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping (String) -> Void,
        onSubmit: @escaping () -> Void
    ) {
        todo()
    }

    public var supportedPickerStyles: [BackendPickerStyle] {
        todo()
    }
}
