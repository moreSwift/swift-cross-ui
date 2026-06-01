import DefaultBackend
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct ObservableApp: App {
    @State var model = ObservableModel()
    @State var count = 0

    var body: some Scene {
        WindowGroup(model.windowTitle) {
            VStack(spacing: 32) {
                Text(model.windowText)
                HStack {
                    View1(model: model)
                        .padding()
                    View2(model: model)
                        .padding()
                }
                ModifyingView(model: model)
                    .padding()
                if !model.automaticModeIsOn {
                    Button("Start automatic Mode") {
                        model.startAutomaticMode()
                    }
                }
            }
            .padding()
        }
        .defaultSize(width: 400, height: 200)
    }
}

struct View1: View {
    let model: ObservableModel
    
    var body: some View {
        VStack {
            Text(model.view1Text)
            ModifyingView(model: model)
        }
        .padding()
        .background(Color.green)
    }
}

struct View2: View {
    let model: ObservableModel
    
    var body: some View {
        VStack {
            Text(model.view2Text)
            ModifyingView(model: model)
        }
        .padding()
        .background(Color.red)
    }
}

struct ModifyingView: View {
    @Bindable var model: ObservableModel
    
    var body: some View {
        if !model.automaticModeIsOn {
            VStack {
                TextField("Window Title", text: $model.windowTitle)
                TextField("Window Text", text: $model.windowText)
                TextField("View 1 Text", text: $model.view1Text)
                TextField("View 2 Text", text: $model.view2Text)
            }
        }
    }
}
