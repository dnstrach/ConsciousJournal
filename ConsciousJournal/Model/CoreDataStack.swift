//
//  CoreDataStack.swift
//  ConsciousJournal
//
//  Created by Dominique Strachan on 10/10/23.
//

import CoreData

// CoreData stack can also be found in app delegate
// enum constants are public, static and final
// using utility enum instead of class or else remove static and create shared singleton whenever referencing variables or functions in CoreDataStack
enum CoreDataStack {
    //The persistent container that holds data objects.
    //This container is responsible for loading and managing the Core Data stack.
    static let journalContainer: NSPersistentContainer = {
        //container name matches entity name
        let journalContainer = NSPersistentContainer(name: "Journal")
        // Load persistent stores, matching the container name with the entity name.
        journalContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Error loading persistent stores \(error)")
            }
        }
        return journalContainer
    }()

    // This context tracks changes in data objects saved in the `journalContainer`.
    static var journalContext: NSManagedObjectContext { journalContainer.viewContext }

    //Saves changes made in the `journalContext` to the persistent store.
    static func saveJournalContext() {
        if journalContext.hasChanges {
            do {
                try journalContext.save()
            } catch {
                NSLog("Error saving context \(error)")
            }
        }
    }
}
