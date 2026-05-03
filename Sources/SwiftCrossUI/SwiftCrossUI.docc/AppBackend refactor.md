# AppBackend refactor

Changes to the `AppBackend` protocol

> Note: See [the relevant PR](https://github.com/moreSwift/swift-cross-ui/pull/513) for more info.

There was recently a _massive_ refactoring of the equally massive `AppBackend` protocol. Here's a
comprehensive-ish list of changes:

- The `AppBackend` protocol has been split up into three dozen or so smaller protocols, all
  organized within a ``BackendFeatures`` namespace enum.
  - There are three core, "top-level" protocols (actually typealiases for protocol compositions)
    that backend developers need to worry about:
    - ``BackendFeatures/Core`` contains the bare minimum needed for a SCUI app to launch without
      crashing immediately. (This one's a true `protocol`, not a typealias.)
    - ``BaseAppBackend`` extends `Core` with most UI controls, containers, and noninteractive views.
      This is the protocol that the ``App/Backend`` associated type requires.
    - ``FullAppBackend`` contains everything the original protocol had, including all of `Base` as
      well as URL handling, revealing files, the global menu, file dialogs, alerts, sheets, corner
      radii, web views, tables, gestures, menus, paths, colors, tooltips, date pickers, and some
      windowing functionality.
      - All of these features are now **optional** for backends to implement.
      - For ``BackendFeatures/RevealFiles``, the `canRevealFiles` property has been removed in favor
        of simply not conforming to the protocol if revealing files isn't supported.
  - All of the protocols below these are described in the doc comments for the new wrapper types and
    grouping typealiases.
- Code in the SwiftCrossUI target has been updated to use `BaseAppBackend` instead of just
  `AppBackend`. Backend instances are dynamically casted to additional protocols as needed.
  - A new internal macro, `CastBackend`, was added to simplify the task of casting backends. It has
    the following signature:

    ```swift
    @attached(body)
    internal macro CastBackend<NewBackend>(
        backendGenericName: String? = nil,
        returnsWidget: Bool = false
    )
    ```

    It currently only works correctly within implementations of `View` methods, but since that's
    where most of the boilerplate resides, this macro should still be a huge help.
- The backends themselves have been updated for the new organization. Here are the backend protocols
  each backend conforms to:
  - ``BaseAppBackend``: all backends
    - ``BackendFeatures/Toggles`` is stubbed for UIKitBackend on all platforms;
      ``BackendFeatures/Sliders`` is stubbed for UIKitBackend on tvOS.
  - ``BackendFeatures/ApplicationMenus``: all backends except UIKitBackend (except for Mac Catalyst
    where it _is_ implemented)
  - ``BackendFeatures/ExternalURLs``: all backends
  - ``BackendFeatures/IncomingURLs``: all backends
  - ``BackendFeatures/RevealFiles``: all backends except UIKitBackend and WinUIBackend
  - ``BackendFeatures/FileOpenDialogs``: all backends except UIKitBackend on tvOS
  - ``BackendFeatures/FileSaveDialogs``: all backends except UIKitBackend
  - ``BackendFeatures/Alerts``: all backends
  - ``BackendFeatures/Sheets``: all backends except WinUIBackend and Gtk3Backend
  - ``BackendFeatures/CornerRadius``: all backends (but janky on Gtk3Backend)
  - ``BackendFeatures/WebViews``: AppKitBackend and UIKitBackend only
  - ``BackendFeatures/Tables``: AppKitBackend only
  - ``BackendFeatures/TapGestures``: all backends
  - ``BackendFeatures/HoverGestures``: all backends except UIKitBackend on tvOS
  - ``BackendFeatures/MenuButtons``: all backends except UIKitBackend before iOS 14 / Mac Catalyst 14 / tvOS 17
  - ``BackendFeatures/Paths``: all backends
  - ``BackendFeatures/Tooltips``: all backends
  - ``BackendFeatures/Colors``: all backends
  - ``BackendFeatures/DatePickers``: all backends except Gtk3Backend, and UIKitBackend on tvOS
  - ``BackendFeatures/WindowClosing``: all backends except UIKitBackend
  - ``BackendFeatures/WindowBehaviors``: all backends

## Random Extras
A fun side effect of all this that stackotter noticed is that people can now implement missing
backend features _in user code_ — e.g. if someone needs sheets in WinUI, they could simply
declare `extension WinUIBackend: BackendFeatures.Sheets` in their app.

Of course, we'd want to encourage people to upstream such code into the main project, but this is
still a useful thing for people to be able to do. It'd also slightly reduce the (admittedly not
large at all) barrier to entry for contributing to SCUI as well as third-party backend projects.
