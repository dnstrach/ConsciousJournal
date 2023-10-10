//
//  CoreDataStack.swift
//  ConsciousJournal
//
//  Created by Dominique Strachan on 10/10/23.
//

import CoreData

//CoreData stack can also be found in app delegate
//enum constants are public, static and final
//using enum instead of class or else remove static and create shared singleton whenever referencing variables or functions in CoreDataStack
enum CoreDataStack {
    //NSPersistent container holds data objects
    static let journalContainer: NSPersistentContainer = {
        //container name matches entity name
        let journalContainer = NSPersistentContainer(name: "Journal")
        journalContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Error loading persistent stores \(error)")
            }
        }
        return journalContainer
    }()

    //context tracks changes in data objects saved in container
    static var journalContext: NSManagedObjectContext { journalContainer.viewContext }

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
