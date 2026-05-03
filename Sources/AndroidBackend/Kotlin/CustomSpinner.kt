package dev.swiftcrossui.androidbackend

import android.R
import android.app.Activity
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Spinner

class CustomSpinner(activity: Activity): Spinner(activity, Spinner.MODE_DROPDOWN) {
    // I'm not 100% sure why, but without this (and the check in onItemSelected),
    // update() was being spammed, making it impossible for the user to select anything.
    private var oldSelectedPosition = AdapterView.INVALID_POSITION
    
    fun update(onChange: SwiftAction, options: Array<String>, isEnabled: Boolean) {
        setAdapter(ArrayAdapter(context, R.layout.simple_list_item_1, options))
        
        setOnItemSelectedListener(object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(
                parent: AdapterView<*>,
                view: View?,
                position: Int,
                id: Long
            ) {
                if (position != oldSelectedPosition) {
                    onChange.call()
                }
                oldSelectedPosition = position
            }
            
            override fun onNothingSelected(parent: AdapterView<*>) {
                onItemSelected(
                    parent,
                    null,
                    AdapterView.INVALID_POSITION,
                    AdapterView.INVALID_ROW_ID
                )
            }
        })
        
        setEnabled(isEnabled)
    }
    
    fun selectOption(index: Int) {
        setSelection(index)
        oldSelectedPosition = index
    }
}
