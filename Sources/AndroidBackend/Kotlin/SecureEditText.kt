package dev.swiftcrossui.androidbackend

import android.app.Activity
import android.text.Editable
import android.text.InputType
import android.text.method.KeyListener
import android.view.KeyEvent
import android.view.View

/*
Input type is a bitfield consisting of a "class" (text, number, phone), a "variation" (name, URL,
email), and some flags. For the most part, it just affects the IME, telling it which on-screen
keyboard to use and how to handle autocorrect. However, the text and number classes also have a
variation for "password," which additionally obscures the input. This makes it harder to control the
keyboard type for passwords, since you can't set the variation to both "email" and "password" at the
same time. It is possible to give the text field itself and the IME separate input types if you add
a custom keyListener, so that's what this class does.
*/

class SecureEditText(activity: Activity) : CustomEditText(activity) {
    private var keyboardType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD

    override fun setInputType(type: Int) {
        keyboardType = type
        if (type and InputType.TYPE_MASK_CLASS == InputType.TYPE_CLASS_NUMBER) {
            super.setInputType(
                InputType.TYPE_CLASS_NUMBER or
                    (type and InputType.TYPE_MASK_FLAGS) or
                    InputType.TYPE_NUMBER_VARIATION_PASSWORD
            )
        } else {
            super.setInputType(InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD)
        }

        if (keyListener !is CustomKeyListener) {
            keyListener = CustomKeyListener(keyListener)
        }
    }

    private inner class CustomKeyListener(private val base: KeyListener?) : KeyListener {
        override fun getInputType() = keyboardType

        override fun clearMetaKeyState(view: View?, content: Editable?, states: Int) {
            base?.clearMetaKeyState(view, content, states)
        }

        override fun onKeyDown(view: View?, text: Editable?, keyCode: Int, event: KeyEvent?) =
            base?.onKeyDown(view, text, keyCode, event) ?: false

        override fun onKeyUp(view: View?, text: Editable?, keyCode: Int, event: KeyEvent?) =
            base?.onKeyUp(view, text, keyCode, event) ?: false

        override fun onKeyOther(view: View?, text: Editable?, event: KeyEvent?) =
            base?.onKeyOther(view, text, event) ?: false
    }
}
