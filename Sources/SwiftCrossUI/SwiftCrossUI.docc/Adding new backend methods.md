# Adding new backend methods

Guidelines for organizing backend protocols

## Overview

- Tip: This page is for SwiftCrossUI contributors who need to add new
  functionality to ``BackendFeatures``. If you're trying to write your own
  backend by using the `BackendFeatures` set of protocols, refer to
  <doc:Custom-backends> and the documentation for the appropriate protocols.

We recently split up the monolithic `AppBackend` protocol into a set of
three dozen or so smaller protocols to better organize the huge set of backend
functionality and to allow for a more modular backend development approach. This
file contains some guidelines as to how to organize these protocols when adding
new backend methods, in order to keep our protocol definitions easily
maintainable.

- Note: These guidelines are not hard-and-fast rules. If you feel the need to
  break them, feel free (just be sure other maintainers are cool with it first).

## Adding methods to existing protocols

If you're augmenting an existing SwiftCrossUI feature with new functionality,
it's usually best to add a new method to an existing protocol that deals with
that feature. For example, if you're adding functionality to ``WebView`` and
need a new backend method, you should put it inside of
``BackendFeatures/WebViews``.

Here are some guidelines for adding methods to existing protocols:
- Separate every protocol requirement with a single empty line.
- Add documentation to your backend method describing the expected behavior, as
  well as any areas where the conforming backend is free to do its own thing.
  Make sure to document parameters and return values!
- If the method is a requirement of ``BaseAppBackend`` (including methods in
  ``BackendFeatures/Core``), add a default implementation to
  ``BackendFeatures/BaseStubs``. There's a private struct in that file called
  `BaseStubsTest` that the compiler will probably error on if you add new
  backend APIs without updating `BaseStubs`; see that type's doc comment for
  further info.

  Don't add these implementations for protocols which aren't a part of
  ``BaseAppBackend``.

## Adding new protocols

If you're adding a wholly new feature to SwiftCrossUI -- for example, a new
control -- you should put its corresponding backend methods in a new protocol.

Here are some tips for new backend protocols:
- Follow the guidelines above for individual methods.
- If the protocol name is a noun, make it plural. (This isn't just for stylistic
  reasons -- it helps to avoid ambiguity in doc comments if there's a
  SwiftCrossUI type with the same name.)
- Declare your protocol `@MainActor` -- it doesn't make much sense for backends
  to run outside the main actor, since most UI frameworks must be run on the
  main thread. If you absolutely have to, you can mark individual requirements
  `nonisolated`.
- Decide at what level the protocol should be required:
  - If it fits under the umbrella of an existing group of protocols (such as
    ``BackendFeatures/Controls`` or ``BackendFeatures/Gestures``), add it there
    and don't add it anywhere else. It'll automatically bubble up the protocol
    inheritance chain into `BaseAppBackend` or `FullAppBackend`.
  - If it's critical for core app functionality, add it to the inheritance
    clause of ``BackendFeatures/Core``. **You should have to do this very
    rarely.**
  - If it could be considered a basic feature that all SwiftCrossUI backends
    should implement (mobile and desktop!), add it to the ``BaseAppBackend``
    typealias.
  - If the feature is optional and can reasonably go unimplemented by certain
    backends, add it to ``FullAppBackend``. Make sure to dynamically cast your
    backend instance in the feature's implementation and prepare some sort of
    fallback if the backend doesn't support the feature. (The internal
    `CastBackend` macro can help with casting backends in view implementations.)
  - Whatever type you add your protocol to, don't forget to also add it to that
    type's doc comment! That way people can quickly see what other functionality
    is required by a specific protocol.
- Usually, your protocol should inherit from `Core` and nothing else; if you
  need to inherit from a different backend protocol, you can do that too. The
  only non-backend conformance should be `Sendable`, which is required by
  `Widgets` and thus usually inherited.
- If an existing file makes sense for the protocol, add it there in a reasonable
  location; otherwise, make a new file in the `AppBackend` folder with a
  name modeled on `BackendFeatures+Feature`.
