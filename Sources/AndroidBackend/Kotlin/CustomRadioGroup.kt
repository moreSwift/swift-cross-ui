package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.graphics.Typeface
import android.util.TypedValue
import android.widget.RadioButton
import android.widget.RadioGroup

class CustomRadioGroup(activity: Activity) : RadioGroup(activity) {
    fun getSelectedOption() = getCheckedRadioButtonId()

    fun update(
        onChange: SwiftAction,
        options: Array<String>,
        isEnabled: Boolean,
        color: Int,
        fontSize: Float,
        lineHeight: Int,
        typeface: Typeface,
    ) {
        val optionCount = childCount
        if (optionCount < options.size) {
            for (i in 0..<childCount) {
                val button = getChildAt(i) as RadioButton
                button.text = options[i]
                button.setEnabled(isEnabled)
                button.setTextColor(color)
                button.setTextSize(TypedValue.COMPLEX_UNIT_SP, fontSize)
                button.lineHeight = lineHeight
                button.typeface = typeface
            }

            for (i in optionCount..<options.size) {
                val button = RadioButton(context)
                button.text = options[i]
                button.id = i
                button.setEnabled(isEnabled)
                button.setTextColor(color)
                button.setTextSize(TypedValue.COMPLEX_UNIT_SP, fontSize)
                button.lineHeight = lineHeight
                button.typeface = typeface
                addView(button)
            }
        } else {
            for (i in 0..<options.size) {
                val button = getChildAt(i) as RadioButton
                button.text = options[i]
                button.setEnabled(isEnabled)
                button.setTextColor(color)
                button.setTextSize(TypedValue.COMPLEX_UNIT_SP, fontSize)
                button.lineHeight = lineHeight
                button.typeface = typeface
            }

            for (i in (options.size..<optionCount).reversed()) {
                removeViewAt(i)
            }
        }

        setOnCheckedChangeListener { _, _ -> onChange.call() }
    }

    fun selectOption(index: Int) {
        val oldIndex = getCheckedRadioButtonId()
        if (oldIndex == index) return

        if (oldIndex >= 0) {
            val oldButton = getChildAt(oldIndex) as RadioButton
            oldButton.isChecked = false
        }

        if (index >= 0) {
            val newButton = getChildAt(index) as RadioButton
            newButton.isChecked = true
        }
    }
}
