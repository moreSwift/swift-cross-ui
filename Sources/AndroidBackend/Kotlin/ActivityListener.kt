package dev.swiftcrossui.androidbackend

import android.content.Intent
import android.content.res.Configuration
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner

class ActivityListener(val activity: FragmentActivity, val delegate: SwiftObject) {
    init {
        activity.lifecycle.addObserver(
            object : DefaultLifecycleObserver {
                override fun onStart(owner: LifecycleOwner) = this@ActivityListener.onStart()

                override fun onResume(owner: LifecycleOwner) = this@ActivityListener.onResume()

                override fun onPause(owner: LifecycleOwner) = this@ActivityListener.onPause()

                override fun onStop(owner: LifecycleOwner) = this@ActivityListener.onStop()

                override fun onDestroy(owner: LifecycleOwner) = this@ActivityListener.onDestroy()
            }
        )

        activity.addOnNewIntentListener(::onNewIntent)
        activity.addOnConfigurationChangedListener(::onConfigurationChanged)
    }

    external fun onStart()

    external fun onResume()

    external fun onPause()

    external fun onStop()

    external fun onDestroy()

    external fun onNewIntent(intent: Intent)

    external fun onConfigurationChanged(configuration: Configuration)
}
