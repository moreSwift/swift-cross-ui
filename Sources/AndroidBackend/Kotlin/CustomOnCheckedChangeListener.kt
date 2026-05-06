package dev.swiftcrossui.androidbackend

import android.widget.CompoundButton

class CustomOnCheckedChangeListener(
    private val action: SwiftAction
): CompoundButton.OnCheckedChangeListener {
    override fun onCheckedChanged(
        buttonView: CompoundButton,
        isChecked: Boolean
    ) {
        action.call()
    }
}
