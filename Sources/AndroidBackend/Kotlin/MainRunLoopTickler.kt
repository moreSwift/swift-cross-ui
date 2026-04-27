package dev.swiftcrossui.androidbackend

import android.os.Handler
import android.os.Looper

class MainRunLoopTickler {
    fun start() {
        loop()
    }

    fun loop(nextDelayMilliseconds: Int? = null) {
        val delay = nextDelayMilliseconds ?: getDefaultDelay()
        Handler(Looper.getMainLooper()).postDelayed({
            val nextDelay: Int = tickle()
            loop(nextDelay)
        }, delay.toLong())
    }

    external fun tickle(): Int

    external fun getDefaultDelay(): Int
}
