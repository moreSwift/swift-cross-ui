package dev.swiftcrossui.androidbackend

import android.app.Activity
import com.google.android.material.slider.Slider

class CustomSlider(activity: Activity) : Slider(activity) {
    var action: SwiftAction? = null

    private var places = 7

    init {
        addOnChangeListener { _, _, fromUser ->
            if (fromUser) {
                action?.call()
            }
        }

        isTickVisible = false

        setLabelFormatter { String.format("%.${places}f", it.toDouble()) }
    }

    fun setBounds(min: Float, max: Float, places: Int) {
        this.places = places
        valueFrom = min
        valueTo = max
    }
}
