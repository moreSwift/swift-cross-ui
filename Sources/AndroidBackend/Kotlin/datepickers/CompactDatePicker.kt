package dev.swiftcrossui.androidbackend.datepickers

import androidx.fragment.app.FragmentActivity
import java.time.LocalDateTime

class CompactDatePicker(activity: FragmentActivity) : AbstractDatePicker(activity) {
    protected override val dateView = DateButton(activity)
    protected override val timeView = TimeButton(activity)

    init {
        val childAction: () -> Unit = {
            // Clamp to range before calling through to Swift
            timeView.value = value.toLocalTime()
            action?.call()
        }

        dateView.action = childAction
        timeView.action = childAction

        addView(dateView)
        addView(timeView)
    }

    protected override var currentValue: LocalDateTime
        get() = LocalDateTime.of(dateView.value, timeView.value)
        set(newValue) {
            dateView.value = newValue.toLocalDate()
            timeView.value = newValue.toLocalTime()
        }

    protected override fun applyRange(min: LocalDateTime, max: LocalDateTime) {
        dateView.setRange(min, max)
        timeView.value = value.toLocalTime()
    }

    fun setForegroundColor(color: Int) {
        dateView.setTextColor(color)
        timeView.setTextColor(color)
    }
}
