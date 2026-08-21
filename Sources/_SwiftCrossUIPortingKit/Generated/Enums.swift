import Foundation
import SwiftCrossUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public enum LayoutDirection : Swift.Hashable, Swift.CaseIterable, Swift.Sendable {
    case leftToRight
    case rightToLeft
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public enum ScrollPhase : Swift.Equatable {
    case idle
    case tracking
    case interacting
    case decelerating
    case animating
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public enum HorizontalDirection : Swift.Int8, Swift.CaseIterable, Swift.Codable {
    case leading
    case trailing
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public enum VerticalDirection : Swift.Int8, Swift.CaseIterable, Swift.Codable {
    case up
    case down
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum HorizontalEdge : Swift.Int8, Swift.CaseIterable, Swift.Codable {
    case leading
    case trailing
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum VerticalEdge : Swift.Int8, Swift.CaseIterable, Swift.Codable {
    case top
    case bottom
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum TimelineScheduleMode : Swift.Sendable {
    case normal
    case lowFrequency
}

@available(macOS 26.0, visionOS 26.0, *)
@available(iOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
public enum WorldRecenterPhase : Swift.Sendable {
    case began
    case ended
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public enum LayoutDirectionBehavior : Swift.Hashable, Swift.Sendable {
    case fixed
    case mirrors(in: LayoutDirection)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public enum ColorRenderingMode : Swift.Sendable {
    case nonLinear
    case linear
    case extendedLinear
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum AccessibilityHeadingLevel : Swift.UInt {
    case unspecified
    case h1
    case h2
    case h3
    case h4
    case h5
    case h6
}

@available(iOS 15.0, macOS 10.15, tvOS 15.0, visionOS 1.0, watchOS 9.0, *)
public enum ControlSize : Swift.CaseIterable, Swift.Sendable {
    case mini
    case small
    case regular
    @available(macOS 11.0, *)
    case large
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
    case extraLarge
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public enum BlendMode : Swift.Sendable {
    case normal
    case multiply
    case screen
    case overlay
    case darken
    case lighten
    case colorDodge
    case colorBurn
    case softLight
    case hardLight
    case difference
    case exclusion
    case hue
    case saturation
    case color
    case luminosity
    case sourceAtop
    case destinationOver
    case destinationOut
    case plusDarker
    case plusLighter
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
public enum AttributedTextFormatting {
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum ShapeRole : Swift.Sendable {
    case fill
    case stroke
    case separator
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum DynamicTypeSize : Swift.Hashable, Swift.Comparable, Swift.CaseIterable, Swift.Sendable {
    case xSmall
    case small
    case medium
    case large
    case xLarge
    case xxLarge
    case xxxLarge
    case accessibility1
    case accessibility2
    case accessibility3
    case accessibility4
    case accessibility5
}

@available(iOS, introduced: 13.0, deprecated: 100000.0, renamed: "DynamicTypeSize")
@available(macOS, introduced: 10.15, deprecated: 100000.0, renamed: "DynamicTypeSize")
@available(tvOS, introduced: 13.0, deprecated: 100000.0, renamed: "DynamicTypeSize")
@available(watchOS, introduced: 6.0, deprecated: 100000.0, renamed: "DynamicTypeSize")
@available(visionOS, introduced: 1.0, deprecated: 100000.0, renamed: "DynamicTypeSize")
public enum ContentSizeCategory : Swift.Hashable, Swift.CaseIterable, Swift.Sendable {
    case extraSmall
    case small
    case medium
    case large
    case extraLarge
    case extraExtraLarge
    case extraExtraExtraLarge
    case accessibilityMedium
    case accessibilityLarge
    case accessibilityExtraLarge
    case accessibilityExtraExtraLarge
    case accessibilityExtraExtraExtraLarge
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public enum SystemFormatStyle : Swift.Sendable {
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum Prominence : Swift.Sendable {
    case standard
    case increased
}

@available(macOS 26.0, visionOS 2.0, *)
@available(iOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
public enum Chirality : Swift.Hashable, Swift.Sendable {
    case left
    case right
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public enum TransitionPhase {
    case willAppear
    case identity
    case didDisappear
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public enum CoordinateSpace {
    case global
    case local
    case named(Swift.AnyHashable)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public enum TextAlignment : Swift.Hashable, Swift.CaseIterable {
    case leading
    case center
    case trailing
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public enum UserInterfaceSizeClass : Swift.Sendable {
    case compact
    case regular
}

@available(iOS, unavailable)
@available(
    macCatalyst,
    introduced: 13.0,
    deprecated: 100000.0,
    message: "Use `EnvironmentValues.appearsActive` instead."
)
@available(
    macOS,
    introduced: 10.15,
    deprecated: 100000.0,
    message: "Use `EnvironmentValues.appearsActive` instead."
)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public enum ControlActiveState : Swift.Equatable, Swift.CaseIterable, Swift.Sendable {
    case key
    case active
    case inactive
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public enum LegibilityWeight : Swift.Hashable, Swift.Sendable {
    case regular
    case bold
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public enum ColorSchemeContrast : Swift.CaseIterable, Swift.Sendable {
    case standard
    case increased
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public enum RoundedCornerStyle : Swift.Sendable {
    case circular
    case continuous
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public enum AccessibilityLabeledPairRole {
    case label
    case content
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public enum AccessibilityAdjustmentDirection : Swift.Sendable {
    case increment
    case decrement
}

@available(iOS 13.4, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public enum DropOperation : Swift.Sendable {
    case cancel
    case forbidden
    case copy
    case move
    @available(macOS 26.0, *)
    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    case delete
    @available(macOS 26.0, *)
    @available(iOS, unavailable)
    @available(visionOS, unavailable)
    case alias
}

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public enum TouchBarItemPresence : Swift.Sendable {
    case required(_: Swift.String)
    case `default`(_: Swift.String)
    case optional(_: Swift.String)
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, *)
@available(watchOS, unavailable)
public enum HoverPhase : Swift.Equatable {
    case active(Foundation.CGPoint)
    case ended
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
public enum TabViewBottomAccessoryPlacement : Swift.Hashable, Swift.Sendable {
    case inline
    case expanded
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public enum ScenePhase : Swift.Comparable {
    case background
    case inactive
    case active
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public enum ScrollTransitionPhase {
    case topLeading
    case identity
    case bottomTrailing
}

@available(macOS 15.0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public enum FrameResizePosition : Swift.Int8, Swift.CaseIterable {
    case top
    case leading
    case bottom
    case trailing
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
}

@available(macOS 15.0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public enum FrameResizeDirection : Swift.Int8, Swift.CaseIterable {
    case inward
    case outward
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum SidebarRowSize : Swift.Sendable {
    case small
    case medium
    case large
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public enum PreviewPlatform : Swift.Sendable {
    case iOS
    case macOS
    case tvOS
    case watchOS
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public enum PopoverAttachmentAnchor {
    case rect(Anchor<Foundation.CGRect>.Source)
    case point(UnitPoint)
}

@available(macOS 10.15, tvOS 13.0, *)
@available(iOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public enum MoveCommandDirection : Swift.Sendable {
    case up
    case down
    case left
    case right
}

@available(iOS 17.5, macOS 14.5, visionOS 26.2, *)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
public enum PencilSqueezeGesturePhase : Swift.Equatable {
    case active(PencilSqueezeGestureValue)
    case ended(PencilSqueezeGestureValue)
    case failed
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum AsyncImagePhase : Swift.Sendable {
    case empty
    case success(Image)
    case failure(any Swift.Error)
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
public enum EditMode : Swift.Sendable {
    case inactive
    case transient
    case active
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public enum TextSelectionAffinity : Swift.Equatable, Swift.Hashable {
    case automatic
    case upstream
    case downstream
}
