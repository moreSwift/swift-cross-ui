import SwiftCrossUI
import DefaultBackend

@main
struct TapGesturesApp: App {
    @State var primaryGestureCount = 0
    @State var secondaryGestureCount = 0
    @State var longPressCount = 0

    var body: some Scene {
        WindowGroup("TapGesturesExample") {
            VStack {
                Text("Primary gesture target")
                    .padding()
                    .background(Color.green)
                    .onTapGesture(gesture: .primary) {
                        primaryGestureCount += 1
                    }

                Text("Primary gesture count: \(primaryGestureCount)")

                Divider()

                Text("Secondary gesture target")
                    .padding()
                    .background(Color.green)
                    .onTapGesture(gesture: .secondary) {
                        secondaryGestureCount += 1
                    }

                Text("Secondary gesture count: \(secondaryGestureCount)")

                Divider()

                Text("Long press target")
                    .padding()
                    .background(Color.green)
                    .onTapGesture(gesture: .longPress) {
                        longPressCount += 1
                    }

                Text("Long press count: \(longPressCount)")
            }
        }
    }
}
