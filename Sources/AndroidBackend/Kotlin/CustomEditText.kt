package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.graphics.Canvas
import android.view.inputmethod.EditorInfo
import android.widget.EditText

open class CustomEditText(activity: Activity) : EditText(activity) {
    var onChange: SwiftAction? = null

    private var onSubmit: SwiftAction? = null

    // EditText calls onTextChanged with empty string multiple times before the initial render.
    // Because it's multiple times, we can't just use a one-time flag that's cleared in
    // onTextChanged. However, they all seem to happen before the first onDraw, so we can clear it
    // there.
    private var hasBeenRendered = false

    private var isSettingText = false

    private fun isSubmitAction(action: Int) =
        action == EditorInfo.IME_ACTION_SEND ||
            action == EditorInfo.IME_ACTION_GO ||
            action == EditorInfo.IME_ACTION_SEARCH

    init {
        setOnEditorActionListener { v, actionId, event ->
            val action =
                if (actionId == EditorInfo.IME_NULL) v.imeOptions and EditorInfo.IME_MASK_ACTION
                else actionId

            if (isSubmitAction(action)) {
                onSubmit?.call()
                onSubmit != null
            } else {
                false
            }
        }
    }

    fun setOnSubmit(value: SwiftAction?) {
        onSubmit = value
        if (value != null) {
            val currentOptions = imeOptions
            if (!isSubmitAction(currentOptions and EditorInfo.IME_MASK_ACTION)) {
                imeOptions =
                    (currentOptions and EditorInfo.IME_MASK_ACTION.inv()) or
                        EditorInfo.IME_ACTION_GO
            }
        }
    }

    fun setTextFromSwift(text: String) {
        isSettingText = true
        try {
            setText(text as CharSequence)
        } finally {
            isSettingText = false
        }
    }

    protected override fun onDraw(canvas: Canvas) {
        hasBeenRendered = true
        super.onDraw(canvas)
    }

    protected override fun onTextChanged(
        text: CharSequence,
        start: Int,
        lengthBefore: Int,
        lengthAfter: Int,
    ) {
        if (!isSettingText && hasBeenRendered) {
            onChange?.call()
        }
    }
}
