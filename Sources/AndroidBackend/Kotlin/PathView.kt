package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.view.View

class PathView(activity: Activity) : View(activity) {
    private lateinit var path: Path
    private lateinit var fillPaint: Paint
    private lateinit var strokePaint: Paint

    fun set(path: Path, fillPaint: Paint, strokePaint: Paint) {
        this.path = path
        this.fillPaint = fillPaint
        this.strokePaint = strokePaint
    }

    override fun onDraw(canvas: Canvas) {
        canvas.drawPath(path, fillPaint)
        canvas.drawPath(path, strokePaint)
    }
}
