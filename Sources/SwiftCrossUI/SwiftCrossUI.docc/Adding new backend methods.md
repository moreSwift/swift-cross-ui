# Adding new backend methods

Guidelines for organizing backend protocols

## Overview

- Tip: This page is for SwiftCrossUI contributors who need to add new functionality
  to ``AppBackend``. If you're just trying to write your own backend by using the
  `AppBackend` set of protocols, refer to <doc:Custom-backends> and the documentation
  for the appropriate protocols.

We recently split up the monolithic `AppBackend` protocol into a set of three dozen
or so smaller protocols to better organize the huge set of backend functionality and
to allow for a more modular backend development approach. This file contains some
guidelines as to how to organize these protocols when adding new backend methods, in
order to keep our protocol definitions easily maintainable.

- Note: These guidelines are not hard-and-fast rules. If you feel the need to break
  them, feel free (just be sure other maintainers are cool with it first).

### Adding methods to existing protocols

If you're augmenting an existing SwiftCrossUI feature with new functionality, it's
usually best to add a new method to an existing protocol that deals with that
feature. For example, if you're adding functionality to ``WebView`` and need a new
backend method, you should put it inside of ``AppBackend/WebViews``.

Here are some guidelines for adding methods to existing protocols:
- Separate every protocol requirement with a single empty line.
- Add documentation to your backend method describing the expected behavior, as
  well as any areas where the conforming backend is free to do its own thing.
  Make sure to document parameters and return values!
- If the method is not absolutely critical for core app functionality (usually
  this is indicated by it being a requirement of ``AppBackend/Core``), add a
  default implementation that simply calls `fatalError`. For example:

  ```swift
  // MARK: Default Implementations
      
  extension AppBackend.Tooltips {
      public func createTooltipContainer(wrapping child: Widget) -> Widget {
          fatalError("\(Self.self): \(#function) not implemented")
      }
  }
  ```

  Put any such default implementation near the end of the file, after the MARK
  comment shown in the above code block. Declare these default implementations
  in the same order as the protocols themselves.

### Adding new protocols

If you're adding a wholly new feature to SwiftCrossUI -- for example, a new
control -- you should put its corresponding backend methods in a new protocol.

Here are some tips for new backend protocols:
- Follow the guidelines above for individual methods.
- If the protocol name is a noun, make it plural. (This isn't just for stylistic
  reasons -- it helps to avoid ambiguity in doc comments if there's a SwiftCrossUI
  type with the same name.)
- Declare your protocol `@MainActor` -- it doesn't make much sense for backends
  to run outside the main actor, since most UI frameworks must be run on the main
  thread. If you absolutely have to, you can mark individual requirements
  `nonisolated`.
- Decide at what level the protocol should be required:
  - If it fits under the umbrella of an existing group of protocols (such as
    ``AppBackend/Controls`` or ``AppBackend/Gestures``), add it there and don't
    add it anywhere else. It'll automatically bubble up the protocol inheritance
    chain into `Base` or `Full`.
  - If it's critical for basic app functionality, add it to the inheritance clause
    of ``AppBackend/Core``. **You should have to do this very rarely.**
  - If it could be considered a basic feature that all SwiftCrossUI backends can
    reasonably implement (mobile and desktop!), add it to the ``AppBackend/Base``
    typealias. This will probably be the most common choice.
  - If the feature is optional and can reasonably go unimplemented by certain
    backends, add it to ``AppBackend/Full``. Make sure to dynamically cast your
    backend instance in the feature's implementation and prepare some sort of
    fallback if the backend doesn't support the feature.
  - Whatever type you add your protocol to, don't forget to also add it to that
    type's doc comment! That way people can quickly see what other functionality
    is required by a specific protocol.
- Usually, your protocol should inherit from `Core` and nothing else; if you need
  to inherit from a different backend protocol, you can do that too. The only
  non-backend conformance should be `Sendable`, which is required by `Widgets`
  and thus usually inherited.
- If an existing file makes sense for the protocol, add it there in a reasonable
  location; otherwise, make a new file in the `AppBackend` folder with a name
  modeled on `AppBackend+Feature`.
