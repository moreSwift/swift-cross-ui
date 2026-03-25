import AppKit
import SwiftCrossUI

extension AppKitBackend {
    public typealias Sheet = NSCustomSheet

    public func createSheet(content: NSView) -> NSCustomSheet {
        // Initialize with a default contentRect, similar to `createWindow`
        let sheet = NSCustomSheet(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: 400,
                height: 400
            ),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: true
        )

        let backgroundView = NSView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.wantsLayer = true

        let contentView = NSView()
        contentView.addSubview(backgroundView)
        contentView.addSubview(content)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: content.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
        ])
        contentView.translatesAutoresizingMaskIntoConstraints = false

        sheet.contentView = contentView
        sheet.backgroundView = backgroundView

        return sheet
    }

    public func updateSheet(
        _ sheet: NSCustomSheet,
        window: NSCustomWindow,
        environment: EnvironmentValues,
        size: SIMD2<Int>,
        onDismiss: @escaping () -> Void,
        cornerRadius: Double?,
        detents: [PresentationDetent],
        dragIndicatorVisibility: Visibility,
        backgroundColor: Color.Resolved?,
        interactiveDismissDisabled: Bool
    ) {
        sheet.setContentSize(NSSize(width: size.x, height: size.y))
        sheet.onDismiss = onDismiss

        let background = sheet.backgroundView!
        background.layer?.backgroundColor = backgroundColor?.nsColor.cgColor
        sheet.interactiveDismissDisabled = interactiveDismissDisabled

        // - dragIndicatorVisibility is only for mobile so we ignore it
        // - detents are only for mobile so we ignore them
        // - cornerRadius isn't supported by macOS so we ignore it
    }

    public func size(ofSheet sheet: NSCustomSheet) -> SIMD2<Int> {
        guard let size = sheet.contentView?.frame.size else {
            return SIMD2(x: 0, y: 0)
        }
        return SIMD2(x: Int(size.width), y: Int(size.height))
    }

    public func presentSheet(_ sheet: NSCustomSheet, window: Window, parentSheet: Sheet?) {
        let parent = parentSheet ?? window
        // beginSheet and beginCriticalSheet should be equivalent here, because we
        // directly present the sheet on top of the top-most sheet. If we were to
        // instead present sheets on top of the root window every time, then
        // beginCriticalSheet would produce the desired behaviour and beginSheet
        // would wait for the parent sheet to finish before presenting the nested sheet.
        parent.beginSheet(sheet)
        parent.nestedSheet = sheet
    }

    public func dismissSheet(_ sheet: NSCustomSheet, window: Window, parentSheet: Sheet?) {
        let parent = parentSheet ?? window

        // Dismiss nested sheets first
        if let nestedSheet = sheet.nestedSheet {
            dismissSheet(nestedSheet, window: window, parentSheet: sheet)
            // Although the current sheet has been dismissed programmatically,
            // the nested sheets kind of haven't (at least, they weren't
            // directly dismissed by SwiftCrossUI, so we must called onDismiss
            // to let SwiftUI react to the dismissals of nested sheets).
            nestedSheet.onDismiss?()
        }

        parent.endSheet(sheet)
        parent.nestedSheet = nil
    }
}

public final class NSCustomSheet: NSCustomWindow, NSWindowDelegate {
    public var onDismiss: (() -> Void)?

    public var interactiveDismissDisabled: Bool = false

    public var backgroundView: NSView?

    @objc override public func cancelOperation(_ sender: Any?) {
        if !interactiveDismissDisabled {
            sheetParent?.endSheet(self)
            onDismiss?()
        }
    }
}
