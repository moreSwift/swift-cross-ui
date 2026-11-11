package dev.swiftcrossui.androidbackend.activityresults

import android.net.Uri
import androidx.activity.result.ActivityResultCallback
import dev.swiftcrossui.androidbackend.SwiftAction

class FolderActivityCallback() : ActivityResultCallback<Uri?> {
    var action: SwiftAction? = null

    var urlString: String? = null
        private set

    override fun onActivityResult(result: Uri?) {
        urlString = result?.toString()
        action?.call()
    }
}
