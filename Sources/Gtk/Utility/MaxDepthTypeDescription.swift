/// If a type has generic subtypes deeper than `maxDepth` they are replaced
/// by `moreTypeInfoIndicator`. eg: ViewContent2<Text, OptionalView<ViewContent2<ForEach<...>>>>
func typeDescription<T>(
    of _: T.Type,
    withMaxDepth maxDepth: Int,
    moreTypeInfoIndicator: String = "<...>"
) -> String {
    var currentDepth = 0
    let fullTypeDescription = String(describing: T.self)
    var clampedTypeDescription = ""

    func append(_ char: Character) {
        if currentDepth < maxDepth {
            clampedTypeDescription.append(char)
        }
    }

    for char in fullTypeDescription {
        switch char {
            case "<":
                append(char)
                currentDepth += 1
            case ">":
                currentDepth -= 1
                append(char)
            default:
                append(char)
        }
    }

    return
        clampedTypeDescription
            .replacingOccurrences(of: "<>", with: moreTypeInfoIndicator)
}
