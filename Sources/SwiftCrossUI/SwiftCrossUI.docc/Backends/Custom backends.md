# Custom backends

## Overview

With being open and extensible as a core goal, SwiftCrossUI allows custom
backends to be implemented in third-party packages.

"Simply" implement the ``BaseAppBackend`` protocol and you're good to go!

- Note: While ``BaseAppBackend`` is all that's required for a functional,
  production-ready backend, there are more features (part of ``FullAppBackend``)
  that you may want to implement. These features are all optional and may be
  omitted if your underlying UI framework doesn't support them.

  See the documentation for ``FullAppBackend`` and the ``BackendFeatures``
  namespace enum for more details.

## Topics

### Protocols
- <doc:AppBackend-refactor>
- ``BackendFeatures``
- ``BaseAppBackend``
- ``FullAppBackend``

### Supporting Types
- ``CellPosition``
- ``MenuImplementationStyle``
- ``DialogResult``
- ``ResolvedMenu``
- ``BackendPickerStyle``
