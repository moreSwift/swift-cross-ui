import DefaultBackend
import Foundation
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

struct Person {
    var name: String
    var age: Int
    var phone: String
    var email: String
    var occupation: String
}

@main
@HotReloadable
struct SpreadsheetApp: App {
    @State var data = [
        Person(
            name: "Alice",
            age: 99,
            phone: "(+61)1234123412",
            email: "alice@example.com",
            occupation: "developer"
        ),
        Person(
            name: "Bob",
            age: 99,
            phone: "(+61)1234123412",
            email: "bob@example.com",
            occupation: "adversary"
        ),
    ]

    @State var greeting: String?

    var body: some Scene {
        WindowGroup("Spreadsheet") {
            #hotReloadable {
                VStack(spacing: 0) {
                    VStack {
                        if let greeting = greeting {
                            Text(greeting)
                        } else {
                            Text("Pending greeting...")
                        }
                    }
                    .padding(10)
                    Table(data) {
                        TableColumn("Name", value: \Person.name)
                        TableColumn("Age", value: \Person.age.description)
                        TableColumn("Phone", value: \Person.phone)
                        TableColumn("Email", value: \Person.email)
                        TableColumn("Occupation", value: \Person.occupation)
                        TableColumn("Action") { (person: Person) in
                            Button("Greet") {
                                greeting = "Hello, \(person.name)!"
                            }
                        }
                    }
                }
            }
        }
    }
}
