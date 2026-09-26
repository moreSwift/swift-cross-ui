import DefaultBackend
import Foundation
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

enum SubjectArea: String, CaseIterable, Identifiable {
    var id: Self { self }

    case science = "Science"
    case humanities = "Humanities"
}

enum Subject: Hashable, Identifiable {
    case science(ScienceSubject)
    case humanities(HumanitiesSubject)

    var id: Self { self }

    var rawValue: String {
        switch self {
            case .science(let scienceSubject):
                return scienceSubject.rawValue
            case .humanities(let humanitiesSubject):
                return humanitiesSubject.rawValue
        }
    }

    var saying: String {
        switch self {
            case .science(.physics):
                "Physics is applied maths"
            case .science(.chemistry):
                "Chemistry is applied physics"
            case .humanities(.english):
                "I don't like essays"
            case .humanities(.history):
                "Don't repeat it"
        }
    }

    static let scienceSubjects = ScienceSubject.allCases.map(Self.science)
    static let humanitiesSubjects = HumanitiesSubject.allCases.map(Self.humanities)
}

enum ScienceSubject: String, CaseIterable {
    case physics = "Physics"
    case chemistry = "Chemistry"
}

enum HumanitiesSubject: String, CaseIterable {
    case english = "English"
    case history = "History"
}

enum Columns {
    case two
    case three
}

struct ContentView: View {
    @State var selectedArea: SubjectArea?
    @State var selectedDetail: Subject?
    @State var columns: Columns = .two

    var body: some View {
        switch columns {
            case .two:
                doubleColumn
            case .three:
                tripleColumn
        }
    }

    /// Example view for a two column NavigationSplitView
    var doubleColumn: some View {
        NavigationSplitView {
            VStack {
                List(SubjectArea.allCases, selection: $selectedArea) { subject in
                    HStack {
                        Color.purple.frame(width: 40, height: 40).cornerRadius(4)
                        Text(subject.rawValue)
                    }.padding(5)
                }
                Button {
                    print("large click")
                } label: {
                    Color.red.frame(width: 100, height: 100)
                }
                Spacer()
                Button("Switch to 3 column example") {
                    print("3 column")
                    columns = .three
                }
            }.padding(10)
        } detail: {
            VStack {
                Text(selectedArea?.rawValue ?? "Select an area")
            }.padding(10)
        }
    }

    /// Example view for a three column NavigationSplitView
    var tripleColumn: some View {
        NavigationSplitView {
            VStack {
                List(SubjectArea.allCases, selection: $selectedArea) { subject in
                    HStack {
                        Color.purple.frame(width: 40, height: 40).cornerRadius(4)
                        Text(subject.rawValue)
                    }.padding(5)
                }
                Spacer()
                Button("Switch to 2 column example") { columns = .two }
            }.padding(10)
        } content: {
            VStack {
                switch selectedArea {
                    case .science:
                        List(Subject.scienceSubjects, selection: $selectedDetail) { subject in
                            Text(subject.rawValue).padding(5)
                        }
                    case .humanities:
                        List(Subject.humanitiesSubjects, selection: $selectedDetail) { subject in
                            Text(subject.rawValue).padding(5)
                        }
                    case nil:
                        Text("Select an area")
                }
                Spacer()
            }
            .padding(10)
            .frame(minWidth: 190)
        } detail: {
            VStack {
                Text(selectedDetail?.saying ?? "Select a subject")
            }
            .padding(10)
        }
    }
}

@main
@HotReloadable
struct SplitApp: App {
    var body: some Scene {
        WindowGroup("Split") {
            #hotReloadable {
                VStack {
                    ContentView()
                    Button("Hi") {
                        print("hi")
                    }
                }
            }
        }
        .defaultSize(width: 600, height: 250)
    }
}
