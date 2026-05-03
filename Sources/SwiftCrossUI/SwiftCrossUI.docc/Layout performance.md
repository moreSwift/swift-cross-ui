# Layout performance

Recently (December 2025), SwiftCrossUI's layout algorithm received a massive
overhaul, drastically boosting layout performance.

Detailed information can be found in [the PR]; it's reproduced and edited here
for convenience (written from the perspective of \@stackotter, the project's
lead maintainer).

[the PR]: https://github.com/stackotter/swift-cross-ui/pull/278

## Optimizations

### Splitting `View.update` into `View.computeLayout` and `View.commit`

Before this PR, `View` had a single update-related method, `View.update`, which
had two modes: dry run, and non-dry run. Dry runs were used to probe the sizes
of views without actually committing the layout to the underlying widgets. This
let us cache layout results (because we didn't have to worry about keeping the
widgets in sync during dry run updates). Then when the final layout was decided,
a non-dry run update would happen, during which the layout would be committed to
the underlying widgets. This architecture was inefficient because the final
non-dry run update would effectively have to compute the entire layout again,
leading to a lot of doubling up of work.

My solution was to split `View.update` into two separate requirements:
``View/computeLayout(_:children:proposedSize:environment:backend:)-2gzmc`` and
``View/commit(_:children:layout:environment:backend:)-6kzjk``.
`View.computeLayout` computes layouts as usual without committing anything to
the underlying widgets, and then `View.commit` can be called with the result of
`View.computeLayout` to efficiently commit the last computed layout of the view
and all of its children.

This lead to a 7.7x improvement for the grid benchmark, and a 2.8x improvement
for the message list benchmark.

The main reason that this was so effective is that during the commit phase, each
view gets handed its last computed result which it can blindly trust, as opposed
to each view having to recompute its desired size.

### Update layout algorithm to match SwiftUI

The layout system's biggest layout problem prior to this PR was that its stack
layout algorithm required computing the layout of each child view multiple
times. This led to exponentially worse layout performance as the amount of
nesting increased. My caching system managed to curb the exponential growth in
some situations, but it was easy to render the caching useless.

After much thinking, I discovered a few unavoidable approximations that we'd
have to adopt if we were to avoid computing the layout of each child view
multiple times per stack layout pass. I created [some edge cases] that would
behave differently depending on whether or not SwiftUI used these
approximations I had landed on. SwiftUI uses all of them.

In my opinion, these approximations lead to less desirable behaviour than
SwiftCrossUI's previous layout system, but I don't think that we can handle all
of the aforementioned edge cases well without keeping our serious performance
issues. There are likely other sets of approximations that would lead to similar
performance, but given that SwiftUI already uses these approximations, and that
I arrived at these approximations independently, I decided that they're our best
option.

Adopting said approximations went hand in hand with updating ``ViewSize`` to be
a simple size type (rather than tracking minimum size, maximum size, ideal size,
etc), and our proposed view sizes to be 2D vectors of `Double?`.

Together, adopting the approximations and simplifying our ``ViewSize``
type allowed us to reduce our effective child layout passes per stack layout
pass to 1. I say effective layout passes, because we still query the child
multiple times for its minimum, maximum, and final sizes, but together those
roughly equate to the same amount of work as a single layout pass would have if
we still had our old ``ViewSize`` type. The key to making it work out like so is
that querying the minimum, maximum or ideal size of a stack layout now only
requires computing the minimum, maximum or ideal sizes of its children
respectively. This means that minimum, maximum and ideal size requests are
linear in the number of views in the stack's view hierarchy. Additionally, our
probing child layout requests enable `environment.allowLayoutCaching`, so any
given view only ends up computing its minimum, maximum or ideal size once during
a given update cycle. This means that even though our stack layout algorithm
technically queries each child multiple times, the minimum and maximum size
requests are free if any parent view has already computed them, meaning that we
effectively only query each child once.

This lead to a 4x improvement for the grid benchmark, but somehow made our
message list benchmark twice as bad. I haven't properly investigated why that
happened, but that'd be a good place to start for future performance work, as it
would probably help us figure out exactly what became slower when introducing
this new layout system.

[some edge cases]: https://github.com/stackotter/swiftui-layout-edge-cases 

### Layout system changes

Any ``VStack`` (or height-specific) behaviours described here apply to
``HStack``s as well. I'm just being lazy.

- The minimum height of a stack layout is just the minimum heights of its
  children added together. Due to the greedy nature of the stack layout
  algorithm this can lead to the stack overflowing its frame when proposed its
  minimum size. This is most noticeable when the stack is in the layout context
  of a window (rather than inside of a decoupling container such as a
  ``ScrollView``).
- When a ``VStack`` is given a concrete height and an unspecified width, it may
  end up overflowing its own reported bounds, because we delay the final layout
  pass until the commit step. This isn't ideal, but it's what SwiftUI does, and
  it lets us keep the effective branching factor of our stack layout algorithm
  at 1.
- When a `minHeight` frame is proposed an unspecified height, it may end up with
  a different width to its child. The child gets proposed an unspecified height,
  then the frame clamps the resulting height and assumes that the child will
  keep its reported width. During commit, the frame will lay the child out again
  with the clamped height, and the child may end up growing or shrinking
  horizontally. This means that the unconstrained axis of a frame may end up not
  hugging its content even though it has no reason not to. This less than ideal
  behaviour is to keep our branching factor at 1.

### Using a custom `Mirror` replacement

I noticed that we were spending about half of each layout update in
`Mirror`-related code. I've had a `Mirror` optimisation idea in the back of my
head for a while so I gave it a go, and it basically eliminated `Mirror`
overhead for stateless views (1500x faster), and made updating dynamic
properties (e.g. ``State`` properties) 5-10x faster for views with less than 16
dynamic properties. The new system still uses `Mirror` during `ViewGraphNode`
creation, but it uses a custom technique to infer the offset of each dynamic
property discovered by the mirror. We can then reuse the offsets for the rest of
the `ViewGraphNode`'s lifecycle, and we cache the offsets for each type in a
global look up table to reduce `Mirror` usage even further.

I've documented this system quite thoroughly in
`Sources/SwiftCrossUI/State/DynamicPropertyUpdater.swift`, so if you wanna know
more about how it works, give that a read.

This made both benchmarks (grid and message list) twice as fast.

### Benchmarks

All benchmarking has been done on my M2 MacBook Air with 8GB of RAM.

- The grid benchmark is now 61 times faster.
- The message list benchmark is now 4 times faster (it didn't benefit as much
  from our branching factor reductions because it has less nesting).
- @bbrk24's private DiscordBotGUI app now has 29 times faster window resize
  handling, and a synthetic benchmark based off the core of its performance
  issues is 11.34 times faster.

### Future directions

- Investigate why `ed24b0fa` (splitting `View.update` into `computeLayout` and
  `commit`) &rarr; `e4daa213` (adopting SwiftUI's layout approximations) made
  the message list benchmark twice as slow. It may help us figure out
  inefficiencies in the new layout system.
- Optimise `ViewGraphNode` and other generic parts of the layout system for some
  linear performance gains. E.g. `TupleViewChildren` does a bunch of work
  computing information related to the state snapshotting system, even when no
  snapshots are present.
