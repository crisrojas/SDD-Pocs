//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 15/08/2024.
//

import Foundation

// List data controller
extension Items {
    @MainActor
    final class DataController: ObservableObject, ItemNetworker {
        @Published var data = [Items.Model]()
        
        var enqueuedItems: [Items.Model] {
            data.filter { $0.enqueuedIsChecked != nil }
        }
        
        var debounceTask: Task<Void, Never>?
        static let debounceTime: TimeInterval = 0.5
        
        
        func load() async {
            do {
                let items = try await fetch()
                self.data = items.map { Items.Model(domainObject: $0) }
            } catch {
                dp("@todo: Handle errors")
            }
        }
        
        func toggle(_ itemId: UUID) {
            debounceTask?.cancel()
            
            enqueue(itemId)
            
            if shouldNotUpdate(itemId) {
                dequeue(itemId)
            }
            
            debounceTask = Task {
                do {
                    try await Task.sleep(seconds: Self.debounceTime)
                    guard !Task.isCancelled else { return }
                    await dequeueItemsParallely()
                } catch is CancellationError {
                    dp("Task cancelled")
                } catch {
                    dp(error.localizedDescription)
                }
            }
        }
        
        func dequeueItems() async throws {
            for item in enqueuedItems {
                try await toggle(item.domainObject)
                data[item.id]?.domainObject.isChecked.toggle()
                dequeue(item.id)
            }
        }
        
        func dequeueItemsParallely() async {
            await withTaskGroup(of: Void.self) { [weak self] group in
                guard let self else { return }
                for item in enqueuedItems {
                    group.addTask {
                        do {
                            try await self.toggle(item.domainObject)
                            await MainActor.run {
                                self.data[item.id]?.domainObject.isChecked.toggle()
                                self.dequeue(item.id)
                            }
                        } catch {
                            dp("Error in task for item \(item.id): \(error)")
                        }
                    }
                }
                
                await group.waitForAll()
            }
        }
    }
}


extension Items.DataController {
    func enqueue(_ itemId: UUID) {
        data[itemId]?.enqueueIsCheckedUpdate()
    }
    
    func dequeue(_ itemId: UUID) {
        data[itemId]?.dequeueIsCheckedUpdate()
    }
    
    func shouldNotUpdate(_ itemId: UUID) -> Bool {
        data[itemId]?.enqueuedIsChecked == data[itemId]?.domainObject.isChecked
    }
}

func dp(_ msg: Any) {
    #if DEBUG
    print(msg)
    #endif
}


extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
