//
//  CoreDataManager.swift
//  Notes
//
//  Created by Sami Youssef on 9/14/18.
//  Copyright © 2018 Sami Youssef. All rights reserved.
//

import CoreData

final class CoreDataManager {
    private let modelName: String
    private (set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Unable to find data model")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to load data model")
        }
        return managedObjectModel
    }()
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                           NSInferMappingModelAutomaticallyOption: true]
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: options)
        } catch {
            fatalError("Unable to add Persistent Stor")
        }
        return persistentStoreCoordinator
    }()

    init(modelName: String) {
        self.modelName = modelName
        setUpNotificationHandling()
    }

    private func setUpNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)),
                                       name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)),
                                       name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    @objc func saveChanges(_ notification: NSNotification) {
        saveChanges()
    }

    private func saveChanges() {
        guard managedObjectContext.hasChanges else { return }
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Unable to save managed object context")
            print("\(error) \n \(error.localizedDescription)")
        }
    }
}
