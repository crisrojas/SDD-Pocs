//
//  PersistenceController.swift
//  Persistency

//  Created by Cristian Felipe Patiño Rojas on 10/03/2023.

import CoreData

public final class PersistenceController {
    
    static let shared = PersistenceController()
    static var preview: PersistenceController = {.init(inMemory: true)}()
    
    static func get(inMemory: Bool) -> PersistenceController {
        if inMemory { return preview }
        else { return shared }
    }
    
    public func context() -> NSManagedObjectContext {container.viewContext}
    var container: NSPersistentCloudKitContainer
    
    public init(inMemory: Bool = false) {
         
        container = NSPersistentCloudKitContainer(name: "CoreDataModel", managedObjectModel: managedObjectModel)
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func destroy() {
        
        // Delete each existing persistent store
        let storeContainer = container.persistentStoreCoordinator
        for store in storeContainer.persistentStores {
            try? storeContainer.destroyPersistentStore(
                at: store.url!,
                ofType: store.type,
                options: nil
            )
        }
        
        // Re-create the persistent container
        container = NSPersistentCloudKitContainer(name: "Things")
        
        // Calling loadPersistentStores will re-create the
        container.loadPersistentStores {(_, _) in}
    }
}

fileprivate var managedObjectModel: NSManagedObjectModel = {
    let frameworkBundleIdentifier = "lat.cristian.Persistency"
    let customKitBundle = Bundle(identifier: frameworkBundleIdentifier)!
    let modelURL = customKitBundle.url(forResource: "CoreDataModel", withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
}()


public final class CoreDataManager {
    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func create_item(with id: UUID) async throws {
        try await context.perform { [context] in
            let item = Item(context: context)
            item.id = id
            item.date = Date()
            try context.save()
        }
    }
    
    func read(id: UUID) async throws -> Item? {
        try await context.get(id: id)
    }
    
    func read() async throws -> [Item] {
        try await context.get(request: Item.fetchRequest())
    }
    
    func delete(id: UUID) async throws {
        let _: Item? = try await context.delete(id: id)
    }
}

enum CoreDataError: Error {
    case entityNotFound
}

extension NSManagedObjectContext {
    func get<T>(request: NSFetchRequest<T>) async throws -> [T] {
        try await self.perform { [weak self] in
            try self?.fetch(request) ?? []
        }
    }
    
    
    func get<T: NSManagedObject>(id: UUID) async throws -> T? {
        try await self.perform { [weak self] in
            let request = NSFetchRequest<T>(entityName: T.className)
            request.predicate = NSPredicate(
                format: "id == %@",
                id as CVarArg
            )
            
            return try self?.fetch(request).first
        }
    }
    
    @discardableResult
    func delete<T: NSManagedObject>(id: UUID) async throws -> T? {
        try await self.perform { [weak self] in
            let request = NSFetchRequest<T>(entityName: T.className)
            request.predicate = NSPredicate(
                format: "id == %@",
                id as CVarArg
            )
            request.fetchLimit = 1
            
            guard let object = try self?.fetch(request).first else {
                throw CoreDataError.entityNotFound
            }
            
            self?.delete(object)
            return nil
        }
    }
}


extension NSObject {
    var className: String {
        String(describing: type(of: self))
    }
    
    class var className: String {
        String(describing: self)
    }
}
