package dev.swiftcrossui.compose

import android.util.Log
import android.util.TypedValue
import android.os.Handler
import android.os.Looper
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshots.SnapshotStateMap
import androidx.core.view.WindowInsetsCompat
import java.util.concurrent.ConcurrentLinkedQueue

/**
 * AndroidComposeBackendHost
 *
 * The single object Swift talks to via JNI/swift-java.
 *
 * Threading contract
 * ------------------
 * All writes to [nodes] MUST happen on the main thread — Compose's snapshot
 * system is not thread-safe for writes. We enforce this with [mainHandler].
 *
 * Swift calls come in on whatever thread the Swift run loop uses, so every
 * @JvmStatic entry point posts to main before touching [nodes].
 *
 * Events go the other direction: Compose pushes to [eventQueue] (thread-safe),
 * and Swift drains it from its own polling loop.
 */
object AndroidComposeBackendHost {

    var applicationContext: android.content.Context? = null

    var windowInsets: WindowInsetsCompat? = null

    var treeReady by mutableStateOf(false)

    val nodeParent: SnapshotStateMap<Int, Int> = mutableStateMapOf()

    val nodes: SnapshotStateMap<Int, WidgetNode> = mutableStateMapOf()

    /** The ID of the top-level node Swift wants rendered. -1 = nothing yet. */
    private val _rootNodeId = mutableIntStateOf(-1)
    var rootNodeId: Int
        get() = _rootNodeId.value
        private set(value) { _rootNodeId.value = value }

    private val mainHandler = Handler(Looper.getMainLooper())

    @JvmStatic
    fun initialize(context: android.content.Context) {
        applicationContext = context.applicationContext
    }

    /**
     * Create a new node with the given type. Must be followed by property/child
     * calls before [setRootNode] makes it visible.
     */
    @JvmStatic
    fun createNode(id: Int, type: String) {
        onMain { nodes[id] = WidgetNode(id = id, type = type) }
    }

    /**
     * Set or overwrite a single string property on an existing node.
     * Compose sees this as a new WidgetNode value and recomposes affected subtrees.
     */
    @JvmStatic
    fun setProperty(id: Int, key: String, value: String) {
        onMain {
            val existing = nodes[id] ?: return@onMain
            nodes[id] = existing.copy(
                properties = existing.properties + (key to value)
            )
        }
    }

    /**
     * Replace the entire ordered child list of a container.
     * Swift calls this when the child count changes.
     */
    @JvmStatic
    fun setChildren(parentId: Int, childIds: IntArray) {
        onMain {
            val existing = nodes[parentId] ?: return@onMain
            val newSize = childIds.size
            // Preserve positions for valid indices; setPosition will update them
            val retained = existing.childPositions.filter { (idx, _) -> idx < newSize }
            nodes[parentId] = existing.copy(
                children = childIds.toList(),
                childPositions = retained
            )
        }
    }

    /**
     * Set the absolute position of the child at [index] inside [containerId].
     * Called by SCUI after it finishes computing layout for a container.
     * [x] and [y] are in dp.
     */
    @JvmStatic
    fun setPosition(containerId: Int, index: Int, x: Int, y: Int) {
        onMain {
            val existing = nodes[containerId] ?: return@onMain
            nodes[containerId] = existing.copy(
                childPositions = existing.childPositions + (index to Pair(x, y))
            )
        }
    }

    /**
     * Declare which node is the root. Triggers a full re-render from that node.
     * Safe to call multiple times (e.g. after a navigation push).
     */
    @JvmStatic
    fun setRootNode(id: Int) {
        onMain {
            rootNodeId = id
            // Rebuild nodeParent from final tree
            nodeParent.clear()
            fun traverse(nodeId: Int) {
                val node = nodes[nodeId] ?: return
                node.children.forEach { childId ->
                    if (!nodeParent.containsKey(childId)) {  // first parent wins
                        nodeParent[childId] = nodeId
                    }
                    traverse(childId)
                }
            }
            traverse(id)
            treeReady = true
        }
    }

    /**
     * Remove a node from the tree. Swift is responsible for removing it from
     * its parent's child list first to avoid dangling references.
     */
    @JvmStatic
    fun removeNode(id: Int) {
        onMain { nodes.remove(id) }
    }

    /**
     * Wipe everything. Call before tearing down the activity or during hot-reload.
     */
    @JvmStatic
    fun clearAll() {
        onMain {
            nodes.clear()
            rootNodeId = -1
        }
    }

    /**
     * Thread-safe event queue. Each entry is a JSON string:
     *   {"id": 42, "type": "click", "payload": ""}
     *   {"id": 7,  "type": "change", "payload": "hello"}
     *   {"id": 3,  "type": "toggle", "payload": "true"}
     *   {"id": 9,  "type": "slide",  "payload": "0.75"}
     */
    private val eventQueue = ConcurrentLinkedQueue<String>()

    /**
     * Dequeue one event and return it as a JSON string, or null if the queue is
     * empty. Swift calls this in a tight loop on a background thread.
     */
    @JvmStatic
    fun pollEvent(): String? = eventQueue.poll()

    /**
     * How many events are waiting. Swift can use this to decide whether to spin
     * or yield.
     */
    @JvmStatic
    fun pendingEventCount(): Int = eventQueue.size

    internal fun pushEvent(widgetId: Int, eventType: String, payload: String = "") {
        // Escape payload for JSON — replace backslash then double-quote
        val safe = payload.replace("\\", "\\\\").replace("\"", "\\\"")
        eventQueue.offer("""{"id":$widgetId,"type":"$eventType","payload":"$safe"}""")
    }

    private inline fun onMain(crossinline block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            block()
        } else {
            mainHandler.post { block() }
        }
    }

    @JvmStatic
    fun measureText(text: String, fontSizeSp: Float, maxWidthDp: Int): String {
        val ctx = applicationContext ?: return "100,20"
        val density = ctx.resources.displayMetrics.density
        @Suppress("DEPRECATION")
        val scaledDensity = ctx.resources.displayMetrics.scaledDensity
        val paint = android.text.TextPaint().apply {
            textSize = fontSizeSp * scaledDensity
        }
        val maxWidthPx = if (maxWidthDp > 0) (maxWidthDp * density).toInt() else Int.MAX_VALUE
        val layout = android.text.StaticLayout.Builder
            .obtain(text, 0, text.length, paint, maxWidthPx)
            .build()
        val maxLineWidth = (0 until layout.lineCount).maxOfOrNull { layout.getLineWidth(it) } ?: 0f
        val naturalWidthDp = (maxLineWidth / density).toInt() + 1
        val heightDp = (layout.height / density).toInt()
        return "$naturalWidthDp,$heightDp"
    }

    @JvmStatic
    fun measureWidget(id: Int): String {
        val ctx = applicationContext ?: return "0,0"
        val density = ctx.resources.displayMetrics.density
        val scaledDensity = ctx.resources.displayMetrics.scaledDensity
        val node = nodes[id] ?: return "0,0"

        fun dp(dp: Int) = (dp * density).toInt()

        val (widthPx, heightPx) = when (node.type) {
            WidgetType.TEXT -> {
                val text = node.properties[PropKey.TEXT] ?: ""
                val fontSizeSp = node.properties[PropKey.FONT_SIZE]?.toFloatOrNull() ?: 14f
                val paint = android.text.TextPaint().apply {
                    textSize = fontSizeSp * ctx.resources.displayMetrics.scaledDensity
                }
                val layout = android.text.StaticLayout.Builder
                    .obtain(text, 0, text.length, paint, (280 * density).toInt())
                    .build()
                val maxW = (0 until layout.lineCount).maxOfOrNull { layout.getLineWidth(it) } ?: 0f
                Pair((maxW / density).toInt() + 1, (layout.height / density).toInt())
            }
            WidgetType.BUTTON -> {
                val paint = android.text.TextPaint().apply {
                    textSize = 14f * ctx.resources.displayMetrics.scaledDensity
                }
                val label = node.properties[PropKey.LABEL] ?: ""
                val textWidth = paint.measureText(label)
                // Material3 button: horizontal padding 24dp each side, height 40dp
                Pair((textWidth + 48 * density).toInt(), (40 * density).toInt())
            }
            WidgetType.TEXT_FIELD -> Pair((280 * density).toInt(), (56 * density).toInt())
            WidgetType.TOGGLE    -> Pair((280 * density).toInt(), (56 * density).toInt())
            WidgetType.SLIDER    -> Pair((280 * density).toInt(), (40 * density).toInt())
            WidgetType.DIVIDER   -> Pair((280 * density).toInt(), (1  * density).toInt())
            WidgetType.SECURE_FIELD   -> Pair((280 * density).toInt(), (56 * density).toInt())
            WidgetType.TOGGLE_BUTTON  -> {
                val paint = android.text.TextPaint().apply {
                    textSize = 14f * ctx.resources.displayMetrics.scaledDensity
                }
                val label = node.properties[PropKey.LABEL] ?: ""
                val textWidth = paint.measureText(label)
                Pair((textWidth + 48 * density).toInt(), (40 * density).toInt())
            }
            WidgetType.SWITCH         -> Pair((280 * density).toInt(), (56 * density).toInt())
            WidgetType.CHECKBOX       -> Pair((280 * density).toInt(), (56 * density).toInt())
            WidgetType.PROGRESS_SPINNER -> Pair((48 * density).toInt(), (48 * density).toInt())
            WidgetType.PICKER_MENU    -> Pair((280 * density).toInt(), (56 * density).toInt())
            WidgetType.PICKER_RADIO_GROUP -> {
                val options = node.properties["options"]?.split("\u001F") ?: emptyList()
                Pair((280 * density).toInt(), (options.size * 48 * density).toInt())
            }
            WidgetType.PICKER_WHEEL   -> Pair((280 * density).toInt(), (144 * density).toInt())
            WidgetType.DATE_PICKER -> Pair((280 * density).toInt(), (560 * density).toInt())
            WidgetType.SCROLL_CONTAINER -> Pair(0, 0)
            else -> Pair(0, 0)
        }
        
        val widthDp  = (widthPx  / density).toInt()
        val heightDp = (heightPx / density).toInt()
        return "$widthDp,$heightDp"
    }

    @JvmStatic
    fun getTextFieldValue(id: Int): String {
        return nodes[id]?.properties[PropKey.VALUE] ?: ""
    }

    @JvmStatic
    fun getWindowInsets(): String {
        val insets = windowInsets ?: return "0,0,0,0"
        val status = insets.getInsets(WindowInsetsCompat.Type.statusBars())
        val nav = insets.getInsets(WindowInsetsCompat.Type.navigationBars())
        return "${status.top},${nav.bottom}"
    }
}
