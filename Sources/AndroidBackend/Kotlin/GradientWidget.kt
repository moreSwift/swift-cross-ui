package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Shader
import android.view.View

class GradientWidget(activity: Activity) : View(activity) {
    private var path = Path()
    private var matrix: Matrix? = null
    private var fillPaint =
        Paint().apply {
            style = Paint.Style.FILL
            isAntiAlias = true
        }

    fun set(shader: Shader, width: Float, height: Float) {
        this.fillPaint.shader = shader

        // Reset path and draw rectangle for current bounds
        this.path.apply {
            rewind()
            addRect(0f, 0f, width, height, Path.Direction.CW)
        }
    }

    // Only call this method AFTER set, to ensure the shader is set.
    fun setMatrix(
        centerX: Float,
        centerY: Float,
        rotationAngle: Float,
        scaleX: Float,
        scaleY: Float,
    ) {
        // If matrix exists use it, else initialize, store and use new reference
        val localMatrix = matrix ?: Matrix().also { matrix = it }

        localMatrix.reset()
        localMatrix.postRotate(rotationAngle, centerX, centerY)
        localMatrix.postScale(scaleX, scaleY, centerX, centerY)
        this.fillPaint.shader?.setLocalMatrix(localMatrix)
    }

    override fun onDraw(canvas: Canvas) {
        canvas.drawPath(path, fillPaint)
    }
}
