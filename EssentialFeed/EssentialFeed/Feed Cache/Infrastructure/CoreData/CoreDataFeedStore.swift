//
//  CoreDataStore.swift
//  EssentialFeed
//
//  Created by Ivo on 09/03/23.
//

import CoreData

public final class CoreDataFeedStore  {
    /* NOTE why to make the bundle static, commit message
     
     Load NSManagedObjectModel instance lazily and cache it to prevent multiple `NSEntityDescriptions` claiming the same `NSManagedObject` model subclasses (This problem just generates warnings but could lead to undefined behavior in the future).
     
     */
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    // NOTE
    // trade-off: by making the feedStore functions into separate file, had to make context public.
    // Solution 2 would be to use the perform function
    let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
    
    // I think capturing the context is so much cleaner.
    func performAsync(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
         let context = self.context
         var result: Result<R, Error>!
         context.performAndWait { result = action(context) }
         return try result.get()
     }
}
