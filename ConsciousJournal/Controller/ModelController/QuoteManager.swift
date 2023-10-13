//
//  QuoteManager.swift
//  ConsciousJournal
//
//  Created by Dominique Strachan on 10/10/23.
//

import Foundation

class QuoteManager {
    
    // MARK: - Properties
   // shared instance
   static let shared = QuoteManager()
    
    let baseURL = URL(string: "https://zenquotes.io/")
    let apiComponent = "api"
    let todayComponent = "today"
    let userDefaultKey = "quote"
    
    // MARK: - Helper Methods
    // fetching quote from API call which will either result in quote data object (quote and author) or network error
    // Network errors are defined in resource file
    func fetchQuote(completion: @escaping(Result<Quote, NetworkError>) -> Void) {
        
        guard var url = baseURL else {
            completion(.failure(.baseURLError))
            return
        }
        
        // adding endpoints to baseURL
        url.append(path: apiComponent)
        url.append(path: todayComponent)
        
        // finalizing added components
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        guard let builtURL = components?.url else {
            return completion(.failure(.builtURLError))
        }
        
        // URL request for HTTP request and headers - not using header because API key not required
        let request = URLRequest(url: builtURL)
        
        // checking built URL
        //print("[QuoteController] - \(#function) built: \(builtURL.description)")
        
        // encoding/decoding data with URL request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.invalidData(error.localizedDescription)))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.statusCode))
                return
            }
            
            guard let data = data else { return completion(.failure(.noData))}
            
            do {
                // decoding JSON object held in array
                let quotes = try JSONDecoder().decode([Quote].self, from: data)
                
                // saving first quote object in [quotes] to be displayed
                guard let firstQuote = quotes.first else {
                    completion(.failure(.unableToDecode))
                    return
                }
                completion(.success(firstQuote))
            } catch {
                print(error)
                completion(.failure(.unableToDecode))
            }
            
        }.resume()
    }
    
    // saving encoded quote of the day into user defaults
    func saveQuote(quote: Quote) {
        do {
            let data = try JSONEncoder().encode(quote)
            
            UserDefaults.standard.set(data, forKey: userDefaultKey)
        } catch {
            print("Unable to Encode Quote (\(error)")
        }
    }
    
    // fetching decoded quote to be displayed from user defaults
    func fetchQuote() -> Quote? {
        if let data = UserDefaults.standard.data(forKey: userDefaultKey) {
            do {
                let quote = try JSONDecoder().decode(Quote.self, from: data)
                return quote
            } catch {
                print("Unable to Decode Quote (\(error)")
            }
        }
        
        // must return nil since Quote is optional
        return nil
    }
}
