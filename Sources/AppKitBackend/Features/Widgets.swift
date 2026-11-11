import AppKit
@_spi(Backends) import SwiftCrossUI

extension AppKitBackend: BackendFeatures.Widgets {
    public typealias Widget = NSView

    public var defaultPaddingAmount: Int { 10 }

    public func show(widget: Widget) {}

    public func naturalSize(of widget: Widget) -> SIMD2<Int> {
        if let spinner = widget.subviews.first as? NSProgressIndicator,
           spinner.style == .spinning
        {
            let size = spinner.intrinsicContentSize
            return SIMD2(
                Int(size.width),
                Int(size.height)
            )
        }
        let size = widget.intrinsicContentSize
        return SIMD2(
            Int(size.width),
            Int(size.height)
        )
    }

    public func setSize(of widget: Widget, to size: SIMD2<Int>) {
        setSize(of: widget, to: ProposedViewSize(ViewSize(Double(size.x), Double(size.y))))
    }

    func setSize(of widget: Widget, to proposedSize: ProposedViewSize) {
        var foundConstraint = false
        for constraint in widget.constraints {
            if constraint.firstAnchor === widget.widthAnchor {
                if let proposedWidth = proposedSize.width {
                    constraint.constant = CGFloat(proposedWidth)
                    constraint.isActive = true
                } else {
                    constraint.isActive = false
                }
                foundConstraint = true
                break
            }
        }

        if !foundConstraint, let proposedWidth = proposedSize.width {
            widget.widthAnchor.constraint(equalToConstant: proposedWidth).isActive = true
        }

        foundConstraint = false
        for constraint in widget.constraints {
            if constraint.firstAnchor === widget.heightAnchor {
                if let proposedHeight = proposedSize.height {
                    constraint.constant = CGFloat(proposedHeight)
                    constraint.isActive = true
                } else {
                    constraint.isActive = false
                }
                foundConstraint = true
                break
            }
        }

        if !foundConstraint, let proposedHeight = proposedSize.height {
            widget.heightAnchor.constraint(equalToConstant: proposedHeight).isActive = true
        }
    }
}
