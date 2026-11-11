package dev.swiftcrossui.androidbackend.datepickers

import android.content.Context
import android.icu.util.Calendar
import android.widget.DatePicker
import android.widget.TimePicker
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit
import java.util.Locale

class GraphicalDatePicker(context: Context) : AbstractDatePicker(context) {
    protected override val dateView = DatePicker(context)
    protected override val timeView = TimePicker(context)

    protected override var currentValue = LocalDateTime.now()

    private var locale = Locale.getDefault()

    init {
        dateView.setOnDateChangedListener { _, year, month, day ->
            currentValue = currentValue.withYear(year).withMonth(month + 1).withDayOfMonth(day)

            adjustTimeForBounds()

            action?.call()
        }

        timeView.setOnTimeChangedListener { _, hour, minute ->
            currentValue = currentValue.withHour(hour).withMinute(minute)

            adjustTimeForBounds()

            action?.call()
        }

        addView(dateView)
        addView(timeView)
    }

    protected override fun applyRange(min: LocalDateTime, max: LocalDateTime) {
        dateView.minDate = Constants.EPOCH.until(min, ChronoUnit.MILLIS)
        dateView.maxDate = Constants.EPOCH.until(max, ChronoUnit.MILLIS)

        adjustTimeForBounds()
    }

    private fun adjustTimeForBounds() {
        val time = value
        timeView.hour = time.hour
        timeView.minute = time.minute
    }

    override fun setLocale(locale: Locale) {
        if (locale == this.locale) return
        this.locale = locale
        dateView.firstDayOfWeek = Calendar.getInstance(locale).firstDayOfWeek
        timeView.setIs24HourView(is24HourLocale(locale))
    }
}
