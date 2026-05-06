package dev.swiftcrossui.androidbackend

import android.R
import android.app.Activity
import android.app.AlertDialog
import android.app.Dialog
import android.app.DialogFragment // TODO(bbrk24): Use androidx.fragment.app.DialogFragment
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

class AlertFragment(): DialogFragment() {
    companion object {
        const val TAG = "AlertFragment"
    }

    private var titleView: TextView? = null
    private var titleText: String? = null

    private var buttonContainer: LinearLayout? = null
    private var buttonTexts: Array<String>? = null

    var buttonIndex = -1
        private set

    var action: SwiftAction? = null

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val rootView = LinearLayout(context)
        rootView.orientation = LinearLayout.VERTICAL

        val titleView = TextView(
            context,
            null,
            0,
            R.style.TextAppearance_DeviceDefault_DialogWindowTitle
        )
        
        val titleLayoutParams = LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT,
            0.0f
        )
        val paddingAmount = TypedValue.convertDimensionToPixels(
            TypedValue.COMPLEX_UNIT_DIP,
            16.0f,
            resources.displayMetrics
        ).toInt()
        titleLayoutParams.setMargins(
            paddingAmount,
            paddingAmount,
            paddingAmount,
            0
        )
        
        titleView.layoutParams = titleLayoutParams
        titleView.gravity = Gravity.START or Gravity.TOP
        titleText?.let { titleView.setText(it) }
                
        this.titleView = titleView
        rootView.addView(titleView)

        val buttonContainer = LinearLayout(context)
        buttonContainer.gravity = Gravity.END

        this.buttonContainer = buttonContainer
        setButtons()
        rootView.addView(buttonContainer)

        val dialog = AlertDialog.Builder(activity)
            .setCancelable(false)
            .setView(rootView)
            .create()
        
        dialog.setCanceledOnTouchOutside(false)
        
        return dialog
    }

    override fun onDestroyView() {
        titleView = null
        buttonContainer = null
        super.onDestroyView()
    }

    fun update(
        title: String,
        buttons: Array<String>
    ) {
        titleText = title
        titleView?.setText(title)

        buttonTexts = buttons
        setButtons()
    }
    
    fun show(activity: Activity) {
        show(activity.fragmentManager, TAG)
    }

    private fun setButtons() {
        val buttonTexts = buttonTexts ?: return
        val buttonContainer = buttonContainer ?: return

        buttonContainer.removeAllViews()

        buttonContainer.orientation =
            if (buttonTexts.size > 3) LinearLayout.VERTICAL
            else LinearLayout.HORIZONTAL

        for ((i, text) in buttonTexts.withIndex()) {
            val button = Button(context)
            button.setText(text)
            button.setBackgroundColor(0) // 0 = transparent

            button.setOnClickListener { _ ->
                buttonIndex = i
                dismiss()
                action?.call()
            }
            
            buttonContainer.addView(button)
        }
    }
}
