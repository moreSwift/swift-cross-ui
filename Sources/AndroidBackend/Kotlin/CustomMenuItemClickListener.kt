package dev.swiftcrossui.androidbackend

import android.view.MenuItem

class CustomMenuItemClickListener(private val action: SwiftAction) :
    MenuItem.OnMenuItemClickListener {
    override fun onMenuItemClick(item: MenuItem): Boolean {
        action.call()
        return true
    }
}
