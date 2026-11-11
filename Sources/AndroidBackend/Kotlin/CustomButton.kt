package dev.swiftcrossui.androidbackend

import android.R
import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.FrameLayout

class CustomButton(activity: Activity) : FrameLayout(activity) {
    var buttonStyle: Short = ButtonStyle.BORDERED
    var action: SwiftAction? = null

    private val density = resources.displayMetrics.density

    companion object {
        const val horizontalPadding = 11
        const val verticalPadding = 5

        const val borderedButtonStyle = ButtonStyle.BORDERED
        const val plainButtonStyle = ButtonStyle.PLAIN
        const val borderlessButtonStyle = ButtonStyle.BORDERLESS

        private val BORDERED_ATTR = R.attr.selectableItemBackground
        private val BORDERLESS_ATTR = R.attr.selectableItemBackgroundBorderless

        private fun getDrawable(context: Context, attrId: Int): Drawable? {
            val outValue = TypedValue()
            context.theme.resolveAttribute(attrId, outValue, true)
            return context.getDrawable(outValue.resourceId)
        }
    }

    object ButtonStyle {
        const val BORDERED: Short = 0
        const val PLAIN: Short = 1
        const val BORDERLESS: Short = 2
    }

    init {
        isClickable = true
        isFocusable = true

        setOnClickListener { view -> if (isEnabled) this.action?.call() }
    }

    fun set(action: SwiftAction, buttonStyle: Short, isEnabled: Boolean, isDarkMode: Boolean) {
        this.buttonStyle = buttonStyle
        this.action = action
        this.isEnabled = isEnabled

        updateButtonStyle(isDarkMode)
    }

    fun updateButtonStyle(isDarkMode: Boolean) {
        // Why 38% opacity was chosen:
        // https://m2.material.io/design/interaction/states.html#disabled
        alpha = if (isEnabled) 1.0f else 0.38f

        val borderedBackground by lazy {
            GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                setColor(getAdaptiveGray(isDarkMode))
                cornerRadius = 3f * resources.displayMetrics.density
            }
        }

        val convertedHorizontalPadding = (horizontalPadding * density).toInt()
        val convertedVerticalPadding = (verticalPadding * density).toInt()

        when (buttonStyle) {
            ButtonStyle.BORDERED -> {
                background = borderedBackground
                setPadding(
                    convertedHorizontalPadding,
                    convertedVerticalPadding,
                    convertedHorizontalPadding,
                    convertedVerticalPadding,
                )
            }
            ButtonStyle.PLAIN,
            ButtonStyle.BORDERLESS -> {
                background = null
                setPadding(0, 0, 0, 0)
            }
            else -> {
                background = borderedBackground
                setPadding(
                    convertedHorizontalPadding,
                    convertedVerticalPadding,
                    convertedHorizontalPadding,
                    convertedVerticalPadding,
                )
            }
        }

        val foregroundAttr =
            when (buttonStyle) {
                ButtonStyle.PLAIN,
                ButtonStyle.BORDERLESS -> BORDERLESS_ATTR
                else -> BORDERED_ATTR
            }

        // Sets or removes the press ripple effect.
        if (isEnabled) {
            foreground = getDrawable(context, foregroundAttr)
        } else {
            foreground = null
        }
    }

    override fun onInitializeAccessibilityNodeInfo(info: AccessibilityNodeInfo) {
        super.onInitializeAccessibilityNodeInfo(info)
        info.className = "android.widget.Button"
    }

    override fun addView(child: View, index: Int, params: ViewGroup.LayoutParams) {
        val frameParams = params as? LayoutParams ?: LayoutParams(params)

        frameParams.gravity = Gravity.CENTER
        frameParams.width = ViewGroup.LayoutParams.WRAP_CONTENT
        frameParams.height = ViewGroup.LayoutParams.WRAP_CONTENT

        super.addView(child, index, frameParams)
    }

    fun getAdaptiveGray(isDarkMode: Boolean): Int {
        return if (isDarkMode) Color.DKGRAY else Color.LTGRAY
    }
}
