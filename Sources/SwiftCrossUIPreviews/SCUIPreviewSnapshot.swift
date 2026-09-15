#if canImport(SwiftUI) && canImport(AppKit) && !targetEnvironment(macCatalyst)
    import AppKit
    import Foundation

    import SwiftCrossUI

    /// A testing utility that renders SwiftCrossUI views to images without a
    /// running app or a preview canvas.
    ///
    /// Xcode's preview canvas can't be captured programmatically, so this
    /// renders the same view through the same hosting path that ``SCUIPreview``
    /// uses. That makes it usable for catching rendering regressions in tests.
    ///
    /// ```swift
    /// let png = try SCUIPreviewSnapshot.png(of: MyComponent(), size: ViewSize(400, 300))
    /// try png.write(to: url)
    /// ```
    public enum SCUIPreviewSnapshot {
        /// An error encountered while rendering a snapshot.
        public enum Error: LocalizedError {
            /// The view laid out to a size with a zero dimension, leaving
            /// nothing to render.
            case emptyView(ViewSize)
            /// AppKit declined to provide a bitmap to render into.
            case bitmapUnavailable
            /// The rendered bitmap couldn't be encoded in the requested format.
            case encodingFailed

            public var errorDescription: String? {
                switch self {
                    case .emptyView(let size):
                        """
                        View rendered with an empty size (\(size.width)x\(size.height)), \
                        so there was nothing to snapshot
                        """
                    case .bitmapUnavailable:
                        "Failed to create a bitmap to render into"
                    case .encodingFailed:
                        "Failed to encode the rendered image"
                }
            }
        }

        /// Renders a view and returns the result as PNG data.
        ///
        /// - Parameters:
        ///   - view: The view to render.
        ///   - size: The size to propose to the view. Pass `nil` in a dimension
        ///     to let the view choose that dimension itself.
        /// - Returns: The rendered view, encoded as a PNG.
        /// - Throws: ``Error`` if the view renders empty or can't be encoded.
        @MainActor
        public static func png(
            of view: some SwiftCrossUI.View,
            size: ProposedViewSize = .unspecified
        ) throws -> Data {
            let bitmap = try bitmap(of: view, size: size)

            guard let data = bitmap.representation(using: .png, properties: [:]) else {
                throw Error.encodingFailed
            }

            return data
        }

        /// Renders a view into a bitmap.
        ///
        /// - Parameters:
        ///   - view: The view to render.
        ///   - size: The size to propose to the view. Pass `nil` in a dimension
        ///     to let the view choose that dimension itself.
        /// - Returns: The rendered bitmap.
        /// - Throws: ``Error`` if the view renders empty or can't be rendered into.
        @MainActor
        public static func bitmap(
            of view: some SwiftCrossUI.View,
            size: ProposedViewSize = .unspecified
        ) throws -> NSBitmapImageRep {
            let host = SCUIPreview.Host(content: view)
            let contentSize = host.layout(proposing: size)

            guard contentSize.width > 0, contentSize.height > 0 else {
                throw Error.emptyView(contentSize)
            }

            let container = host.container
            container.frame = NSRect(
                x: 0,
                y: 0,
                width: contentSize.width,
                height: contentSize.height
            )
            host.relayout()

            // Snapshotting a view with a transparent backing produces an image
            // that's hard to read against dark backgrounds, so fill it first.
            // Idea taken from the AppKitBackend tests.
            container.wantsLayer = true
            container.layer?.backgroundColor = CGColor.white

            // `bitmapImageRepForCachingDisplay(in:)` sizes the bitmap using the
            // current display's scale factor, which would make snapshots differ
            // between Retina and non-Retina machines. Build the bitmap
            // explicitly at 1x instead so that output is reproducible.
            guard
                let bitmap = NSBitmapImageRep(
                    bitmapDataPlanes: nil,
                    pixelsWide: Int(container.bounds.width.rounded()),
                    pixelsHigh: Int(container.bounds.height.rounded()),
                    bitsPerSample: 8,
                    samplesPerPixel: 4,
                    hasAlpha: true,
                    isPlanar: false,
                    colorSpaceName: .deviceRGB,
                    bytesPerRow: 0,
                    bitsPerPixel: 0
                )
            else {
                throw Error.bitmapUnavailable
            }

            container.cacheDisplay(in: container.bounds, to: bitmap)
            return bitmap
        }
    }
#endif
