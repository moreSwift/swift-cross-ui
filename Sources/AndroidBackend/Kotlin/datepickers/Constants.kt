package dev.swiftcrossui.androidbackend.datepickers

import java.time.LocalDateTime
import java.time.temporal.ChronoUnit

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
