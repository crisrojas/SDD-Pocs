//
//  Worker & Crud .swift
//  PlaygroundsTests
//
//  Created by Cristian Felipe Patiño Rojas on 06/12/2023.
//

import Foundation


import SwiftUI
protocol Patchable {
    associatedtype PATCH
}

protocol Putable {
    associatedtype PUT
}

struct Count: Identifiable {
    let id: UUID
    var name: String
    let value: Int
}

extension Count: Patchable, Putable {
    struct PATCH {
        var name: String?
        var value: Int?
    }
    
    struct PUT {
        var name: String?
        var value: Int?
    }
}

final class CountersRemote {
    func create(_ item: Count) {}
    func read() -> [Count] {[]}
    func update(_ item: Count) {}
    func delete(_ id: Count.ID) {}
    
    func update(_ patch: Count.PATCH) {}
    func update(_ put  : Count.PUT  ) {}
}

final class CountersLocal  {
    func create(_ item: Count) {}
    func read() -> [Count] {[]}
    func update(_ item: Count) {}
    func delete(_ id: Count.ID) {}
}

final class CountersWorker: ObservableObject {
    @Published var counts = [Count]()
    var remote = CountersRemote()
    var local  = CountersLocal()
    var isReachable = false
    
    func create(_ item: Count) {
        if isReachable {
            remote.create(item)
            local.create(item)
        } else {
            local.create(item)
        }
    }
    
    func read() {
        if isReachable {
            counts = remote.read()
        } else {
            counts = local.read()
        }
    }
    
    func update(_ patch: Count.PATCH) {
        if isReachable {
            remote.update(patch)
        }
    }
    
    
    func update(_ put: Count.PUT) {
        if isReachable {
            remote.update(put)
        } else {
            
        }
    }
    
    func update(_ item: Count) {
        if isReachable {
            remote.update(item)
            local.update(item)
        } else {
            local.update(item)
        }
    }
    
    func delete(_ id: Count.ID) {
        if isReachable {
            remote.delete(id)
            local.delete(id)
        } else {
            local.delete(id)
        }
    }
}


struct Counters: View {
    @ObservedObject var counts = CountersWorker()
    let item = Count(id: UUID(), name: "test", value: 0)
    var body: some View {
        VStack {
            Text("Crud actions")
            
            Button("Create") {
                counts.create(item)
            }
            
            Button("Read") {
                counts.read()
            }
            
            Button("Update") {
                counts.update(item)
            }
            
            Update(item: item, update: counts.update)
            
            Button("Delete") {
                counts.delete(UUID())
            }
        }
    }
}

extension Counters {
    struct Update: MappableView {
        @State var item: Count
        var update: ((Count) -> Void)?
        var body: some View {
            TextField(item.name, text: $item.name)
                .onSubmit {update?(item)}
        }
    }
}

final class CRUD<T: Identifiable> {
    typealias I = T.ID
    let create: (T) -> Void
    let readid: (I) -> Count?
    let update: (T) -> Void
    let delete: (T) -> Void

    init(create: @escaping (T) -> Void, readid: @escaping (I) -> Count?, update: @escaping (T) -> Void, delete: @escaping (T) -> Void) {
        self.create = create
        self.readid = readid
        self.update = update
        self.delete = delete
    }
}


struct CountFeature: View {
    var crud: CRUD<Count>?
    var body: some View {
        VStack {
            CountDetail(id: UUID())
                .inject(\.crud, crud)
        }
    }
}

typealias MappableView = View & Mappable & KeyPathMutable

struct CountDetail: MappableView {
    let id: UUID
    @State private var count: Count?
    var crud: CRUD<Count>?
    var body: some View {
        VStack {
            if let count {
                count.name
            } else {
                ProgressView().onAppear {
                    count = crud?.readid(id)
                }
            }
        }
       
    }
}


extension String: View {
    public var body: Text {
        Text(self)
    }
}
