/// A font that can dynamically adapt to the environment.
public struct Font: Hashable, Sendable {
    /// Gets a system font to use with the specified size, weight, and design.
    public static func system(
        size: Double,
        weight: Weight? = nil,
        design: Design? = nil
    ) -> Font {
        let kind = Kind.concrete(
            identifier: .system,
            size: size,
            weight: weight,
            design: design
        )
        return Font(kind: kind)
    }

    /// Gets a system font that uses the specified style, weight, and design.
    public static func system(
        _ style: Font.TextStyle,
        weight: Weight? = nil,
        design: Design? = nil
    ) -> Font {
        return Font(kind: .dynamic(style))
            .weight(weight)
            .design(design)
    }

    /// The font style for large titles.
    public static let largeTitle = Font(dynamic: .largeTitle)
    /// The font used for first level hierarchical headings.
    public static let title = Font(dynamic: .title)
    /// The font used for second level hierarchical headings.
    public static let title2 = Font(dynamic: .title2)
    /// The font used for third level hierarchical headings.
    public static let title3 = Font(dynamic: .title3)
    /// The font used for headings.
    public static let headline = Font(dynamic: .headline)
    /// The font used for subheadings.
    public static let subheadline = Font(dynamic: .subheadline)
    /// The font used for body text.
    public static let body = Font(dynamic: .body)
    /// The font used for callouts.
    public static let callout = Font(dynamic: .callout)
    /// The font used for standard captions.
    public static let caption = Font(dynamic: .caption)
    /// The font used for alternate captions.
    public static let caption2 = Font(dynamic: .caption2)
    /// The font used in footnotes.
    public static let footnote = Font(dynamic: .footnote)

    /// Selects whether or not to use the font's emphasized variant.
    public func emphasized(_ emphasized: Bool = true) -> Font {
        var font = self
        font.overlay.emphasize = emphasized
        return font
    }

    /// Selects whether or not to italicize the font.
    public func italic(_ italic: Bool = true) -> Font {
        var font = self
        font.overlay.italicize = italic
        return font
    }

    /// Overrides the font's weight. Takes an optional for convenience. Does
    /// nothing if given `nil`.
    public func weight(_ weight: Weight?) -> Font {
        var font = self
        if let weight {
            font.overlay.weight = weight
        }
        return font
    }

    /// Overrides the font's design. Takes an optional for convenience. Does
    /// nothing if given `nil`.
    public func design(_ design: Design?) -> Font {
        var font = self
        if let design {
            font.overlay.design = design
        }
        return font
    }

    /// Overrides the font's point size.
    public func pointSize(_ pointSize: Double) -> Font {
        var font = self
        font.overlay.pointSize = pointSize
        font.overlay.pointSizeScaleFactor = 1
        return font
    }

    /// Scales the font's point size and line height by a given factor.
    public func scaled(by factor: Double) -> Font {
        var font = self
        font.overlay.pointSizeScaleFactor *= factor
        font.overlay.lineHeightScaleFactor *= factor
        return font
    }

    /// Selects whether or not to use the font's monospaced variant.
    public func monospaced(_ monospaced: Bool = true) -> Font {
        var font = self
        if monospaced {
            font.overlay.design = .monospaced
        } else if font.overlay.design == .monospaced {
            font.overlay.design = .default
        }
        return font
    }

    private var kind: Kind
    private var overlay = Overlay()

    private init(kind: Kind) {
        self.kind = kind
    }

    private init(dynamic textStyle: TextStyle) {
        self.kind = .dynamic(textStyle)
    }

    /// Internal storage enum to hide away Font's implementation.
    private enum Kind: Hashable, Sendable {
        case concrete(
            identifier: Resolved.Identifier,
            size: Double,
            weight: Weight? = nil,
            design: Design? = nil
        )
        case dynamic(TextStyle)
    }

    /// A font weight.
    ///
    /// The cases are in order of increasing weight.
    public enum Weight: Hashable, Sendable, CaseIterable, Codable {
        case ultraLight
        case thin
        case light
        case regular
        case medium
        case semibold
        case bold
        case heavy
        case black
    }

    /// A font's design.
    public enum Design: Hashable, Sendable, CaseIterable, Codable {
        case `default`
        case monospaced
    }

    /// An overlay applied to a font after resolving its concrete properties.
    struct Overlay: Hashable, Sendable {
        /// Overrides the font's base size. Applied before scaling.
        var pointSize: Double?
        /// Overrides the font's line height. Applied before scaling.
        var lineHeight: Double?
        /// Applied to the font's point size (after applying the ``pointSize``
        /// overlay if present).
        var pointSizeScaleFactor: Double = 1
        /// Applied to the font's line height (after applying the ``lineHeight``
        /// overlay if present).
        var lineHeightScaleFactor: Double = 1

        /// Overrides the font's weight. Applied before (i.e. overridden by)
        /// ``Self/isEmphasized``.
        var weight: Weight?
        /// If `true`, overrides the font's weight with the font's emphasized
        /// weight. If `false`, does nothing. Applied after the ``weight``
        /// overlay has been applied if one is present.
        var emphasize: Bool = false

        /// If `true`, overrides the font to be italicized. If `false`, does
        /// nothing.
        var italicize: Bool = false

        /// Overrides the font's design.
        var design: Design?

        /// Applies an overlay to a resolved font. Requires an emphasized weight
        /// for the resolved font.
        func apply(
            to resolvedFont: inout Font.Resolved,
            emphasizedWeight: Weight
        ) {
            if let weight {
                resolvedFont.weight = weight
            }
            if let design {
                resolvedFont.design = design
            }
            if emphasize {
                resolvedFont.weight = emphasizedWeight
            }
            if italicize {
                resolvedFont.isItalic = true
            }
            if let pointSize {
                resolvedFont.pointSize = pointSize
            }
            if let lineHeight {
                resolvedFont.lineHeight = lineHeight
            }
            resolvedFont.pointSize *= pointSizeScaleFactor
            resolvedFont.lineHeight *= lineHeightScaleFactor
        }
    }

    public struct Resolved: Hashable, Sendable {
        public struct Identifier: Hashable, Sendable {
            public var kind: Kind

            public static let system = Self(kind: .system)

            public enum Kind: Hashable {
                case system
            }
        }

        public var identifier: Identifier
        public var pointSize: Double
        public var lineHeight: Double
        public var weight: Weight
        public var design: Design
        public var isItalic: Bool
    }

    public struct Context: Sendable {
        var overlay: Font.Overlay
        var deviceClass: DeviceClass
        var resolveTextStyle: @MainActor @Sendable (TextStyle) -> TextStyle.Resolved
    }

    @MainActor
    public func resolve(in context: Context) -> Resolved {
        let emphasizedWeight: Weight
        var resolved: Resolved
        switch kind {
            case .concrete(let identifier, let size, let weight, let design):
                switch identifier.kind {
                    case .system:
                        emphasizedWeight = .bold
                        resolved = Resolved(
                            identifier: .system,
                            pointSize: size,
                            // TODO: Research which line height ratio would be
                            //   the best default (or any alternatives to a
                            //   constant ratio).
                            lineHeight: (size * 1.25).rounded(.awayFromZero),
                            weight: weight ?? .regular,
                            design: design ?? .default,
                            isItalic: false
                        )
                }
            case .dynamic(let textStyle):
                let resolvedTextStyle = context.resolveTextStyle(textStyle)
                emphasizedWeight = resolvedTextStyle.emphasizedWeight
                resolved = Resolved(
                    identifier: .system,
                    pointSize: resolvedTextStyle.pointSize,
                    lineHeight: resolvedTextStyle.lineHeight,
                    weight: resolvedTextStyle.weight,
                    design: .default,
                    isItalic: false
                )
        }

        overlay.apply(to: &resolved, emphasizedWeight: emphasizedWeight)
        context.overlay.apply(to: &resolved, emphasizedWeight: emphasizedWeight)

        return resolved
    }
}
