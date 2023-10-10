//
//  DateFormatter.swift
//  ConsciousJournal
//
//  Created by Dominique Strachan on 10/10/23.
//

import Foundation

//formats date --> month/date/year
extension DateFormatter {
    static let journalEntryDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
        
    }()
}
