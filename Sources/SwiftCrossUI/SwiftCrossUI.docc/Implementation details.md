# Implementation details

## Overview

You don't need to interact with any of this directly unless you're doing
something very advanced. Many of these are only exposed as `public` so that
advanced users don't have to reimplement helpers that we've already implemented,
and others are exposed to enable unique use-cases such as embedding SwiftCrossUI
view graphs inside existing non-SwiftCrossUI apps.

### Contents
- <doc:#High-level-overview>
  - <doc:#Entry-point>
  - <doc:#Scenes>
  - <doc:#The-view-graph>
  - <doc:#View-updates>
  - <doc:#The-View-protocol>
  - <doc:#Environment>
  - <doc:#Preferences>
- <doc:#Dynamic-properties>
  - <doc:#Primary-method>
  - <doc:#Fallback-method>

<!-- TODO: Write technical deep dives into some of these implementation details -->

## High-level overview

It's a good idea to refer to [the source code] while reading this, as not all of
the APIs mentioned are made public.

[the source code]: https://github.com/stackotter/swift-cross-ui/tree/main/Sources/SwiftCrossUI

### Entry point

The entry point of SwiftCrossUI apps is the implementation of ``App/main()``
provided by the ``App`` protocol. That function defers to
`_App.run()`.

`_App.run()` starts the backend's main loop, and does the rest of the setup once
the backend is ready. The rest of the setup phase involves:
- Computing the root environment
- Instantiating any ``Environment`` properties on the app struct via
  `updateDynamicProperties(of:previousValue:environment:)`
- Observing any ``State`` properties on the app struct using `Mirror` and
  `observeAsUIUpdater(backend:action:)` (which handles basic update debouncing)
- Creating the root scene graph node
- Listening for environment changes (e.g. system theme changes)
- Updating the root scene graph node

### Scenes

Scene types (structs conforming to ``Scene``) each have their own node type
(conforming to ``SceneGraphNode``). These node types are classes and store any
persistent state associated with the scene (e.g. the window pointer or the
``ViewGraph`` associated with the scene).

_Scenes_ here are just anything that exists at the level above views (e.g.
windows and app menus).

### The view graph

The root of the view graph is the ``ViewGraph`` class. It stores a root node and 
some information required to glue scenes and view graphs together (such as the
last known window size). ``ViewGraph`` is a pretty thin wrapper around
``ViewGraphNode`` and essentially just hides some of the more internal details
that scenes don't need to worry about.

Each view generally has an associated ``ViewGraphNode``. This is where the
view's state is persisted, and is where any fancy layout caching happens. The
view graph node's lifecycle is also what ``View/onAppear(perform:)`` and
``View/onDisappear(perform:)`` are based on; for example,
``View/onDisappear(perform:)`` runs when a node deinits.

``ViewGraphNode``s store their children using types conforming to the
``ViewGraphNodeChildren`` protocol. The exact type is determined by the
associated view. For example, ``TupleView3`` stores its three child nodes ---
`child0`, `child1`, and `child2` --- using ``TupleViewChildren3``, while
``ForEach`` stores its children in the `ForEachViewChildren` class which is
designed for storing a homogenous array of child nodes. It's the responsibility
of ``View/computeLayout(_:children:proposedSize:environment:backend:)``
implementations to propagate updates on to any relevant child nodes.

### View updates

View updates happen in two phases; the layout phase and the commit phase.

The layout phase allows views to efficiently be queried for their layout at
multiple different sizes without too much overhead. During the layout phase,
``ViewGraphNode`` can avoid querying its associated view for a potentially
expensive layout computation if it believes that it can already satisfy the
query using basic assumptions about view layout behaviour and the results of
previous layout updates (see `ViewGraphNode.resultCache` and
`ViewGraphNode.currentResult`).

The commit phase simply applies the result of the last layout computation to
the view's underlying widget.

There are two types of view updates; top-down and bottom-up. Top-down updates
occur when a view's parent view has updated for some reason (be that a state
update, or the parent's parent updating, or some other reason). Bottom-up
updates happen when a view's child updated due to a state change _and_ the child
changed size due to that update. Bottom-up updates continue propagating upwards
until a view doesn't change size (meaning that we can avoid notifying its
parent).

### The View protocol

The most famous requirement of ``View`` is ``View/body``; this is the property
you know and love from SwiftUI. It's sufficient to just implement this property
when you're implementing regular views.

The following requirements are used to implement internal views such as
``Button``:

- term ``View/children(backend:snapshots:environment:)``: This method
  produces the ``ViewGraphNodeChildren`` instance that the view would like to
  use to store its children. The return type is an existential because otherwise
  we would need to expose an `associatedtype Children: ViewGraphNodeChildren`
  requirement to users just trying to write regular views using the
  ``View/body`` requirement. (There is an internal `TypeSafeView` protocol that
  adds this requirement.)

- term ``View/layoutableChildren(backend:children:)``: This method is only
  implemented by the `TupleViewN` types. It essentially just gets the view's
  children as an array of ``LayoutSystem/LayoutableChild``s, the type that
  ``LayoutSystem`` works with when computing stack layouts.

- term ``View/asWidget(_:backend:)``: This method is generally pretty
  simple; just use the backend instance to produce the widget type the view
  wants to use. Views only ever have a single associated widget instance; views
  that want to change their underlying widget can use an intermediate container
  widget to satisfy this requirement.

  This method shouldn't configure the widget at all, that's handled by
  ``View/computeLayout(_:children:proposedSize:environment:backend:)`` and
  ``View/commit(_:children:layout:environment:backend:)``
  (which are guaranteed to be called between ``View/asWidget(_:backend:)``
  and the first time the view appears on screen).

- term ``View/computeLayout(_:children:proposedSize:environment:backend:)``:
  This method is the meat of most view implementations; its role is to compute
  view layouts. It may be called multiple times before the layout system settles
  on a result.

- term ``View/commit(_:children:layout:environment:backend:)``: This
  method updates the widgets to be displayed on-screen. It recieves the most
  recent result of ``View/computeLayout(_:children:proposedSize:environment:backend:)``
  as the `layout` parameter.

Internally, we have the `ElementaryView` and `TypeSafeView` protocols (which
extend ``View``) and are just nicer versions of the ``View`` protocol useful for
certain purposes. `ElementaryView` is for views with no children, and
`TypeSafeView` is identical to ``View`` but with a `Children` associated type.

### Environment

If a view or modifier wants to change the environment for all child views, it
does this in
``View/computeLayout(_:children:proposedSize:environment:backend:)`` by
passing a modified copy of the environment to child nodes when calling their
update methods.

### Preferences

Preferences are similar to environment values, except they propagate _up_ the
view graph instead of _down_. For instance, the ``PreferenceValues/onOpenURL``
preference is used to propagate external URL handlers to the top level to be
registered with the backend.

Preferences are propagated as part of the ``ViewLayoutResult`` type. Container
views can pass multiple ``ViewLayoutResult`` instances to
``ViewLayoutResult/init(size:childResults:participateInStackLayoutsWhenEmpty:preferencesOverlay:)``
to have their preferences merged automatically into a single ``PreferenceValues``
instance.

## Dynamic properties

Dynamic properties are properties of ``View``- or ``App``-conforming structs
that conform to the ``DynamicProperty`` protocol --- for example, ``State`` or
``Environment``.

There are two methods used to update these properties when view or app bodies
are recomputed: the primary one calculates the offsets to the properties at
runtime, while the fallback method uses `Mirror` to set the properties. Choosing
which method to use, as well as actually performing the update, is handled by
`DynamicPropertyUpdater`.

### Primary method

This method uses the `DynamicKeyPath` type, which can construct a "key path" at
runtime given an instance of the type and the current value of the property in
question. `DynamicKeyPath` performs some `withUnsafeBytes(of:_:)` magic to find
the property's offset within the type.

### Fallback method

The fallback method (which was the _only_ method before the
<doc:Layout-performance> PR was merged) simply uses `Mirror` to query the type's
properties, check them for conformance to ``DynamicProperty``, and update the
values. It's only used when computing offsets for the primary method fails
(usually because multiple properties of the type have the same bit-level
representation of their current values).

It can be up to 1500 times slower than the primary method (with the difference
decreasing as more stateful properties are added); this is why the primary
method is preferred wherever possible.

## Topics

- ``LayoutSystem``

- ``EitherView``
- ``EmptyView``
- ``OptionalView``
- ``HotReloadableView``

- ``ViewSize``
- ``ViewLayoutResult``
- ``ProposedViewSize``

- ``AnyWidget``

- ``PublishedMarkerProtocol``
- ``DynamicProperty``
- ``ObservableProperty``
- ``SnapshottableProperty``

- <doc:View-graph>
- <doc:Scene-graph>
- <doc:Adding-new-backend-methods>
