package dev.swiftcrossui.compose

import android.util.Log
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.horizontalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.layout.SubcomposeLayout
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.Modifier
import androidx.compose.ui.Alignment
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.foundation.text.KeyboardOptions

/**
 * Recursively renders a WidgetNode tree.
 *
 * Because [nodes] is a SnapshotStateMap, Compose tracks which nodes each
 * call site reads. When Swift mutates a node via [AndroidComposeBackendHost], only
 * the composables that read that specific node recompose — not the whole tree.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RenderNode(nodeId: Int, nodes: Map<Int, WidgetNode>) {
    val node = nodes[nodeId] ?: return

    when (node.type) {

        WidgetType.CONTAINER -> {
            val heightDp = node.properties["height"]?.toIntOrNull()
            // Width is never stored (setSize only writes height) so containers
            // always fill the available parent width. Height is stored so the
            // scroll container knows its total vertical extent.
            val sizeModifier = if (heightDp != null) {
                Modifier.fillMaxWidth().heightIn(min = heightDp.dp)
            } else {
                Modifier.fillMaxSize()
            }

            Box(modifier = sizeModifier) {
                node.children.forEachIndexed { index, childId ->
                    val registeredParent = AndroidComposeBackendHost.nodeParent[childId]
                    if (registeredParent != null && registeredParent != nodeId) return@forEachIndexed
                    val (x, y) = node.childPositions[index] ?: (0 to 0)
                    Box(modifier = Modifier.absoluteOffset(x.dp, y.dp)) {
                        RenderNode(childId, nodes)
                    }
                }
            }
        }

        WidgetType.TEXT -> {
            val text = node.prop(PropKey.TEXT) ?: ""
            val fontSize = node.prop(PropKey.FONT_SIZE)?.toIntOrNull()
            val fontWeight = when (node.prop(PropKey.FONT_WEIGHT)) {
                "bold"   -> FontWeight.Bold
                "light"  -> FontWeight.Light
                "medium" -> FontWeight.Medium
                else     -> FontWeight.Normal
            }
            val color = node.prop(PropKey.FOREGROUND)?.let { parseColor(it) }

            Measured(node.id) {
                Text(
                    text = text,
                    fontSize = fontSize?.sp ?: LocalTextStyle.current.fontSize,
                    fontWeight = fontWeight,
                    color = color ?: Color.Unspecified,
                )
            }
        }

        WidgetType.BUTTON -> {
            val label = node.prop(PropKey.LABEL) ?: ""
            val enabled = node.prop(PropKey.ENABLED) != "false"
            val menuItems = node.prop("menuItems")
                ?.split("\n")
                ?.filter { it.isNotEmpty() }

            if (!menuItems.isNullOrEmpty()) {
                var expanded by remember(nodeId) { mutableStateOf(false) }
                Measured(node.id) {
                    Box {
                        Button(
                            enabled = enabled,
                            onClick = { expanded = true }
                        ) { Text(label) }
                        DropdownMenu(
                            expanded = expanded,
                            onDismissRequest = { expanded = false }
                        ) {
                            menuItems.forEachIndexed { index, item ->
                                DropdownMenuItem(
                                    text = { Text(item) },
                                    onClick = {
                                        expanded = false
                                        AndroidComposeBackendHost.pushEvent(node.id, "menuSelect", index.toString())
                                    }
                                )
                            }
                        }
                    }
                }
            } else {
                Measured(node.id) {
                    Button(
                        enabled = enabled,
                        onClick = { AndroidComposeBackendHost.pushEvent(node.id, "click") }
                    ) { Text(label) }
                }
            }
        }

        WidgetType.TEXT_FIELD -> {
            var draft by remember(nodeId) {
                mutableStateOf(node.prop(PropKey.VALUE) ?: "")
            }
            val canonical = node.prop(PropKey.VALUE) ?: ""
            LaunchedEffect(canonical) {
                if (draft != canonical) draft = canonical
            }

            Measured(node.id, Modifier.fillMaxWidth()) {
                OutlinedTextField(
                    modifier = Modifier.fillMaxWidth(),
                    value = draft,
                    onValueChange = { new ->
                        draft = new
                        AndroidComposeBackendHost.pushEvent(node.id, "change", new)
                    },
                    label = {
                        node.prop(PropKey.PLACEHOLDER)?.let { Text(it) }
                    },
                    enabled = node.prop(PropKey.ENABLED) != "false",
                )
            }
        }

        WidgetType.TOGGLE -> {
            var checked by remember(nodeId) {
                mutableStateOf(node.prop(PropKey.VALUE) == "true")
            }
            val canonical = node.prop(PropKey.VALUE) == "true"
            LaunchedEffect(canonical) {
                if (checked != canonical) checked = canonical
            }

            Measured(node.id, Modifier.fillMaxWidth()) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Text(node.prop(PropKey.LABEL) ?: "")
                    Switch(
                        checked = checked,
                        onCheckedChange = { new ->
                            checked = new
                            AndroidComposeBackendHost.pushEvent(node.id, "toggle", new.toString())
                        },
                        enabled = node.prop(PropKey.ENABLED) != "false",
                    )
                }
            }
        }

        WidgetType.SLIDER -> {
            var value by remember(nodeId) {
                mutableStateOf(node.prop(PropKey.VALUE)?.toFloatOrNull() ?: 0f)
            }
            val min = node.prop(PropKey.MIN_VALUE)?.toFloatOrNull() ?: 0f
            val max = node.prop(PropKey.MAX_VALUE)?.toFloatOrNull() ?: 1f

            Measured(node.id, Modifier.fillMaxWidth()) {
                Slider(
                    modifier = Modifier.fillMaxWidth(),
                    value = value,
                    valueRange = min..max,
                    onValueChange = { new ->
                        value = new
                        AndroidComposeBackendHost.pushEvent(node.id, "slide", new.toString())
                    },
                    onValueChangeFinished = {
                        AndroidComposeBackendHost.pushEvent(node.id, "slideEnd", value.toString())
                    },
                )
            }
        }

        WidgetType.PICKER_RADIO_GROUP -> {
            val options = node.prop("options")?.split("\u001F") ?: emptyList()
            val selected = node.prop("selected")?.toIntOrNull() ?: -1
            val enabled = node.prop(PropKey.ENABLED) != "false"

            Measured(node.id, Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.fillMaxWidth()) {
                    options.forEachIndexed { index, label ->
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp)
                        ) {
                            RadioButton(
                                selected = index == selected,
                                onClick = {
                                    AndroidComposeBackendHost.pushEvent(node.id, "change", index.toString())
                                },
                                enabled = enabled
                            )
                            Text(label)
                        }
                    }
                }
            }
        }

        WidgetType.PICKER_MENU -> {
            val options = node.prop("options")?.split("\u001F") ?: emptyList()
            val selected = node.prop("selected")?.toIntOrNull() ?: -1
            val enabled = node.prop(PropKey.ENABLED) != "false"
            var expanded by remember(nodeId) { mutableStateOf(false) }

            Measured(node.id, Modifier.fillMaxWidth()) {
                ExposedDropdownMenuBox(
                    expanded = expanded,
                    onExpandedChange = { if (enabled) expanded = it }
                ) {
                    OutlinedTextField(
                        value = if (selected >= 0 && selected < options.size) options[selected] else "",
                        onValueChange = {},
                        readOnly = true,
                        enabled = enabled,
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
                        modifier = Modifier.menuAnchor().fillMaxWidth()
                    )
                    ExposedDropdownMenu(
                        expanded = expanded,
                        onDismissRequest = { expanded = false }
                    ) {
                        options.forEachIndexed { index, label ->
                            DropdownMenuItem(
                                text = { Text(label) },
                                onClick = {
                                    expanded = false
                                    AndroidComposeBackendHost.pushEvent(node.id, "change", index.toString())
                                }
                            )
                        }
                    }
                }
            }
        }

        WidgetType.PICKER_WHEEL -> {
            val options = node.prop("options")?.split("\u001F") ?: emptyList()
            val selected = node.prop("selected")?.toIntOrNull() ?: 0
            val enabled = node.prop(PropKey.ENABLED) != "false"
            val listState = rememberLazyListState(initialFirstVisibleItemIndex = maxOf(0, selected))
            val itemHeightDp = 48.dp

            Measured(node.id, Modifier.fillMaxWidth()) {
                Box(modifier = Modifier
                    .height(itemHeightDp * 3)
                    .fillMaxWidth()
                ) {
                    LazyColumn(state = listState) {
                        itemsIndexed(options) { index, label ->
                            Box(
                                modifier = Modifier
                                    .height(itemHeightDp)
                                    .fillMaxWidth()
                                    .clickable(enabled = enabled) {
                                        AndroidComposeBackendHost.pushEvent(node.id, "change", index.toString())
                                    },
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = label,
                                    fontWeight = if (index == selected) FontWeight.Bold else FontWeight.Normal
                                )
                            }
                        }
                    }
                }
            }
        }

        WidgetType.TOGGLE_BUTTON -> {
            var checked by remember(nodeId) { mutableStateOf(node.prop(PropKey.VALUE) == "true") }
            LaunchedEffect(node.prop(PropKey.VALUE)) { checked = node.prop(PropKey.VALUE) == "true" }
            val label = node.prop(PropKey.LABEL) ?: ""
            val enabled = node.prop(PropKey.ENABLED) != "false"

            Measured(node.id) {
                Button(
                    onClick = {
                        val new = !checked
                        checked = new
                        AndroidComposeBackendHost.pushEvent(node.id, "toggle", new.toString())
                    },
                    enabled = enabled,
                    colors = if (checked) ButtonDefaults.buttonColors()
                             else ButtonDefaults.outlinedButtonColors()
                ) {
                    Text(label)
                }
            }
        }

        WidgetType.CHECKBOX -> {
            var checked by remember(nodeId) { mutableStateOf(node.prop(PropKey.VALUE) == "true") }
            LaunchedEffect(node.prop(PropKey.VALUE)) { checked = node.prop(PropKey.VALUE) == "true" }
            val enabled = node.prop(PropKey.ENABLED) != "false"
            val label = node.prop(PropKey.LABEL) ?: ""

            Measured(node.id, Modifier.fillMaxWidth()) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Text(label)
                    Checkbox(
                        checked = checked,
                        onCheckedChange = { new ->
                            checked = new
                            AndroidComposeBackendHost.pushEvent(node.id, "toggle", new.toString())
                        },
                        enabled = enabled
                    )
                }
            }
        }

        WidgetType.SWITCH -> {
            var checked by remember(nodeId) { mutableStateOf(node.prop(PropKey.VALUE) == "true") }
            LaunchedEffect(node.prop(PropKey.VALUE)) { checked = node.prop(PropKey.VALUE) == "true" }
            val enabled = node.prop(PropKey.ENABLED) != "false"
            val label = node.prop(PropKey.LABEL) ?: ""

            Measured(node.id, Modifier.fillMaxWidth()) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Text(label)
                    Switch(
                        checked = checked,
                        onCheckedChange = { new ->
                            checked = new
                            AndroidComposeBackendHost.pushEvent(node.id, "toggle", new.toString())
                        },
                        enabled = enabled
                    )
                }
            }
        }

        WidgetType.SECURE_FIELD -> {
            var draft by remember(nodeId) { mutableStateOf("") }
            val enabled = node.prop(PropKey.ENABLED) != "false"

            Measured(node.id, Modifier.fillMaxWidth()) {
                OutlinedTextField(
                    value = draft,
                    onValueChange = { new ->
                        draft = new
                        AndroidComposeBackendHost.pushEvent(node.id, "change", new)
                    },
                    label = { node.prop(PropKey.PLACEHOLDER)?.let { Text(it) } },
                    visualTransformation = PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    enabled = enabled,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }

        WidgetType.PROGRESS_SPINNER -> {
            val widthDp = node.properties["width"]?.toIntOrNull()
            val heightDp = node.properties["height"]?.toIntOrNull()
            val sizeModifier = if (widthDp != null && heightDp != null)
                Modifier.size(widthDp.dp, heightDp.dp)
            else
                Modifier

            Measured(node.id) {
                CircularProgressIndicator(modifier = sizeModifier)
            }
        }

        WidgetType.DATE_PICKER -> {
            val currentMs = node.prop(PropKey.VALUE)?.toDoubleOrNull()
                ?.let { (it * 1000).toLong() }
                ?: System.currentTimeMillis()
            val datePickerState = rememberDatePickerState(initialSelectedDateMillis = currentMs)
            // Skip the first emission so we don't fire a "change" on initial
            // composition — that would update Swift's @State date, trigger a
            // full re-render, and cause the VStack to compute wrong positions.
            var initialized by remember(nodeId) { mutableStateOf(false) }
            LaunchedEffect(datePickerState.selectedDateMillis) {
                if (!initialized) { initialized = true; return@LaunchedEffect }
                datePickerState.selectedDateMillis?.let { ms ->
                    AndroidComposeBackendHost.pushEvent(
                        node.id, "change", (ms / 1000.0).toString()
                    )
                }
            }

            Measured(node.id, Modifier.fillMaxWidth()) {
                DatePicker(
                    state = datePickerState,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }

        WidgetType.SCROLL_CONTAINER -> {
            val scrollH = node.prop("scrollH") == "true"
            val scrollV = node.prop("scrollV") != "false"
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState(), enabled = scrollV)
                    .then(if (scrollH) Modifier.horizontalScroll(rememberScrollState()) else Modifier)
            ) {
                node.children.firstOrNull()?.let { childId ->
                    RenderNode(childId, nodes)
                }
            }
        }

        // Unknown type — render children anyway
        else -> Box {
            node.children.forEachIndexed { index, childId ->
                val registeredParent = AndroidComposeBackendHost.nodeParent[childId]
                if (registeredParent != null && registeredParent != nodeId) return@forEachIndexed
                val (x, y) = node.childPositions[index] ?: (0 to 0)
                Box(modifier = Modifier.absoluteOffset(x.dp, y.dp)) {
                    RenderNode(childId, nodes)
                }
            }
        }
    }
}

/** Shorthand to avoid nullable map lookups everywhere. */
private fun WidgetNode.prop(key: String): String? = properties[key]

/**
 * Parse a hex color string like "#RRGGBB" or "#AARRGGBB".
 * Returns null for anything it can't parse so callers fall back to defaults.
 */
private fun parseColor(hex: String): Color? = runCatching {
    val clean = hex.trimStart('#')
    when (clean.length) {
        6 -> Color(("FF$clean").toLong(16).toInt())
        8 -> Color(clean.toLong(16).toInt())
        else -> null
    }
}.getOrNull()

/**
 * Measures [content] synchronously during Compose's layout phase via
 * SubcomposeLayout, then reports the dp size to Swift via a "measured" event.
 */
@Composable
private fun Measured(nodeId: Int, modifier: Modifier = Modifier, content: @Composable () -> Unit) {
    val density = LocalDensity.current.density
    SubcomposeLayout(modifier = modifier) { constraints ->
        val placeable = subcompose(nodeId, content).first().measure(constraints)
        val wDp = (placeable.width / density).toInt()
        val hDp = (placeable.height / density).toInt()
        AndroidComposeBackendHost.pushEvent(nodeId, "measured", "$wDp,$hDp")
        layout(
            width = placeable.width.coerceIn(
                constraints.minWidth,
                constraints.maxWidth
            ),
            height = placeable.height.coerceIn(
                constraints.minHeight,
                constraints.maxHeight
            )
        ) {
            placeable.place(0, 0)
        }
    }
}
