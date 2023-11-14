//
//  JournalEntryViewController.swift
//  ConsciousJournal
//
//  Created by Dominique Strachan on 10/10/23.
//

import UIKit

class JournalEntryViewController: UIViewController {
    
    //MARK: - Properties
    var journalEntries: Journal?
    let seenWarningModalKey = "seenWarningModal"
    // used for dismissing keyboard
    var tapGesture: UITapGestureRecognizer!
    // Original content inset and offset for adjusting the UITextView when the keyboard appears
    var originalContentInset: UIEdgeInsets!
    var originalContentOffset: CGPoint!

    //computed property to track wether or not the user has seen warning alert by saving bool value into user defaults
    var userHasSeenModal: Bool {
        set {
            UserDefaults.standard.set(true, forKey: seenWarningModalKey)
        } get {
            UserDefaults.standard.bool(forKey: seenWarningModalKey)
        }
    }
    
    //MARK: - Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var entryTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        entryTextView.delegate = self
        entryTextView.layer.cornerRadius = 20
        
        // If there is an existing journal entry, populate the view with its data
        if let journalEntry = journalEntries,
           let journalEntryDate = journalEntry.journalEntryDate {
            
            datePicker.date = journalEntryDate
            entryTextView.text = journalEntry.entryText
        }
        
        // Hide the placeholder label if text is not empty
        if !entryTextView.text.isEmpty {
            placeholderLabel.isHidden = true
        }else if entryTextView.text.isEmpty {
            placeholderLabel.text = "Gratitude \nThoughts \nAffirmations"
        }
        
        presentAlert()
        
        // Set up a tap gesture recognizer to dismiss the keyboard
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        // Store the original content inset and offset
        originalContentInset = entryTextView.contentInset
        originalContentOffset = entryTextView.contentOffset
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let entryText = entryTextView.text else { return }
        
        let journalEntryDate = datePicker.date
        
        let monthSection = datePicker.date
        
        let journalDateString = dateToString(date: journalEntryDate)
        
        let monthYearString = dateToMonthYearString(date: journalEntryDate)
        
        if let journalEntry = journalEntries {
            JournalManager.shared.updateJournalEntry(journalEntry: journalEntry, journalEntryDate: journalEntryDate, journalDateString: journalDateString, monthSection: monthSection, entryText: entryText, monthYearString: monthYearString)
        } else {
            JournalManager.shared.createJournalEntry(journalEntryDate: journalEntryDate, journalDateString: journalDateString, monthSection: monthSection, monthYearString: monthYearString, entryText: entryText)
        }
        
        print(journalEntryDate)
        print(journalDateString)
        print(monthSection)
        
        //dismiss nav controller after tapping save
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    //MARK: - Helper Methods
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Dismiss the keyboard
        view.endEditing(true)
    }
    
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        let shortDateString = dateFormatter.string(from: date)
        
        return shortDateString
    }
    
    func dateToMonthYearString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    func presentAlert() {
        
        //do not present alert...return out of function
        if userHasSeenModal {
            return
        }
        
        let alert = UIAlertController(title: "Warning", message: "Once app is deleted, journal entries will not be saved", preferredStyle: .actionSheet)
        
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        
        alert.addAction(okayAction)
        
        //once alert is presented set userSeenModal to true so that alert will not be shown again
        present(alert, animated: true) {
            self.userHasSeenModal = true
        }
        
    }
    
    deinit {
        // Remove the tap gesture recognizer when the view is deinitialized
        view.removeGestureRecognizer(tapGesture)
    }
    
}

extension JournalEntryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // Hide the placeholder label based on text content
        let placeholderLabel = textView.subviews.first { $0 is UILabel } as? UILabel
        placeholderLabel?.isHidden = !textView.text.isEmpty
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        placeholderLabel.isHidden = true
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
    
    func subscribeToKeyboardNotifications() {
          NotificationCenter.default.addObserver(self,
                                                 selector: #selector(keyboardWillShow(_:)),
                                                 name: UIResponder.keyboardWillShowNotification,
                                                 object: nil)
          NotificationCenter.default.addObserver(self,
                                                 selector: #selector(keyboardWillHide(_:)),
                                                 name: UIResponder.keyboardWillHideNotification,
                                                 object: nil)
      }

      func unsubscribeFromKeyboardNotifications() {
          NotificationCenter.default.removeObserver(self)
      }

      @objc func keyboardWillShow(_ notification: Notification) {
          // Adjust the content inset to make room for the keyboard when it appears
          if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
              // Adjust the content inset to make room for the keyboard
              entryTextView.contentInset.bottom = keyboardSize.height
              entryTextView.verticalScrollIndicatorInsets.bottom = keyboardSize.height
          }
      }

      @objc func keyboardWillHide(_ notification: Notification) {
          // Restore the original content inset and offset when the keyboard is hidden
          entryTextView.contentInset = originalContentInset
          entryTextView.verticalScrollIndicatorInsets = originalContentInset
          entryTextView.contentOffset = originalContentOffset
      }
}
