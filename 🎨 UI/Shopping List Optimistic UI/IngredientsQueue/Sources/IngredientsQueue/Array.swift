// Our item would need to conform to Identifiable
extension Array where Element: Identifiable {
    subscript(id: Element.ID) -> Element? {
        get { first { $0.id == id } }
        set(newValue) {
            if let index = firstIndex(where: { $0.id == id }) {
                if let newValue = newValue {
                    self[index] = newValue
                } else {
                    remove(at: index)
                }
            } else if let newValue = newValue {
                append(newValue)
            }
        }
    }
}