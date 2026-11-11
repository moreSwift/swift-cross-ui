package dev.swiftcrossui.androidbackend.activityresults

import android.net.Uri
import androidx.activity.result.ActivityResultCallback
import dev.swiftcrossui.androidbackend.SwiftAction

class FilesActivityCallback() : ActivityResultCallback<Set<Uri>> {
    var action: SwiftAction? = null

    lateinit var urlStrings: Array<String>
        private set

    override fun onActivityResult(result: Set<Uri>) {
        urlStrings = result.map { it.toString() }.toTypedArray()
        action?.call()
    }
}
