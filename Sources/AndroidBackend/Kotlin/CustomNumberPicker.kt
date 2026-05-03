package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.widget.NumberPicker

class CustomNumberPicker(activity: Activity): NumberPicker(activity) {
    init {
        minValue = 0
    }
    
    fun update(onChange: SwiftAction, options: Array<String>, isEnabled: Boolean) {
        maxValue = options.size
        displayedValues = arrayOf("") + options
        
        setOnValueChangedListener { _, _, _ ->
            onChange.call()
        }
        
        setEnabled(isEnabled)
    }
}
