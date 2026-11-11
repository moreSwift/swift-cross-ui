import SwiftCrossUI

struct MessageView: View {
    static let profileSize = 40

    var message: ScrollableMessageListView.Message

    var body: some View {
        HStack(alignment: .top) {
            message.author.profileColor
                .frame(width: Self.profileSize, height: Self.profileSize)
                .cornerRadius(Self.profileSize / 2)

            VStack(alignment: .leading) {
                HStack {
                    Text(message.author.name)
                        .foregroundColor(message.author.handleColor)
                        .emphasized()

                    Text(message.time)
                        .foregroundColor(.gray)
                }

                Text(message.content)
            }
        }
    }
}

struct ScrollableMessageListView: TestCaseView {
    static let authors = [
        Author(name: "stackotter", handleColor: .blue, profileColor: .pink),
        Author(name: "gregc", handleColor: .yellow, profileColor: .yellow),
        Author(name: "bbrk24", handleColor: .purple, profileColor: .green)
    ]

    static let sentences = [
        "in the meantime you should be able to disable hot reloading support on linux at line 107 of Package.swift. hot reloading isn't actually supported on linux (it'll tell you that it's unsupported if you try to use hot reloading at runtime), i just left the code enabled to catch cross-platform regressions like this one hahah",
        "I assume stroke style gets overridden? if so we can make path store stroke style and then StyledShape can store another strokestyle if it wants, and when it produces the path it just overwrites its strokestyle before passing it on or something",
        "I am hesitant to completely mimic SwiftUI here because you can set stroke style on both Path and Shape, but stroke color only on Shape, so I have no idea what happens if you give them conflicting stroke styles",
        "I think stroke and fill modifiers on Shape would be a bit nicer. we could get them to return StyledShape or something and then implement the same two modifiers on StyledShape and get StyledShape to store fill and stroke",
        "Computer Software Is Hard"
    ]

    static let times = [
        "8:54am",
        "9:13am",
        "10:20pm",
        "12:01am",
        "1:00pm"
    ]

    static let messages = generateMessages(1000)

    struct Author {
        var name: String
        var handleColor: Color
        var profileColor: Color

        static let empty = Self(
            name: "<no name>",
            handleColor: .white,
            profileColor: .white
        )
    }

    struct Message: Identifiable {
        var author: Author
        var content: String
        var time: String
        var id: Int
    }

    static func generateMessages(_ count: Int) -> [Message] {
        var messages: [Message] = []
        messages.reserveCapacity(count)

        for i in 0..<count {
            let message = Message(
                author: authors[i % authors.count],
                content: sentences[i % sentences.count],
                time: times[i % times.count],
                id: i
            )
            messages.append(message)
        }
        return messages
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(Self.messages) { message in
                    MessageView(message: message)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
        }
    }
}
