package dev.swiftcrossui.compose

import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Column
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarDefaults
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.runtime.remember
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.core.view.ViewCompat

data class TabItem(
    val label: String,
    val icon: ImageVector,
    /** The root node ID that Swift registered for this tab, or -1 if unused. */
    val rootNodeId: Int = -1,
)

// Adjust labels, icons, and rootNodeIds to match the node IDs that your Swift
// layer registers via AndroidComposeBackendHost.setRootNode().

val AppTabs = listOf(
    TabItem(label = "Home", icon = Icons.Filled.Home),
    TabItem(label = "Search", icon = Icons.Filled.Search),
    TabItem(label = "Social", icon = Icons.Filled.Person),
    TabItem(label = "Settings", icon = Icons.Filled.Settings),
)

/**
 * AndroidComposeBackendActivity
 *
 * The single Activity for apps built on the Compose backend. Declare this in
 * AndroidManifest.xml as your launcher activity.
 *
 * Swift starts the app, then calls ComposeBackendHost APIs to build the widget
 * tree. The activity observes [ComposeBackendHost.nodes] and
 * [ComposeBackendHost.rootNodeId] — both are Compose state, so changes are
 * picked up automatically without any explicit signaling.
 */
class AndroidComposeBackendActivity : com.example.helloworld.MainActivity() {
  
    override fun onCreate(savedInstanceState: Bundle?) {
        AndroidComposeBackendHost.initialize(this)
        super.onCreate(savedInstanceState)
        
        ViewCompat.setOnApplyWindowInsetsListener(window.decorView) { _, insets ->
            AndroidComposeBackendHost.windowInsets = insets
            insets
        }

        setContent {
          val context = this
          val darkTheme = isSystemInDarkTheme()

          val colorScheme = remember(darkTheme) {
              when {
                  Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
                      // Android 12+: pull wallpaper/system accent colors
                      if (darkTheme) dynamicDarkColorScheme(context)
                      else           dynamicLightColorScheme(context)
                  }
                  else -> {
                      // Older devices: fall back to Material3 baseline
                      if (darkTheme) darkColorScheme()
                      else           lightColorScheme()
                  }
              }
          }
          
          MaterialTheme(colorScheme = colorScheme) {
              Surface(
                  modifier = Modifier.fillMaxSize(),
                  color = MaterialTheme.colorScheme.background,
              ) {
                  AndroidComposeBackendRoot()
              }
          }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Let Swift know the activity is going away so it can tear down
        // its own state cleanly.
        AndroidComposeBackendHost.clearAll()
    }
    
    fun pollEvent(): String? = AndroidComposeBackendHost.pollEvent()
    fun pendingEventCount(): Int = AndroidComposeBackendHost.pendingEventCount()
    fun createNode(id: Int, type: String) = AndroidComposeBackendHost.createNode(id, type)
    fun setProperty(id: Int, key: String, value: String) = AndroidComposeBackendHost.setProperty(id, key, value)
    fun setChildren(parentId: Int, childIds: IntArray) = AndroidComposeBackendHost.setChildren(parentId, childIds)
    fun setPosition(containerId: Int, index: Int, x: Int, y: Int) = AndroidComposeBackendHost.setPosition(containerId, index, x, y)
    fun setRootNode(id: Int) = AndroidComposeBackendHost.setRootNode(id)
    fun removeNode(id: Int) = AndroidComposeBackendHost.removeNode(id)
    fun clearAll() = AndroidComposeBackendHost.clearAll()
    fun measureWidget(id: Int): String = AndroidComposeBackendHost.measureWidget(id)
    fun measureText(text: String, fontSizeSp: Float, maxWidthDp: Int): String = AndroidComposeBackendHost.measureText(text, fontSizeSp, maxWidthDp)
    fun getTextFieldValue(id: Int): String = AndroidComposeBackendHost.getTextFieldValue(id)
    fun getWindowInsets(): String = AndroidComposeBackendHost.getWindowInsets()
}

/**
 * Root composable. Wraps content in a [Scaffold] that houses a [NavigationBar]
 * at the bottom. The selected tab index is saved across recompositions and
 * configuration changes via [rememberSaveable].
 *
 * When a tab has a non-(-1) [TabItem.rootNodeId] the corresponding node tree
 * from [AndroidComposeBackendHost] is rendered; otherwise an empty [Box] is
 * shown so the host can still drive content via [AndroidComposeBackendHost.rootNodeId].
 */
@Composable
private fun AndroidComposeBackendRoot() {
    val nodes = AndroidComposeBackendHost.nodes
    val hostRootId = AndroidComposeBackendHost.rootNodeId
    
    LaunchedEffect(nodes.size) {
        Log.d("compose", "nodes changed: count=${nodes.size}, keys=${nodes.keys}")
    }
    LaunchedEffect(hostRootId) {
        Log.d("compose", "rootNodeId changed: $hostRootId")
    }
    
    var selectedTabIndex by rememberSaveable { mutableIntStateOf(0) }

    Scaffold(
        bottomBar = {
            AppNavigationBar(
                tabs = AppTabs,
                selectedIndex = selectedTabIndex,
                onTabSelected = { selectedTabIndex = it },
            )
        },
    ) { innerPadding ->
        Box(modifier = Modifier
            .fillMaxSize()
            .padding(innerPadding)
        ) {
            // Prefer the per-tab rootNodeId when set; fall back to the global
            // hostRootId so existing Swift call-sites keep working unchanged.
            val activeTab = AppTabs[selectedTabIndex]
            val resolvedRootId = when {
                activeTab.rootNodeId != -1 -> activeTab.rootNodeId
                hostRootId != -1           -> hostRootId
                else                       -> -1
            }
            
            if (resolvedRootId != -1 && AndroidComposeBackendHost.treeReady) {
                // FOR DEBUGGING SWIFT UI RENDERING:
                // Column {
                //     Text("swift render debug: rootId=$resolvedRootId nodes=${nodes.size}")
                //     nodes.forEach { (id, node) ->
                //         Text("RenderNode: id=$id found=${node.type}")
                //     }
                // }
                RenderNode(nodeId = resolvedRootId, nodes = nodes)
            }
        }
    }
}

/**
 * Stateless Material3 bottom navigation bar.
 *
 * @param tabs          Ordered list of tabs to display.
 * @param selectedIndex Index of the currently active tab.
 * @param onTabSelected Callback invoked with the new index when the user taps a tab.
 */
@Composable
private fun AppNavigationBar(
    tabs: List<TabItem>,
    selectedIndex: Int,
    onTabSelected: (Int) -> Unit,
) {
    NavigationBar(
        containerColor = MaterialTheme.colorScheme.surfaceContainer,
        contentColor   = MaterialTheme.colorScheme.onSurfaceVariant,
        tonalElevation = NavigationBarDefaults.Elevation,
    ) {
        tabs.forEachIndexed { index, tab ->
            NavigationBarItem(
                selected = index == selectedIndex,
                onClick  = { onTabSelected(index) },
                icon     = { Icon(imageVector = tab.icon, contentDescription = tab.label) },
                label    = { Text(text = tab.label) },
                colors = NavigationBarItemDefaults.colors(
                    selectedIconColor       = MaterialTheme.colorScheme.onSecondaryContainer,
                    selectedTextColor       = MaterialTheme.colorScheme.onSurface,
                    unselectedIconColor     = MaterialTheme.colorScheme.onSurfaceVariant,
                    unselectedTextColor     = MaterialTheme.colorScheme.onSurfaceVariant,
                    indicatorColor          = MaterialTheme.colorScheme.secondaryContainer,
                ),
            )
        }
    }
}
