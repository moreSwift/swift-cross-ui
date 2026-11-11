package dev.swiftcrossui.androidbackend.activityresults

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import androidx.activity.result.contract.ActivityResultContract

// ActivityResultContracts.OpenMultipleDocuments doesn't set the starting directory.
class FilesActivityContract : ActivityResultContract<FilesActivityContract.Options, Set<Uri>>() {
    data class Options(
        val allowMultiple: Boolean,
        val mimeTypes: Array<String>,
        val rootDirectory: String?,
    )

    override fun createIntent(context: Context, input: Options) =
        Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, input.allowMultiple)

            when (input.mimeTypes.size) {
                0 -> setType("*/*")
                1 -> setType(input.mimeTypes[0])
                else -> {
                    setType("*/*")
                    putExtra(Intent.EXTRA_MIME_TYPES, input.mimeTypes)
                }
            }

            if (input.rootDirectory != null) {
                putExtra(DocumentsContract.EXTRA_INITIAL_URI, Uri.parse(input.rootDirectory))
            }
        }

    override fun parseResult(resultCode: Int, intent: Intent?): Set<Uri> {
        if (intent == null || resultCode != Activity.RESULT_OK) return emptySet<Uri>()

        val clipData = intent.clipData
        if (clipData == null) return setOfNotNull(intent.data)

        val result = hashSetOf<Uri>()

        val intentData = intent.data
        if (intentData != null) {
            result.add(intentData)
        }

        for (i in 0..<clipData.itemCount) {
            val uri = clipData.getItemAt(i).uri
            if (uri != null) {
                result.add(uri)
            }
        }

        return result
    }
}
