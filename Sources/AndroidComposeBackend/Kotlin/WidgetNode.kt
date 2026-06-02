package dev.swiftcrossui.compose

import androidx.compose.runtime.Stable

/**
 * Immutable descriptor for a single widget in the tree.
 * Held inside a SnapshotStateMap so any mutation triggers recomposition.
 *
 * Swift owns the ID space (simple incrementing counter). Kotlin never
 * allocates IDs — it only stores and renders what Swift sends.
 */
@Stable
data class WidgetNode(
    val id: Int,
    val type: String,
    val properties: Map<String, String> = emptyMap(),
    // Ordered child IDs — index here matches the index SCUI passes to setPosition
    val children: List<Int> = emptyList(),
    // Per-child absolute positions keyed by child index (not child ID).
    // SCUI calls setPosition(ofChildAt: index, in: container, to: x/y) after
    // computing layout; we store those here so RenderNode can offset each child.
    val childPositions: Map<Int, Pair<Int, Int>> = emptyMap(),
)

/** Canonical type strings — keep in sync with ComposeBackend.swift */
object WidgetType {
    const val CONTAINER          = "Container"
    const val TEXT               = "Text"
    const val BUTTON             = "Button"
    const val TEXT_FIELD         = "TextField"
    const val TOGGLE             = "Toggle"
    const val SLIDER             = "Slider"
    const val DIVIDER            = "Divider"
    const val IMAGE              = "Image"
    const val PICKER_RADIO_GROUP = "PickerRadioGroup"
    const val PICKER_MENU        = "PickerMenu"
    const val PICKER_WHEEL       = "PickerWheel"
    const val TOGGLE_BUTTON      = "ToggleButton"
    const val CHECKBOX           = "Checkbox"
    const val SWITCH             = "Switch"
    const val SECURE_FIELD       = "SecureField"
    const val PROGRESS_SPINNER   = "ProgressSpinner"
    const val DATE_PICKER        = "DatePicker"
    const val SCROLL_CONTAINER   = "ScrollContainer"

}

/** Canonical property key strings */
object PropKey {
    const val TEXT        = "text"
    const val LABEL       = "label"
    const val VALUE       = "value"
    const val PLACEHOLDER = "placeholder"
    const val MIN_VALUE   = "min"
    const val MAX_VALUE   = "max"
    const val FONT_SIZE   = "fontSize"
    const val FONT_WEIGHT = "fontWeight"
    const val FOREGROUND  = "foregroundColor"
    const val BACKGROUND  = "backgroundColor"
    const val ENABLED     = "enabled"
    const val WIDTH       = "width"
    const val HEIGHT      = "height"
}
