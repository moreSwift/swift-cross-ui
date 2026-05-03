package dev.swiftcrossui.androidbackend

import android.view.WindowInsets
import android.app.Activity

class AndroidBackendHelpers {
    fun getWindowWidth(activity: Activity): Int {
        val windowMetrics = activity.getWindowManager().getCurrentWindowMetrics()
        val insets = windowMetrics.getWindowInsets()
                .getInsetsIgnoringVisibility(WindowInsets.Type.systemBars())
        return windowMetrics.getBounds().width() - insets.left - insets.right
    }

    fun getWindowHeight(activity: Activity): Int {
        val windowMetrics = activity.getWindowManager().getCurrentWindowMetrics()
        val insets = windowMetrics.getWindowInsets()
                .getInsetsIgnoringVisibility(WindowInsets.Type.systemBars())
        return windowMetrics.getBounds().height() - insets.top - insets.bottom
    }
}
