import Benchmark
import SwiftCrossUI
import DummyBackend
import Foundation

protocol TestCaseView: View {
    init()
}

#if BENCHMARK_VIZ
    import DefaultBackend

    @MainActor
    var visualizationSize: (width: Int?, height: Int?) = (nil, nil)

    struct VizApp<V: TestCaseView>: App {
        var body: some Scene {
            WindowGroup("Benchmark visualization") {
                V().frame(width: visualizationSize.width, height: visualizationSize.height)
            }
        }
    }
#endif

@main
struct Benchmarks {
    @MainActor
    static func main() async {
        let backend = DummyBackend()
        let defaultEnvironment = EnvironmentValues(backend: backend)
        let environment = backend.computeRootEnvironment(defaultEnvironment: defaultEnvironment)
            .with(\.window, backend.createWindow(withDefaultSize: nil))

        @MainActor
        func makeNode<V: View>(_ view: V) -> ViewGraphNode<V, DummyBackend> {
            ViewGraphNode(for: view, backend: backend, snapshot: nil, environment: environment)
        }

        @MainActor
        func updateNode<V: View>(_ node: ViewGraphNode<V, DummyBackend>, _ size: ProposedViewSize) {
            _ = node.computeLayout(proposedSize: size, environment: environment)
            _ = node.commit()
        }

        #if BENCHMARK_VIZ
            var benchmarkVisualizations: [
                (name: String, size: ProposedViewSize, main: () -> Never)
            ] = []
        #endif

        @MainActor
        func benchmarkLayout<V: TestCaseView>(
            of viewType: V.Type,
            _ size: ProposedViewSize,
            _ label: String
        ) {
            #if BENCHMARK_VIZ
                benchmarkVisualizations.append((
                    label,
                    size,
                    {
                        VizApp<V>.main()
                        exit(0)
                    }
                ))
            #else
                benchmark(label) { @MainActor in
                    let node = makeNode(V())
                    updateNode(node, size)
                }
            #endif
        }

        // Register benchmarks
        benchmarkLayout(of: GridView.self, ProposedViewSize(800, 800), "grid")
        benchmarkLayout(
            of: ScrollableMessageListView.self,
            ProposedViewSize(800, 800),
            "message list"
        )

        #if BENCHMARK_VIZ
            let names = benchmarkVisualizations.map(\.name).joined(separator: " | ")
            print("Benchmark to viz (\(names)): ", terminator: "")
            guard let benchmarkName = readLine() else {
                print("Nothing entered")
                exit(1)
            }

            guard
                let benchmark = benchmarkVisualizations.first(
                    where: { $0.name == benchmarkName }
                )
            else {
                print("\(benchmarkName) doesn't match any benchmarks")
                exit(1)
            }

            visualizationSize = (
                benchmark.size.width.map(Int.init),
                benchmark.size.height.map(Int.init)
            )

            benchmark.main()
        #else
            await Benchmark.main()
        #endif
    }
}
