import DefaultBackend
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

enum ColorOption: String, CaseIterable {
    case red
    case green
    case blue

    var color: Color {
        switch self {
            case .red:
                return .red
            case .green:
                return .green
            case .blue:
                return .blue
        }
    }
}

@main
@HotReloadable
struct RandomNumberGeneratorApp: App {
    @State var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup("Random Number Generator") {
            #hotReloadable {
                ContentView()
                    .environment(viewModel)
            }
        }
        .defaultSize(width: 500, height: 0)
        .windowResizability(.contentMinSize)
    }
}

struct ContentView: View {
    @Environment(ViewModel.self) var viewModel

    var body: some View {
        VStack {
            Text("Random Number: \(viewModel.randomNumber)")
            Button("Generate") {
                viewModel.randomNumber = Int.random(
                    in: Int(viewModel.minNum)...Int(viewModel.maxNum))
            }

            Text("Minimum: \(viewModel.minNum)")
            Slider(
                value: viewModel.$minNum.onChange { newValue in
                    if newValue > viewModel.maxNum {
                        viewModel.minNum = viewModel.maxNum
                    }
                },
                in: 0...100
            )

            Text("Maximum: \(viewModel.maxNum)")
            Slider(
                value: viewModel.$maxNum.onChange { newValue in
                    if newValue < viewModel.minNum {
                        viewModel.maxNum = viewModel.minNum
                    }
                },
                in: 0...100
            )

            HStack {
                Text("Choose a color:")
                Picker(of: ColorOption.allCases, selection: viewModel.$colorOption)
            }
        }
        .padding(10)
        .foregroundColor(viewModel.colorOption?.color ?? .red)
    }
}

@ObservableObject
class ViewModel {
    var minNum = 0
    var maxNum = 100
    var randomNumber = 0
    var colorOption: ColorOption? = ColorOption.red
}
