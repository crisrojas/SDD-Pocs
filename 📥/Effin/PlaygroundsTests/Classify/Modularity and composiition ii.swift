////
////  Modularity and composiition ii.swift
////  Effin
////
////  Created by Cristian Felipe Patiño Rojas on 03/12/2023.
////
//
//import Foundation
//
///*
// 
// #!/bin/bash
// // @caio and mike essential develppers
// import Foundation
// import _Concurrency
//
// private var server = Array(0...2).map {_ in FeedSO()}
// private var database = [FeedDO]()
//
// struct FeedSO: Identifiable {let id = UUID()} // Feed server object
// struct FeedPO: Identifiable {let id: UUID   } // Feed persistence object
// struct FeedDO: Identifiable {let id: UUID   } // Feed domain object
// struct FeedVO: Identifiable {let id: UUID   } // Feed view object
//
// struct Reachability {
//     static let isAvailable = true
// }
//
// typealias VoidAction<T> = (T) -> Void
// typealias FeedDOs = [FeedDO]
// protocol FeedLoader: AnyObject {
//     func load(completion: VoidAction<FeedDOs>)
// }
//
// final class WorkerFeedLoader: FeedLoader {
//     
//     private let remote: FeedLoader
//     private let local : FeedLoader
//     
//     init(remote r: FeedLoader, local l: FeedLoader) {
//         remote = r
//         local  = l
//     }
//     
//     func load(completion: VoidAction<FeedDOs>){
//         let load = Reachability.isAvailable
//         ? remote.load
//         : local .load
//         
//         load(completion)
//     }
// }
//
// final class RemoteFeedLoader: FeedLoader {
//
//     func load(completion: VoidAction<FeedDOs>) {
//         completion(server.map {FeedDO(id: $0.id)})
//     }
// }
//
// final class LocalFeedLoader: FeedLoader {
//     func load(completion: VoidAction<FeedDOs>) {
//         completion(database.map {FeedDO(id: $0.id)})
//     }
// }
//
// enum ViewState<T> {
//     case idle
//     case loading
//     case success(T)
//     case error(Error)
// }
//
// final class FeedView {
//     var feedLoader: FeedLoader?
//     
//     private var state = ViewState<[FeedVO]>.idle {didSet{print(state)}}
//     
//     func fetchData() {
//         state = .loading
//         feedLoader?.load {
//             state = .success($0.map {FeedVO(id:$0.id)})
//         }
//     }
// }
//
// let view = FeedView()
// let remote = RemoteFeedLoader()
//
// view.feedLoader = WorkerFeedLoader(
//     remote: RemoteFeedLoader(),
//     local: LocalFeedLoader()
// )
//
// view.fetchData()
// */
///// Each module has its own entities
//extension Server   {struct FeedSO: Identifiable {let id: UUID}}
//extension Database {struct FeedPO: Identifiable {let id: UUID}}
//extension Main     {struct FeedDO: Identifiable {let id: UUID}}
//extension UI       {struct FeedVO: Identifiable {let id: UUID}}
//
//extension Server   {typealias FeedSOs = [FeedSO]}
//extension Database {typealias FeedPOs = [FeedPO]}
//extension Main     {typealias FeedDOs = [FeedDO]}
//extension UI       {typealias FeedVOs = [FeedVO]}
//
//// MARK: - Common utilities
//typealias VoidAction <T> = (T            ) -> Void
//typealias VoidClosure<T> = (@escaping VoidAction<T>) -> Void
//
//
//// MARK: - UI
//// Each view has it's own client, which describes its methods
//// This particular client, loads from an abstract datasource the data the view need to render
//protocol FeedClient {
//    func load(completion: VoidAction<UI.FeedVOs>)
//    // More methods ...
//}
//
//enum UI {
//    enum ViewState<T> {
//        case idle
//        case loading
//        case success(T)
//        case error(Error)
//    }
//    
//
//    final class FeedView {
//        // In this case we only need a single function.
//        // For simplicity, we will use it instead the FeedClient protocol
//        let loader: VoidClosure<FeedVOs>
//        
//        private var state = ViewState<[FeedVO]>.idle {didSet{print(state)}}
//        
//        init(loader l: @escaping VoidClosure<FeedVOs>) {loader = l}
//        func fetch() {
//            state = .loading
//            loader {self.state = .success($0)}
//        }
//    }
//}
//
//
//// MARK: - Data providers
//// Data providers store data that can be deserialized to their own entities
//struct Database {private let data = Array(0...2).map {_ in FeedPO(id: .init())}}
//struct Server   {private let data = Array(0...2).map {_ in FeedSO(id: .init())}}
//
//extension Database {
//    func fetch(completion: VoidAction<FeedPOs>) {completion(data)}
//}
//
//extension Server {
//    func fetch(completion: VoidAction<FeedSOs>) {completion(data)}
//}
//
//
//// MARK: - Main
//protocol FeedLoader {
//    func load(completion: VoidAction<Main.FeedDOs>)
//}
//
//struct Main {
//
//    // Main module imports Database & Server
//    let DB : Database
//    let Api: Server
//    
//    struct Reachability {
//        static let isAvailable = true
//    }
//    
//    
//struct RemoteFeedLoader: FeedLoader {
//    let provider: Server
//    func load(completion: VoidAction<FeedDOs>) {
//        provider.fetch { data in
//            completion(data.map {FeedDO(id: $0.id)})
//        }
//    }
//}
//
//struct LocalFeedLoader: FeedLoader {
//    let provider: Database
//    func load(completion: VoidAction<FeedDOs>) {
//        provider.fetch { data in
//            completion(data.map {FeedDO(id: $0.id)})
//        }
//    }
//}
//    
//    
//    func makeFeedLoader() -> VoidClosure<UI.FeedVOs> {
//        let local  = LocalFeedLoader(provider: DB)
//        let remote = RemoteFeedLoader(provider: Api)
//        
//        let loadDOs = Reachability.isAvailable
//        ? remote.load
//        : local.load
//        
//        
//        let loadVOs: VoidClosure<UI.FeedVOs> = { completion in
//            loadDOs { DOs in
////                DispatchQueue.main.async {
//                    completion(DOs.map {UI.FeedVO(id: $0.id)})
////                }
//            }
//        }
//        
//        return loadVOs
//    }
//    
//    func load(completion: @escaping VoidAction<UI.FeedVOs>) {
//        let local  = LocalFeedLoader(provider: DB)
//        let remote = RemoteFeedLoader(provider: Api)
//        
//        let loadDOs = Reachability.isAvailable
//        ? remote.load
//        : local.load
//        
//        
//        loadDOs { DOs in
////            DispatchQueue.main.async {
//                completion(DOs.map {UI.FeedVO(id:$0.id)})
////            }
//        }
//    }
//    
//    // Assembler makes views and inject them their clients.
//func makeView() -> UI.FeedView {
//    UI.FeedView(loader: makeFeedLoader())
//}
//}
//
//
//fileprivate let main = Main(DB: Database(), Api: Server())
//fileprivate let view = main.makeView()
////view.fetch()
