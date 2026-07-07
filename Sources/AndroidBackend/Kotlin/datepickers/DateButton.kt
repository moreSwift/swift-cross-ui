package dev.swiftcrossui.androidbackend.datepickers

import android.app.DatePickerDialog
import android.app.Dialog
import android.icu.text.DateFormat
import android.icu.util.GregorianCalendar
import android.icu.util.ULocale
import android.os.Bundle
import android.widget.Button
import androidx.appcompat.app.AppCompatDialogFragment
import androidx.fragment.app.FragmentActivity
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit

class DateButton(private val activity: FragmentActivity) : Button(activity) {
    private var minDate = Constants.defaultMinDate
    private var maxDate = Constants.defaultMaxDate

    private var _value = LocalDate.now()

    var action: (() -> Unit)? = null

    private val dialogFragment = DialogFragment()

    var value: LocalDate
        get() = _value
        set(newValue) {
            _value = newValue
            dialogFragment.datePicker?.updateDate(
                newValue.year,
                newValue.monthValue - 1,
                newValue.dayOfMonth,
            )
            updateText()
        }

    init {
        dialogFragment.button = this

        isAllCaps = false

        setOnClickListener { _ ->
            dialogFragment.show(activity.supportFragmentManager, DialogFragment.TAG)
        }

        updateText()
    }

    private fun updateText() {
        val calendar = GregorianCalendar()
        calendar.set(_value.year, _value.monthValue - 1, _value.dayOfMonth)

        setText(
            calendar
                .getDateTimeFormat(DateFormat.LONG, DateFormat.NONE, ULocale.getDefault())
                .format(calendar.time)
        )
    }

    fun setRange(min: LocalDateTime, max: LocalDateTime) {
        minDate = Constants.EPOCH.until(min, ChronoUnit.MILLIS)
        maxDate = Constants.EPOCH.until(max, ChronoUnit.MILLIS)

        dialogFragment.datePicker?.minDate = minDate
        dialogFragment.datePicker?.maxDate = maxDate
    }

    class DialogFragment : AppCompatDialogFragment() {
        companion object {
            const val TAG = "DateButton.DialogFragment"
        }

        lateinit var button: DateButton

        val datePicker
            get() = (dialog as DatePickerDialog?)?.datePicker

        override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
            val dialog =
                DatePickerDialog(
                    requireContext(),
                    DatePickerDialog.OnDateSetListener { _, year, month, day ->
                        val newValue = LocalDate.of(year, month + 1, day)
                        if (newValue != button._value) {
                            button._value = newValue
                            button.updateText()
                            button.action?.invoke()
                        }
                    },
                    button._value.year,
                    button._value.monthValue - 1,
                    button._value.dayOfMonth,
                )

            dialog.datePicker.minDate = button.minDate
            dialog.datePicker.maxDate = button.maxDate

            return dialog
        }
    }
}
