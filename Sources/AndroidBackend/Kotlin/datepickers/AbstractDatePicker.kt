package dev.swiftcrossui.androidbackend.datepickers

import android.content.Context
import android.view.View
import android.widget.LinearLayout
import dev.swiftcrossui.androidbackend.SwiftAction
import java.time.LocalDateTime

abstract class AbstractDatePicker(context: Context) : LinearLayout(context) {
    companion object {
        const val COMPONENT_DATE = 0x1C
        const val COMPONENT_HOUR_MINUTE = 0x60
        const val COMPONENT_SECOND = 0x80
        const val COMPONENT_TIME = COMPONENT_HOUR_MINUTE or COMPONENT_SECOND
        const val COMPONENT_MASK = COMPONENT_DATE or COMPONENT_HOUR_MINUTE or COMPONENT_SECOND
    }

    var action: SwiftAction? = null

    protected abstract val dateView: View
    protected abstract val timeView: View

    private var minDate = LocalDateTime.MIN
    private var maxDate = LocalDateTime.MAX

    protected abstract var currentValue: LocalDateTime

    init {
        orientation = LinearLayout.HORIZONTAL
    }

    protected abstract fun applyRange(min: LocalDateTime, max: LocalDateTime)

    var value: LocalDateTime
        get() = currentValue.coerceIn(minDate, maxDate)
        set(newValue) {
            currentValue = newValue.coerceIn(minDate, maxDate)
        }

    fun setRange(min: LocalDateTime, max: LocalDateTime) {
        minDate = min
        maxDate = max
        applyRange(min, max)
    }

    fun setComponents(components: Int) {
        require(components and COMPONENT_MASK == components)
        require(components != 0)

        dateView.visibility = if (components and COMPONENT_DATE != 0) View.VISIBLE else View.GONE
        timeView.visibility = if (components and COMPONENT_TIME != 0) View.VISIBLE else View.GONE
    }

    override fun setEnabled(enabled: Boolean) {
        dateView.isEnabled = enabled
        timeView.isEnabled = enabled
        super.setEnabled(enabled)
    }
}
