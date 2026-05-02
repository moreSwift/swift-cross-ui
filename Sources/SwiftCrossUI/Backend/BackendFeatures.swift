/// Namespace for backend protocols.
///
/// Conform to ``BaseAppBackend`` to create a backend that can be used to run
/// an app. Backends are usually built on top of an existing UI framework.
///
/// Default placeholder implementations are available for all backend methods,
/// via the ``BackendFeatures/BaseStubs`` protocol. **These implementations will
/// `fatalError` when called and are simply intended to allow incremental
/// implementation of backends, not as a production-ready fallback for views
/// that cannot be represented by a given backend.** See that type's
/// documentation for more details.
///
/// ## Backend Protocols
///
/// Since a fully-functional SwiftCrossUI backend is such a complicated beast,
/// we've split it up into a bunch of smaller protocols, each of which deals
/// with implementing a single feature or logical set of features.
///
/// At a high level, there are three protocols (technically typealiases of
/// protocol compositions) you need to worry about.
///
/// - term ``Core``: This protocol describes the absolute bare minimum amount
///   of code required for an app to launch, show something on the screen, and
///   perform basic widget manipulation.
/// - term ``BaseAppBackend``: This protocol describes all the code required for
///   a minimally functional backend, including everything in `Core` as well as
///   many UI controls and containers, text and images. Conforming to this
///   protocol is required for your backend type to be usable in SwiftCrossUI
///   APIs.
///
///   You will probably want to implement some other backend protocols in
///   addition to `BaseAppBackend`, since this is pretty bare-bones on its own.
/// - term ``FullAppBackend``: This protocol describes all the code needed for a
///   fully functional backend that supports everything SwiftCrossUI has to
///   offer, including URL and file handling, alerts, and sheets. It includes
///   everything in `BaseAppBackend`.
///
/// See the documentation for each protocol for more details on what they
/// require.
///
/// ## Design Notes
///
/// If you need to modify the children of a widget after creation but there
/// aren't update methods available, this is an intentional limitation to
/// reduce the complexity of maintaining a multitude of backends -- nest
/// another container, such as a VStack, inside the container to allow you
/// to change its children on demand.
///
/// For interactive controls with values, the method for setting the
/// control's value is always separate from the method for updating the
/// control's properties (e.g. its minimum value, or placeholder label etc).
/// This is because it's very common for view implementations to either
/// update a control's properties without updating its value (in the case
/// of an unbound control), or update a control's value only if it doesn't
/// match its current value (to prevent infinite loops).
///
/// Many views have both a `create` and an `update` method. The `create`
/// method should only have parameters for properties which don't have
/// sensible defaults (e.g. under some backends, image widgets can't be
/// created without an underlying image being selected up-front, so the
/// `create` method requires a `filePath` and will overlap with the `update`
/// method). This design choice was made to reduce the amount of repeated
/// code between the `create` and `update` methods of the various widgets
/// (since the `update` method is always called between calling `create`
/// and actually displaying the widget anyway).
///
/// ## Topics
///
/// ### Top-Level
/// - ``BackendFeatures/Core``
/// - ``BaseAppBackend``
/// - ``FullAppBackend``
///
/// ### Implementation Helpers
/// - ``BackendFeatures/BaseStubs``
public enum BackendFeatures {}
