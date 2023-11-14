//
//  JournalManager.swift
//  ConsciousJournal
//
//  Created by Dominique Strachan on 10/10/23.
//

import CoreData

class JournalManager {
    
    // MARK: - Properties
    static let shared = JournalManager()
    
    // no longer need source of truth with NSFetchResultsController
    // Source of Truth
    //    var journalEntries: [Journal] = []
    
    // Fetch request of type Journal from CoreData with computed property which returns all Journal entries saved in Journal entity
    // Predicate is not necessary because fetching all journal entries in database
    var journalFetchRequest: NSFetchRequest<Journal> = {
        let request = NSFetchRequest<Journal>(entityName: "Journal")
        return request
    }()
    
    
    //MARK: - CRUD
    // create
    func createJournalEntry(journalEntryDate: Date, journalDateString: String, monthSection: Date, monthYearString: String, entryText: String) {
        
        // converting month section to be first day of month plus month and year so that journal entry dates will be sorted by month/year
        guard let monthSection = monthAndYearConversion(from: journalEntryDate) else { return }
        
        // used to search journal entries by short date style
        guard let journalDateString = dateToString(date: journalEntryDate) else { return }
        
        // used to search journal entries by month year section
        guard let monthYearString = dateToMonthYearString(date: journalEntryDate) else { return }
        
        let journalEntry = Journal(journalEntryDate: journalEntryDate, journalDateString: journalDateString, monthSection: monthSection, monthYearString: monthYearString, entryText: entryText)
        
        //saving created entry to CoreData
        CoreDataStack.saveJournalContext()
        
    }
    
    func updateJournalEntry(journalEntry: Journal, journalEntryDate: Date, journalDateString: String, monthSection: Date, entryText: String, monthYearString: String) {
        journalEntry.journalEntryDate = journalEntryDate
        journalEntry.journalDateString = dateToString(date: journalEntryDate)
        journalEntry.monthSection = monthAndYearConversion(from: journalEntryDate)
        journalEntry.entryText = entryText
        journalEntry.monthYearString = dateToMonthYearString(date: journalEntryDate)
        
        // saving updated entry to CoreData
        CoreDataStack.saveJournalContext()
    }
    
    func deleteJournalEntry(journalEntry: Journal) {
        
        //deleting journal entry built in delete function with CoreData
        CoreDataStack.journalContext.delete(journalEntry)
        //saving deletion to CoreData
        CoreDataStack.saveJournalContext()
    }
    
}

extension JournalManager {
    
    //Converts a given date to the first day of its month and year.
    //dates can now be grouped by month and year for sections
    func monthAndYearConversion(from date: Date) -> Date? {
        // Get the calendar and components
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        
        var firstDayComponents = DateComponents()
        firstDayComponents.year = components.year
        firstDayComponents.month = components.month

        return calendar.date(from: firstDayComponents)
    }
    
    //used to search journal entry as short date style
    func dateToString(date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let shortDateString = dateFormatter.string(from: date)
        
        return shortDateString
    }
    
    // used to search journal entry by month and year
    func dateToMonthYearString(date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
}
