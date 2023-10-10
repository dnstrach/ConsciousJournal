//
//  QuoteViewController.swift
//  ConsciousJournal
//
//  Created by Dominique Strachan on 10/10/23.
//

import UIKit

class QuoteViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var quoteLabel: UILabel!
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchQuote()
    }
    
    //MARK: - Actions
    //dismiss modal
    @IBAction func xButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    //MARK: - Helper Methods
    //fetching quote with fetchQuote completion handler
    private func fetchQuote() {
        QuoteManager.shared.fetchQuote { result in
            switch result {
            case .success(let quote):
                //main thread so quote shows for view controller
                DispatchQueue.main.async {
                    self.quoteLabel.text = "\(quote.quote)\n\n- \(quote.author)"
                }
                QuoteManager().saveQuote(quote: quote)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

}
