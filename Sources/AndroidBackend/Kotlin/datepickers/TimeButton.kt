package dev.swiftcrossui.androidbackend.datepickers

import android.app.Dialog
import android.app.TimePickerDialog
import android.icu.util.Calendar
import android.icu.util.GregorianCalendar
import android.icu.util.ULocale
import android.os.Bundle
import android.widget.Button
import androidx.appcompat.app.AppCompatDialogFragment
import androidx.fragment.app.FragmentActivity
import java.time.LocalTime

class TimeButton(private val activity: FragmentActivity) : Button(activity) {
    private var _value = LocalTime.now()

    var action: (() -> Unit)? = null

    private val dialogFragment = DialogFragment()

    var value: LocalTime
        get() = _value
        set(newValue) {
            if (newValue != _value) {
                _value = newValue
                (dialogFragment.dialog as TimePickerDialog?)?.updateTime(
                    newValue.hour,
                    newValue.minute,
                )
                updateText()
            }
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
        calendar[Calendar.HOUR_OF_DAY] = _value.hour
        calendar[Calendar.MINUTE] = _value.minute

        setText(
            calendar
                .getDateTimeFormat(
                    android.icu.text.DateFormat.NONE,
                    android.icu.text.DateFormat.SHORT,
                    ULocale.getDefault(),
                )
                .format(calendar.time)
        )
    }

    class DialogFragment : AppCompatDialogFragment() {
        companion object {
            val TAG = "TimeButton.DialogFragment"
        }

        lateinit var button: TimeButton

        override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
            val context = requireContext()

            val dialog =
                TimePickerDialog(
                    context,
                    TimePickerDialog.OnTimeSetListener { _, hour, minute ->
                        val newValue = LocalTime.of(hour, minute)
                        if (newValue != button._value) {
                            button._value = newValue
                            button.updateText()
                            button.action?.invoke()
                        }
                    },
                    button._value.hour,
                    button._value.minute,
                    android.text.format.DateFormat.is24HourFormat(context),
                )

            return dialog
        }
    }
}
