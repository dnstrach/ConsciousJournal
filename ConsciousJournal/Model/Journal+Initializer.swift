//
//  Journal+Initializer.swift
//  ConsciousJournal
//
//  Created by Dominique Strachan on 10/10/23.
//

import CoreData

extension Journal {
    
    
    //make journalDateString
    
    convenience init(context: NSManagedObjectContext = CoreDataStack.journalContext, journalEntryDate: Date, journalDateString: String, monthSection: Date, monthYearString: String, entryText: String) {
        self.init(context: context)
        self.journalEntryDate = journalEntryDate
        self.journalDateString = journalDateString
        self.monthSection = monthSection
        self.monthYearString = monthYearString
        self.entryText = entryText

    }
    
}
