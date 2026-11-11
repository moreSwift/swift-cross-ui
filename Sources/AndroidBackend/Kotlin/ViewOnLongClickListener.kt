package dev.swiftcrossui.androidbackend

import android.view.View

class ViewOnLongClickListener(private val action: SwiftAction) : View.OnLongClickListener {
    override fun onLongClick(view: View): Boolean {
        action.call()
        return true
    }
}
