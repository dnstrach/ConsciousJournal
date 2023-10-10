//
//  Journal+Initializer.swift
//  ConsciousJournal
//
//  Created by Dominique Strachan on 10/10/23.
//

import CoreData

extension Journal {
    
    
    convenience init(context: NSManagedObjectContext = CoreDataStack.journalContext, journalEntryDate: Date, monthSection: Date, entryText: String) {
        self.init(context: context)
        self.journalEntryDate = journalEntryDate
        self.monthSection = monthSection
        self.entryText = entryText

    }
    
}
