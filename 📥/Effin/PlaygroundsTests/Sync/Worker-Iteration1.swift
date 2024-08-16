//
//  POP.swift
//  Effin
//
//  Created by Cristian Patiño Rojas on 15/11/23.
//

import Foundation

/// **Goals of this playground**:
///
/// Refactor a worker solution with protocol + extension
/// that perform *CRUD *actions over a persisted store or a remote one depending on reachability
///
/// Basically we want this api:
///
/// let data: T = try? await worker.get()
///
/// Where worker will fetch from store / remote depending on network availability.
///
/// En la primera iteración hubo algo que creo puede dar problemas en una situación real:
/// ResourceLoader devuelve un Data.
/// Creo que es raro que un ResourceLoader local pueda devolver un Data.
/// Por ejemplo, CoreData nos devolverá NSManagedObjects.
/// Si usamos serialización a disco, sí que al leer leemos los datos serializados en formato Data:
/// Data(contentsOf: fileURL(path: path, fm: fm)))
/// Si usamos SQLite.swift, se nos devuelve un objeto Row.
/// Así que ResourceLoader debería de tener un tipo asociado, porque considero buena práctica pasar una entidad de CoreData a Data, sólo para deserializarla después.
/// Lo que complica las cosas a la hora de definir el protocolo Worker
/// En esta segunda implementación, estoy intentando usar type-erasure.
///
///
/// Fetches Data
protocol DataResourceFetcher {
    func get() async throws -> Data
}

/// Fetches T
fileprivate protocol ResourceLoader {
    associatedtype ResourceType
    func get() async throws -> ResourceType
}

fileprivate protocol NetworkResourceLoader: ResourceLoader {
    var resource: DataResourceFetcher { get }
}

fileprivate extension NetworkResourceLoader where ResourceType: Decodable {
    func get() async throws -> ResourceType {
       let data = try await resource.get()
       let decoded = try JSONDecoder().decode(ResourceType.self, from: data)
       return decoded
    }
}

/// #type-erasure
/// Esto está incompleto, porque le puedo pasar cualquier tipo de ResourceLoader
/// por ejemplo:
/// let remoteLoader = ResourceLoaderEraser<[Feed]>(loader: ProfilesLoader())
final class ResourceLoaderEraser<T>: ResourceLoader {
    typealias ResourceType = T
    fileprivate let loader: any ResourceLoader
    fileprivate init(loader: any ResourceLoader) {
        self.loader = loader
    }
    func get() async throws -> T {
        try await loader.get() as! T
    }
}

fileprivate let worker = FeedWorker(
    isReachable: true,
    remoteLoader: ResourceLoaderEraser<[Feed]>(loader: FeedRemoteLoader()),
    localLoader : ResourceLoaderEraser<[Feed]>(loader: FeedLocalLoader ())
)


fileprivate protocol Worker: ResourceLoader {
    var jsonDecoder : JSONDecoder  { get }
    var isReachable: Bool { get }
    var remoteLoader: ResourceLoaderEraser<ResourceType> { get }
    var localLoader : ResourceLoaderEraser<ResourceType> { get }
}

extension Worker {
    func get() async throws -> ResourceType {
        if isReachable {
            return try await remoteLoader.get()
        } else {
            return try await localLoader.get()
        }
    }
}

struct Feed: Decodable {}

struct FeedResource: DataResourceFetcher {
    func get(completion: @escaping (Data) -> Void) {}
    func get() async throws -> Data { .init() }
}

fileprivate struct FeedWorker: Worker {
    typealias ResourceType = [Feed]
    var jsonDecoder : JSONDecoder { defaultDecoder }
    let isReachable: Bool
    let remoteLoader: ResourceLoaderEraser<[Feed]>
    let localLoader : ResourceLoaderEraser<[Feed]>
}

fileprivate var defaultDecoder: JSONDecoder = {
    JSONDecoder()
}()


struct FeedRemoteLoader: NetworkResourceLoader {
    typealias ResourceType = [Feed]
    var resource: DataResourceFetcher { FeedResource() }
}

struct FeedLocalLoader: ResourceLoader {
    typealias ResourceType = [Feed]
    func get() async throws -> [Feed] {[]}
}

