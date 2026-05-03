extension View {
    /// Sets the font of contained text. Can be overridden by other font
    /// modifiers within the contained view, unlike other font-related
    /// modifiers such as ``View/fontWeight(_:)`` and ``View/emphasized()``
    /// which override the font properties of all contained text.
    ///
    /// - Parameter font: The font to set.
    public func font(_ font: Font) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.font, font)
        }
    }

    /// Overrides the font weight of any contained text.
    ///
    /// - Parameter weight: The font weight to set. If `nil`, this modifier
    ///   does nothing.
    public func fontWeight(_ weight: Font.Weight?) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.fontOverlay.weight, weight)
        }
    }

    /// Overrides the font design of any contained text.
    ///
    /// - Parameter design: The font design to set. If `nil`, this modifier
    ///   does nothing.
    public func fontDesign(_ design: Font.Design?) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.fontOverlay.design, design)
        }
    }

    /// Forces any contained text to be bold, or if the a contained font is a
    /// ``Font/TextStyle``, forces the style's emphasized weight to be used.
    ///
    /// Deprecated and renamed for clarity. Use ``fontWeight(_:)`` to make text
    /// bold.
    @available(
        *, deprecated,
        message: "Use View.emphasized() instead",
        renamed: "View.emphasized()"
    )
    public func bold() -> some View {
        emphasized()
    }

    /// Forces any contained text to become emphasized. For text that uses
    /// ``Font/TextStyle``-based fonts, this means using the text style's
    /// emphasized weight. For all other text, this means using
    /// ``Font/Weight/bold``.
    public func emphasized() -> some View {
        EnvironmentModifier(self) { environment in
            return environment.with(
                \.fontOverlay.emphasize,
                true
            )
        }
    }

    /// Forces any contained text to become italic.
    public func italic() -> some View {
        EnvironmentModifier(self) { environment in
            return environment.with(
                \.fontOverlay.italicize,
                true
            )
        }
    }
}
