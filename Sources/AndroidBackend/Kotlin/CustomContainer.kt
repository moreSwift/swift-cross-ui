package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.view.ViewGroup
import android.util.Log
import android.util.AttributeSet
import android.view.View

class CustomContainer(
    val activity: Activity
): ViewGroup(activity) {
    class LayoutParams(
        width: Int,
        height: Int,
        var x: Int,
        var y: Int
    ): ViewGroup.LayoutParams(width, height) {}

    override fun checkLayoutParams(layoutParams: ViewGroup.LayoutParams?): Boolean {
        return layoutParams is LayoutParams
    }

    override fun generateDefaultLayoutParams(): ViewGroup.LayoutParams? {
        return LayoutParams(0, 0, 0, 0)
    }

    override fun generateLayoutParams(attrs: AttributeSet?): ViewGroup.LayoutParams? {
        return LayoutParams(0, 0, 0, 0)
    }

    override fun generateLayoutParams(
        layoutParams: ViewGroup.LayoutParams?
    ): ViewGroup.LayoutParams {
        return LayoutParams(layoutParams!!.width, layoutParams!!.height, 0, 0)
    }

    override protected fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        setMeasuredDimension(layoutParams.width, layoutParams.height)

        for (i in 0..<childCount) {
            val child = getChildAt(i)
            // If you're debugging this implementation and see a child with
            // strange layoutParams dimensions (such as 1073741822, or <= 0),
            // then it's likely that there is a widget that SwiftCrossUI
            // mistakenly hasn't assigned an explicit size via
            // AndroidBackend.setSize(of:to:). This often leads to views
            // within such a view not being visible at all.
            val layoutParams = child.layoutParams
            val widthSpec = View.MeasureSpec.makeMeasureSpec(
                layoutParams.width,
                View.MeasureSpec.EXACTLY
            )
            val heightSpec = View.MeasureSpec.makeMeasureSpec(
                layoutParams.height,
                View.MeasureSpec.EXACTLY
            )
            child.measure(widthSpec, heightSpec)
        }
    }

    override protected fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        for (i in 0..<childCount) {
            val child = getChildAt(i)
            val layoutParams = child.layoutParams as LayoutParams
            child.layout(
                layoutParams.x,
                layoutParams.y,
                layoutParams.x + layoutParams.width,
                layoutParams.y + layoutParams.height
            )
        }
    }
}
