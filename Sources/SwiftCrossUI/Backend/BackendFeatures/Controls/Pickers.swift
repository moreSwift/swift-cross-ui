extension BackendFeatures {
    /// Backend methods for pickers.
    ///
    /// These are used by ``Picker``.
    @MainActor
    public protocol Pickers: Core {
        /// The supported picker styles.
        var supportedPickerStyles: [BackendPickerStyle] { get }

        /// The picker style used by ``PickerStyle/automatic``.
        var defaultPickerStyle: BackendPickerStyle { get }

        /// Creates a picker for selecting from a finite set of options (e.g. a radio button group,
        /// a drop-down, a picker wheel).
        ///
        /// Predominantly used by ``Picker``.
        ///
        /// - Parameter style: The picker's style.
        /// - Returns: A picker.
        func createPicker(style: BackendPickerStyle) -> Widget

        /// Sets the options for a picker to display, along with a change handler for when its
        /// selected option changes.
        ///
        /// The change handler
        ///
        /// - Parameters:
        ///   - picker: The picker to update.
        ///   - options: The picker's options.
        ///   - environment: The current environment.
        ///   - onChange: The action to perform when the selected option changes.
        ///     This handler replaces any existing change handlers and is called
        ///     whenever a selection is made, even if the same option is picked
        ///     again.
        func updatePicker(
            _ picker: Widget,
            options: [String],
            environment: EnvironmentValues,
            onChange: @escaping (Int?) -> Void
        )

        /// Sets the index of the selected option of a picker.
        ///
        /// - Parameters:
        ///   - picker: The picker.
        ///   - selectedOption: The index of the option to select. If `nil`, all
        ///     options should be deselected.
        func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?)
    }
}

// MARK: Default Implementations

extension BackendFeatures.Pickers {
    public var defaultPickerStyle: BackendPickerStyle {
        supportedPickerStyles.first ?? .menu
    }
}
