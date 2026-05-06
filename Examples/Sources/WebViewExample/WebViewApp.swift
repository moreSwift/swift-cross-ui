import DefaultBackend
import Foundation
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct WebViewApp: App {
    @State var urlInput = "https://swiftcrossui.dev"

    @State var url = URL(string: "https://swiftcrossui.dev")!

    func go(_ url: String) {
        guard let url = URL(string: urlInput) else {
            return
        }

        self.url = url
    }

    var body: some Scene {
        WindowGroup("WebViewExample") {
            #hotReloadable {
                VStack {
                    HStack {
                        #if !canImport(AndroidBackend)
                        TextField("URL", text: $urlInput)
                            .onSubmit {
                                go(urlInput)
                            }
                        #endif

                        Button("Go") {
                            go(urlInput)
                        }.disabled(URL(string: urlInput) == nil)
                    }
                    .padding()

                    #if !os(tvOS)
                        WebView($url)
                            .onChange(of: url) {
                                urlInput = url.absoluteString
                            }
                    #else
                        Text("WebView isn't supported on tvOS")
                    #endif
                }
            }
        }
        .defaultSize(width: 800, height: 800)
    }
}
