//
//  ContentView.swift
//  Counters
//
//  Created by Cristian Felipe Patiño Rojas on 01/12/2023.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var resource = API.shared.counters
    @State private var name: String = ""
    @State private var showingAlert = false
    var body: some View {
        VStack {
            if resource.counts.isEmpty {
                "Nothing to show".onAppear(perform: {resource.load()})
            } else {
                resource.counts.list(deleteAction: delete, updateAction: update)
            }
        }
        .animation(.default, value: resource.counts)
        .toolbar {
            SymbolButton(systemName: "trash", action: trash)
            SymbolButton(systemName: "arrow.counterclockwise", action: load)
            SymbolButton(systemName: "plus", action:{showingAlert=true})
        }
        .insideNavView()
        .alert("Create counter", isPresented: $showingAlert) {
            Button("Cancel", role: .cancel, action: {})
            Button("OK", action: submit)
            TextField("ex) Ants killed today", text: $name)
        } message: {
            Text("Enter the name of the counter")
        }
    }

    
    func load() {DispatchQueue.main.async{resource.load()}}
    func trash() {
        resource.load(using: resource.request(.delete)).onFailure { _ in
            resource.load()
        }
    }
    
    func submit() {
        let postCmd = Count.POST(name: name, value: 0)
        let request = resource.request(.post, postCmd)
        name = ""
        resource.load(using: request).onFailure { _ in
            /// Currently returns empy data, but load method expects an array
            /// So it fails because decodingError, this is probably something that should  be adressed author of Bonfire
            /// or maybe I'm dumb and there's something I'm missing
            load()
        }
    }
    
    
    func delete(id: UUID) {
        /// I need to create a new instance of resource so I can have a different url (delete route needs an id)
        /// Again, maybe I'm missing something about the lib
        let resource = API.Counters()
        resource.url = "counters/\(id)"
        let request = resource.request(.delete)
        resource.load(using: request).onFailure { _ in
            load()
        }
    }
    
    func update(id: UUID, command: Count.PATCH) {
        
        /// Same problem than the one described at delete(id:)
        let resource = API.Counters()
        resource.url = "counters/\(id)"
        let request = resource.request(.patch, command)
        resource.load(using: request).onFailure { _ in
            load()
        }
    }
}

import Networking

fileprivate var jsonEncoder = JSONEncoder()
extension HttpBody where Self: Encodable {
    public var body: Data? {
        try? jsonEncoder.encode(self)
    }
}

/// This is probably something that we should move to the network module
extension Count: Equatable {
    public static func == (lhs: Count, rhs: Count) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name  &&
        lhs.value == rhs.value
    }
}
extension Count.POST : HttpBody {}
extension Count.PATCH: HttpBody {}

struct SymbolButton: View {
    let systemName: String
    
    /// Button behaves weird when inside a list
    let tapGesture: Bool
    
    let action: () -> Void
    
    init(systemName: String, tapGesture: Bool = false, action: @escaping () -> Void) {
        self.systemName = systemName
        self.action = action
        self.tapGesture = tapGesture
    }
    
    var body: some View {
        if tapGesture {
            label().onTapGesture(perform: action)
        } else {
            Button(action: action, label: label)
        }
    }
    
    func label() -> some View {
        Image(systemName: systemName)
    }
}

extension View {
    func insideNavView() -> some View {NavigationView{self}}
}

import Networking
extension [Count]: View {
   public var body: some View {
       List(self, id: \.id) { item in
           HStack {
               item.name
               Spacer()
               item.value
           }
        }
    }
    
    func list(
        deleteAction: @escaping (Element.ID   ) -> Void,
        updateAction: @escaping (Element.ID, Element.PATCH) -> Void
    ) -> some View {
        List {
            ForEach(self) { item in
                HStack {
                    CountNameTextField(text: item.name, id: item.id, updateAction: updateAction)
                    Spacer()
                    SymbolButton(systemName: "minus", tapGesture: true) {
                        updateAction(item.id, .init(value: item.value - 1))
                    }
                    item.value
                    
                    SymbolButton(systemName: "plus", tapGesture: true) {
                        updateAction(item.id, .init(value: item.value + 1))
                    }
                }
            }
            .onDelete { indexSet in
                indexSet.forEach {
                    deleteAction(self[$0].id)
                }
            }
         }
    }
}

struct CountNameTextField: View {
    @State var text: String
    let id: Count.ID
    let updateAction: (Count.ID, Count.PATCH) -> Void
    var body: some View {
        TextField(text, text: $text)
            .onSubmit {
                updateAction(id, .init(name: text))
            }
    }
}

extension Int: View {
    public var body: Text {
        Text(description)
    }
}
extension String: View {
    public var body: Text {
        Text(self)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
