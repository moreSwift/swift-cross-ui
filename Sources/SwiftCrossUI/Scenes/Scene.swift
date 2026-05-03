/// Scenes wrap views and dictate how they are displayed (e.g. in a window or
/// a menu bar).
///
/// Scenes can also be a composition of multiple child scenes instead of
/// wrapping a root view.
///
/// Implementing scenes yourself is considered an advanced use-case.
public protocol Scene {
    /// The node type used to manage this scene in the scene graph.
    associatedtype Node: SceneGraphNode where Node.NodeScene == Self
}
