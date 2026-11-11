package dev.swiftcrossui.androidbackend

import android.view.HapticFeedbackConstants
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import kotlin.math.hypot

class SecondaryClickListener(private val action: SwiftAction) : View.OnTouchListener {
    private var buttonState: Int = 0
    // Using NaN instead of null to avoid needing !!s
    private var x = Float.NaN
    private var y = Float.NaN
    private var isTracking = false

    private fun reset() {
        buttonState = 0
        x = Float.NaN
        y = Float.NaN
        isTracking = false
    }

    override fun onTouch(v: View, event: MotionEvent) =
        when (event.actionMasked) {
            MotionEvent.ACTION_CANCEL -> {
                reset()
                false
            }

            MotionEvent.ACTION_DOWN,
            MotionEvent.ACTION_POINTER_DOWN -> {
                buttonState = event.buttonState
                x = event.x
                y = event.y
                isTracking = true

                true
            }

            MotionEvent.ACTION_MOVE -> {
                if (isTracking) {
                    val slop = ViewConfiguration.get(v.context).getScaledTouchSlop().toFloat()
                    val hasMoved = hypot(x - event.x, y - event.y) >= slop

                    isTracking = !hasMoved

                    when (event.getToolType(0)) {
                        MotionEvent.TOOL_TYPE_MOUSE,
                        MotionEvent.TOOL_TYPE_STYLUS -> buttonState = event.buttonState

                        else ->
                            if (
                                isTracking &&
                                    event.eventTime - event.downTime >=
                                        ViewConfiguration.getLongPressTimeout()
                            ) {
                                v.performHapticFeedback(HapticFeedbackConstants.CONTEXT_CLICK)
                                action.call()
                                isTracking = false
                            }
                    }

                    !hasMoved
                } else false
            }

            MotionEvent.ACTION_UP,
            MotionEvent.ACTION_POINTER_UP -> {
                val isSecondaryAction =
                    isTracking &&
                        when (event.getToolType(0)) {
                            MotionEvent.TOOL_TYPE_MOUSE ->
                                buttonState and MotionEvent.BUTTON_SECONDARY != 0
                            MotionEvent.TOOL_TYPE_STYLUS ->
                                buttonState and MotionEvent.BUTTON_STYLUS_SECONDARY != 0
                            else -> false // handled by ACTION_MOVE
                        }

                if (isSecondaryAction) {
                    v.performHapticFeedback(HapticFeedbackConstants.CONTEXT_CLICK)
                    action.call()
                }

                reset()
                isSecondaryAction
            }

            else -> false
        }
}
