# Contributing

## Table of contents

- 1\. [Environment setup](#1-environment-setup)
- 2\. [Pull request checklist](#2-pull-request-checklist)
- 3\. [Finding something to do](#3-finding-something-to-do)
- 4\. [Running tests](#4-running-tests)
- 5\. [Special files](#5-special-files)
- 6\. [Codestyle](#6-codestyle)
- 7\. [Code formatting](#7-code-formatting)
- 8\. [Comments](#8-comments)
- 9\. [Documentation](#9-documentation)
  - 9.5\. [Previewing documentation](#96-previewing-documentation)
  - 9.6\. [Documentation formatting](#95-documentation-formatting)
- 10\. [Referencing/attribution](#10-referencingattribution)

## 1. Environment setup

1. Fork and clone SwiftCrossUI
2. Install the required dependencies as detailed in the [readme](README.md)
3. Open Package.swift to open the package in Xcode or your favourite text editor, and you're ready to code

## 2. Pull request checklist

1. Make sure to avoid massive monolithic commits where possible
2. Use DocC documentation comments to document all public declarations that you have introduced or modified. Also consider documentation internal/private members if their usage wouldn’t be immediately clear to a another contributor, or if there is nuance to their behaviour.
3. Supply screenshots for each applicable platform if you’ve introduced a UI feature or otherwise changed the appearance of a SwiftCrossUI feature in some way
4. Add unit tests to cover your changes if your changes would benefit from tests. If it’s not obvious whether a change would benefit from unit tests, omit them and ask for clarification in your pull request description.
5. If you are adding a new feature, consider adding an example usage of it to the examples
6. Run `Scripts/format.sh` (requires installing [`SwiftFormat`](https://github.com/nicklockwood/SwiftFormat?tab=readme-ov-file#command-line-tool))

## 3. Finding something to do

Look through [the issues on GitHub](https://github.com/moreSwift/swift-cross-ui/issues) for tasks to work on. If nothing piques your interest, join the [moreSwift Discord server](https://moreswift.dev/discord) and let us know what you're interested in working on.

## 4. Running tests

To run the tests, run `./Scripts/test.sh` in the root of the repository.

```sh
# Run SwiftCrossUI's tests
./Scripts/test.sh
```

The script is required due to limitations of SwiftPM and the way this project is structured. Running `swift test` without any arguments causes SwiftPM to build all backends, even those not supported on the current platform. 

### Backend-specific tests

The project has some Gtk3Backend-specific tests which are disabled by default given that many contributors don't have Gtk 3 installed. We recommend running these tests if you are working on the layout system or Gtk3Backend. CI will always run these tests, so that you don't have to worry about missing these tests locally. 

```sh
# Run Gtk3Backend tests alongside default tests
SCUI_TEST_GTK3BACKEND=1 ./Scripts/test.sh
```

## 5. Special files

Here are a few rules regarding special files;

1. Do not directly modify a file that has a corresponding `.gyb` template file (which will be in the
   same directory). Instead, modify the template file and then run `./Scripts/generate_gyb.sh`
   to build all of the templates. To learn more about gyb
   [read this post](https://nshipster.com/swift-gyb/)
2. Do not directly modify files in `Sources/Gtk/Generated` or `Sources/Gtk3/Generated`. Update the
   generator at `Sources/GtkCodeGen` instead and run `./Scripts/generate_gtk.sh` to regenerate the
   Gtk 3 and Gtk 4 bindings. If the changes can not be made by updating the generator, pull the
   target file out of `Sources/{Gtk,Gtk3}/Generated` and into `Sources/{Gtk,Gtk3}/Widgets` and
   modify it however you want. Remember to remove the class from `allowListedClasses`,
   `gtk3AllowListedClasses` or `gtk4AllowListedClasses` so that it doesn't get regenerated the
   next time someone runs `./Scripts/generate_gtk.sh`. Alternatively, if possible, add
   code to the generated classes via extensions outside of the Generated directories. I usually
   name these extension files `ClassName+ManualAdditions.swift`.

## 6. Codestyle

1. Avoid using shorthand when the alternative is more readable at a glance
2. Use `logger` to log warnings and errors. 
3. Avoid using positional closure parameters (e.g. `$0`, `$1`) for non-trivial closures (generally those that don't fit on a single line). Give the parameter a name and use that instead.
4. Use `guard` statements where possible, especially when introducing early returns, as they are easier to skim read than if statements (as long as you understand the condition, you can skip over the body of the guard statement knowing that it will exit the current scope no matter what).

## 7. Code formatting

As a baseline, we use Nick Lockwood's [SwiftFormat](https://github.com/nicklockwood/SwiftFormat)
tool with the configuration file at [.swiftformat](./.swiftformat). This tool doesn't cover
all of our preferences, so here are our main rules;

1. Use 4 space indentation
2. Keep lines under 80 characters where possible, with a hard limit at 100 characters
   - You can break long string literals across multiple lines by using a multiline string literal and ending each line (except the last) with a backslash
     ```swift
     log.warning(
         """
         This is a very long warning with lots of context and detail to aid the developer \
         in resolving the issue that it's flagging. This message will appear as one line to \
         the developer but it line-wrapped within the source file, making things easier to \
         read as a SwiftCrossUI contributor.
         """
     )
     ```
3. When breaking function parameters across multiple lines, put each parameter on a separate line, with the closing parenthesis on its own line at ambient indentation level
   ```swift
   func myFunctionWithLotsOfParameters(
       _ parameter1: Int,
       _ parameter2: Int,
       _ parameter3: Int,
       _ parameter4: Int
   ) async throws
       -> MyVeryLongReturnType<Int, String, [UInt8], MyErrorType>.Element
   {
       // ...
   }
   ```
4. Separate functions, types and computed properties with a single blank line. Stored properties may also be separated by blank lines but are allowed to be grouped together by feature, meaning, or some other reasonable system.
5. Place each top-level type declaration in its own file with a name matching that of the type. We sometimes make an exception for internal/private helper types not used outside of the containing file.

## 8. Comments

1. Use sentence case
2. Put a single space between the double slash and the comment’s text
3. Use multiple single line comments instead of a multi-line comment
4. New todo comments must be tagged with your GitHub username
   ```swift
   // TODO(stackotter): Make this more robust once we have a state dependency
   //   tracking system
   ```
5. Add comments to any code you think would need explaining to other contributors

### Bad comments

```swift
//this comment is poorly formatted

//This comment is poorly formatted

/*
  This comment uses the multi-line comment syntax,
  which SwiftCrossUI doesn't use
*/

// TODO: Fix this todo comment that isn't attributed to a GitHub username
```

### Good comments

```swift
// This comment is well formatted

// TODO(stackotter): Make this more robust once we have a state dependency
//   tracking system
```

## 9. Documentation

moreSwift’s projects use DocC to document code, and to author documentation articles.

1. Document all public declarations
2. Document all function parameters
3. Document all non-Void return types
4. Document preconditions

If using Xcode, pressing option+cmd+/ generates a template documentation comment for the declaration that your cursor is currently on. If using another code editor with Sourcekit LSP, similar functionality is generally available as a code action.

### 9.5. Previewing documentation

To preview documentation, run `./Scripts/preview_docs.sh` from the root of the repository.

```sh
# Preview docs (builds SwiftCrossUI first to obtain symbol graphs, and then
# previews Sources/SwiftCrossUI/SwiftCrossUI.docc)
./Scripts/preview_docs.sh

# Preview docs without symbol graphs (faster if just working on articles/tutorials)
SKIP_SYMBOL_GRAPHS=1 ./Scripts/preview_docs.sh
```

### 9.6. Documentation formatting

1. Documentations comments should be punctuated as proper sentences (which generally means ending with a period).
2. Use sentence case
3. Leave a space between the triple slash and the documentation text
4. Use multiple single-line documentation comments instead of a multi-line documentation comment
5. When referring to another symbol within the same target, use double backticks to generate a symbol link. See DocC's article on [linked to symbols and other content](https://www.swift.org/documentation/docc/linking-to-symbols-and-other-content).
   ```swift
   /// This method has been superceded by ``View/emphasized()``.
   ```
6. Use type hints to disambiguate otherwise ambiguous symbol links, and avoid using FNV-1 hash based disambiguation as it isn't human readable and can't be easily manipulated with standard text editors. See [DocC's documentation on ambiguous symbol links](https://www.swift.org/documentation/docc/linking-to-symbols-and-other-content#Ambiguous-Symbol-Links) for the specifics of symbol disambiguation.
7. Use named links to make documentation markdown line wrap at a sensible width.
   ```swift
   /// For a detailed explanation, see Wikipedia's [page on parallel curves][wikipedia]. 
   ///
   /// [wikipedia]: https://en.wikipedia.org/wiki/Parallel_curve
   ```

The following is an example of documentation that follows all of these rules. It
has been manufactured to demonstrate all of the rules, so it's longer than our
usual documentation comments.

```swift
/// Computes this view's layout after a state change or a change in
/// available space.
///
/// Implementations of this method should follow similar semantics to the
/// [SwiftUI layout algorithm][algorithm].
///
/// The default implementation lives at
/// ``View/defaultComputeLayout(_:children:proposedSize:environment:backend:)-(_,any ViewGraphNodeChildren,_,_,_)``.
///
/// [algorithm]: https://www.hackingwithswift.com/books/ios-swiftui/how-layout-works-in-swiftui
///
/// - Precondition: Requires that the target widget has been added to its parent widget.
/// - Parameters:
///   - widget: The widget to compute the layout for.
///   - children: The view's child nodes.
///   - proposedSize: The size suggested by the parent container.
///   - environment: The environment to compute the layout in.
///   - backend: The backend used to create the widget.
/// - Returns: The view's computed layout result.
func computeLayout<Backend: AppBackend>(
    _ widget: Backend.Widget,
    children: any ViewGraphNodeChildren,
    proposedSize: ProposedViewSize,
    environment: EnvironmentValues,
    backend: Backend
) -> ViewLayoutResult
```

## 10. Referencing/attribution

1. When taking/adapting non-trivial code from another project or a blog post etc, make sure to provide the source in a comment and briefly state how the reference code was used (e.g. `// Adapted from: <url>`). Code that is licensed with a more restrictive license than MIT cannot be used, even if referenced.
