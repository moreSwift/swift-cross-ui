package dev.swiftcrossui.androidbackend.lists

import android.view.View
import android.widget.AdapterView
import dev.swiftcrossui.androidbackend.SwiftAction

class ListItemSelectedListener : AdapterView.OnItemSelectedListener {
    var action: SwiftAction? = null

    var selectedPosition = AdapterView.INVALID_POSITION
        private set

    private var oldSelectedPosition = AdapterView.INVALID_POSITION

    override fun onNothingSelected(parent: AdapterView<*>) {
        onItemSelected(parent, null, AdapterView.INVALID_POSITION, AdapterView.INVALID_ROW_ID)
    }

    override fun onItemSelected(parent: AdapterView<*>, view: View?, position: Int, id: Long) {
        selectedPosition = position
        if (position != oldSelectedPosition) action?.call()
        oldSelectedPosition = position
    }
}
