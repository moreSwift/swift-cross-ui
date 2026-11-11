package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.HorizontalScrollView
import android.widget.ScrollView

class ScrollContainer(activity: Activity, child: View) : FrameLayout(activity) {
    init {
        child.layoutParams =
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
                Gravity.FILL,
            )

        addView(child)
    }

    private val verticalScrollView =
        ScrollView(activity).apply {
            layoutParams =
                FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    Gravity.FILL,
                )
        }

    private val horizontalScrollView =
        HorizontalScrollView(activity).apply {
            layoutParams =
                FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    Gravity.FILL,
                )
        }

    private var isVerticalScrollViewAdded = false
    private var isHorizontalScrollViewAdded = false

    fun updateScroll(vertical: Boolean, horizontal: Boolean) {
        if (isHorizontalScrollViewAdded && !horizontal) {
            val horizontalScrollViewChild = horizontalScrollView.getChildAt(0)
            val horizontalScrollViewParent = horizontalScrollView.parent as FrameLayout
            horizontalScrollView.removeView(horizontalScrollViewChild)
            horizontalScrollViewParent.removeView(horizontalScrollView)
            horizontalScrollViewParent.addView(horizontalScrollViewChild)
            isHorizontalScrollViewAdded = false
        }

        if (isVerticalScrollViewAdded && !vertical) {
            val verticalScrollViewChild = verticalScrollView.getChildAt(0)
            val verticalScrollViewParent = verticalScrollView.parent as FrameLayout
            verticalScrollView.removeView(verticalScrollViewChild)
            verticalScrollViewParent.removeView(verticalScrollView)
            verticalScrollViewParent.addView(verticalScrollViewChild)
            isVerticalScrollViewAdded = false
        }

        if (!isHorizontalScrollViewAdded && horizontal) {
            val ownChild = getChildAt(0)
            removeView(ownChild)
            horizontalScrollView.addView(ownChild)
            addView(horizontalScrollView)
            isHorizontalScrollViewAdded = true
        }

        if (!isVerticalScrollViewAdded && vertical) {
            val ownChild = getChildAt(0)
            removeView(ownChild)
            verticalScrollView.addView(ownChild)
            addView(verticalScrollView)
            isVerticalScrollViewAdded = true
        }
    }
}
