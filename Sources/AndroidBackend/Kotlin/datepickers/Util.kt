package dev.swiftcrossui.androidbackend.datepickers

import java.text.DateFormat
import java.text.SimpleDateFormat
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit
import java.util.Locale

object Constants {
    val EPOCH = LocalDateTime.of(1970, 1, 1, 0, 0)

    val defaultMinDate =
        try {
            EPOCH.until(LocalDateTime.MIN, ChronoUnit.MILLIS)
        } catch (_: ArithmeticException) {
            Long.MIN_VALUE
        }

    val defaultMaxDate =
        try {
            EPOCH.until(LocalDateTime.MAX, ChronoUnit.MILLIS)
        } catch (_: ArithmeticException) {
            Long.MAX_VALUE
        }
}

fun is24HourLocale(locale: Locale): Boolean {
    // Based on
    // https://cs.android.com/android/platform/superproject/+/android-latest-release:frameworks/base/core/java/android/text/format/DateFormat.java;drc=8b53f4656c9760da39d5b55b86dde5b311ed131d;l=214

    val natural = DateFormat.getTimeInstance(DateFormat.LONG, locale)
    if (natural !is SimpleDateFormat) return false

    var insideQuote = false
    for (c in natural.toPattern()) {
        if (c == '\'') {
            insideQuote = !insideQuote
        } else if (!insideQuote && c == 'H') {
            return true
        }
    }

    return false
}
