# Custom backends

## Overview

With being open and extensible as a core goal, SwiftCrossUI allows custom
backends to be implemented in third-party packages.

"Simply" implement the ``AppBackend/Base`` protocol and you're good to go!

- Note: While ``AppBackend/Base`` is all that's required for a functional,
  production-ready backend, there are more features (part of
  ``AppBackend/Full``) that you may want to implement. These features are all
  optional and may be omitted if your underlying UI framework doesn't support
  them.

  See the documentation for ``AppBackend/Full`` and the ``AppBackend`` namespace
  enum for more details.

## Topics

- ``AppBackend``
- ``CellPosition``
- ``MenuImplementationStyle``
- ``DialogResult``
- ``ResolvedMenu``
