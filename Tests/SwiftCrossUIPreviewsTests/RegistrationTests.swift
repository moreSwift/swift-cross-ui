#if canImport(SwiftUI) && canImport(AppKit) && !targetEnvironment(macCatalyst)
    import DeveloperToolsSupport
    import SwiftUI
    import Testing

    import SwiftCrossUI
    import SwiftCrossUIPreviews

    // Xcode renders a preview by building the registry type its macro emitted,
    // calling `makePreview()` on it, and rendering the result through an
    // `any SwiftUI.View`. These exercise those entry points, which the hosting
    // tests reach past by driving the representable with a concrete type.

    @Suite("Preview registration")
    struct RegistrationTests {
        @Test("A registration built by the overload can be made")
        @MainActor
        func testOverloadRegistrationMakesPreview() throws {
            _ = try DeveloperToolsSupport.Preview {
                SwiftCrossUIPreviews.SCUIPreview {
                    RegistrationFixture()
                }
            }
        }

        @Test("A registration wrapping a SwiftUI view can be made")
        @MainActor
        func testSwiftUIRegistrationMakesPreview() throws {
            _ = try DeveloperToolsSupport.Preview {
                SwiftUI.Text("anchor")
            }
        }

        @Test("Both registries' previews can be made through the protocol")
        @MainActor
        func testRegistriesMakePreviewThroughProtocol() throws {
            // Local registry types stand in for the generated ones, which
            // can't be named in source.
            struct CrossRegistry: DeveloperToolsSupport.PreviewRegistry {
                static let fileID = "SwiftCrossUIPreviewsTests/RegistrationTests.swift"
                static let line = 60
                static let column = 5

                @MainActor static func makePreview() throws
                    -> DeveloperToolsSupport.Preview
                {
                    DeveloperToolsSupport.Preview {
                        SwiftCrossUIPreviews.SCUIPreview {
                            RegistrationFixture()
                        }
                    }
                }
            }

            struct SwiftUIRegistry: DeveloperToolsSupport.PreviewRegistry {
                static let fileID = "SwiftCrossUIPreviewsTests/RegistrationTests.swift"
                static let line = 54
                static let column = 5

                @MainActor static func makePreview() throws
                    -> DeveloperToolsSupport.Preview
                {
                    DeveloperToolsSupport.Preview {
                        SwiftUI.Text("anchor")
                    }
                }
            }

            let registries: [any DeveloperToolsSupport.PreviewRegistry.Type] = [
                SwiftUIRegistry.self,
                CrossRegistry.self,
            ]
            for registry in registries {
                _ = try registry.makePreview()
            }
        }

        @Test("A view reached through the registration's existential renders")
        @MainActor
        func testExistentialViewRenders() throws {
            // The registration hands the preview an `any SwiftUICore.View`, so
            // force that same erasure before rendering.
            let erased: any SwiftUI.View = SwiftCrossUIPreviews.SCUIPreview {
                RegistrationFixture()
            }

            let controller = SwiftUI.NSHostingController(
                rootView: SwiftUI.AnyView(erased)
            )
            let view = controller.view
            view.frame = NSRect(x: 0, y: 0, width: 300, height: 200)

            view.layoutSubtreeIfNeeded()
            let representation = try #require(
                view.bitmapImageRepForCachingDisplay(in: view.bounds),
                "Could not create a bitmap for the hosted preview"
            )
            view.cacheDisplay(in: view.bounds, to: representation)

            #expect(view.frame.width > 0)
        }

        /// A view with visible content, standing in for a real previewed view.
        private struct RegistrationFixture: SwiftCrossUI.View {
            var body: some SwiftCrossUI.View {
                SwiftCrossUI.Text("Registration fixture")
            }
        }
    }
#endif
