package dev.swiftcrossui.androidbackend

import android.widget.EditText
import android.widget.TextView
import android.view.KeyEvent
import android.view.inputmethod.EditorInfo
import android.app.Activity
import android.util.Log

class CustomEditText(
    val activity: Activity,
    var onChange: SwiftAction? = null,
    var onSubmit: SwiftAction? = null
): EditText(activity) {
    init {
        setOnEditorActionListener { v, actionId, event ->
            Log.i("CustomEditText", "Editor action!")
            if (
                actionId == EditorInfo.IME_ACTION_SEND
                || actionId == EditorInfo.IME_ACTION_GO
                || actionId == EditorInfo.IME_ACTION_SEARCH
            ) {
                Log.i("CustomEditText", "Submit")
                onSubmit?.call()
                true
            } else {
                false
            }
        }
    }

    override fun onTextChanged(
        text: CharSequence, 
        start: Int, 
        lengthBefore: Int, 
        lengthAfter: Int
    ) {
        Log.i("CustomEditText", "Text changed!")
        Log.i("CustomEditText", getText().toString())
        onChange?.call()
    }
}
