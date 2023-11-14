//
//  Journal+Initializer.swift
//  ConsciousJournal
//
//  Created by Dominique Strachan on 10/10/23.
//

import CoreData

extension Journal {
    
    //This convenience initializer is providing a way to create an instance of the Journal class with specified properties, using a default managed object context (context) and setting various properties based on the passed parameters. It allows you to create a Journal object more conveniently with a subset of parameters, relying on default values for some properties.
    convenience init(context: NSManagedObjectContext = CoreDataStack.journalContext, journalEntryDate: Date, journalDateString: String, monthSection: Date, monthYearString: String, entryText: String) {
        self.init(context: context)
        self.journalEntryDate = journalEntryDate
        self.journalDateString = journalDateString
        self.monthSection = monthSection
        self.monthYearString = monthYearString
        self.entryText = entryText

    }
    
}
