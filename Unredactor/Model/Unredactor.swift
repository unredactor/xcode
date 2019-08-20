//
//  Unredactor.swift
//  Unredactor
//
//  Created by tyler on 7/17/19.
//  Copyright © 2019 tyler. All rights reserved.
//

import Foundation
import UIKit
import JavaScriptCore

// I'm going to make this a singleton because there should only be one unredactor and it doesn't carry info between things, it only performs functions
class Unredactor {
    static var maskToken: String = "unk"
    
    func unredact(_ redactedText: ClassifiedText, completion: @escaping (ClassifiedText) -> Void) {
        // Implement by accessing the website API
        
        // Get array of words that are unredacted back:
        var unredactedWords: [String] = [] // Placeholder for now
        
        // Create a copy of redactedText
        let unredactedText: ClassifiedText = redactedText.copy() as! ClassifiedText
        
        let redactedWords = unredactedText.words.filter { $0.redactionState == .redacted }
        
        // Placeholder definition of unredactedWords - get from API
        //unredactedWords = Array(repeating: "prediction", count: redactedWords.count)// TODO: Replace with accessing the API and stuff]
        
        print("unredactor.unredact() called")
        
        getUnredactedWords(fromText: unredactedText.rawText) { (words) in
            print("unredactoed words something or another")
            
            unredactedWords = words
            
            // Unredact all the redacted words
            for (index, redactedWord) in redactedWords.enumerated() {
                redactedWord.lastRedactionState = redactedWord.redactionState
                redactedWord.redactionState = .unredacted
                
                let unredactedWord = unredactedWords[safeIndex: UInt(index)] ?? "Not enough unredacted words were returned from getUnredactedWords()"
                
                redactedWord.unredactorPrediction = unredactedWord
            }
            print("finished unredacting()")
            
            completion(unredactedText)
        }
    }
    
    func getUnredactedWords(fromText text: String, completion: @escaping (([String]) -> Void)) {
        // Lesson 5.5 in App Development with Swift
        let baseURL = URL(string: "https://unredactor.com/api?text=hello")!
        
        //let query: [String: String] = ["text": text]
        
        //let url = baseURL.appendingPathComponent("/api").withQueries(query)!
        
        print("Getting unredacted words")
        
        let task = URLSession.shared.dataTask(with: baseURL) { (data, response, error) in
            print("donig something with the task")
            let jsonDecoder = JSONDecoder()
            
            if let response = response {
                print("RESPONSE: \(response)")
            }
            
            if let error = error {
                print("ERROR: \(error)")
            }
            
            if let data = data {
                if let unredactorInfo = try? jsonDecoder.decode(UnredactorInfo.self, from:data) {
                
                    completion(unredactorInfo.unredacted_words)
                    print(String(data: data, encoding: .utf8)!)
                } else {
                    completion(["getUnredactedWords() failed; couldn't properly parse JSON response."])
                }
            } else {
                print("didn't work i guess lmao gotem")
                completion(["getUnredactedWords() failed; couldn't get JSON response from server"])
            }
        }
        
        
        
        task.resume()
    }
    
    // MARK: - Unredactor Info
    struct UnredactorInfo: Codable {
        var text: String // original text
        var unredacted_text: String // unredacted text
        var unredacted_words: [String] // unredacted words
        
        enum CodingKeys: String, CodingKey {
            case text// = "text"
            case unredacted_text// = "unredacted_text"
            case unredacted_words// = "words"
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.text = try valueContainer.decode(String.self, forKey: .text)
            self.unredacted_text = try valueContainer.decode(String.self, forKey: .unredacted_text)
            self.unredacted_words = try valueContainer.decode([String].self, forKey: .unredacted_words)
        }
    }
    
    // Find the beginning of each instance of a mask token in a given string and return those indices (like the string was a [char])
    private func findMaskTokens(inString string: String) -> [Int] {
        // Maybe implement this, but the unredactor API should do this for us, so it doesn't really matter
        
        return [0]
    }
}
