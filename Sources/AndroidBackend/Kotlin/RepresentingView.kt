package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout

class RepresentingView(activity: Activity) : FrameLayout(activity) {
    var swiftContext: SwiftObject? = null

    private var _child: View? = null

    var child: View?
        get() = _child
        set(value) {
            removeAllViews()
            _child = value
            value?.let {
                addView(it)

                it.layoutParams =
                    FrameLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        Gravity.FILL,
                    )
            }
        }
}
