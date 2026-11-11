import AndroidKit
@_spi(Backends) import SwiftCrossUI

extension AndroidBackend: BackendFeatures.TapGestures {
    public func createTapGestureTarget(wrapping child: Widget, gesture: TapGesture) -> Widget {
        child
    }

    public func updateTapGestureTarget(
        _ tapGestureTarget: Widget,
        gesture: TapGesture,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        switch gesture.kind {
            case .primary:
                if environment.isEnabled {
                    tapGestureTarget.setOnClickListener(
                        ViewOnClickListener(action: action, environment: Self.env)
                            .as(AndroidKit.View.OnClickListener.self)!
                    )
                } else {
                    tapGestureTarget.setOnClickListener(nil)
                }
            case .secondary:
                if environment.isEnabled {
                    tapGestureTarget.setOnTouchListener(
                        SecondaryClickListener(action: action, environment: Self.env)
                            .as(AndroidKit.View.OnTouchListener.self)!
                    )
                } else {
                    tapGestureTarget.setOnTouchListener(nil)
                }
            case .longPress:
                if environment.isEnabled {
                    tapGestureTarget.setOnLongClickListener(
                        ViewOnLongClickListener(action: action, environment: Self.env)
                            .as(AndroidKit.View.OnLongClickListener.self)!
                    )
                } else {
                    tapGestureTarget.setOnLongClickListener(nil)
                }
        }
    }
}
