import DefaultBackend
import Foundation
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

enum SubjectArea: Codable {
    case science
    case humanities
}

enum ScienceSubject: Codable {
    case physics
    case chemistry
}

enum HumanitiesSubject: Codable {
    case english
    case history
}

@main
@HotReloadable
struct NavigationApp: App {
    @State var path = NavigationPath()

    var body: some Scene {
        WindowGroup("Navigation") {
            #hotReloadable {
                NavigationStack(path: $path) {
                    Text("Learn about subject areas")
                        .padding(.bottom, 10)

                    NavigationLink("Science", value: SubjectArea.science, path: $path)
                    NavigationLink("Humanities", value: SubjectArea.humanities, path: $path)
                }
                .navigationDestination(for: SubjectArea.self) { area in
                    switch area {
                        case .science:
                            Text("Choose a science subject")
                                .padding(.bottom, 10)

                            NavigationLink(
                                "Physics",
                                value: ScienceSubject.physics,
                                path: $path
                            )
                            NavigationLink(
                                "Chemistry",
                                value: ScienceSubject.chemistry,
                                path: $path
                            )
                        case .humanities:
                            Text("Choose a humanities subject")
                                .padding(.bottom, 10)

                            NavigationLink(
                                "English",
                                value: HumanitiesSubject.english,
                                path: $path
                            )
                            NavigationLink(
                                "History",
                                value: HumanitiesSubject.history,
                                path: $path
                            )
                    }

                    backButton
                }
                .navigationDestination(for: ScienceSubject.self) { subject in
                    switch subject {
                        case .physics:
                            Text("Physics is applied maths")
                        case .chemistry:
                            Text("Chemistry is applied physics")
                    }

                    backButton
                }
                .navigationDestination(for: HumanitiesSubject.self) { subject in
                    switch subject {
                        case .english:
                            Text("I don't like essays")
                        case .history:
                            Text("Don't repeat it")
                    }

                    backButton
                }
                .padding(10)
            }
        }
        .defaultSize(width: 200, height: 250)
    }

    @ViewBuilder
    var backButton: some View {
        Button("Back") {
            path.removeLast()
        }
        .padding(.top, 10)
    }
}
