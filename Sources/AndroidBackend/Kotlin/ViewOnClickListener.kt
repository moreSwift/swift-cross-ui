package dev.swiftcrossui.androidbackend

import android.view.View

class ViewOnClickListener(private val action: SwiftAction) : View.OnClickListener {
    override fun onClick(view: View) = action.call()
}
