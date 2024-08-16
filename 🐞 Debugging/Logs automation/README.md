# Automatic logging on effects

The idea of this small playground is to have a way of automatically log effects provided through protocol conformance.

The implementation of examples 1 and 3, have been taken from the gist of [Jim Lai](https://gist.github.com/swift2931/6c9fb7fb828777a50860be2b9ae05fe0) with slightly modifications. Though is a good step towards automatic loggin, it needs the conformer of Redux protocol to implement boilerplate (it has to manually add a Binding<Store> for protocol conformance) as for know, protocols don't support propery wrappers, so we can't have default bindings on extensions.

One way to do that, is declaring store as follows:

protocol Redux {
    associatedType Store
    var store: State<Store> { get set }
}

extension Redux {
    var binding: Binding<Store> {
        Binding(
            get: { self.store.wrappedValue },
            set: { self.store.wrappedValue = $0 }
        )
    }
}

But it has its own drawbacks (you can't use @State property wrapper on the view side, and that won't work with ObservableObjects), see example 1.

The other way I found to log state changes is by implementing a diffing method and invoking in on store/state willset, which still far from ideal as you have to manually invoke it on each stroe. It seems isn't a way to do automatically loggin.
