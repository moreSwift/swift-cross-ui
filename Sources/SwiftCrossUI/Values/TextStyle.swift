extension Font {
    /// A dynamic text style based off [Apple's typography guidelines](https://developer.apple.com/design/human-interface-guidelines/typography).
    public enum TextStyle: Hashable, Sendable, CaseIterable, Codable {
        /// The font style for large titles.
        case largeTitle
        /// The font used for first level hierarchical headings.
        case title
        /// The font used for second level hierarchical headings.
        case title2
        /// The font used for third level hierarchical headings.
        case title3
        /// The font used for headings.
        case headline
        /// The font used for subheadings.
        case subheadline
        /// The font used for body text.
        case body
        /// The font used for callouts.
        case callout
        /// The font used for standard captions.
        case caption
        /// The font used for alternate captions.
        case caption2
        /// The font used in footnotes.
        case footnote
    }
}

extension Font.TextStyle {
    /// A text style's resolved properties.
    public struct Resolved: Sendable {
        /// The point size.
        public var pointSize: Double
        /// The weight.
        public var weight: Font.Weight = .regular
        /// The emphasized weight.
        public var emphasizedWeight: Font.Weight
        /// The line height, in points.
        public var lineHeight: Double

        /// Fallback to macOS's body text style.
        ///
        /// This isn't expected to ever get used because it's only reachable if
        /// we forgot to supply text styles for a new device class or missed a
        /// text style in a device class' text style lookup table.
        static let fallback = Self(
            pointSize: 13,
            weight: .regular,
            emphasizedWeight: .semibold,
            lineHeight: 16
        )
    }

    /// Resolves the text style's concrete text properties for the given device
    /// class.
    ///
    /// Generally follows [Apple's typography guidelines][typography]. Our
    /// styles only differ from Apple's where Apple decided not to specify a
    /// text style for a specific platform.
    ///
    /// [typography]: https://developer.apple.com/design/human-interface-guidelines/typography
    public func resolve(for deviceClass: DeviceClass) -> Resolved {
        guard let textStyles = Self.resolvedTextStyles[deviceClass] else {
            logger.warning("missing text styles for device class \(deviceClass)")
            return .fallback
        }

        guard let textStyle = textStyles[self] else {
            logger.warning("missing \(self) text style for device class \(deviceClass)")
            return .fallback
        }

        return textStyle
    }

    private static let resolvedTextStyles: [DeviceClass: [Self: Resolved]] = [
        .desktop: desktopTextStyles,
        .phone: mobileTextStyles,
        .tablet: mobileTextStyles,
        .tv: tvTextStyles,
    ]

    private static let desktopTextStyles: [Self: Resolved] = [
        .largeTitle: Resolved(
            pointSize: 26,
            emphasizedWeight: .bold,
            lineHeight: 32
        ),
        .title: Resolved(
            pointSize: 22,
            emphasizedWeight: .bold,
            lineHeight: 26
        ),
        .title2: Resolved(
            pointSize: 17,
            emphasizedWeight: .bold,
            lineHeight: 22
        ),
        .title3: Resolved(
            pointSize: 15,
            emphasizedWeight: .semibold,
            lineHeight: 20
        ),
        .headline: Resolved(
            pointSize: 13,
            weight: .bold,
            emphasizedWeight: .heavy,
            lineHeight: 16
        ),
        .body: Resolved(
            pointSize: 13,
            emphasizedWeight: .semibold,
            lineHeight: 16
        ),
        .callout: Resolved(
            pointSize: 12,
            emphasizedWeight: .semibold,
            lineHeight: 15
        ),
        .subheadline: Resolved(
            pointSize: 11,
            emphasizedWeight: .semibold,
            lineHeight: 14
        ),
        .footnote: Resolved(
            pointSize: 10,
            emphasizedWeight: .semibold,
            lineHeight: 13
        ),
        .caption: Resolved(
            pointSize: 10,
            emphasizedWeight: .medium,
            lineHeight: 13
        ),
        .caption2: Resolved(
            pointSize: 10,
            weight: .medium,
            emphasizedWeight: .semibold,
            lineHeight: 13
        ),
    ]

    private static let mobileTextStyles: [Self: Resolved] = [
        .largeTitle: Resolved(
            pointSize: 34,
            emphasizedWeight: .semibold,
            lineHeight: 41
        ),
        .title: Resolved(
            pointSize: 28,
            emphasizedWeight: .semibold,
            lineHeight: 34
        ),
        .title2: Resolved(
            pointSize: 22,
            emphasizedWeight: .semibold,
            lineHeight: 28
        ),
        .title3: Resolved(
            pointSize: 20,
            emphasizedWeight: .semibold,
            lineHeight: 25
        ),
        .headline: Resolved(
            pointSize: 17,
            weight: .semibold,
            emphasizedWeight: .semibold,
            lineHeight: 22
        ),
        .body: Resolved(
            pointSize: 17,
            emphasizedWeight: .semibold,
            lineHeight: 22
        ),
        .callout: Resolved(
            pointSize: 16,
            emphasizedWeight: .semibold,
            lineHeight: 21
        ),
        .subheadline: Resolved(
            pointSize: 15,
            emphasizedWeight: .semibold,
            lineHeight: 20
        ),
        .footnote: Resolved(
            pointSize: 13,
            emphasizedWeight: .semibold,
            lineHeight: 18
        ),
        .caption: Resolved(
            pointSize: 12,
            emphasizedWeight: .semibold,
            lineHeight: 16
        ),
        .caption2: Resolved(
            pointSize: 11,
            emphasizedWeight: .semibold,
            lineHeight: 13
        ),
    ]

    // The tvOS large title and footnote styles are the only ones not from the
    // Apple typography guidelines. I've just made it up based off the ratios
    // used on other platforms to provide a consistent set of text styles
    // across all platforms.
    private static let tvTextStyles: [Self: Resolved] = [
        .largeTitle: Resolved(
            pointSize: 91,
            weight: .medium,
            emphasizedWeight: .bold,
            lineHeight: 80
        ),
        .title: Resolved(
            pointSize: 76,
            weight: .medium,
            emphasizedWeight: .bold,
            lineHeight: 96
        ),
        .title2: Resolved(
            pointSize: 57,
            weight: .medium,
            emphasizedWeight: .bold,
            lineHeight: 66
        ),
        .title3: Resolved(
            pointSize: 48,
            weight: .medium,
            emphasizedWeight: .bold,
            lineHeight: 56
        ),
        .headline: Resolved(
            pointSize: 38,
            weight: .medium,
            emphasizedWeight: .bold,
            lineHeight: 46
        ),
        .body: Resolved(
            pointSize: 29,
            weight: .medium,
            emphasizedWeight: .bold,
            lineHeight: 36
        ),
        .callout: Resolved(
            pointSize: 31,
            weight: .medium,
            emphasizedWeight: .bold,
            lineHeight: 38
        ),
        .subheadline: Resolved(
            pointSize: 38,
            weight: .regular,
            emphasizedWeight: .medium,
            lineHeight: 46
        ),
        .footnote: Resolved(
            pointSize: 27,
            weight: .medium,
            emphasizedWeight: .bold,
            lineHeight: 33
        ),
        .caption: Resolved(
            pointSize: 25,
            weight: .medium,
            emphasizedWeight: .bold,
            lineHeight: 32
        ),
        .caption2: Resolved(
            pointSize: 23,
            weight: .medium,
            emphasizedWeight: .bold,
            lineHeight: 30
        ),
    ]
}
