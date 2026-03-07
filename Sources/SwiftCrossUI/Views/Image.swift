import Foundation
import ImageFormats

/// A view that displays an image.
public struct Image: Sendable {
    /// Whether the image is resizable.
    private var isResizable = false
    /// The source of the image.
    private var source: Source

    enum Source: Equatable {
        case url(URL, useFileExtension: Bool)
        case image(ImageFormats.Image<RGBA>)
    }

    /// Creates an image view.
    ///
    /// `png`, `jpg`, and `webp` are supported.
    ///
    /// - Parameters:
    ///   - url: The URL of the file to display.
    ///   - useFileExtension: If `true`, the file extension is used to determine
    ///     the file type, otherwise the first few ('magic') bytes of the file
    ///     are used.
    public init(_ url: URL, useFileExtension: Bool = true) {
        source = .url(url, useFileExtension: useFileExtension)
    }

    /// Displays an image from raw pixel data.
    ///
    /// - Parameter image: The image data to display.
    public init(_ image: ImageFormats.Image<RGBA>) {
        source = .image(image)
    }

    /// Makes the image resize to fit the available space.
    public func resizable() -> Self {
        var image = self
        image.isResizable = true
        return image
    }

    init(_ source: Source, resizable: Bool) {
        self.source = source
        self.isResizable = resizable
    }
}

extension Image: View {
    public var body: some View { return EmptyView() }
}

extension Image: TypeSafeView {
    func layoutableChildren<Backend: AppBackend>(
        backend: Backend,
        children: ImageChildren
    ) -> [LayoutSystem.LayoutableChild] {
        []
    }

    func children<Backend: AppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> ImageChildren {
        ImageChildren(backend: backend)
    }

    func asWidget<Backend: AppBackend>(
        _ children: ImageChildren,
        backend: Backend
    ) -> Backend.Widget {
        children.container.into()
    }

    func computeLayout<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: ImageChildren,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        let image: ImageFormats.Image<RGBA>?
        if source != children.cachedImageSource {
            switch source {
                case .url(let url, let useFileExtension):
                    if let data = try? Data(contentsOf: url) {
                        let bytes = Array(data)
                        if useFileExtension {
                            image = try? ImageFormats.Image<RGBA>.load(
                                from: bytes,
                                usingFileExtension: url.pathExtension
                            )
                        } else {
                            image = try? ImageFormats.Image<RGBA>.load(from: bytes)
                        }
                    } else {
                        image = nil
                    }
                case .image(let sourceImage):
                    image = sourceImage
            }

            children.cachedImageSource = source
            children.cachedImage = image
            children.imageChanged = true
        } else {
            image = children.cachedImage
        }

        let size: ViewSize
        if let image {
            let idealSize = ViewSize(Double(image.width), Double(image.height))
            if isResizable {
                size = proposedSize.replacingUnspecifiedDimensions(by: idealSize)
            } else {
                size = idealSize
            }
        } else {
            size = .zero
        }

        return ViewLayoutResult.leafView(size: size)
    }

    func commit<Backend: AppBackend>(
        _ widget: Backend.Widget,
        children: ImageChildren,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let size = layout.size.vector
        let hasResized = children.cachedImageDisplaySize != size
        children.cachedImageDisplaySize = size
        if children.imageChanged
            || hasResized
            || (backend.requiresImageUpdateOnScaleFactorChange
                && children.lastScaleFactor != environment.windowScaleFactor)
        {
            if let image = children.cachedImage {
                backend.updateImageView(
                    children.imageWidget.into(),
                    rgbaData: image.bytes,
                    width: image.width,
                    height: image.height,
                    targetWidth: size.x,
                    targetHeight: size.y,
                    dataHasChanged: children.imageChanged,
                    environment: environment
                )
                if children.isContainerEmpty {
                    backend.insert(
                        children.imageWidget.into(),
                        into: children.container.into(),
                        at: 0
                    )
                    backend.setPosition(ofChildAt: 0, in: children.container.into(), to: .zero)
                }
                children.isContainerEmpty = false
            } else {
                backend.removeAllChildren(of: children.container.into())
                children.isContainerEmpty = true
            }
            children.imageChanged = false
            children.lastScaleFactor = environment.windowScaleFactor
        }
        backend.setSize(of: children.container.into(), to: size)
        backend.setSize(of: children.imageWidget.into(), to: size)
    }
}

/// Image's persistent storage. Only exposed with the `package` access level
/// in order for backends to implement the `Image.inspect(_:_:)` modifier.
package class ImageChildren: ViewGraphNodeChildren {
    var cachedImageSource: Image.Source? = nil
    var cachedImage: ImageFormats.Image<RGBA>? = nil
    var cachedImageDisplaySize: SIMD2<Int> = .zero
    var container: AnyWidget
    package var imageWidget: AnyWidget
    var imageChanged = false
    var isContainerEmpty = true
    var lastScaleFactor: Double = 1

    init<Backend: AppBackend>(backend: Backend) {
        container = AnyWidget(backend.createContainer())
        imageWidget = AnyWidget(backend.createImageView())
    }

    package var widgets: [AnyWidget] = []
    package var erasedNodes: [ErasedViewGraphNode] = []
}
