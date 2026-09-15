import SwiftCrossUI

/// Previews a SwiftCrossUI view in Xcode's canvas, spelled the same way as
/// SwiftUI's `#Preview`.
///
/// This overloads SwiftUI's macro rather than replacing it. The closure's return
/// type selects between them, so one file can preview both kinds of view with
/// the same spelling:
///
/// ```swift
/// #Preview("Native") { SwiftUI.Text("hi") }        // SwiftUI's
/// #Preview("Cross-platform") { CounterView() }     // this one
/// ```
///
/// It needs no conditional compilation and no availability annotation. The
/// expansion is empty on platforms that have no preview canvas, so a file
/// using it builds unchanged on Linux and Windows, and the availability the
/// registration needs is part of the expansion.
///
/// ## Where previews appear
///
/// Xcode runs a preview inside a host executable, chosen from the targets that
/// both depend on the previewed one and belong to the active scheme. When no
/// such executable exists it falls back to hosting the previewed module on its
/// own.
///
/// That choice decides which symbols the preview can reach:
///
/// | Previewing from | Previews render |
/// | --- | --- |
/// | An app target's scheme | Anything the app links, including package views |
/// | A package's own scheme | Views the previewed module itself builds |
///
/// Previewing a package's views from the package alone works as long as the
/// view and the preview are in one module of a library target. A body that
/// reaches into another of the package's modules reports "Missing Preview"
/// instead: the fallback host resolves only what the previewed module already
/// links.
///
/// - Warning: An executable package target can't host the canvas at all. Xcode
///   requires the `ENABLE_DEBUG_DYLIB` build setting to preview an executable,
///   a package manifest has no way to set it, and Xcode refuses with that
///   setting's name in the error. Keep previews in library targets, or preview
///   from an app project as described below.
///
/// Both rows require a literal `#Preview`, which is what Xcode scans for. That
/// makes them inapplicable inside SwiftCrossUIPreviews itself, where this
/// overload can't be written at all (see the note below).
///
/// To preview across a package's modules, open it from an Xcode project whose
/// app target depends directly on the product containing the previewed file,
/// and make that app's scheme the active one. A transitive dependency isn't
/// enough for the app to be chosen as the host. See `Examples/PreviewsExample`
/// for a working project set up this way.
///
/// - Note: This overload can't be used inside SwiftCrossUIPreviews itself. A
///   same-module declaration outranks the imported SwiftUI one, so within this
///   module `#Preview` always resolves here, and previews of genuine SwiftUI
///   views stop compiling. Consumers are unaffected, since for them neither
///   declaration is same-module and the closure's type decides.
///
/// - Parameters:
///   - name: A display name for the preview, shown in Xcode's canvas.
///   - body: A closure returning the view to preview.
@freestanding(declaration)
public macro Preview<Content: SwiftCrossUI.View>(
    _ name: String? = nil,
    @SwiftCrossUI.ViewBuilder body: @escaping () -> Content
) = #externalMacro(module: "SwiftCrossUIMacrosPlugin", type: "SCUIPreviewMacro")
