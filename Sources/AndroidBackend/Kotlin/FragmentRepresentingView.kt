package dev.swiftcrossui.androidbackend

import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentContainerView
import androidx.fragment.app.FragmentManager
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver

// FragmentContainerView is final, which makes this needlessly complex.
class FragmentRepresentingView(activity: FragmentActivity) : FrameLayout(activity) {
    private val containerView = FragmentContainerView(activity)

    var swiftContext: SwiftObject? = null

    // TODO(bbrk24): Once we upgrade to androidx.fragment 1.4 or later, this could just be
    //   computed as containerView.getFragment() instead of being a stored property
    var fragment: Fragment? = null
        private set

    init {
        containerView.id = View.generateViewId()
        containerView.layoutParams =
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
                Gravity.FILL,
            )

        addView(containerView)
    }

    fun set(
        fragment: Fragment,
        manager: FragmentManager,
        onStartListener: SwiftAction,
        onDestroyListener: SwiftAction,
    ) {
        this.fragment = fragment

        val transaction = manager.beginTransaction()
        transaction.setReorderingAllowed(true)
        transaction.replace(containerView.id, fragment)
        transaction.commitNow()

        fragment.lifecycle.addObserver(
            LifecycleEventObserver { _, event ->
                when (event) {
                    Lifecycle.Event.ON_START -> onStartListener.call()
                    Lifecycle.Event.ON_DESTROY -> onDestroyListener.call()
                    else -> {}
                }
            }
        )
    }
}
