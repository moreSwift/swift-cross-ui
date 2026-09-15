## Safe areas

UIKitBackend currently positions all views relative to their enclosing container's safe area anchors (using constraints).

This can cause issues when implementing new native container views that impose their own safe areas (such as UISplitViewController which uses safe areas to reserve space for its navigation bar). You have to remember to subtract the safe areas from size proposals before passing them on to the container's children, otherwise the children will overflow the container downwards and to the right (depending on the top and left safe areas)

- Subtract container safe areas before passing on size proposals to children, and add the safe areas back on when returning the container's layout size

## Debugging views that aren't receiving user interactions

I've spent hours debugging interactivity issues in UIKitBackend, particularly in relation to our NavigationSplitView implementation. I was finding that button clicks weren't registering, even though I could clearly see the button and it had layed out correctly. The cause turned out to be a parent container that had been allocated a 0x0 size, which was causing the entire subtree of views to be ignored during hit testing.

- Ensure that all parent containers include the problematic point (by using the Xcode view hierarchy debugger)

## UINavigationController

### Pushed view controllers don't properly update until transition completes

When pushing a UIViewController onto a UINavigationController, the pushee doesn't get properly updated until the transition completes. This means that if you push a UINavigationController onto a UINavigationController, the inner navigation controller's safe area for its own navigation bar won't get initialized until after the transition. This makes the content of the inner navigation controller jump down about 64 pixels when the transition completes, because the inner navigation controller finally realises that it needs to reserve space for its navigation bar.

The solution that I've found for SwiftCrossUI is to just not push UINavigationControllers onto UINavigationControllers. The only reason that we were doing that was because it was the most convenient approach given the utility classes that we had already built out during previous NavigationSplitView implementation efforts. By pushing a regular UINavigationController, we get proper safe area handling.

Note that this is about safe areas imposed by pushees, not by the navigation controller itself. The navigation controller correctly applies its own safe area to the pushee before the transition begins.

- Don't push UINavigationControllers onto UINavigationControllers (at least, not directly)
