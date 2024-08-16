import SwiftUI

// MARK: - List View
public struct Items: View {
    @StateObject private var controller = DataController()
    public init() {}
    public var body: some View {
            if controller.data.isEmpty {
                ProgressView().task {
                    await controller.load()
                }
            } else {
                List(controller.data) { item in
                    Button {
                        controller.toggle(item.id)
                    } label: {
                        HStack {
                            Text(item.name)
                            Spacer()
                            Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                        }
                        .contentShape(Rectangle())
                    }
                    
                    .buttonStyle(.plain)
                }
                .overlay(debugView, alignment: .bottom)
            }
    }
    
    var debugView: some View {
        LazyVStack {
            ForEach(controller.enqueuedItems) { item in
                HStack {
                    Text(item.name)
                    Text("target: \(item.enqueuedIsChecked!)")
                    Text("isChecked: \(item.domainObject.isChecked)")
                }
            }
        }
    }
}

// MARK: - View Model
extension Items {
    struct Model: Identifiable {
        var domainObject: Item
        var id: UUID { domainObject.id }
        var name: String { domainObject.name }
        
        ///  This variable will be setted whenever the user toggles a given item
        ///  If no nil it means that the call to remotely toggle the item is taking place.
        ///  In which case we'll use it to render the checkbox state / on the view side,
        ///  So user can have and immediate feedback to its toggling / action (**Optimistic UI**)
        ///  This also allows us to preserve the current local state / separetely
        var enqueuedIsChecked: Bool?
        
        /// Uses transient enqueued is checked value if is setted, if not, we default to original state.
        var isChecked: Bool {
            get { enqueuedIsChecked ?? domainObject.isChecked }
            set { domainObject.isChecked = newValue }
        }
    }
}

extension Items.Model {
    
    /// Evaluates the next value of `enqueuedIsChecked`.
    /// If there's already a `enqueuedIsChecked`, it means we're performing a
    /// network call/waiting to it to take place..
    /// The new enqueuedIsChecked should be the opposite of that / existing value
    /// instead of the opposite of the current `isChecked` state of / the item.
    /// If `enqueuedIsChecked` doesn't exists, then the targeted new / state is the contrary of the current state (`!item.isChecked`)
    private func makeEnqueuedIsChecked() -> Bool {
        guard let enqueuedIsChecked else { return !domainObject.isChecked }
        return !enqueuedIsChecked
    }
    
    mutating func enqueueIsCheckedUpdate() {
        enqueuedIsChecked = makeEnqueuedIsChecked()
    }
    
    mutating func dequeueIsCheckedUpdate() {
        enqueuedIsChecked = nil
    }
}

