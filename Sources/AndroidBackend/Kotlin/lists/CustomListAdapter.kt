package dev.swiftcrossui.androidbackend.lists

import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.ListView

// All the existing concrete adapters require an XML resource ID.
class CustomListAdapter : BaseAdapter() {
    private var views = arrayOf<View>()
    private var heights = intArrayOf()

    var isEnabled = true

    fun setViews(newViews: Array<View>, newHeights: IntArray) {
        require(newViews.size == newHeights.size)
        views = newViews
        heights = newHeights
        notifyDataSetChanged()
    }

    override fun areAllItemsEnabled() = isEnabled

    override fun isEnabled(position: Int) = isEnabled

    override fun getCount() = views.size

    override fun getItem(position: Int) = views[position]

    override fun getItemId(position: Int) = position.toLong()

    override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
        val view = views[position]

        val height = heights[position] - (parent as ListView).dividerHeight

        view.layoutParams =
            if (convertView === view) {
                // Reuse the existing layoutParams when applicable in case it's a subclass of
                // ViewGroup.LayoutParams
                val lp = convertView.layoutParams
                lp.height = height
                lp.width = parent.width
                lp
            } else {
                ViewGroup.LayoutParams(parent.width, height)
            }

        return view
    }
}
