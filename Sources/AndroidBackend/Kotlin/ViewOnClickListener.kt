package dev.swiftcrossui.androidbackend

import android.view.View

// Adapted from: https://github.com/PureSwift/Android/blob/e980a12f6d7236bed32ff687b40dae2366ac8e91/Demo/app/src/main/java/com/pureswift/swiftandroid/ViewOnClickListener.kt#L5
class ViewOnClickListener(val action: SwiftObject): View.OnClickListener {
    external override fun onClick(view: View)
}
