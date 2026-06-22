package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.graphics.Canvas
import android.graphics.Path
import android.graphics.RectF
import android.view.Gravity
import android.view.ViewGroup
import android.widget.FrameLayout

// Based on https://stackoverflow.com/a/55457959/6253337
class CornerRadiusContainer(activity: Activity) : FrameLayout(activity) {
    private var rectF: RectF? = null
    private val path = Path()

    private var cornerRadius = 0.0f

    fun setCornerRadius(newCornerRadius: Float) {
        cornerRadius = newCornerRadius
        resetPath()
    }

    override fun generateDefaultLayoutParams() =
        FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT,
            Gravity.FILL,
        )

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        rectF = RectF(0f, 0f, w.toFloat(), h.toFloat())
        resetPath()
    }

    override fun draw(canvas: Canvas) {
        val save = canvas.save()
        canvas.clipPath(path)
        super.draw(canvas)
        canvas.restoreToCount(save)
    }

    override fun dispatchDraw(canvas: Canvas) {
        val save = canvas.save()
        canvas.clipPath(path)
        super.dispatchDraw(canvas)
        canvas.restoreToCount(save)
    }

    private fun resetPath() {
        if (rectF != null) {
            path.rewind()
            path.addRoundRect(rectF!!, cornerRadius, cornerRadius, Path.Direction.CW)
            path.close()
        }
    }
}
