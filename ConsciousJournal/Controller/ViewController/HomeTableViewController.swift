//
//  HomeTableViewController.swift
//  ConsciousJournal
//
//  Created by Dominique Strachan on 10/10/23.
//

import UIKit
import CoreData

class HomeTableViewController: UITableViewController {
    // MARK: - Properties
    var fetchedResultsController: NSFetchedResultsController<Journal>!
    let viewContext = CoreDataStack.journalContext
    
    // MARK: - Outlets
    @IBOutlet var journalTableView: UITableView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSavedData()
        navBarSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadSavedData()
        
        // need to reload table each time home view appears or else added entries will only show when re-running the app
        journalTableView.reloadData()
        
    }
    
    //MARK: - Helpers
    func loadSavedData() {
        if fetchedResultsController == nil {
            //let request = NSFetchRequest<Journal>(entityName: "Journal")
            let request = JournalManager.shared.journalFetchRequest
            //sort both entryDate and monthSection
            let sectionSort = NSSortDescriptor(key: "journalEntryDate", ascending: false)
            let rowSort = NSSortDescriptor(key: "monthSection", ascending: false)
            request.sortDescriptors = [sectionSort, rowSort]
            request.fetchBatchSize = 20
            
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: "monthSection", cacheName: nil)
            //        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: "journalEntryDate", cacheName: nil)
            
            
            fetchedResultsController.delegate = self
        }
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
        
        tableView.reloadData()
    }
    
    func navBarSetup() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Kohinoor Bangla", size: 25)!]
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset > 1 { // Or choose any desired offset
            self.navigationController?.navigationBar.barTintColor = UIColor(named: "DarkGrayPurple")
        } else if offset == 0 {
            self.navigationController?.navigationBar.barTintColor = UIColor(named: "GrayPurple")
        }
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(named: "Header")
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(named: "Default")
        header.textLabel?.font =  UIFont(name: "Kohinoor Bangla", size: 18)
        header.frame.size.width = 600
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sections = self.fetchedResultsController?.sections else {
            return nil
        }
        
        let sectionInfo = sections[section]
        
        if let date = sectionDateFromString(dateString: sectionInfo.name) {
            let monthYearString = convertToMonthYearFormat(date: date)
            return monthYearString
        } else {
            return ""
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = self.fetchedResultsController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "journalCell", for: indexPath)
        
        // NSFETCHRESULTSCONTROLLER
        let journalEntry = fetchedResultsController.object(at: indexPath)
        
        var newContent = cell.defaultContentConfiguration()
        
        newContent.text = DateFormatter.journalEntryDate.string(from: journalEntry.journalEntryDate ?? Date())
        newContent.textProperties.font = UIFont(name: "Avenir Next Regular", size: 20)!
        
        cell.contentConfiguration = newContent
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { [weak self] _, _, complete in
            
            let journalEntry = self!.fetchedResultsController.object(at: indexPath)
            JournalManager.shared.deleteJournalEntry(journalEntry: journalEntry)
            
            complete(true)
        }
        
        deleteAction.backgroundColor = UIColor(named: "DarkGrayPurple")
        
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toJournalEntryDetails",
           let indexPath = journalTableView.indexPathForSelectedRow,
           let destination = segue.destination as? JournalEntryViewController {
            
            let journalEntry = fetchedResultsController.object(at: indexPath)
            
            destination.journalEntries = journalEntry
        }
    }
}

extension HomeTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        @unknown default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        @unknown default:
            break
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
    }
}

extension HomeTableViewController {
    func sectionDateFromString(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" // Replace with your date format
        return dateFormatter.date(from: dateString)
    }
    
    func convertToMonthYearFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
}
