//
//  DateFormatter.swift
//  ConsciousJournal
//
//  Created by Dominique Strachan on 10/10/23.
//

import Foundation

//formats date --> month/day/year
//used to display short style in home tableview cells
extension DateFormatter {
    static let journalEntryDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
        
    }()
    
    static let journalEntryDateDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
}
